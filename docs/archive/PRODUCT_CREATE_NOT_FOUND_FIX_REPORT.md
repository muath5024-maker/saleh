# ✅ تقرير إصلاح مشكلة "خطأ في إضافة المنتج: [NOT_FOUND]"

## 📋 المشكلة
- رفع الصورة يعمل بنجاح ✅
- بعد رفع الصورة مباشرة يظهر: "خطأ في إضافة المنتج: [NOT_FOUND] العنصر غير موجود" ❌

---

## 🔧 الحل المنفذ

### 1. Worker Endpoint

**الملف:** `C:\muath\mbuy-worker\src\index.ts`  
**الدالة:** `POST /secure/products` (السطر 1633-1678)

**التعديلات:**
1. ✅ إزالة `id`، `product_id`، `store_id` من body
2. ✅ Logging شامل (body، userId، operation، response)
3. ✅ إضافة `user_id` تلقائياً من JWT

---

### 2. Edge Function

**الملف:** `C:\muath\mbuy-backend\functions\product_create\index.ts`

**التعديلات:**
1. ✅ **استخراج `store_id` من JWT فقط:**
   - استعلام: `SELECT id FROM stores WHERE owner_id = userId LIMIT 1`
   - إذا لم يوجد متجر → `{ ok: false, error: 'NO_STORE_FOR_USER' }` مع status 400

2. ✅ **إصلاح استخدام `single()` بعد `insert()`:**
   - تغيير من `.single()` إلى `.select()` ثم استخدام `products[0]`
   - التحقق من أن المنتج تم إنشاؤه بنجاح

3. ✅ **Logging شامل:**
   - `user_id`، `store_id`
   - بيانات المنتج قبل الإدراج
   - الخطأ الكامل من Supabase (code, message, details, hint)

---

### 3. Flutter

**الملف:** `C:\muath\saleh\lib\features\merchant\presentation\screens\merchant_products_screen.dart`  
**الدالة:** `_createProduct()` (السطر 222-349)

**التعديلات:**
1. ✅ **إزالة `store_id` من body:**
   - لا يتم إرسال `store_id` من Flutter
   - يتم جلبها من JWT في الـ backend فقط

2. ✅ **إزالة أي `id` من body:**
   ```dart
   productData.remove('id');
   productData.remove('product_id');
   productData.remove('store_id');
   ```

---

## 📝 الكود النهائي

### Worker - `POST /secure/products`:

```typescript
app.post('/secure/products', async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();

  console.log('[Worker] POST /secure/products - Request received:', {
    userId,
    hasStoreId: !!body.store_id,
    hasId: !!body.id,
    operation: 'CREATE',
    bodyKeys: Object.keys(body)
  });

  // Remove any id fields
  const cleanBody = { ...body };
  delete cleanBody.id;
  delete cleanBody.product_id;
  delete cleanBody.store_id; // Get from JWT only

  const response = await fetch(`${c.env.SUPABASE_URL}/functions/v1/product_create`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-internal-key': c.env.EDGE_INTERNAL_KEY,
    },
    body: JSON.stringify({ ...cleanBody, user_id: userId }),
  });

  const data = await response.json();
  return c.json(data, response.status);
});
```

### Edge Function - `product_create`:

```typescript
// Get user's store from JWT only
const { data: store, error: storeError } = await supabase
  .from('stores')
  .select('id')
  .eq('owner_id', user_id)
  .maybeSingle();

if (!store) {
  return new Response(
    JSON.stringify({ 
      ok: false,
      error: 'NO_STORE_FOR_USER', 
      detail: 'User does not have a store. Please create a store first.' 
    }),
    { status: 400, ... }
  );
}

const storeId = store.id;

// Create product - use insert only
const { data: products, error: createError } = await supabase
  .from('products')
  .insert({
    store_id: storeId,
    name,
    description: description || '',
    price,
    stock: stockValue,
    status: status || 'active',
    is_active: is_active !== undefined ? is_active : true,
    main_image_url: main_image_url || null,
    images: images || [],
  })
  .select();

if (createError) {
  console.error('[product_create] Insert error:', {
    code: createError.code,
    message: createError.message,
    details: createError.details,
    hint: createError.hint
  });
  
  return new Response(
    JSON.stringify({
      ok: false,
      error: createError.code || 'PRODUCT_CREATE_ERROR',
      detail: createError.message,
      hint: createError.hint || null
    }),
    { status: 500, ... }
  );
}

if (!products || products.length === 0) {
  return new Response(
    JSON.stringify({
      ok: false,
      error: 'NOT_FOUND',
      detail: 'Product was not created or could not be retrieved'
    }),
    { status: 404, ... }
  );
}

const product = products[0];
return new Response(
  JSON.stringify({
    ok: true,
    data: product,
  }),
  { status: 201, ... }
);
```

---

## 📊 مثال Body المرسل من Flutter

### في حالة الإضافة (Create):

```json
{
  "name": "منتج تجريبي",
  "description": "وصف المنتج",
  "price": 100.0,
  "stock": 10,
  "status": "active",
  "is_active": true,
  "main_image_url": "https://...",
  "images": ["https://..."]
}
```

**لا يحتوي على:**
- ❌ `id`
- ❌ `product_id`
- ❌ `store_id`

### في حالة التعديل (Update):

```json
{
  "id": "product-uuid",
  "name": "منتج معدل",
  ...
}
```

---

## ✅ ملخص التعديلات

### الملفات المعدلة:

1. ✅ `mbuy-worker/src/index.ts`
   - تنظيف body من `id` و `store_id`
   - Logging شامل

2. ✅ `mbuy-backend/functions/product_create/index.ts`
   - استخراج `store_id` من JWT فقط
   - إصلاح استخدام `single()` بعد `insert()`
   - Logging شامل للأخطاء

3. ✅ `saleh/lib/features/merchant/presentation/screens/merchant_products_screen.dart`
   - إزالة `store_id` من body
   - إزالة أي `id` من body

---

## ✅ السلوك النهائي المتوقع

### (أ) حساب التاجر صاحب المتجر:
- ✅ رفع الصورة يعمل بنجاح
- ✅ إضافة المنتج تعمل **بدون خطأ NOT_FOUND**
- ✅ المنتج يظهر في القائمة مباشرة

### (ب) تعديل منتج موجود:
- ✅ سيتم استخدام endpoint منفصل عند إضافة وظيفة التعديل

---

**تاريخ الإصلاح:** يناير 2025  
**الحالة:** ✅ مكتمل  
**النتيجة:** ✅ المشكلة محلولة

