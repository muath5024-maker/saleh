# 🔧 تقرير شامل لإصلاح مسار إنشاء المنتجات

## 📋 ملخص التعديلات

تم إصلاح مسار إنشاء المنتجات بشكل كامل باستخدام التدفق الصحيح:
`auth.users.id` → `user_profiles.id` → `stores.owner_id` → `products.store_id`

---

## 📝 الملفات المعدلة مع سطور التعديل

### 1. **mbuy-backend/functions/product_create/index.ts**
**الملف بالكامل تم إعادة كتابته**

#### التعديلات الرئيسية:

**السطور 1-295:** إعادة كتابة كاملة للـ Edge Function

**المنطق الجديد:**

1. **استخراج userId من JWT (السطور 44-72):**
   ```typescript
   // Parse JWT to extract userId (jwt.sub = auth.users.id)
   const jwtParts = userJwt.split('.');
   const payload = JSON.parse(atob(jwtParts[1]));
   userId = payload.sub;
   ```

2. **جلب user profile (السطور 129-167):**
   ```typescript
   const { data: profile, error: profileError } = await supabase
     .from('user_profiles')
     .select('id, role, display_name')
     .eq('id', userId)
     .single();
   ```
   - إذا لم يوجد: إرجاع `404` مع كود `user_profile_not_found`

3. **التحقق من role = 'merchant' (السطور 169-187):**
   ```typescript
   if (profile.role !== 'merchant') {
     return { code: 'forbidden_not_merchant', status: 403 };
   }
   ```

4. **جلب store (السطور 189-229):**
   ```typescript
   const { data: store, error: storeError } = await supabase
     .from('stores')
     .select('id, owner_id, status, is_active')
     .eq('owner_id', profile.id)
     .eq('is_active', true)
     .single();
   ```
   - إذا لم يوجد: إرجاع `404` مع كود `store_not_found_for_owner`

5. **إدخال المنتج (السطور 231-293):**
   ```typescript
   const insertData: any = {
     store_id: store.id, // من الاستعلام المُتحقق منه
     name: body.name,
     description: body.description || '',
     price: body.price,
     stock: stockValue,
     // ...
   };
   
   const { data: products, error: createError } = await supabase
     .from('products')
     .insert(insertData)
     .select()
     .single();
   ```

#### Logging شامل:
- ✅ `userId` من JWT
- ✅ نتيجة استعلام profile
- ✅ نتيجة استعلام store
- ✅ أي خطأ من Supabase مع `error.code` و `error.message`

---

### 2. **mbuy-worker/src/index.ts**
**السطور المعدلة: 1659-1780**

#### التعديلات:

**قبل:** Worker كان يجلب store ويُدخل المنتج مباشرة

**بعد:** Worker ينظف body ويمرر البيانات فقط إلى Edge Function

**الكود الجديد (السطور 1659-1780):**
```typescript
// STEP 2: Clean request body
const cleanBody: any = { ...body };
delete cleanBody.id;
delete cleanBody.product_id;
delete cleanBody.store_id;
delete cleanBody.user_id;
delete cleanBody.owner_id;
delete cleanBody.created_at;
delete cleanBody.updated_at;

// STEP 3: Get client JWT token
const authHeader = c.req.header('Authorization');
const clientToken = authHeader ? authHeader.substring(7) : null;

// STEP 4: Call Edge Function
const response = await fetch(edgeFunctionUrl, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'x-internal-key': c.env.EDGE_INTERNAL_KEY,
    'Authorization': `Bearer ${clientToken}`, // Pass JWT
  },
  body: JSON.stringify(cleanBody), // Only product data, NO store_id
});
```

#### معالجة الأخطاء:
- ✅ الحفاظ على كود الخطأ والرسالة من Edge Function
- ✅ عدم تغيير رسائل الخطأ إلى رسائل عامة

---

### 3. **saleh/lib/features/merchant/presentation/screens/merchant_products_screen.dart**
**السطور المعدلة: 404-409**

