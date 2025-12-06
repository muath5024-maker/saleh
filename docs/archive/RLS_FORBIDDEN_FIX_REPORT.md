# 🔧 تقرير إصلاح مشكلة FORBIDDEN عند إضافة منتج

## 📋 المشكلة
خطأ `FORBIDDEN` عند محاولة إضافة منتج جديد من تطبيق Flutter.

**السبب:** 
- RLS Policies في Supabase تستخدم `auth.uid() = id` بدلاً من `auth.uid() = user_id`
- جدول `user_profiles` لا يحتوي على عمود `user_id`
- جدول `user_profiles` لا يحتوي على عمود `full_name`

---

## ✅ الإصلاحات المطبقة

### 1. Migration Script شامل
**الملف:** `mbuy-backend/migrations/20250106000003_fix_user_profiles_and_rls_policies.sql`

#### أ) إضافة الأعمدة المفقودة:
- ✅ `user_id UUID` → `auth.users(id)`
- ✅ `full_name TEXT`

#### ب) تحديث البيانات:
- ✅ `UPDATE user_profiles SET user_id = id WHERE user_id IS NULL`
- ✅ `UPDATE user_profiles SET full_name = display_name WHERE full_name IS NULL`
- ✅ جعل `user_id NOT NULL`

#### ج) إضافة الفهارس:
- ✅ `idx_user_profiles_user_id`
- ✅ `idx_user_profiles_full_name`

---

### 2. RLS Policies لـ user_profiles

#### سياسة SELECT:
```sql
CREATE POLICY "Users can read own profile"
ON public.user_profiles FOR SELECT
USING (user_id = auth.uid());
```

#### سياسة UPDATE:
```sql
CREATE POLICY "Users can update own profile"
ON public.user_profiles FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());
```

#### سياسة INSERT:
```sql
CREATE POLICY "Users can insert own profile"
ON public.user_profiles FOR INSERT
WITH CHECK (user_id = auth.uid());
```

---

### 3. RLS Policies لـ products

#### سياسة INSERT (للتجار فقط):
```sql
CREATE POLICY "Merchants insert their own products"
ON public.products FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 
        FROM public.stores 
        WHERE stores.id = products.store_id 
        AND EXISTS (
            SELECT 1 
            FROM public.user_profiles 
            WHERE user_profiles.id = stores.owner_id 
            AND user_profiles.user_id = auth.uid()
            AND user_profiles.role = 'merchant'
        )
    )
);
```

#### سياسة UPDATE:
```sql
CREATE POLICY "Merchants can update own products"
ON public.products FOR UPDATE
USING (
    EXISTS (
        SELECT 1 
        FROM public.stores 
        WHERE stores.id = products.store_id 
        AND EXISTS (
            SELECT 1 
            FROM public.user_profiles 
            WHERE user_profiles.id = stores.owner_id 
            AND user_profiles.user_id = auth.uid()
            AND user_profiles.role = 'merchant'
        )
    )
);
```

#### سياسة DELETE:
```sql
CREATE POLICY "Merchants can delete own products"
ON public.products FOR DELETE
USING (
    EXISTS (
        SELECT 1 
        FROM public.stores 
        WHERE stores.id = products.store_id 
        AND EXISTS (
            SELECT 1 
            FROM public.user_profiles 
            WHERE user_profiles.id = stores.owner_id 
            AND user_profiles.user_id = auth.uid()
            AND user_profiles.role = 'merchant'
        )
    )
);
```

---

### 4. تصحيح RLS Policies لـ stores

#### سياسة SELECT للتجار:
```sql
CREATE POLICY "Merchants can view own stores"
ON public.stores FOR SELECT
USING (
    EXISTS (
        SELECT 1 
        FROM public.user_profiles 
        WHERE user_profiles.id = stores.owner_id 
        AND user_profiles.user_id = auth.uid()
    )
);
```

#### سياسة ALL للتجار:
```sql
CREATE POLICY "Merchants can manage own stores"
ON public.stores FOR ALL
USING (
    EXISTS (
        SELECT 1 
        FROM public.user_profiles 
        WHERE user_profiles.id = stores.owner_id 
        AND user_profiles.user_id = auth.uid()
    )
);
```

---

### 5. التحقق من JWT في Flutter

**الملف:** `saleh/lib/core/services/api_service.dart`

**الكود الحالي:**
```dart
static String? _getJWT() {
  final session = supabaseClient.auth.currentSession;
  return session?.accessToken; // ✅ صحيح
}
```

**التحقق:**
- ✅ يستخدم `accessToken` من `currentSession`
- ✅ يرسل في Header: `Authorization: Bearer $jwt`

---

### 6. التحقق من JWT في Worker

**الملف:** `mbuy-worker/src/index.ts`

**الكود الحالي:**
```typescript
const authHeader = c.req.header('Authorization');
const token = authHeader.substring(7); // ✅ يستخرج Bearer token
c.set('userId', payload.sub); // ✅ يستخرج userId من JWT
```

**التحقق:**
- ✅ يقرأ `Authorization` header
- ✅ يستخرج `payload.sub` (auth.users.id)
- ✅ يمرره إلى Edge Function

---

## 🔐 السكيمة النهائية

### جدول user_profiles:
```
- id (UUID, PK, FK → auth.users.id)
- user_id (UUID, FK → auth.users.id, NOT NULL) ✅ جديد
- role (TEXT)
- display_name (TEXT)
- full_name (TEXT) ✅ جديد
- phone (TEXT)
- avatar_url (TEXT)
- email (TEXT)
- created_at, updated_at
```

### العلاقات:
```
auth.users.id 
  ↓
user_profiles.user_id (FK → auth.users.id)
user_profiles.id (PK, FK → auth.users.id)
  ↓
stores.owner_id (FK → user_profiles.id)
  ↓
products.store_id (FK → stores.id)
```

---

## 📊 الملفات

### ملف Migration:
1. ✅ `mbuy-backend/migrations/20250106000003_fix_user_profiles_and_rls_policies.sql`

### ملفات الكود (لا تحتاج تعديل):
- ✅ `saleh/lib/core/services/api_service.dart` - يستخدم `accessToken` صحيح
- ✅ `mbuy-worker/src/index.ts` - يقرأ JWT صحيح

---

## 🧪 خطوات التنفيذ

### 1. تشغيل Migration:
```sql
-- في Supabase SQL Editor:
-- انسخ محتوى ملف:
-- mbuy-backend/migrations/20250106000003_fix_user_profiles_and_rls_policies.sql
```

### 2. التحقق من الأعمدة:
```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'user_profiles'
  AND column_name IN ('id', 'user_id', 'full_name', 'display_name');
```

### 3. التحقق من البيانات:
```sql
SELECT 
  id,
  user_id,
  id = user_id as "id_equals_user_id",
  display_name,
  full_name
FROM user_profiles
LIMIT 5;
```

### 4. التحقق من RLS Policies:
```sql
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('user_profiles', 'products', 'stores')
ORDER BY tablename, policyname;
```

---

## ✅ النتيجة المتوقعة

بعد تنفيذ Migration:
- ✅ جدول `user_profiles` يحتوي على `user_id` و `full_name`
- ✅ جميع الصفوف: `user_id = id`
- ✅ RLS Policies تستخدم `user_id = auth.uid()`
- ✅ يمكن للتجار إضافة منتجات بدون خطأ FORBIDDEN

---

**تاريخ الإصلاح:** 2025-01-06  
**الحالة:** ✅ جاهز للتنفيذ

