# ⚙️ دليل Environment Variables - MBUY

<div dir="rtl">

## 📋 نظرة عامة

هذا الدليل يوضح جميع Environment Variables المطلوبة لمشروع MBUY.

---

## 📱 Flutter (.env)

### الموقع: `saleh/.env`

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here

# Cloudflare Worker
WORKER_URL=https://your-worker.workers.dev

# Firebase (اختياري)
FIREBASE_API_KEY=your_firebase_key
FIREBASE_PROJECT_ID=your_project_id
```

### كيفية الحصول على القيم:

#### Supabase URL & ANON_KEY:
1. اذهب إلى [Supabase Dashboard](https://app.supabase.com)
2. اختر مشروعك
3. Settings → API
4. انسخ `URL` و `anon public key`

#### Worker URL:
1. اذهب إلى [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Workers & Pages → Your Worker
3. انسخ Worker URL

---

## ☁️ Cloudflare Worker (Secrets)

### الموقع: Cloudflare Dashboard → Workers → Secrets

```bash
# إعداد Secrets
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_SERVICE_ROLE_KEY
wrangler secret put JWT_SECRET
wrangler secret put PASSWORD_HASH_ROUNDS
```

### القيم المطلوبة:

#### SUPABASE_URL
```
https://your-project.supabase.co
```

#### SUPABASE_SERVICE_ROLE_KEY
1. اذهب إلى Supabase Dashboard
2. Settings → API
3. انسخ `service_role key` (⚠️ حساس - لا تشاركه!)

#### JWT_SECRET
```bash
# Generate random secret (32+ characters)
openssl rand -base64 32
```

#### PASSWORD_HASH_ROUNDS
```
100000
```

---

## 🗄️ Supabase Database

### Environment Variables (في Supabase Dashboard)

لا حاجة لـ environment variables إضافية - Supabase يديرها تلقائياً.

---

## ✅ التحقق من الإعداد

### Flutter

```bash
cd saleh

# تحقق من .env file
cat .env

# تحقق من أن القيم محددة
flutter run
```

### Worker

```bash
cd mbuy-worker

# List secrets
wrangler secret list

# Test Worker
npm run dev
```

---

## 🔐 Security Notes

### ⚠️ مهم:

1. **لا ترفع .env إلى Git**
   - أضف `.env` إلى `.gitignore`
   - استخدم `.env.example` كقالب

2. **لا تشارك Secrets**
   - SERVICE_ROLE_KEY حساس جداً
   - JWT_SECRET يجب أن يكون سرياً

3. **استخدم Secrets في Production**
   - لا تضع Secrets في الكود
   - استخدم Cloudflare Secrets للـ Worker

---

## 📝 .env.example Template

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here

# Cloudflare Worker
WORKER_URL=https://your-worker.workers.dev

# Firebase (اختياري)
FIREBASE_API_KEY=your_firebase_key
FIREBASE_PROJECT_ID=your_project_id
```

---

## 🐛 Troubleshooting

### مشكلة: "Missing environment variable"

**الحل:**
1. تحقق من وجود `.env` file
2. تحقق من أن القيم محددة بشكل صحيح
3. أعد تشغيل التطبيق

### مشكلة: "Invalid credentials"

**الحل:**
1. تحقق من SUPABASE_URL
2. تحقق من SUPABASE_ANON_KEY
3. تحقق من WORKER_URL

---

</div>

