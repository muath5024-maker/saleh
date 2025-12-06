# 🔧 تقرير تصحيح أسماء الأعمدة

## 📋 المشكلة
تم استخدام أسماء أعمدة غير موجودة في جدول `user_profiles`:
- ❌ `user_id` (لا يوجد في user_profiles)
- ❌ `full_name` (لا يوجد في user_profiles)

**الحقول الصحيحة في `user_profiles`:**
- ✅ `id` (PK, FK → auth.users.id)
- ✅ `role`
- ✅ `display_name`
- ✅ `phone`
- ✅ `avatar_url`
- ✅ `email`
- ✅ `created_at`
- ✅ `updated_at`

---

## ✅ التصحيحات المطبقة

### 1. Worker (`mbuy-worker/src/index.ts`)

#### أ) تصحيح استعلام `/secure/users/me`:
**قبل:**
```typescript
`${c.env.SUPABASE_URL}/rest/v1/users?id=eq.${userId}&select=*`
```

**بعد:**
```typescript
`${c.env.SUPABASE_URL}/rest/v1/user_profiles?id=eq.${userId}&select=*`
```

#### ب) تصحيح استعلام `/secure/users/:id`:
**قبل:**
```typescript
`${c.env.SUPABASE_URL}/rest/v1/users?id=eq.${targetUserId}&select=id,full_name,username,avatar_url,created_at`
```

**بعد:**
```typescript
`${c.env.SUPABASE_URL}/rest/v1/user_profiles?id=eq.${targetUserId}&select=id,display_name,email,avatar_url,created_at`
```

#### ج) تصحيح تحديث Profile (`/secure/users/me` PUT):
**قبل:**
```typescript
const allowedFields = ['full_name', 'username', 'avatar_url', 'phone', 'address'];
`${c.env.SUPABASE_URL}/rest/v1/users?id=eq.${userId}`
```

**بعد:**
```typescript
const allowedFields = ['display_name', 'avatar_url', 'phone'];
`${c.env.SUPABASE_URL}/rest/v1/user_profiles?id=eq.${userId}`
```

#### د) تصحيح استعلامات Reviews:
**قبل:**
```typescript
`${c.env.SUPABASE_URL}/rest/v1/reviews?product_id=eq.${productId}&select=*,users(id,full_name,avatar_url)&...`
`${c.env.SUPABASE_URL}/rest/v1/reviews?store_id=eq.${storeId}&select=*,users(id,full_name,avatar_url),products(id,name)&...`
```

**بعد:**
```typescript
`${c.env.SUPABASE_URL}/rest/v1/reviews?product_id=eq.${productId}&select=*,user_profiles!customer_id(id,display_name,avatar_url)&...`
`${c.env.SUPABASE_URL}/rest/v1/reviews?store_id=eq.${storeId}&select=*,user_profiles!customer_id(id,display_name,avatar_url),products(id,name)&...`
```

**ملاحظة:** جدول `reviews` يحتوي على `customer_id` الذي يشير إلى `user_profiles.id`، لذلك استخدمنا `user_profiles!customer_id` في join.

---

### 2. Edge Function (`product_create/index.ts`)

#### تحسين التحقق من ملكية Store:
**قبل:**
```typescript
// كان يستخدم profile verification منفصلة
const { data: profile } = await supabase
  .from('user_profiles')
  .select('id')
  .eq('id', user_id)
  .maybeSingle();
// ثم يتحقق من store.owner_id !== profile.id
```

**بعد:**
```typescript
// تحقق مباشر: stores.owner_id = user_profiles.id
const { data: store } = await supabase
  .from('stores')
  .select('id, owner_id, name')
  .eq('id', store_id)
  .eq('owner_id', user_id) // Direct comparison
  .maybeSingle();
```

**التحسين:**
- ✅ إزالة استعلام profile غير ضروري
- ✅ تحقق مباشر: `stores.owner_id = user_profiles.id` (حيث user_id هو user_profiles.id)
- ✅ توضيح في التعليقات: Schema: `auth.users.id == user_profiles.id == stores.owner_id`

---

## 🔍 السكيمة الصحيحة

### التسلسل الصحيح:
```
auth.users.id 
  ↓
user_profiles.id (PK, FK → auth.users.id)
  ↓
stores.owner_id (FK → user_profiles.id)
  ↓
products.store_id (FK → stores.id)
```

**لا يوجد حقل `user_id` في `user_profiles`!**

---

## 📊 الملفات المعدلة

1. ✅ **`mbuy-worker/src/index.ts`**
   - تصحيح 5 استعلامات
   - تغيير من `users` إلى `user_profiles`
   - تغيير من `full_name` إلى `display_name`

2. ✅ **`mbuy-backend/functions/product_create/index.ts`**
   - تحسين منطق التحقق من ملكية store
   - إزالة استعلام profile غير ضروري

3. ✅ **`mbuy-backend/supabase/functions/product_create/index.ts`**
   - نسخ التغييرات

---

## ✅ التحقق من التصحيحات

### جميع الاستعلامات الآن تستخدم:
- ✅ `user_profiles.id` بدلاً من `user_profiles.user_id`
- ✅ `user_profiles.display_name` بدلاً من `user_profiles.full_name`
- ✅ `user_profiles` بدلاً من `users` (الجدول الصحيح)

### العلاقات محفوظة:
- ✅ `auth.users.id == user_profiles.id`
- ✅ `user_profiles.id == stores.owner_id`
- ✅ `stores.id == products.store_id`

---

## 🧪 الخطوة التالية: الاختبار

بعد نشر التغييرات:
1. ✅ نشر Worker
2. ✅ نشر Edge Function
3. ✅ اختبار إضافة منتج جديد
4. ✅ التحقق من عدم ظهور خطأ `PROFILE_NOT_FOUND`

---

**تاريخ التصحيح:** 2025-01-06  
**الحالة:** ✅ جاهز للنشر والاختبار

