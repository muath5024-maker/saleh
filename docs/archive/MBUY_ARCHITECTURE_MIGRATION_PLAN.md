# خطة ترقية MBUY إلى المعمارية الجديدة

## الهدف
ترقية المشروع بالكامل بحيث:
- Flutter لا يتعامل مع Supabase Auth أو DB مباشرة
- كل شيء يمر عبر Cloudflare Worker كـ API وحيد
- Worker يحتوي على نظام Auth مخصص (mbuy_users / mbuy_sessions + JWT)
- Supabase يعمل فقط كقاعدة بيانات، يتم الوصول لها من Worker باستخدام SERVICE_ROLE_KEY

---

## الجزء الأول: التحقق من جداول Auth في Supabase ✅

### المطلوب:
- ✅ Migration موجودة: `mbuy-backend/migrations/20250107000001_create_mbuy_auth_tables.sql`
- ✅ الجداول المطلوبة موجودة:
  - `public.mbuy_users` (id, email, password_hash, full_name, phone, is_active, created_at, updated_at)
  - `public.mbuy_sessions` (id, user_id, token_hash, user_agent, ip_address, created_at, expires_at, is_active)
- ✅ RLS Policies مفعلة مع Service Role access

---

## الجزء الثاني: تحديث Cloudflare Worker

### 1. Secrets المطلوبة ✅
- ✅ SUPABASE_URL
- ✅ SUPABASE_SERVICE_ROLE_KEY
- ✅ JWT_SECRET
- ✅ PASSWORD_HASH_ROUNDS (default: 100000)

### 2. Supabase Client Helper ✅
- ✅ موجود في `mbuy-worker/src/utils/supabase.ts`
- ✅ يستخدم SERVICE_ROLE_KEY
- ✅ لا يعتمد على مفاتيح من Flutter

### 3. Auth Endpoints ✅
- ✅ POST /auth/register - موجود ويعمل
- ✅ POST /auth/login - موجود ويعمل
- ✅ GET /auth/me - موجود ومحمي بـ middleware
- ✅ POST /auth/logout - موجود ومحمي

### 4. Middleware للـ JWT ✅
- ✅ `mbuyAuthMiddleware` موجود في `mbuy-worker/src/middleware/authMiddleware.ts`
- ✅ يُستخدم في جميع المسارات التي تبدأ بـ `/secure/*`
- ✅ يتحقق من JWT ويستخرج userId

### 5. /secure/products ✅
- ✅ يستخرج userId من JWT
- ✅ ينظف body من الحقول الحساسة (id, store_id, user_id, owner_id)
- ⚠️ حالياً يستدعي Edge Function - يجب تحديثه لاستخدام Supabase مباشرة

### 6. JSON Response Format
- ⚠️ بعض الـ responses لا تستخدم format موحد
- ✅ يجب أن تكون جميع الـ responses: `{ "ok": true/false, "code"?: string, "message"?: string, "data"?: any }`
- ✅ Content-Type: `application/json; charset=utf-8`

---

## الجزء الثالث: تحديث Flutter

### 1. إزالة استخدامات Supabase Auth ✅
- ✅ لا يوجد استخدام لـ `supabase.auth.signInWithPassword`
- ✅ لا يوجد استخدام لـ `supabase.auth.signUp`
- ✅ لا يوجد استخدام لـ `supabase.auth.getSession`
- ✅ لا يوجد استخدام لـ `supabase.auth.onAuthStateChange`
- ✅ لا يوجد استخدام لـ `supabase.auth.signOut`

### 2. AuthRepository / AuthService ✅
- ✅ `AuthRepository` موجود ويعمل مع Worker
- ✅ `login()` - يرسل POST إلى `/auth/login`
- ✅ `register()` - يرسل POST إلى `/auth/register`
- ✅ `me()` - يرسل GET إلى `/auth/me`
- ✅ يحفظ token في `flutter_secure_storage`

### 3. RootWidget ✅
- ✅ يقرأ token من secure storage
- ✅ يستدعي `AuthRepository.verifyAndLoadUser()`
- ⚠️ لا يزال يستخدم `supabaseClient.from('user_profiles')` - يجب استبداله بـ API call

### 4. Auth Screen ✅
- ✅ يستخدم `AuthRepository.login()` و `AuthRepository.register()`
- ✅ ينتقل إلى الصفحة الرئيسية بعد تسجيل الدخول

### 5. ApiService ✅
- ✅ يضيف JWT تلقائياً في الهيدر `Authorization: Bearer <token>`
- ✅ يستخدم Worker endpoints فقط

### 6. استخدامات Supabase المباشرة ⚠️
- ⚠️ `root_widget.dart` - يستخدم `supabaseClient.from('user_profiles')`
- ⚠️ `merchant_profile_tab.dart` - يستخدم `supabaseClient.from('user_profiles')`
- ⚠️ `profile_screen.dart` - يستخدم `supabaseClient.from('user_profiles')`
- ⚠️ `order_status_service.dart` - يستخدم `supabaseClient` مباشرة
- ⚠️ `order_service.dart` - يستخدم `supabaseClient` مباشرة
- ⚠️ `merchant_points_service.dart` - يستخدم `supabaseClient` مباشرة
- ⚠️ `coupon_service.dart` - يستخدم `supabaseClient` مباشرة
- ⚠️ وغيرها...

---

## الجزء الرابع: التغييرات المطلوبة

### Worker Changes:
1. ✅ تحديث `/secure/products` لاستخدام Supabase مباشرة بدلاً من Edge Function
2. ✅ ضمان أن جميع الـ responses تستخدم JSON format موحد
3. ✅ إضافة Content-Type header في جميع الـ responses

### Flutter Changes:
1. ⚠️ استبدال جميع استخدامات `supabaseClient.from()` بـ API calls إلى Worker
2. ⚠️ إنشاء API endpoints في Worker للعمليات المطلوبة
3. ⚠️ تحديث جميع الـ services لاستخدام ApiService بدلاً من Supabase مباشرة

---

## الأولويات:
1. **عالية**: تحديث Worker `/secure/products` لاستخدام Supabase مباشرة
2. **عالية**: استبدال استخدامات Supabase في `root_widget.dart`
3. **متوسطة**: استبدال استخدامات Supabase في profile screens
4. **منخفضة**: استبدال استخدامات Supabase في services أخرى

---

## ملاحظات:
- يجب التأكد من أن جميع الـ API endpoints في Worker تستخدم Supabase Client Helper
- يجب التأكد من أن جميع الـ responses تستخدم JSON format موحد
- يجب التأكد من أن Flutter لا يرسل user_id, owner_id, store_id في body

