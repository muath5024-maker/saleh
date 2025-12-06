# ✅ تم النشر بنجاح - تعليمات Migration

## 📊 حالة النشر

### ✅ Edge Function
- **الحالة:** منشور بنجاح
- **المشروع:** sirqidofuvphqcxqchyc
- **Dashboard:** https://supabase.com/dashboard/project/sirqidofuvphqcxqchyc/functions

### ✅ Worker
- **الحالة:** منشور بنجاح
- **Version ID:** `fcd30125-f17f-4a53-8248-1790f469ec56`
- **URL:** https://misty-mode-b68b.baharista1.workers.dev

---

## 📝 الخطوة التالية: تشغيل Migration

### الملف المطلوب:
`mbuy-backend/migrations/20250106000005_simplify_rls_policies.sql`

### الخطوات:

1. **افتح Supabase Dashboard:**
   - https://supabase.com/dashboard/project/sirqidofuvphqcxqchyc

2. **اذهب إلى SQL Editor:**
   - من القائمة الجانبية: **SQL Editor**
   - أو: https://supabase.com/dashboard/project/sirqidofuvphqcxqchyc/sql/new

3. **انسخ محتوى الملف:**
   - افتح: `mbuy-backend/migrations/20250106000005_simplify_rls_policies.sql`
   - انسخ المحتوى كاملاً

4. **الصق في SQL Editor:**
   - الصق المحتوى
   - اضغط **Run** (أو F5)

5. **تحقق من النتيجة:**
   - يجب أن ترى رسائل:
     ```
     ✅ عدد سياسات user_profiles: 1
     ✅ عدد سياسات stores: 5
     ✅ عدد سياسات products: 4
     ✅ جميع السياسات تم إنشاؤها بنجاح!
     ```

---

## 🧪 الاختبار بعد Migration

### 1. فتح تطبيق Flutter
- شغّل التطبيق

### 2. تسجيل الدخول كتاجر
- استخدم حساب تاجر موجود في قاعدة البيانات

### 3. إضافة منتج جديد
- اذهب إلى شاشة المنتجات
- اضغط "إضافة منتج"
- املأ البيانات:
  - الاسم
  - الوصف
  - السعر
  - الكمية
  - (اختياري) صورة
- اضغط "حفظ"

### 4. التحقق من النتيجة
- ✅ لا يظهر خطأ "ليس لديك صلاحية الوصول" (FORBIDDEN)
- ✅ لا يظهر خطأ "User profile not found"
- ✅ لا يظهر خطأ "Store not found"
- ✅ يتم إضافة المنتج بنجاح
- ✅ يظهر المنتج في القائمة

---

## 🔍 إذا استمرت المشكلة

### 1. تحقق من Logs:
- **Supabase:** Dashboard → Logs → Postgres Logs
- **Worker:** Cloudflare Dashboard → Workers → misty-mode-b68b → Logs
- **Edge Function:** Supabase Dashboard → Edge Functions → product_create → Logs

### 2. تحقق من RLS Policies:
```sql
-- في SQL Editor:
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('user_profiles', 'stores', 'products')
ORDER BY tablename, policyname;
```

### 3. تحقق من البيانات:
```sql
-- تحقق من وجود profile للمستخدم
SELECT id, role FROM user_profiles WHERE id = '<USER_ID>';

-- تحقق من وجود store للمالك
SELECT id, owner_id, is_active FROM stores WHERE owner_id = '<USER_ID>';
```

---

## 📊 ملخص التعديلات

| المكون | الحالة | التفاصيل |
|--------|--------|----------|
| Edge Function | ✅ منشور | إعادة كتابة كاملة |
| Worker | ✅ منشور | تمرير البيانات فقط |
| Flutter | ✅ جاهز | لا يرسل id/store_id/user_id |
| Migration | ⏳ في الانتظار | يحتاج تشغيل في Supabase |

---

**بعد تشغيل Migration، يجب أن تعمل إضافة المنتج بدون أخطاء!** 🚀

