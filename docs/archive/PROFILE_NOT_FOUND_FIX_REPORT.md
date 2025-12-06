# 🔧 تقرير إصلاح خطأ "User profile not found"

## 📋 المشكلة الأصلية
**الخطأ:** `"خطأ في إضافة المنتج: User profile not [NOT_FOUND]: User profile not found"`

يحدث عند محاولة إضافة منتج جديد من تطبيق Flutter.

---

## 🔍 تحليل المشكلة

### التسلسل المطلوب:
```
JWT Token → userId (auth.users.id) 
         → user_profiles.id 
         → stores.owner_id 
         → products.store_id
```

### المشاكل المحتملة:
1. ❌ **عدم تطابق userId من JWT مع id في user_profiles**
2. ❌ **عدم وجود logging كافٍ لتتبع المشكلة**
3. ❌ **Edge Function يحاول جلب profile/store مرة أخرى بدلاً من الاعتماد على Worker**
4. ❌ **استخدام SUPABASE_SERVICE_ROLE_KEY في Worker بدلاً من ANON_KEY**

---

## ✅ الإصلاحات المطبقة

### 1. تحسين Worker - POST /secure/products

**الملف:** `mbuy-worker/src/index.ts`

#### التغييرات:

##### أ) إضافة Logging شامل:
```typescript
console.log('[MBUY] ========================================');
console.log('[MBUY] POST /secure/products - Request received');
console.log('[MBUY] JWT userId (from token):', userId);
console.log('[MBUY] JWT userEmail (from token):', userEmail);
console.log('[MBUY] Query: SELECT * FROM user_profiles WHERE id =', userId);
```

##### ب) تحسين استعلام user_profiles:
- ✅ استخدام `SUPABASE_ANON_KEY` بدلاً من `SERVICE_ROLE_KEY`
- ✅ إضافة `Prefer: return=representation` header
- ✅ فحص دقيق للنتيجة (Array check)
- ✅ تسجيل كامل البيانات المسترجعة

##### ج) التحقق من تطابق البيانات:
```typescript
// Verify that profile.id matches userId from JWT
if (profile.id !== userId) {
  return c.json({
    ok: false,
    code: 'PROFILE_ID_MISMATCH',
    message: 'Profile ID does not match user ID'
  }, 500);
}
```

##### د) تحسين استعلام stores:
- ✅ استخدام نفس المنطق المحسّن
- ✅ التحقق من تطابق `store.owner_id` مع `profile.id`

##### هـ) إرسال store_id إلى Edge Function:
```typescript
body: JSON.stringify({ 
  ...cleanBody, 
  user_id: userId, 
  store_id: store.id  // ✅ الآن نرسل store_id المحقق
})
```

---

### 2. تحسين Edge Function - product_create

**الملف:** `mbuy-backend/functions/product_create/index.ts`

#### التغييرات:

##### أ) تحديث Interface:
```typescript
interface ProductCreateRequest {
  user_id: string;
  store_id: string; // ✅ الآن مطلوب من Worker
  // ...
}
```

##### ب) تبسيط المنطق:
- ❌ **حذف:** منطق جلب profile/store من Edge Function
- ✅ **إضافة:** التحقق السريع من store_id (verification فقط)
- ✅ **الاعتماد:** على Worker الذي قام بالتحقق بالفعل

##### ج) Logging شامل:
```typescript
console.log('[product_create] ========================================');
console.log('[product_create] Edge Function product_create invoked');
console.log('[product_create] Worker provided store_id:', store_id);
console.log('[product_create] Worker provided user_id:', user_id);
```

##### د) تحقق من الملكية:
```typescript
// Verify that store.owner_id matches user_id
if (store.owner_id !== profile.id) {
  return new Response(
    JSON.stringify({ 
      ok: false,
      code: 'STORE_OWNERSHIP_MISMATCH',
      error: 'Store does not belong to this user'
    }),
    { status: 403 }
  );
}
```

---

## 📊 التسلسل الجديد بعد الإصلاح

### في Worker:
1. ✅ استخراج `userId` من JWT (payload.sub)
2. ✅ جلب profile: `SELECT * FROM user_profiles WHERE id = userId`
3. ✅ التحقق من وجود profile
4. ✅ جلب store: `SELECT * FROM stores WHERE owner_id = profile.id`
5. ✅ التحقق من وجود store
6. ✅ إرسال `user_id` و `store_id` إلى Edge Function

### في Edge Function:
1. ✅ استقبال `user_id` و `store_id` من Worker
2. ✅ التحقق السريع من store (verification فقط)
3. ✅ التحقق من الملكية (store.owner_id === user_id)
4. ✅ إنشاء المنتج باستخدام `store_id` المحقق

