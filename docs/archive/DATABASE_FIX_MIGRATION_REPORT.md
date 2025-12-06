# 🔧 تقرير Migration: فحص وإصلاح بنية البيانات

## 📋 ملخص

تم إنشاء ملف migration جديد يفحص ويُصلح بنية البيانات لضمان التوافق مع منطق `product_create` الجديد.

---

## 📁 الملف الجديد

**الموقع:** `mbuy-backend/migrations/20250106000006_fix_user_profiles_and_stores.sql`

---

## 🔗 العلاقات المتوقعة

### السلسلة الكاملة:
```
auth.users.id (jwt.sub)
    ↓
user_profiles.id = auth.users.id (FK: REFERENCES auth.users(id))
    ↓
stores.owner_id = user_profiles.id (FK: REFERENCES user_profiles(id))
    ↓
products.store_id = stores.id (FK: REFERENCES stores(id))
```

### الجداول:

#### 1. **auth.users**
- `id` (UUID, PK)

#### 2. **user_profiles**
- `id` (UUID, PK, FK → `auth.users.id`)
- `role` (TEXT) - يجب أن يكون `'merchant'` للتجار
- `display_name`, `email`, `phone`, `avatar_url`
- **لا يوجد:** `user_id` أو `full_name` (تجاهلها كما طلبت)

#### 3. **stores**
- `id` (UUID, PK)
- `owner_id` (UUID, FK → `user_profiles.id`)
- `is_active` (BOOLEAN) - يجب أن يكون `true` للمتاجر النشطة
- `status` (TEXT) - `'active'`, `'inactive'`, `'suspended'`
- `name`, `description`, وغيرها

#### 4. **products**
- `id` (UUID, PK)
- `store_id` (UUID, FK → `stores.id`)
- `name`, `description`, `price`, `stock`
- وغيرها

---

## 📝 محتوى Migration Script

### القسم A: فحص الوضع الحالي (SELECT فقط)

1. **فحص بنية الجداول:**
   - أنواع البيانات للأعمدة الأساسية
   - وجود `is_active` في `stores`

2. **فحص البيانات:**
   - المستخدمون في `auth.users` بدون `user_profiles`
   - الـ Profiles بدون مستخدم في `auth.users`
   - المتاجر بدون `owner` في `user_profiles`
   - توزيع قيم `role` في `user_profiles`
   - العلاقات بين المتاجر ومالكيها
   - العلاقات بين المنتجات والمتاجر
   - Foreign Keys الحالية

### القسم B: أوامر إصلاح مقترحة (معلقة)

جميع أوامر INSERT/UPDATE/DELETE معلقة بالتعليقات وتحتاج إلى:
- مراجعة النتائج من القسم A
- تعديل قيم PLACEHOLDER
- فك التعليقات خطوة بخطوة

**الأوامر المقترحة:**
1. إضافة `is_active` إلى `stores` إن لم يكن موجوداً
2. إنشاء `user_profiles` للمستخدمين المفقودين
3. تصحيح `owner_id` في `stores`
4. ضبط `role = 'merchant'` للتجار
5. ضبط `is_active = true` للمتاجر النشطة
6. إزالة المتاجر اليتيمة (اختياري)
7. إزالة المنتجات اليتيمة (اختياري)

### القسم C: ملاحظات على RLS

- فحص RLS Policies الحالية
- ملاحظات على RLS المتوقعة
- التحقق من تفعيل RLS
- التحقق من Foreign Keys

---

## 🎯 كيفية استخدام Migration Script

### الخطوة 1: تشغيل فحص الوضع الحالي

1. افتح Supabase SQL Editor:
   - https://supabase.com/dashboard/project/sirqidofuvphqcxqchyc/sql/new

2. انسخ **القسم A فقط** من الملف:
   - من بداية الملف حتى نهاية القسم A

3. الصق واضغط **Run**

4. راجع النتائج:
   - المستخدمون بدون profiles
   - المتاجر بدون owners
   - توزيع الأدوار
   - العلاقات

### الخطوة 2: مراجعة أوامر الإصلاح

1. افتح الملف:
   - `mbuy-backend/migrations/20250106000006_fix_user_profiles_and_stores.sql`

2. اذهب إلى **القسم B**

3. راجع كل أمر معلق:
   - ما يفعله
   - القيم المطلوبة (PLACEHOLDER)
   - التأثير على البيانات

### الخطوة 3: تنفيذ الإصلاحات (خطوة بخطوة)

