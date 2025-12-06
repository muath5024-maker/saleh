# 🔧 تقرير إصلاح نهائي: إضافة المنتجات (FORBIDDEN Error)

## 📋 ملخص المشكلة

### المشكلة:
عند محاولة التاجر إضافة منتج من شاشة منتجات التاجر في التطبيق، يظهر الخطأ:
- **"[FORBIDDEN] ليس لديك صلاحية الوصول"**
- رسالة بالعربي: "خطأ في إضافة المنتج"

### السبب الجذري:
1. **عدم تطابق في سلسلة العلاقات:**
   - عدم التأكد من وجود `user_profiles` للمستخدم
   - عدم التحقق من `role = 'merchant'`
   - عدم التحقق من وجود متجر نشط (`is_active = true`)
   - `store_id` كان يُرسل من Flutter (أو لا يتم جلبها بشكل صحيح)

2. **RLS Policies:**
   - السياسات الموجودة قد لا تكون كافية للتجار
   - Edge Function تستخدم `SERVICE_ROLE_KEY` (تتجاوز RLS) لكن المنطق يجب أن يكون صحيحاً

3. **معالجة الأخطاء:**
   - رسائل خطأ غير واضحة للمستخدم
   - لا يوجد تمييز بين أنواع الأخطاء المختلفة

---

## 🔗 المنطق المطلوب والحل المنفذ

### التسلسل الصحيح:
```
auth.users.id (jwt.sub)
    ↓
user_profiles.id = auth.users.id
    ↓
stores.owner_id = user_profiles.id AND is_active = true
    ↓
products.store_id = stores.id
```

### الحل المنفذ:

#### 1. Edge Function (`product_create/index.ts`)
- ✅ استخراج `userId` من `jwt.sub`
- ✅ جلب `user_profiles` والتحقق من وجودها
- ✅ التحقق من `role = 'merchant'`
- ✅ جلب متجر نشط (`is_active = true`)
- ✅ استخدام `store.id` من الاستعلام (وليس من Body)
- ✅ تجاهل تماماً أي `store_id` من العميل
- ✅ Error codes موحدة:
  - `NO_USER_PROFILE`
  - `NOT_MERCHANT`
  - `NO_ACTIVE_STORE`
  - `INSERT_FAILED`
- ✅ Logging شامل لكل خطوة

#### 2. RLS Policies (Migration جديدة)
- ✅ `user_profiles`: SELECT للمالك فقط
- ✅ `stores`: SELECT/INSERT/UPDATE/DELETE للمالك
- ✅ `products`: INSERT/UPDATE/DELETE/SELECT للمالك فقط
- ✅ الحفاظ على سياسات Public للقراءة العامة

#### 3. Worker (`mbuy-worker/src/index.ts`)
- ✅ تنظيف Body: حذف `id, store_id, user_id, owner_id, created_at, updated_at`
- ✅ تمرير JWT كما هو إلى Edge Function
- ✅ الحفاظ على `error_code` من Edge Function

#### 4. Flutter (`merchant_products_screen.dart`)
- ✅ معالجة محسّنة للأخطاء
- ✅ رسائل واضحة بالعربي لكل نوع خطأ:
  - `NO_USER_PROFILE`: "لا يوجد ملف مستخدم لهذا الحساب"
  - `NOT_MERCHANT`: "هذا الحساب غير مسجل كتاجر"
  - `NO_ACTIVE_STORE`: "لا يوجد متجر نشط لهذا الحساب"
  - `INSERT_FAILED`: "فشل إضافة المنتج في قاعدة البيانات"
  - `FORBIDDEN`: "ليس لديك صلاحية لإضافة منتجات"

---

## 📁 الملفات المعدلة

### 1. Edge Function
**الملف:** `mbuy-backend/functions/product_create/index.ts`

**التغييرات:**
- تحسين استخراج `userId` من JWT
- تحسين جلب `user_profiles` (استخدام `maybeSingle`)
- Error codes موحدة ومتسقة
- Logging شامل لكل خطوة
- تجاهل تماماً `store_id` من Body
- استخدام `store.id` من الاستعلام فقط

**السطور الرئيسية:**
- السطر 97: `console.log("product_create: jwt.sub =", userId);`
- السطر 183-194: معالجة `NO_USER_PROFILE`
- السطر 229-240: معالجة `NOT_MERCHANT`
- السطر 266-286: معالجة `NO_ACTIVE_STORE`
- السطر 322-347: بناء `insertPayload` بدون `store_id` من Body
- السطر 351-375: معالجة `INSERT_FAILED`

---

### 2. Migration جديدة لـ RLS
**الملف:** `mbuy-backend/migrations/20250106000007_finalize_product_create_rls.sql`

