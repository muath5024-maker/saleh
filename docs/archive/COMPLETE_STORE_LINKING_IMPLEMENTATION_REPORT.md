# 📋 تقرير تنفيذ كامل - ربط التاجر مع متجره ومنتجاته

## ✅ الملخص التنفيذي

تم تنفيذ جميع التعديلات المطلوبة لضبط ربط التاجر مع متجره ومنتجاته وفق السكيما التالية:
- `auth.users.id = user_profiles.id = stores.owner_id`
- `stores.id = products.store_id`

---

## 📂 أولاً: Backend – تعديل مسار `/secure/merchant/store`

### ✅ الملف المعدل:
**`C:\muath\mbuy-worker\src\index.ts`** (السطر 632-651)

### ✅ التعديلات المنفذة:

1. **تم تعديل الـ endpoint لاستعلام مباشر من Supabase:**
   ```typescript
   app.get('/secure/merchant/store', async (c) => {
     const userId = c.get('userId'); // auth.users.id (from JWT)
     
     // Query Supabase directly: SELECT id, owner_id, name, status, is_active 
     // FROM stores WHERE owner_id = userId
     const response = await fetch(
       `${c.env.SUPABASE_URL}/rest/v1/stores?owner_id=eq.${userId}&select=id,owner_id,name,status,is_active&limit=1`,
       {
         headers: {
           'apikey': c.env.SUPABASE_ANON_KEY,
           'Authorization': `Bearer ${c.env.SUPABASE_ANON_KEY}`,
           'Content-Type': 'application/json',
         },
       }
     );
   ```

2. **السلوك المنفذ:**
   - ✅ استخراج `userId` من JWT (auth.users.id)
   - ✅ استعلام مباشر من Supabase: `WHERE owner_id = userId`
   - ✅ إذا حدث error → `{ ok: false, error: error.message }` مع status 500
   - ✅ إذا لم يوجد متجر → `{ ok: true, data: null }` مع status 200
   - ✅ إذا وُجد متجر → `{ ok: true, data: { id, owner_id, name, status, is_active } }` مع status 200
   - ✅ إضافة Content-Type header: `application/json`

### ✅ تعديل Edge Function:
**`C:\muath\mbuy-backend\functions\merchant_store\index.ts`**

- تم تعديل Edge Function لتستخدم السكيما الصحيحة مباشرة:
  - `user.id = user_profiles.id = stores.owner_id`
  - الاستعلام مباشر بدون الحاجة لجلب profile أولاً

---

## 📂 ثانياً: Flutter – StoreSession باستخدام Provider

### ✅ الملفات:

#### 1. **إنشاء StoreSession:**
**`C:\muath\saleh\lib\core\session\store_session.dart`**

```dart
class StoreSession extends ChangeNotifier {
  String? _storeId;

  String? get storeId => _storeId;
  bool get hasStore => _storeId != null && _storeId!.isNotEmpty;

  void setStoreId(String id) {
    _storeId = id;
    notifyListeners();
  }

  void clear() {
    _storeId = null;
    notifyListeners();
  }
}
```

#### 2. **تسجيل StoreSession في Provider:**
**`C:\muath\saleh\lib\main.dart`** (السطر 295)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<StoreSession>(create: (_) => StoreSession()),
  ],
  child: MaterialApp(...),
)
```

- ✅ تم التسجيل قبل `MaterialApp`
- ✅ Provider متاح في جميع الشاشات

---

## 📂 ثالثاً: Flutter – جلب المتجر بعد تسجيل الدخول

### ✅ الملفات المعدلة:

#### 1. **جلب المتجر بعد تسجيل الدخول:**
**`C:\muath\saleh\lib\core\root_widget.dart`** (السطر 176-210)

- ✅ دالة `_loadMerchantStoreId()`:
  - تُستدعى تلقائياً عند تسجيل الدخول للتاجر
  - تستخدم `/secure/merchant/store`
  - تحفظ `store_id` في `StoreSession`
  - تحقق من وجود `store_id` قبل الجلب لتوفير الاستدعاءات

#### 2. **جلب المتجر عند الدخول لشاشة التاجر:**
**`C:\muath\saleh\lib\features\merchant\presentation\screens\merchant_home_screen.dart`** (السطر 43-77)

- ✅ دالة `_loadStoreId()` في `initState()`:
  - تُستدعى عند الدخول لشاشة التاجر الرئيسية
  - تحقق من وجود `store_id` قبل الجلب
  - تحفظ `store_id` في `StoreSession`

### ✅ منطق التعامل مع الرد:

```dart
final result = await ApiService.get('/secure/merchant/store');

