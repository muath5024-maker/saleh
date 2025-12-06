# ✅ ملخص نهائي لإصلاح مشكلة FORBIDDEN

## 📋 المشكلة
خطأ `FORBIDDEN` عند محاولة إضافة منتج جديد من تطبيق Flutter.

---

## ✅ الإصلاحات المطبقة

### 1. Migration Script شامل
**الملف:** `mbuy-backend/migrations/20250106000003_fix_user_profiles_and_rls_policies.sql`

#### ما يقوم به:
- ✅ إضافة `user_id UUID` إلى `user_profiles`
- ✅ إضافة `full_name TEXT` إلى `user_profiles`
- ✅ تحديث `user_id = id` لجميع الصفوف
- ✅ تحديث `full_name = display_name`
- ✅ جعل `user_id NOT NULL`
- ✅ إضافة فهارس على الأعمدة الجديدة
- ✅ إنشاء/تحديث RLS Policies لـ `user_profiles`
- ✅ إنشاء/تحديث RLS Policies لـ `products`
- ✅ إنشاء/تحديث RLS Policies لـ `stores`

---

### 2. تصحيح Worker لتمرير JWT
**الملف:** `mbuy-worker/src/index.ts`

**التغيير:**
- ✅ تمرير JWT من Flutter إلى Supabase REST API
- ✅ استخدام `clientToken` بدلاً من `SUPABASE_ANON_KEY` فقط

**قبل:**
```typescript
'Authorization': `Bearer ${c.env.SUPABASE_ANON_KEY}`
```

**بعد:**
```typescript
const authHeader = c.req.header('Authorization');
const clientToken = authHeader ? authHeader.substring(7) : null;
'Authorization': clientToken ? `Bearer ${clientToken}` : `Bearer ${c.env.SUPABASE_ANON_KEY}`
```

---

## 🔐 RLS Policies الجديدة

### user_profiles:
```sql
-- SELECT
USING (user_id = auth.uid())

-- UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid())

-- INSERT
WITH CHECK (user_id = auth.uid())
```

### products (INSERT):
```sql
WITH CHECK (
    EXISTS (
        SELECT 1 
        FROM stores 
        INNER JOIN user_profiles ON user_profiles.id = stores.owner_id
        WHERE stores.id = products.store_id 
        AND user_profiles.user_id = auth.uid()
        AND user_profiles.role = 'merchant'
    )
)
```

### stores:
```sql
USING (
    EXISTS (
        SELECT 1 
        FROM user_profiles 
        WHERE user_profiles.id = stores.owner_id 
        AND user_profiles.user_id = auth.uid()
    )
)
```

---

## 📊 السكيمة النهائية

### user_profiles:
```
- id (UUID, PK, FK → auth.users.id)
- user_id (UUID, FK → auth.users.id, NOT NULL) ✅
- role (TEXT)
- display_name (TEXT)
- full_name (TEXT) ✅
- phone, avatar_url, email
- created_at, updated_at
```

### العلاقات:
```
auth.users.id 
  ↓
user_profiles.user_id = auth.users.id ✅
user_profiles.id = auth.users.id
  ↓
stores.owner_id = user_profiles.id
  ↓
products.store_id = stores.id
```

---

## 🚀 خطوات التنفيذ

### 1. تشغيل Migration:
```
1. Supabase Dashboard → SQL Editor
2. انسخ: mbuy-backend/migrations/20250106000003_fix_user_profiles_and_rls_policies.sql
3. اضغط Run
```

### 2. نشر Worker:
```bash
cd mbuy-worker
wrangler deploy
```

### 3. الاختبار:
```
1. افتح Flutter App
2. سجل دخول كتاجر
3. أضف منتج جديد
4. يجب أن يعمل بدون FORBIDDEN
```

---

## ✅ التحقق

### بعد Migration:
```sql
-- 1. التحقق من الأعمدة
SELECT column_name FROM information_schema.columns
WHERE table_name = 'user_profiles' 
AND column_name IN ('user_id', 'full_name');

-- 2. التحقق من البيانات
SELECT id, user_id, id = user_id FROM user_profiles LIMIT 5;

-- 3. التحقق من RLS
SELECT tablename, policyname, cmd FROM pg_policies
WHERE tablename IN ('user_profiles', 'products', 'stores');
```

---

## 📁 الملفات المعدلة

1. ✅ `mbuy-backend/migrations/20250106000003_fix_user_profiles_and_rls_policies.sql` (جديد)
2. ✅ `mbuy-worker/src/index.ts` (تمرير JWT إلى Supabase)

---

## 🎯 النتيجة المتوقعة

- ✅ لا يظهر خطأ `FORBIDDEN`
- ✅ يمكن للتجار إضافة منتجات
- ✅ RLS يعمل بشكل صحيح
- ✅ JWT يتم تمريره بشكل صحيح

---

**جاهز للتنفيذ!** 🚀