#### التعديلات:
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

### 4. **mbuy-backend/migrations/20250106000005_simplify_rls_policies.sql**
**السطور المعدلة: 1-147**

#### التعديلات:

**إضافة RLS policy لـ user_profiles (السطور 7-19):**
```sql
CREATE POLICY "Profiles are viewable by owner"
ON public.user_profiles
FOR SELECT
USING (id = auth.uid());
```

**RLS Policies للـ stores (السطور 20-48):**
```sql
-- SELECT: المالك يمكنه رؤية متجره
CREATE POLICY "Store owners can view own stores"
USING (auth.uid() = owner_id);

-- INSERT/UPDATE/DELETE: المالك فقط
CREATE POLICY "Users can insert own stores"
WITH CHECK (auth.uid() = owner_id);
```

**RLS Policies للـ products (السطور 63-113):**
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
```

---

## 🔒 التدفق الآمن

### التدفق الكامل:

1. **Flutter → Worker:**
   - يرسل بيانات المنتج فقط (بدون `id`, `store_id`, `user_id`)
   - يرسل JWT في header `Authorization`

2. **Worker → Edge Function:**
   - ينظف body (يزيل أي حقول حساسة)
   - يمرر JWT إلى Edge Function
   - يمرر بيانات المنتج فقط

3. **Edge Function:**
   - يستخرج `userId` من JWT (`jwt.sub`)
   - يجلب `user_profiles` حيث `id = userId`
   - يتحقق من `role = 'merchant'`
   - يجلب `stores` حيث `owner_id = profile.id` و `is_active = true`
   - يُدخل المنتج مع `store_id = store.id`

---

## ✅ التحقق من RLS Policies

### user_profiles:
```sql
-- المالك يمكنه قراءة ملفه فقط
USING (id = auth.uid())
```

### stores:
```sql
-- المالك يمكنه إدارة متجره فقط
USING (owner_id = auth.uid())
WITH CHECK (owner_id = auth.uid())
```

### products:
```sql
-- فقط مالك المتجر يمكنه إدارة منتجات متجره
WITH CHECK (
    EXISTS (
        SELECT 1 FROM stores 
        WHERE stores.id = products.store_id 
        AND stores.owner_id = auth.uid()
    )
)
```

---

## 🎯 كودات الأخطاء

| الكود | الحالة | الوصف |
|-------|--------|-------|
| `user_profile_not_found` | 404 | لم يُعثر على profile للمستخدم |
| `forbidden_not_merchant` | 403 | المستخدم ليس تاجر |
| `store_not_found_for_owner` | 404 | لم يُعثر على متجر للمالك |
| `product_insert_failed` | 500 | فشل إدخال المنتج |
| `INTERNAL_ERROR` | 500 | خطأ داخلي غير متوقع |

---

## 📊 ملخص الملفات

| الملف | السطور | التعديل |
|-------|--------|---------|
| `product_create/index.ts` | 1-295 | إعادة كتابة كاملة |
| `mbuy-worker/src/index.ts` | 1659-1780 | تبسيط: تمرير البيانات فقط إلى Edge Function |
| `merchant_products_screen.dart` | 404-409 | منع إرسال id/store_id/user_id |
| `20250106000005_simplify_rls_policies.sql` | 1-147 | إضافة RLS policies |

---

## 🚀 الخطوات التالية

### 1. نشر Edge Function:
```bash
cd mbuy-backend
supabase functions deploy product_create
```

### 2. نشر Worker:
```bash
cd mbuy-worker
wrangler deploy
```

### 3. تشغيل Migration:
```sql
-- في Supabase SQL Editor
-- ملف: mbuy-backend/migrations/20250106000005_simplify_rls_policies.sql
```

### 4. الاختبار:
- فتح Flutter
- تسجيل الدخول كتاجر
- إضافة منتج جديد
- التحقق من عدم وجود أخطاء

---

**جميع التعديلات جاهزة للنشر والاختبار!** 🎉

