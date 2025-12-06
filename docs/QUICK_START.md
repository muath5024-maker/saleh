# 🚀 البدء السريع - MBUY

<div dir="rtl">

## 📋 المتطلبات

- **Flutter**: SDK ^3.10.0
- **Node.js**: v18+ (لـ Worker)
- **Supabase**: حساب نشط
- **Cloudflare**: حساب مع Workers

---

## ⚡ التثبيت السريع

### 1. Flutter App

```bash
# استنساخ المشروع
git clone <repository-url>
cd saleh

# تثبيت Dependencies
flutter pub get

# تشغيل التطبيق
flutter run
```

### 2. Cloudflare Worker

```bash
cd mbuy-worker

# تثبيت Dependencies
npm install

# تشغيل محلي
npm run dev
```

### 3. Supabase Database

```bash
cd mbuy-backend

# تطبيق migrations
# استخدم Supabase Dashboard أو CLI
```

---

## 🔐 الإعداد

### Flutter Environment

إنشاء ملف `.env` في `saleh/`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
WORKER_URL=https://your-worker.workers.dev
```

### Worker Secrets

إعداد Secrets في Cloudflare:

```bash
cd mbuy-worker

# إعداد Secrets
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_SERVICE_ROLE_KEY
wrangler secret put JWT_SECRET
wrangler secret put PASSWORD_HASH_ROUNDS
```

**أو استخدام PowerShell script:**

```powershell
cd mbuy-worker
.\setup_secrets.ps1
```

### Database Setup

1. اذهب إلى Supabase Dashboard
2. تطبيق Migration: `20250107000001_create_mbuy_auth_tables.sql`
3. التحقق من الجداول:
   - `mbuy_users`
   - `mbuy_sessions`
   - `user_profiles`
   - `stores`
   - `products`
   - `orders`

---

## ✅ التحقق من الإعداد

### Flutter

```bash
cd saleh
flutter doctor
flutter analyze
```

### Worker

```bash
cd mbuy-worker
npm run dev
# افتح http://localhost:8787
```

### Database

```bash
# التحقق من الجداول في Supabase Dashboard
```

---

## 🧪 الاختبار السريع

### 1. تسجيل مستخدم جديد

```bash
curl -X POST https://your-worker.workers.dev/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "full_name": "Test User"
  }'
```

### 2. تسجيل الدخول

```bash
curl -X POST https://your-worker.workers.dev/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 3. جلب المستخدم الحالي

```bash
curl -X GET https://your-worker.workers.dev/auth/me \
  -H "Authorization: Bearer <token>"
```

---

## 📱 تشغيل التطبيق

### Android

```bash
flutter run -d android
```

### iOS

```bash
flutter run -d ios
```

### Web

```bash
flutter run -d chrome
```

---

## 🐛 Troubleshooting

### مشكلة: خطأ في الاتصال بالخادم

**الحل:**
1. تحقق من Worker URL في `.env`
2. تحقق من أن Worker يعمل: `npm run dev`
3. تحقق من CORS settings في Worker

### مشكلة: خطأ في المصادقة

**الحل:**
1. تحقق من JWT_SECRET في Worker secrets
2. تحقق من token expiration
3. جرب تسجيل الدخول مرة أخرى

### مشكلة: خطأ في قاعدة البيانات

**الحل:**
1. تحقق من SERVICE_ROLE_KEY في Worker secrets
2. تحقق من RLS policies في Supabase
3. تحقق من تطبيق migrations

---

## 📚 الخطوات التالية

1. ✅ إكمال الإعداد
2. ✅ قراءة [دليل API](./API.md)
3. ✅ قراءة [البنية المعمارية](./ARCHITECTURE.md)
4. ✅ البدء بالتطوير

---

</div>