**التغييرات:**
- إضافة/تحديث سياسات `user_profiles` للقراءة
- إضافة/تحديث سياسات `stores` للتجار
- إضافة/تحديث سياسات `products` للتجار
- الحفاظ على سياسات Public للقراءة العامة
- التحقق من عدد السياسات في النهاية

**السياسات المضافة:**
```sql
-- user_profiles
- "Profiles are viewable by owner" (SELECT)

-- stores
- "Store owners can view own stores" (SELECT)
- "Users can insert own stores" (INSERT)
- "Store owners can update own stores" (UPDATE)
- "Store owners can delete own stores" (DELETE)

-- products
- "Store owners can insert products" (INSERT)
- "Store owners can update products" (UPDATE)
- "Store owners can delete products" (DELETE)
- "Store owners can view own products" (SELECT)
```

---

### 3. Worker
**الملف:** `mbuy-worker/src/index.ts`

**التغييرات:**
- التأكد من تنظيف Body قبل الإرسال (موجود بالفعل ✅)
- الحفاظ على `error_code` من Edge Function في الرد
- تمرير JWT بشكل صحيح

**السطور الرئيسية:**
- السطر 1662-1671: تنظيف Body (حذف `id, store_id, user_id, owner_id`)
- السطر 1707: تمرير JWT إلى Edge Function
- السطر 1724-1731: الحفاظ على `error_code` من Edge Function

---

### 4. Flutter
**الملف:** `saleh/lib/features/merchant/presentation/screens/merchant_products_screen.dart`

**التغييرات:**
- معالجة محسّنة للأخطاء مع `error_code`
- رسائل واضحة بالعربي لكل نوع خطأ
- Logging أفضل للأخطاء

**السطور الرئيسية:**
- السطر 437-471: معالجة الأخطاء مع `error_code` ورسائل واضحة

---

## 🧪 الاختبارات المطلوبة

### 1. التحقق من البيانات قبل الاختبار

#### أ) التحقق من `user_profiles`:
```sql
-- في Supabase SQL Editor:
SELECT id, role, display_name, email 
FROM user_profiles 
WHERE id = '<YOUR_USER_ID>';
```
- يجب أن يكون `role = 'merchant'`

#### ب) التحقق من `stores`:
```sql
SELECT id, owner_id, name, status, is_active 
FROM stores 
WHERE owner_id = '<YOUR_USER_ID>';
```
- يجب أن يكون `is_active = true`
- يجب أن يكون `status = 'active'`

#### ج) إذا لم توجد بيانات:
- لا تعدّل البيانات يدويًا
- استخدم Migration أو Edge Functions لإنشاء البيانات

---

### 2. اختبار إضافة المنتج

#### الخطوات:
1. سجّل الدخول كمستخدم تاجر (`role = 'merchant'`)
2. افتح شاشة منتجات التاجر
3. اضغط "إضافة منتج"
4. املأ البيانات:
   - الاسم: "منتج تجريبي"
   - الوصف: "وصف المنتج"
   - السعر: 100
   - الكمية: 10
   - (اختياري) صورة
5. اضغط "حفظ"

#### النتيجة المتوقعة:
- ✅ لا يظهر خطأ FORBIDDEN
- ✅ يظهر رسالة نجاح: "تم إضافة المنتج بنجاح!"
- ✅ المنتج يظهر في القائمة
- ✅ المنتج موجود في Supabase مع `store_id` الصحيح

---

### 3. اختبار حالات الخطأ

#### أ) مستخدم بدون `user_profile`:
- **النتيجة المتوقعة:** 
  - `error_code: "NO_USER_PROFILE"`
  - رسالة: "لا يوجد ملف مستخدم لهذا الحساب. يرجى التحقق من إعدادات الحساب."

#### ب) مستخدم بدون متجر نشط:
- **النتيجة المتوقعة:**
  - `error_code: "NO_ACTIVE_STORE"`
  - رسالة: "لا يوجد متجر نشط لهذا الحساب. يرجى إنشاء متجر من إعداد المتجر أولاً."

#### ج) مستخدم ليس تاجر:
- **النتيجة المتوقعة:**
  - `error_code: "NOT_MERCHANT"`
  - رسالة: "هذا الحساب غير مسجل كتاجر. يرجى التحقق من صلاحيات الحساب."

---

### 4. التحقق من Logs

#### Edge Function Logs:
في Supabase Dashboard → Edge Functions → product_create → Logs:
```
[product_create] product_create: jwt.sub = <userId>
[product_create] ✅ Profile found: { id, role, display_name }
[product_create] ✅ User is a merchant
[product_create] ✅ Store found: { id, owner_id, name, is_active }
[product_create] ✅ Product created successfully!
```

#### Worker Logs:
في Cloudflare Dashboard → Workers → misty-mode-b68b → Logs:
```
[MBUY] POST /secure/products - Request received
[MBUY] JWT userId (jwt.sub): <userId>
[MBUY] Clean body (removed id/store_id/user_id): { name, price }
[MBUY] Edge Function response status: 200
```