if (result['ok'] == true && result['data'] != null) {
  final store = result['data'] as Map<String, dynamic>;
  final storeId = store['id'] as String?;
  
  if (storeId != null && storeId.isNotEmpty) {
    context.read<StoreSession>().setStoreId(storeId);
  } else {
    context.read<StoreSession>().clear();
  }
} else {
  context.read<StoreSession>().clear();
}
```

---

## 📂 رابعاً: Flutter – تعديل منطق إضافة المنتج

### ✅ الملف المعدل:
**`C:\muath\saleh\lib\features\merchant\presentation\screens\merchant_products_screen.dart`** (السطر 237-298)

### ✅ التعديلات المنفذة:

1. **الحصول على `storeId` من StoreSession:**
   ```dart
   final storeSession = context.read<StoreSession>();
   final storeId = storeSession.storeId;
   ```

2. **التحقق من وجود متجر:**
   ```dart
   if (storeId == null || storeId.isEmpty) {
     throw Exception(
       'لم يتم العثور على متجر لهذا الحساب. يرجى إنشاء متجر أولاً من قائمة "إعداد المتجر"',
     );
   }
   ```

3. **استخدام `store_id` في body الطلب:**
   ```dart
   final productData = {
     'store_id': storeId, // استخدام store_id من Provider
     'name': _nameController.text.trim(),
     'description': _descriptionController.text.trim(),
     'price': double.parse(_priceController.text),
     'stock': int.parse(_stockController.text),
     'status': 'active',
     'is_active': true,
   };
   ```

### ✅ تعديل Edge Function:
**`C:\muath\mbuy-backend\functions\product_create\index.ts`**

- ✅ تم تعديل Edge Function لاستقبال `store_id` (اختياري)
- ✅ إذا تم إرسال `store_id`، يتم التحقق من أنه يخص المستخدم
- ✅ إذا لم يتم إرسال `store_id`، يتم جلب المتجر تلقائياً من `user_id`
- ✅ التحقق من الملكية: `WHERE id = store_id AND owner_id = user_id`

---

## 📂 خامساً: التأكد من استخدام `store_id` الصحيح

### ✅ الملفات التي تستخدم StoreSession:

1. **`merchant_products_screen.dart`**:
   - ✅ إضافة منتج: يستخدم `context.read<StoreSession>().storeId`

2. **`merchant_orders_screen.dart`**:
   - ✅ جلب الطلبات: يستخدم `context.read<StoreSession>().storeId`

3. **`merchant_store_setup_screen.dart`**:
   - ✅ حفظ `store_id` في `StoreSession` عند إنشاء/جلب المتجر
   - ✅ استخدام `StoreSession.storeId` في `_boostStore()` و `_highlightStoreOnMap()`

### ✅ تنظيف `store_id` الثابت:

- ✅ **لا يوجد `store_id` ثابت في الكود الفعلي**
- ✅ البيانات الوهمية فقط في `dummy_data.dart` (للاستخدام في الاختبار فقط)
- ✅ جميع العمليات تستخدم `context.read<StoreSession>().storeId`

### ✅ شاشة قائمة منتجات التاجر:

- ✅ تستخدم endpoint `/secure/merchant/products`
- ✅ لا تحتاج تمرير `store_id` من Flutter (الـ backend يجلبه من JWT)
- ✅ Worker يجلب المنتجات بناءً على `owner_id` من JWT

---

## 📊 سادساً: تقرير الملفات المعدلة

### 🔧 Backend (Cloudflare Worker):

| الملف | التعديل | السطر |
|------|---------|-------|
| `mbuy-worker/src/index.ts` | تعديل endpoint `/secure/merchant/store` لاستعلام مباشر | 632-651 |
| `mbuy-backend/functions/merchant_store/index.ts` | تعديل Edge Function لاستخدام السكيما الصحيحة | كامل الملف |
| `mbuy-backend/functions/product_create/index.ts` | دعم استقبال `store_id` والتحقق منه | 13-93 |

### 📱 Flutter:

| الملف | التعديل | الوصف |
|------|---------|-------|
| `lib/core/session/store_session.dart` | ✅ موجود | StoreSession Provider |
| `lib/main.dart` | ✅ موجود | تسجيل StoreSession في MultiProvider |
| `lib/core/root_widget.dart` | ✅ موجود | جلب `store_id` بعد تسجيل الدخول |
| `lib/features/merchant/presentation/screens/merchant_home_screen.dart` | ✅ موجود | جلب `store_id` عند الدخول لشاشة التاجر |
| `lib/features/merchant/presentation/screens/merchant_products_screen.dart` | ✅ موجود | استخدام `StoreSession.storeId` في إضافة المنتج |
| `lib/features/merchant/presentation/screens/merchant_orders_screen.dart` | ✅ موجود | استخدام `StoreSession.storeId` في جلب الطلبات |
| `lib/features/merchant/presentation/screens/merchant_store_setup_screen.dart` | ✅ موجود | حفظ `store_id` في `StoreSession` |

---

## ✅ السابع: تأكيد السلوك النهائي

### 1️⃣ حساب لديه متجر ومنتجات:

**السلوك المتوقع:**
- ✅ بعد تسجيل الدخول، يتم جلب `store_id` تلقائياً وحفظه في `StoreSession`
- ✅ عند فتح شاشة المنتجات، تظهر جميع المنتجات بدون أخطاء
- ✅ يمكن إضافة منتج جديد بنجاح باستخدام `store_id` من `StoreSession`
- ✅ لا توجد أخطاء حمراء

### 2️⃣ حساب لديه متجر بدون منتجات:

**السلوك المتوقع:**
- ✅ بعد تسجيل الدخول، يتم جلب `store_id` وحفظه في `StoreSession`
- ✅ عند فتح شاشة المنتجات، تظهر "لا توجد منتجات" بدون أي خطأ أحمر
- ✅ يمكن إضافة منتج جديد بنجاح

### 3️⃣ حساب لا يمتلك متجر:

**السلوك المتوقع:**
- ✅ بعد تسجيل الدخول، `StoreSession.hasStore` يكون `false`
- ✅ عند فتح شاشة المنتجات، تظهر "لا توجد منتجات"
- ✅ عند محاولة إضافة منتج، تظهر رسالة واضحة:
  ```
  "لم يتم العثور على متجر لهذا الحساب. يرجى إنشاء متجر أولاً من قائمة 'إعداد المتجر'"
  ```
- ✅ لا توجد أخطاء حمراء، فقط رسالة واضحة للمستخدم

---

## 🔗 كيفية ربط Provider مع الشاشات

### 1. الوصول إلى StoreSession:

```dart
// جلب store_id
final storeSession = context.read<StoreSession>();
final storeId = storeSession.storeId;

