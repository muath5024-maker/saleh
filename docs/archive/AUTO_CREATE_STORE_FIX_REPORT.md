# ✅ تقرير إصلاح - إنشاء متجر تلقائي للتاجر

## 📋 المشكلة

المشكلة: ظهور رسالة "لم يتم العثور على متجر لهذا الحساب" حتى لو كان المستخدم مسجلاً كتاجر.

**المطلوب:** أي مستخدم مسجل كتاجر يجب أن يكون لديه متجر تلقائياً.

---

## ✅ الحل المنفذ

تم تعديل Edge Function `merchant_store` لإنشاء متجر تلقائياً إذا:
1. لم يكن المستخدم لديه متجر
2. وكان المستخدم مسجلاً كتاجر (`role = 'merchant'`)

---

## 🔧 التعديلات

### 1. تعديل Edge Function (`merchant_store/index.ts`)

**الملف:** `mbuy-backend/functions/merchant_store/index.ts`

**التعديلات:**
- ✅ عند عدم وجود متجر، التحقق من role المستخدم
- ✅ إذا كان `role = 'merchant'`، إنشاء متجر تلقائياً
- ✅ اسم المتجر التلقائي: `متجر {email_prefix}` أو `متجر {user_id_prefix}`
- ✅ إضافة logging شامل لعملية الإنشاء التلقائي

**الكود المضاف:**
```typescript
// If no store found, create one automatically for merchants
if (!store) {
  console.log('[merchant_store] No store found for user_id:', user.id);
  console.log('[merchant_store] Checking if user is a merchant...');
  
  // Check if user is a merchant
  const { data: profile, error: profileError } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle();

  // If user is a merchant, create store automatically
  if (profile && profile.role === 'merchant') {
    console.log('[merchant_store] User is a merchant, creating store automatically...');
    
    // Generate store name from user email or use default
    const storeName = user.email 
      ? `متجر ${user.email.split('@')[0]}`
      : `متجر ${user.id.substring(0, 8)}`;
    
    const { data: newStore, error: createError } = await supabase
      .from('stores')
      .insert({
        owner_id: user.id,
        name: storeName,
        description: 'متجر تلقائي',
        status: 'active',
        is_active: true,
        is_verified: false,
        rating: 0,
        followers_count: 0,
      })
      .select('id, owner_id, name, status, is_active')
      .single();

    // Return the newly created store
    return new Response(
      JSON.stringify({ 
        ok: true, 
        data: {
          id: newStore.id,
          owner_id: newStore.owner_id,
          name: newStore.name,
          status: newStore.status,
          is_active: newStore.is_active,
        }
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    );
  }
}
```

---

## 📊 السلوك الجديد

### السيناريو 1: تاجر لديه متجر موجود
1. ✅ يتم جلب المتجر بنجاح
2. ✅ يتم إرجاع بيانات المتجر
3. ✅ لا يتم إنشاء متجر جديد

### السيناريو 2: تاجر بدون متجر
1. ✅ يتم التحقق من role المستخدم
2. ✅ إذا كان `role = 'merchant'`:
   - يتم إنشاء متجر تلقائياً
   - اسم المتجر: `متجر {email_prefix}` أو `متجر {user_id_prefix}`
   - الحالة: `active`
   - الوصف: `متجر تلقائي`
3. ✅ يتم إرجاع المتجر الجديد

### السيناريو 3: مستخدم عادي (غير تاجر) بدون متجر
1. ✅ يتم إرجاع `{ ok: true, data: null }`
2. ✅ لا يتم إنشاء متجر

---

## 🧪 الاختبار

### عند تسجيل الدخول كتاجر بدون متجر:

**في Logs يجب أن يظهر:**
```
[merchant_store] No store found for user_id: af5ce06e-c2e8-4de0-ad74-c432ff...
[merchant_store] Checking if user is a merchant...
[merchant_store] User is a merchant, creating store automatically...
[merchant_store] Creating store with name: متجر {email_prefix}
[merchant_store] Store created automatically: { storeId: "...", storeName: "...", ownerId: "..." }
```

**في Flutter يجب أن يظهر:**
```
✅ [StoreSession] تم حفظ Store ID بعد تسجيل الدخول: {store_id}
✅ [StoreSession] Store Name: متجر {email_prefix}
```

---

## 📝 الملفات المعدلة

1. ✅ `mbuy-backend/functions/merchant_store/index.ts`
   - إضافة منطق إنشاء متجر تلقائي
   - التحقق من role المستخدم
   - إنشاء متجر جديد للتاجر

2. ✅ `saleh/lib/core/root_widget.dart`
   - تحديث رسائل logging (معلومات فقط)

---

## ✅ النتيجة

### قبل التعديل:
- ❌ رسالة خطأ: "لم يتم العثور على متجر لهذا الحساب"
- ❌ لا يمكن إضافة منتجات
- ❌ StoreSession فارغ

### بعد التعديل:
- ✅ يتم إنشاء متجر تلقائياً للتاجر
- ✅ Store ID يتم حفظه في StoreSession
- ✅ يمكن إضافة منتجات فوراً
- ✅ لا تظهر رسالة خطأ

---

## 🔍 معلومات المتجر التلقائي

**الحقول الافتراضية:**
- `name`: `متجر {email_prefix}` أو `متجر {user_id_prefix}`
- `description`: `متجر تلقائي`
- `status`: `active`
- `is_active`: `true`
- `is_verified`: `false`
- `rating`: `0`
- `followers_count`: `0`

**ملاحظة:** يمكن للتاجر تعديل هذه المعلومات لاحقاً من شاشة إعداد المتجر.

---

**تاريخ التعديل:** يناير 2025  
**الحالة:** ✅ مكتمل وجاهز للاختبار  
**الملفات المعدلة:** 2 ملفات