---

## 🧪 ما يجب البحث عنه في Logs

### Worker Logs يجب أن تحتوي على:
```
[MBUY] ========================================
[MBUY] POST /secure/products - Request received
[MBUY] JWT userId (from token): <UUID>
[MBUY] Query: SELECT * FROM user_profiles WHERE id = <UUID>
[MBUY] Profile API returned: { count: 1, data: [...] }
[MBUY] ✅ Profile found successfully!
[MBUY] Profile data: { id: ..., role: ..., ... }
[MBUY] Query: SELECT * FROM stores WHERE owner_id = <UUID>
[MBUY] ✅ Store found successfully!
[MBUY] Store data: { id: ..., owner_id: ..., ... }
[MBUY] Step 3: Calling Edge Function
```

### Edge Function Logs يجب أن تحتوي على:
```
[product_create] ========================================
[product_create] Edge Function product_create invoked
[product_create] Worker provided store_id: <UUID>
[product_create] Worker provided user_id: <UUID>
[product_create] ✅ Store verification passed
[product_create] Step 2: Creating product
[product_create] Product created successfully: <product_id>
```

---

## ⚠️ رسائل الخطأ المحسّنة

### إذا لم يوجد profile:
```json
{
  "ok": false,
  "code": "PROFILE_NOT_FOUND",
  "message": "User profile not found for this account",
  "error": "No profile found in user_profiles table for userId: <UUID>",
  "details": {
    "searchedUserId": "<UUID>",
    "userEmail": "user@example.com"
  }
}
```

### إذا لم يوجد store:
```json
{
  "ok": false,
  "code": "STORE_NOT_FOUND",
  "message": "No store found for this merchant account",
  "error": "No store found in stores table for owner_id: <UUID>",
  "details": {
    "userId": "<UUID>",
    "profileId": "<UUID>",
    "profileRole": "merchant"
  }
}
```

---

## ✅ الملفات المعدلة

1. **`mbuy-worker/src/index.ts`**
   - تحسين منطق جلب profile/store
   - إضافة logging شامل
   - إصلاح استخدام ANON_KEY
   - إرسال store_id إلى Edge Function

2. **`mbuy-backend/functions/product_create/index.ts`**
   - تحديث interface لاستقبال store_id
   - تبسيط المنطق (الاعتماد على Worker)
   - إضافة verification فقط
   - تحسين logging

3. **`mbuy-backend/supabase/functions/product_create/index.ts`**
   - نسخ التغييرات من functions/product_create

---

## 🚀 الخطوة التالية

### 1. نشر Worker:
```bash
cd mbuy-worker
wrangler deploy
```

### 2. نشر Edge Function:
```bash
cd mbuy-backend
supabase functions deploy product_create --project-ref sirqidofuvphqcxqchyc
```

### 3. الاختبار:
1. افتح تطبيق Flutter
2. سجل دخول كتاجر
3. أضف منتج جديد
4. تحقق من Logs في:
   - Cloudflare Dashboard → Workers → Logs
   - Supabase Dashboard → Functions → product_create → Logs

---

## 📊 النتيجة المتوقعة

### ✅ يجب أن يحدث:
- ✅ لا يظهر خطأ `PROFILE_NOT_FOUND`
- ✅ لا يظهر خطأ `STORE_NOT_FOUND` (إلا إذا لم يكن للمستخدم متجر فعلاً)
- ✅ يتم إنشاء المنتج بنجاح
- ✅ تظهر Logs واضحة في Worker و Edge Function

### ❌ لا يجب أن يحدث:
- ❌ خطأ `User profile not found`
- ❌ خطأ `NOT_FOUND` غير واضح
- ❌ أي خطأ متعلق بعدم تطابق البيانات

---

## 🔍 كيفية التحقق من المشكلة إذا استمرت

### 1. تحقق من Logs:
```
[MBUY] JWT userId (from token): <UUID_من_JWT>
[MBUY] Profile data: { id: <UUID_من_DB> }
```

**إذا كان UUID_من_JWT ≠ UUID_من_DB:**
- المشكلة: JWT token لا يطابق id في user_profiles
- الحل: تحقق من عملية التسجيل/إنشاء profile

### 2. تحقق من قاعدة البيانات:
```sql
-- تحقق من وجود profile
SELECT id, role, email FROM user_profiles WHERE id = '<UUID_من_JWT>';

-- تحقق من وجود store
SELECT id, owner_id, name FROM stores WHERE owner_id = '<UUID_من_JWT>';
```

---

**تاريخ الإصلاح:** 2025-01-06  
**المطور:** AI Assistant  
**الحالة:** ✅ جاهز للاختبار