// التحقق من وجود متجر
if (storeSession.hasStore) {
  // العمل مع المتجر
}

// حفظ store_id
storeSession.setStoreId(storeId);

// مسح store_id
storeSession.clear();
```

### 2. الاستخدام في الشاشات:

- ✅ **`merchant_home_screen.dart`**: جلب `store_id` في `initState()`
- ✅ **`merchant_products_screen.dart`**: استخدام `store_id` عند إضافة منتج
- ✅ **`merchant_orders_screen.dart`**: استخدام `store_id` عند جلب الطلبات
- ✅ **`merchant_store_setup_screen.dart`**: حفظ `store_id` عند إنشاء/جلب المتجر

---

## 📌 ملاحظات مهمة

### 1. **السكيما:**
- ✅ `auth.users.id = user_profiles.id = stores.owner_id`
- ✅ `stores.id = products.store_id`
- ✅ جميع الاستعلامات تستخدم السكيما الصحيحة

### 2. **الأمان:**
- ✅ جميع العمليات تتطلب JWT
- ✅ Worker يتحقق من `owner_id` من JWT
- ✅ Edge Function تتحقق من أن `store_id` يخص المستخدم

### 3. **الأداء:**
- ✅ لا يوجد جلب متكرر لـ `store_id` - يتم التحقق من وجوده أولاً
- ✅ `store_id` محفوظ في `StoreSession` لتجنب الاستدعاءات المتكررة

### 4. **البيانات الوهمية:**
- ⚠️ `dummy_data.dart` يحتوي على `storeId: '1'` لكن هذا للاختبار فقط
- ✅ لا تؤثر البيانات الوهمية على الكود الفعلي

---

## 🎯 النتيجة النهائية

### ✅ تم تنفيذ جميع الخطوات بنجاح:

1. ✅ Worker endpoint `/secure/merchant/store` يستعلم مباشرة من Supabase
2. ✅ StoreSession Provider موجود ومسجل
3. ✅ جلب `store_id` بعد تسجيل الدخول وعند الدخول لشاشة التاجر
4. ✅ استخدام `StoreSession.storeId` في إضافة المنتجات
5. ✅ استخدام `StoreSession.storeId` في جميع العمليات
6. ✅ لا يوجد `store_id` ثابت في الكود الفعلي
7. ✅ Edge Functions محدثة لاستخدام السكيما الصحيحة

---

## 📅 معلومات التنفيذ

**تاريخ التنفيذ:** يناير 2025  
**الحالة:** ✅ مكتمل وجاهز للاختبار  
**الإصدار:** 1.0.0

---

## 🧪 خطوات الاختبار الموصى بها

1. **اختبار جلب المتجر:**
   - تسجيل الدخول كتاجر لديه متجر
   - التحقق من أن `StoreSession.storeId` تم تعبئته
   - فتح شاشة التاجر والتحقق من عدم وجود أخطاء

2. **اختبار إضافة منتج:**
   - فتح شاشة المنتجات
   - إضافة منتج جديد
   - التحقق من أن المنتج تم إضافته بنجاح

3. **اختبار حساب بدون متجر:**
   - تسجيل الدخول كتاجر بدون متجر
   - محاولة إضافة منتج
   - التحقق من ظهور الرسالة الصحيحة

---

**تم تنفيذ جميع المتطلبات بنجاح! ✅**

