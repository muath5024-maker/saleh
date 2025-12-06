# 🔧 تقرير إصلاح مشكلة FORBIDDEN - الإصدار النهائي

## 📋 ملخص التعديلات

تم إصلاح مشكلة "ليس لديك صلاحية الوصول" (FORBIDDEN) عند إضافة منتج من خلال تبسيط الكود واستخدام `auth.uid() = owner_id` مباشرة.

---

## 📝 الملفات المعدلة

### 1. **mbuy-worker/src/index.ts**

#### التعديلات:
- **السطور 1636-1790:** تبسيط endpoint `POST /secure/products`
- **المنطق الجديد:**
  1. استخراج `userId` من `jwt.sub` (من middleware)
  2. استخدام `userId` مباشرة كـ `owner_id` للاستعلام عن المتجر
  3. الاستعلام: `SELECT id FROM stores WHERE owner_id = $1 LIMIT 1`
  4. إذا لم يوجد متجر: إرجاع `{ error: "STORE_NOT_FOUND" }` مع status 400
  5. إذا وُجد متجر: إضافة `store_id` تلقائياً للمنتج قبل الإدخال
  6. منع مرور أي `store_id` أو `user_id` من العميل
  7. إدخال المنتج مباشرة باستخدام `SERVICE_ROLE_KEY` (بدون Edge Function)

#### الكود الرئيسي:
```typescript
// استخراج userId من JWT
const userId = c.get('userId'); // من jwt.sub

// البحث عن المتجر
const storeUrl = `${c.env.SUPABASE_URL}/rest/v1/stores?owner_id=eq.${userId}&select=id&limit=1`;
const storeResponse = await fetch(storeUrl, {
  headers: {
    'apikey': c.env.SUPABASE_SERVICE_ROLE_KEY,
    'Authorization': `Bearer ${c.env.SUPABASE_SERVICE_ROLE_KEY}`,
  },
});

// تنظيف body
delete cleanBody.id;
delete cleanBody.product_id;
delete cleanBody.store_id;
delete cleanBody.user_id;
delete cleanBody.owner_id;

// إضافة store_id المُتحقق منه
cleanBody.store_id = storeId;

// إدخال المنتج مباشرة
const insertResponse = await fetch(`${c.env.SUPABASE_URL}/rest/v1/products`, {
  method: 'POST',
  headers: {
    'apikey': c.env.SUPABASE_SERVICE_ROLE_KEY,
    'Authorization': `Bearer ${c.env.SUPABASE_SERVICE_ROLE_KEY}`,
  },
  body: JSON.stringify(cleanBody),
});
```

---

### 2. **mbuy-backend/migrations/20250106000005_simplify_rls_policies.sql**

#### التعديلات:
- **السطور 1-150:** إنشاء migration script جديد لتبسيط RLS policies

#### RLS Policies الجديدة:

**لـ stores:**
```sql
-- SELECT: المالك يمكنه رؤية متجره
CREATE POLICY "Store owners can view own stores"
USING (auth.uid() = owner_id);

-- INSERT: المالك فقط يمكنه إنشاء متجر لنفسه
CREATE POLICY "Users can insert own stores"
WITH CHECK (auth.uid() = owner_id);

-- UPDATE: المالك فقط يمكنه تحديث متجره
CREATE POLICY "Store owners can update own stores"
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);

-- DELETE: المالك فقط يمكنه حذف متجره
CREATE POLICY "Store owners can delete own stores"
USING (auth.uid() = owner_id);
```

**لـ products:**
```sql
-- INSERT: فقط مالك المتجر يمكنه إضافة منتجات لمتجره
CREATE POLICY "Store owners can insert products"
WITH CHECK (
    EXISTS (
        SELECT 1 
        FROM public.stores 
        WHERE stores.id = products.store_id 
        AND stores.owner_id = auth.uid()
    )
);

-- UPDATE: فقط مالك المتجر يمكنه تحديث منتجات متجره
CREATE POLICY "Store owners can update products"
USING (
    EXISTS (
        SELECT 1 
        FROM public.stores 
        WHERE stores.id = products.store_id 
        AND stores.owner_id = auth.uid()
    )
);

-- DELETE: فقط مالك المتجر يمكنه حذف منتجات متجره
CREATE POLICY "Store owners can delete products"
USING (
    EXISTS (
        SELECT 1 
        FROM public.stores 
        WHERE stores.id = products.store_id 
        AND stores.owner_id = auth.uid()
    )
);
```

---

### 3. **saleh/lib/features/merchant/presentation/screens/merchant_products_screen.dart**

#### التعديلات:
- **السطور 404-407:** التأكد من عدم إرسال `id`, `store_id`, `user_id`, `owner_id` من العميل

#### الكود:
```dart
// التأكد من عدم وجود أي id في البيانات - منع إرسالها من العميل
productData.remove('id');
productData.remove('product_id');
productData.remove('store_id');
productData.remove('user_id');
productData.remove('owner_id');
```

**الحقول المسموح بها فقط:**
- `name`
- `description`
- `price`
- `stock`
- `main_image_url` / `images`
- `status`
- `is_active`

---

## ✅ النتيجة

### قبل الإصلاح:
- ❌ كان Worker يجلب `user_profiles` أولاً
- ❌ ثم يجلب `stores` بناءً على `profile.id`
- ❌ ثم يستدعي Edge Function
- ❌ RLS Policies معقدة مع JOINs متعددة

### بعد الإصلاح:
- ✅ Worker يستخدم `userId` مباشرة من `jwt.sub` كـ `owner_id`
- ✅ استعلام مباشر: `SELECT id FROM stores WHERE owner_id = userId LIMIT 1`
- ✅ إدخال المنتج مباشرة باستخدام `SERVICE_ROLE_KEY`
- ✅ RLS Policies مبسطة: `auth.uid() = owner_id`

---

## 🔒 الأمان

1. ✅ لا يمكن للعميل إرسال `store_id` أو `user_id`
2. ✅ `store_id` يُستخرج فقط من قاعدة البيانات بناءً على `userId` من JWT
3. ✅ RLS Policies تتحقق من أن `auth.uid() = owner_id`
4. ✅ `SERVICE_ROLE_KEY` يتجاوز RLS للعمليات الإدارية (Worker فقط)

---

## 📊 الخطوات المطلوبة

### 1. تشغيل Migration
```sql
-- في Supabase SQL Editor:
-- نسخ محتوى ملف: mbuy-backend/migrations/20250106000005_simplify_rls_policies.sql
-- وتشغيله
```

### 2. نشر Worker
```bash
cd mbuy-worker
wrangler deploy
```

### 3. اختبار
- فتح تطبيق Flutter
- تسجيل الدخول كتاجر
- إضافة منتج جديد
- التحقق من عدم وجود خطأ FORBIDDEN

---

## 📝 الملخص

| الملف | السطور المعدلة | التعديل الرئيسي |
|-------|----------------|------------------|
| `mbuy-worker/src/index.ts` | 1636-1790 | تبسيط endpoint، استخدام userId مباشرة |
| `migrations/20250106000005_simplify_rls_policies.sql` | 1-150 | RLS policies مبسطة |
| `merchant_products_screen.dart` | 404-407 | منع إرسال id/store_id/user_id |

---

**جاهز للنشر والاختبار!** 🚀