#### مثال 1: إضافة `is_active` إلى `stores`
```sql
-- إذا كان العمود غير موجود:
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
    AND table_name = 'stores' 
    AND column_name = 'is_active'
  ) THEN
    ALTER TABLE public.stores 
      ADD COLUMN is_active BOOLEAN DEFAULT true;
    
    UPDATE public.stores 
    SET is_active = true 
    WHERE is_active IS NULL;
  END IF;
END $$;
```

#### مثال 2: إنشاء profiles للمستخدمين المفقودين
```sql
-- ⚠️ عدّل قائمة merchant_user_ids أولاً!
DO $$
DECLARE
  merchant_user_ids UUID[] := ARRAY[
    'af5ce06e-c2e8-4de0-ad74-c432ff...'::UUID, -- ⚠️ ضع UUID الحقيقي
    -- أضف المزيد
  ];
  auth_user RECORD;
BEGIN
  FOR auth_user IN 
    SELECT au.id, au.email, au.raw_user_meta_data
    FROM auth.users au
    LEFT JOIN public.user_profiles up ON au.id = up.id
    WHERE up.id IS NULL
  LOOP
    INSERT INTO public.user_profiles (
      id, role, display_name, email, created_at, updated_at
    ) VALUES (
      auth_user.id,
      CASE 
        WHEN auth_user.id = ANY(merchant_user_ids) THEN 'merchant'
        ELSE 'customer'
      END,
      COALESCE(
        auth_user.raw_user_meta_data->>'display_name',
        split_part(auth_user.email, '@', 1),
        'User'
      ),
      auth_user.email,
      NOW(),
      NOW()
    )
    ON CONFLICT (id) DO NOTHING;
  END LOOP;
END $$;
```

#### مثال 3: ضبط role للتجار
```sql
-- ⚠️ عدّل قائمة merchant_profile_ids أولاً!
DO $$
DECLARE
  merchant_profile_ids UUID[] := ARRAY[
    'af5ce06e-c2e8-4de0-ad74-c432ff...'::UUID, -- ⚠️ ضع UUID من user_profiles.id
  ];
BEGIN
  UPDATE public.user_profiles
  SET role = 'merchant', updated_at = NOW()
  WHERE id = ANY(merchant_profile_ids) AND role != 'merchant';
END $$;
```

---

## ✅ النتيجة المتوقعة بعد الإصلاحات

### العلاقات الصحيحة:
- ✅ كل مستخدم في `auth.users` له profile في `user_profiles` (id = id)
- ✅ كل متجر في `stores` له owner في `user_profiles` (owner_id = id)
- ✅ كل منتج في `products` له store في `stores` (store_id = id)

### البيانات الصحيحة:
- ✅ التجار لديهم `role = 'merchant'` في `user_profiles`
- ✅ المتاجر النشطة لديها `is_active = true` و `status = 'active'`

---

## 🔒 RLS Policies المتوقعة

### user_profiles:
```sql
SELECT: USING (id = auth.uid())
```
- المالك فقط يمكنه قراءة ملفه

### stores:
```sql
SELECT: USING (auth.uid() = owner_id)
INSERT/UPDATE/DELETE: USING (auth.uid() = owner_id)
```
- المالك فقط يمكنه إدارة متجره

### products:
```sql
INSERT/UPDATE/DELETE: 
WITH CHECK (EXISTS (
  SELECT 1 FROM stores 
  WHERE stores.id = products.store_id 
  AND stores.owner_id = auth.uid()
))
```
- فقط مالك المتجر يمكنه إدارة منتجات متجره

---

## ⚠️ تحذيرات مهمة

1. **لا تنفّذ جميع أوامر B دفعة واحدة**
   - راجع كل أمر بعناية
   - نفّذ خطوة بخطوة

2. **عدّل قيم PLACEHOLDER**
   - لا تترك `PLACEHOLDER_USER_ID` كما هو
   - استخدم UUIDs الحقيقية

3. **احتفظ بنسخة احتياطية**
   - قبل تنفيذ أي UPDATE/DELETE

4. **اختبر بعد كل خطوة**
   - تأكد من النتيجة
   - ثم انتقل للخطوة التالية

---

## 📊 ملخص الخطوات

| الخطوة | الوصف | الحالة |
|--------|-------|--------|
| 1 | تشغيل فحص الوضع (القسم A) | ⏳ في الانتظار |
| 2 | مراجعة نتائج الفحص | ⏳ بعد الخطوة 1 |
| 3 | تعديل قيم PLACEHOLDER | ⏳ قبل التنفيذ |
| 4 | تنفيذ أوامر الإصلاح | ⏳ خطوة بخطوة |
| 5 | التحقق من النتيجة | ⏳ بعد كل خطوة |

---

**Migration Script جاهز للاستخدام!** 🚀

