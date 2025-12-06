# 📋 ملخص التغييرات: إصلاح FORBIDDEN في إضافة المنتجات

## ✅ الملفات المعدلة

### 1. Edge Function ✅
**الملف:** `mbuy-backend/functions/product_create/index.ts`

**التغييرات الرئيسية:**
- ✅ استخراج `userId` من `jwt.sub` مع logging: `console.log("product_create: jwt.sub =", userId)`
- ✅ استخدام `maybeSingle()` بدلاً من `single()` لجلب profile وstore
- ✅ Error codes موحدة: `NO_USER_PROFILE`, `NOT_MERCHANT`, `NO_ACTIVE_STORE`, `INSERT_FAILED`
- ✅ Logging شامل لكل خطوة
- ✅ تجاهل تماماً `store_id` من Body
- ✅ استخدام `store.id` من الاستعلام فقط

---

### 2. Migration جديدة ✅
**الملف:** `mbuy-backend/migrations/20250106000007_finalize_product_create_rls.sql`

**التغييرات:**
- ✅ إضافة/تحديث سياسات RLS لـ `user_profiles`, `stores`, `products`
- ✅ الحفاظ على سياسات Public للقراءة العامة
- ✅ سياسات للتجار: INSERT/UPDATE/DELETE/SELECT للمالك فقط

---

### 3. Worker ✅
**الملف:** `mbuy-worker/src/index.ts`

**التغييرات:**
- ✅ الحفاظ على تنظيف Body (حذف `id, store_id, user_id, owner_id`)
- ✅ الحفاظ على `error_code` من Edge Function في الرد
- ✅ تمرير JWT بشكل صحيح

---

### 4. Flutter ✅
**الملف:** `saleh/lib/features/merchant/presentation/screens/merchant_products_screen.dart`

**التغييرات:**
- ✅ معالجة محسّنة للأخطاء مع `error_code`
- ✅ رسائل واضحة بالعربي لكل نوع خطأ
- ✅ Logging أفضل للأخطاء

---

## 🔄 التدفق الجديد

```
Flutter
  ↓ (POST /secure/products)
  ↓ Body: { name, price, stock, ... } (NO store_id)
Worker
  ↓ تنظيف Body (حذف store_id)
  ↓ تمرير JWT
Edge Function
  ↓ استخراج userId من jwt.sub
  ↓ جلب user_profiles (id = userId)
  ↓ التحقق: role = 'merchant'
  ↓ جلب stores (owner_id = userId, is_active = true)
  ↓ استخدام store.id
  ↓ إدراج product (store_id = store.id)
Supabase
  ↓ RLS Policies تتحقق
  ✅ نجاح!
```

---

## 🎯 الخطوات التالية

1. ✅ تشغيل Migration: `20250106000007_finalize_product_create_rls.sql` في Supabase
2. ✅ نشر Edge Function: `supabase functions deploy product_create`
3. ✅ نشر Worker: `wrangler deploy`
4. ✅ اختبار إضافة منتج جديد
5. ✅ التحقق من Logs

---

**الحالة:** ✅ **جاهز للنشر والاختبار**

