# ✅ إصلاح RLS و FORBIDDEN - جاهز للتنفيذ

## 📋 الخطوات المطلوبة

### 1. تشغيل Migration في Supabase ⚠️ **مهم جداً**

**الملف:** `mbuy-backend/migrations/20250106000003_fix_user_profiles_and_rls_policies.sql`

**الطريقة:**
1. افتح: https://supabase.com/dashboard/project/sirqidofuvphqcxqchyc
2. اذهب إلى **SQL Editor**
3. انسخ محتوى الملف كاملاً
4. الصق واضغط **Run**
5. انتظر رسالة: `✅ جميع الإصلاحات تمت بنجاح!`

---

### 2. Worker منشور ✅

**تم النشر:** Worker محدث ومرسل JWT بشكل صحيح

---

## ✅ ما تم تطبيقه

### Migration Script:
- ✅ إضافة `user_id` و `full_name` إلى `user_profiles`
- ✅ تحديث البيانات (`user_id = id`)
- ✅ RLS Policies جديدة لـ `user_profiles`, `products`, `stores`

### Worker:
- ✅ تمرير JWT من Flutter إلى Supabase REST API
- ✅ استخدام `clientToken` في استعلامات `user_profiles` و `stores`

---

## 🧪 الاختبار

### 1. بعد تشغيل Migration:
```sql
-- التحقق من الأعمدة
SELECT column_name FROM information_schema.columns
WHERE table_name = 'user_profiles' 
AND column_name IN ('user_id', 'full_name');
```

### 2. من Flutter:
1. افتح التطبيق
2. سجل دخول كتاجر
3. أضف منتج جديد
4. يجب أن يعمل بدون FORBIDDEN ✅

---

## 📊 السكيمة النهائية

### user_profiles:
- `id` (PK, FK → auth.users.id)
- `user_id` (FK → auth.users.id, NOT NULL) ✅
- `full_name` (TEXT) ✅
- `display_name`, `role`, `phone`, `avatar_url`, `email`

### RLS Policies:
- `user_profiles`: تستخدم `user_id = auth.uid()`
- `products`: تستخدم JOIN مع `user_profiles.user_id = auth.uid()`
- `stores`: تستخدم JOIN مع `user_profiles.user_id = auth.uid()`

---

**الخطوة التالية:** شغّل Migration في Supabase! 🚀

