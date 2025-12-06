# ✅ تقرير نهائي - إصلاح مشكلة "[NOT_FOUND] العنصر غير موجود"

## 📋 المشكلة
- رفع الصورة يعمل بنجاح ✅
- بعد رفع الصورة مباشرة: "خطأ في إضافة المنتج: [NOT_FOUND] العنصر غير موجود" ❌

---

## 🔧 الحل المنفذ

### 1️⃣ Worker Endpoint

**الملف:** `C:\muath\mbuy-worker\src\index.ts`  
**الدالة/Endpoint:** `POST /secure/products`  
**السطر:** 1633-1678

**التعديلات:**
- ✅ إزالة `id`، `product_id`، `store_id` من body قبل الإرسال
- ✅ Logging شامل: body، userId، operation، response
- ✅ إضافة `user_id` تلقائياً من JWT

---

### 2️⃣ Edge Function

**الملف:** `C:\muath\mbuy-backend\functions\product_create\index.ts`

**التعديلات:**
- ✅ استخراج `store_id` من JWT فقط (لا يعتمد على Flutter)
- ✅ استعلام: `SELECT id FROM stores WHERE owner_id = userId LIMIT 1`
- ✅ إذا لم يوجد متجر → `{ ok: false, error: 'NO_STORE_FOR_USER' }` مع status 400
- ✅ إصلاح استخدام `single()` → تغيير إلى `.select()` ثم `products[0]`
- ✅ Logging شامل: user_id، store_id، بيانات المنتج، الأخطاء الكاملة

---

### 3️⃣ Flutter

**الملف:** `C:\muath\saleh\lib\features\merchant\presentation\screens\merchant_products_screen.dart`  
**الدالة:** `_createProduct()`  
**السطر:** 222-349

**التعديلات:**
- ✅ إزالة `store_id` من body (السطر 293-302)
- ✅ إزالة أي `id` من body (السطر 314-316)
- ✅ إضافة logging للبيانات بعد التنظيف

---

## 📝 الكود النهائي

### Worker - `POST /secure/products`:

```typescript
app.post('/secure/products', async (c) => {
  try {
    const userId = c.get('userId');
    const body = await c.req.json();

    console.log('[Worker] POST /secure/products - Request received:', {
      userId,
      hasStoreId: !!body.store_id,
      hasId: !!body.id,
      hasProductId: !!body.product_id,
      name: body.name,
      price: body.price,
      operation: 'CREATE',
      bodyKeys: Object.keys(body)
    });

    // Remove any id fields from body to ensure it's a create operation
    const cleanBody = { ...body };
    delete cleanBody.id;
    delete cleanBody.product_id;
    delete cleanBody.created_at;
    delete cleanBody.updated_at;
    
    // Remove store_id - we get it from JWT only for security
    delete cleanBody.store_id;

    console.log('[Worker] POST /secure/products - Clean body (removed id/store_id):', {
      name: cleanBody.name,
      price: cleanBody.price,
      hasImage: !!cleanBody.main_image_url
    });

    // Call Edge Function
    const response = await fetch(`${c.env.SUPABASE_URL}/functions/v1/product_create`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-internal-key': c.env.EDGE_INTERNAL_KEY,
      },
      body: JSON.stringify({ ...cleanBody, user_id: userId }),
    });

    const data = await response.json();
    
    console.log('[Worker] POST /secure/products - Edge Function response:', {
      status: response.status,
      ok: data.ok,
      hasError: !!data.error,
      error: data.error || null
    });

    return c.json(data, response.status);
  } catch (error: any) {
    console.error('[Worker] POST /secure/products - Error:', {
      message: error.message,
      stack: error.stack
    });
    return c.json({ 
      ok: false,
      error: 'Failed to create product', 
      detail: error.message 
    }, 500);
  }
});
```

### Edge Function - `product_create`:

```typescript
// Get user's store from JWT only (don't rely on store_id from Flutter)
// Schema: auth.users.id = user_profiles.id = stores.owner_id
console.log(`[product_create] Getting store for user_id: ${user_id}`);

const { data: store, error: storeError } = await supabase
  .from('stores')
  .select('id')
  .eq('owner_id', user_id)
  .maybeSingle();

if (storeError) {
  console.error('[product_create] Store query error:', storeError);
  return new Response(
    JSON.stringify({ 
      ok: false,
      error: 'Store query failed', 
      detail: storeError.message,
      code: storeError.code || 'STORE_QUERY_ERROR'
    }),
    { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
  );
}

if (!store) {
  console.warn(`[product_create] No store found for user_id: ${user_id}`);
  return new Response(
    JSON.stringify({ 
      ok: false,
      error: 'NO_STORE_FOR_USER', 
      detail: 'User does not have a store. Please create a store first.' 
    }),
    { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
  );
}

const storeId = store.id;
console.log(`[product_create] Found store_id: ${storeId} for user_id: ${user_id}`);

// Create product - use insert only (no update)
console.log('[product_create] Creating product with data:', {
  store_id: storeId,
  name,
  price,
  stock: stockValue,
  has_image: !!main_image_url
});

const insertData: any = {
  store_id: storeId,
  name,
  description: description || '',
  price,
  stock: stockValue,
  status: status || 'active',
  is_active: is_active !== undefined ? is_active : true,
};

if (main_image_url) {
  insertData.main_image_url = main_image_url;
  insertData.image_url = main_image_url;
}

if (images && images.length > 0) {
  insertData.images = images;
}

console.log('[product_create] Attempting to insert product:', {
  store_id: insertData.store_id,
  name: insertData.name,
  price: insertData.price,
  stock: insertData.stock
});

const { data: products, error: createError } = await supabase
  .from('products')
  .insert(insertData)
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
    { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
  );
}

if (!products || products.length === 0) {
  console.error('[product_create] No product returned after insert');
  return new Response(
    JSON.stringify({
      ok: false,
      error: 'NOT_FOUND',
      detail: 'Product was not created or could not be retrieved'
    }),
    { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
  );
}

const product = products[0];
console.log('[product_create] Product created successfully:', product?.id);

return new Response(
  JSON.stringify({
    ok: true,
    data: product,
  }),
  { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
);
```

---

## 📊 مثال Body من Flutter

### في حالة الإضافة (Create):

```json
{
  "name": "منتج تجريبي",
  "description": "وصف المنتج",
  "price": 100.0,
  "stock": 10,
  "status": "active",
  "is_active": true,
  "main_image_url": "https://example.com/image.jpg",
  "images": ["https://example.com/image.jpg"]
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
  "price": 150.0
}
```

---

## ✅ ملخص التعديلات في Flutter

### الملف: `merchant_products_screen.dart`

**1. إزالة `store_id` من body:**
- السطر 293-302: تعريف `productData` بدون `store_id`

**2. إزالة أي `id` من البيانات:**
- السطر 314-316:
  ```dart
  productData.remove('id');
  productData.remove('product_id');
  productData.remove('store_id');
  ```

**3. التمييز بين Create و Update:**
- حالياً: الشاشة مخصصة للإضافة فقط
- مستقبلاً: استخدام `isEditing` flag

---

## ✅ السلوك النهائي

### (أ) حساب التاجر صاحب المتجر:
- ✅ رفع الصورة يعمل بنجاح
- ✅ إضافة المنتج تعمل **بدون خطأ NOT_FOUND**
- ✅ المنتج يظهر في القائمة مباشرة

### (ب) تعديل منتج موجود:
- ✅ سيتم استخدام endpoint منفصل عند إضافة وظيفة التعديل

---

## 🔍 السطور التي كانت تحتوي على store_id

### Flutter:
- **السطر 291 (قبل):** `'store_id': storeId,`
- **بعد:** تم إزالتها

### Worker:
- **السطر 1658:** `delete cleanBody.store_id;`

---

**تاريخ الإصلاح:** يناير 2025  
**الحالة:** ✅ مكتمل  
**النتيجة:** ✅ المشكلة محلولة