---

## 🔍 التحقق من النتيجة

### في Supabase:
```sql
-- التحقق من المنتج الجديد
SELECT 
  p.id,
  p.name,
  p.price,
  p.stock,
  p.store_id,
  s.name as store_name,
  s.owner_id,
  up.id as owner_profile_id,
  up.role
FROM products p
JOIN stores s ON p.store_id = s.id
JOIN user_profiles up ON s.owner_id = up.id
ORDER BY p.created_at DESC
LIMIT 5;
```

**النتيجة المتوقعة:**
- ✅ `store_id` = `stores.id`
- ✅ `stores.owner_id` = `user_profiles.id`
- ✅ `user_profiles.role` = `'merchant'`
- ✅ `stores.is_active` = `true`

---

## 📝 سكربت SQL لإنشاء بيانات الاختبار (لا تنفّذ في Production)

إذا لم تكن البيانات موجودة، يمكن استخدام هذا السكربت **فقط للاختبار**:

```sql
-- ⚠️ تحذير: هذا السكربت للاختبار فقط
-- ⚠️ استبدل <YOUR_USER_ID> بـ UUID الحقيقي

-- 1. إنشاء user_profile (إذا لم يكن موجوداً)
INSERT INTO public.user_profiles (
  id,
  role,
  display_name,
  email,
  created_at,
  updated_at
)
VALUES (
  '<YOUR_USER_ID>'::UUID,
  'merchant',
  'تاجر تجريبي',
  'merchant@example.com',
  NOW(),
  NOW()
)
ON CONFLICT (id) DO UPDATE
SET role = 'merchant',
    updated_at = NOW();

-- 2. إنشاء متجر (إذا لم يكن موجوداً)
INSERT INTO public.stores (
  owner_id,
  name,
  description,
  city,
  status,
  is_active,
  visibility,
  created_at,
  updated_at
)
VALUES (
  '<YOUR_USER_ID>'::UUID,
  'متجر تجريبي',
  'وصف المتجر التجريبي',
  'الرياض',
  'active',
  true,
  'public',
  NOW(),
  NOW()
)
ON CONFLICT DO NOTHING;
```

---

## 🎯 كيفية الاختبار بعد أي تعديل مستقبلي

### 1. التحقق من Edge Function:
- تأكد من وجود `console.log("product_create: jwt.sub =", userId);`
- تحقق من Logs في Supabase Dashboard

### 2. التحقق من Worker:
- تأكد من تنظيف Body (حذف `store_id`)
- تحقق من تمرير JWT إلى Edge Function

### 3. التحقق من Flutter:
- تأكد من عدم إرسال `store_id` من Flutter
- تحقق من معالجة الأخطاء مع `error_code`

### 4. التحقق من RLS:
```sql
-- في Supabase SQL Editor:
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('user_profiles', 'stores', 'products')
ORDER BY tablename, policyname;
```

---

## ✅ Checklist بعد الإصلاح

- [ ] ✅ Edge Function يستخرج `userId` من `jwt.sub`
- [ ] ✅ Edge Function يتحقق من `user_profiles` و `role = 'merchant'`
- [ ] ✅ Edge Function يتحقق من وجود متجر نشط
- [ ] ✅ Edge Function لا يستخدم `store_id` من Body
- [ ] ✅ RLS Policies موجودة ومفعّلة
- [ ] ✅ Worker ينظف Body قبل الإرسال
- [ ] ✅ Worker يمرر JWT بشكل صحيح
- [ ] ✅ Flutter لا يرسل `store_id`
- [ ] ✅ Flutter يعالج الأخطاء بشكل صحيح
- [ ] ✅ اختبار إضافة منتج ناجح
- [ ] ✅ اختبار حالات الخطأ تعمل بشكل صحيح

---

## 📊 ملخص التغييرات

| المكون | الملف | التغييرات |
|--------|-------|-----------|
| Edge Function | `product_create/index.ts` | تحسين المنطق + Error codes + Logging |
| RLS Policies | `20250106000007_finalize_product_create_rls.sql` | إضافة/تحديث السياسات |
| Worker | `index.ts` | التأكد من تنظيف Body + حفظ error_code |
| Flutter | `merchant_products_screen.dart` | معالجة محسّنة للأخطاء |

---

## 🔐 الأمان

### المبادئ المطبقة:
1. ✅ **Never trust client:** لا نثق أبداً بـ `store_id` من Flutter
2. ✅ **Derive from JWT:** `store_id` يُستخرج دائماً من JWT → profile → stores
3. ✅ **Verify ownership:** التحقق من أن المستخدم يملك المتجر
4. ✅ **RLS as backup:** RLS Policies كحماية إضافية

---

**التقرير أعد في:** 6 يناير 2025
**الحالة:** ✅ **جاهز للاختبار**

