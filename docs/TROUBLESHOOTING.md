# 🐛 Troubleshooting Guide - MBUY

<div dir="rtl">

## 🔍 مشاكل شائعة وحلولها

---

## 🔐 مشاكل المصادقة

### المشكلة: خطأ "UNAUTHORIZED"

**الأسباب المحتملة:**
- Token مفقود أو منتهي الصلاحية
- JWT_SECRET غير صحيح
- Token غير صالح

**الحل:**
1. تحقق من JWT_SECRET في Worker secrets
2. جرب تسجيل الدخول مرة أخرى
3. تحقق من token expiration (30 يوم)

```bash
# Test token
curl -X GET https://your-worker.workers.dev/auth/me \
  -H "Authorization: Bearer <token>"
```

---

### المشكلة: خطأ "INVALID_CREDENTIALS"

**الأسباب المحتملة:**
- البريد الإلكتروني أو كلمة المرور غير صحيحة
- المستخدم غير موجود
- كلمة المرور غير صحيحة

**الحل:**
1. تحقق من بيانات تسجيل الدخول
2. جرب إنشاء حساب جديد
3. تحقق من password_hash في Database

---

## 🌐 مشاكل الاتصال

### المشكلة: "خطأ في الاتصال بالخادم"

**الأسباب المحتملة:**
- Worker URL غير صحيح
- Worker غير نشط
- مشكلة في الشبكة

**الحل:**
1. تحقق من Worker URL في `.env`
2. تحقق من أن Worker يعمل: `npm run dev`
3. تحقق من CORS settings في Worker

```bash
# Test Worker
curl https://your-worker.workers.dev/
```

---

### المشكلة: "CORS Error"

**الأسباب المحتملة:**
- CORS settings غير صحيحة في Worker
- Origin غير مسموح

**الحل:**
1. تحقق من CORS middleware في Worker
2. أضف origin إلى allowed origins
3. تحقق من headers في request

---

## 🗄️ مشاكل قاعدة البيانات

### المشكلة: "STORE_NOT_FOUND"

**الأسباب المحتملة:**
- المتجر غير موجود
- owner_id غير صحيح
- RLS policy يمنع الوصول

**الحل:**
1. تحقق من وجود المتجر في Database
2. تحقق من owner_id في stores table
3. تحقق من RLS policies

```sql
-- Check store
SELECT * FROM stores WHERE owner_id = 'user_id';
```

---

### المشكلة: "ORDER_NOT_FOUND"

**الأسباب المحتملة:**
- الطلب غير موجود
- user_id غير صحيح
- RLS policy يمنع الوصول

**الحل:**
1. تحقق من وجود الطلب في Database
2. تحقق من customer_id في orders table
3. تحقق من RLS policies

---

## 📦 مشاكل المنتجات

### المشكلة: "PRODUCT_NOT_FOUND"

**الأسباب المحتملة:**
- المنتج غير موجود
- store_id غير صحيح
- RLS policy يمنع الوصول

**الحل:**
1. تحقق من وجود المنتج في Database
2. تحقق من store_id في products table
3. تحقق من RLS policies

---

## 🔧 Debugging Tips

### 1. Enable Debug Logging

**Flutter:**
```dart
// في main.dart
debugPrint('Debug message');
logger.debug('Debug message', tag: 'App');
```

**Worker:**
```typescript
console.log('[Worker] Debug message');
console.error('[Worker] Error:', error);
```

### 2. Check Network Requests

**Flutter:**
- استخدام DevTools Network tab
- استخدام logger في ApiService

**Worker:**
- استخدام Cloudflare Dashboard → Logs
- استخدام `console.log` في Worker

### 3. Check Database

```sql
-- Check users
SELECT * FROM mbuy_users WHERE email = 'test@example.com';

-- Check sessions
SELECT * FROM mbuy_sessions WHERE user_id = 'user_id';

-- Check orders
SELECT * FROM orders WHERE customer_id = 'user_id';
```

---

## 📞 الحصول على المساعدة

### Logs

**Flutter:**
```bash
flutter logs
```

**Worker:**
- Cloudflare Dashboard → Workers → Logs

**Database:**
- Supabase Dashboard → Logs

### Error Codes

راجع [API Documentation](./API.md) للحصول على قائمة كاملة بـ error codes.

---

</div>

