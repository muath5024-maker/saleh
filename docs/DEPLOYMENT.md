# 🚀 دليل النشر - MBUY

<div dir="rtl">

## 📋 قبل النشر

### Checklist

- [ ] جميع Tests تمر بنجاح
- [ ] Environment variables محددة
- [ ] Secrets محددة في Cloudflare
- [ ] Database migrations مطبقة
- [ ] Error handling محسّن
- [ ] Logging مفعل

---

## 📱 نشر Flutter App

### Android

```bash
cd saleh

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
cd saleh

# Build iOS
flutter build ios --release
```

### Web

```bash
cd saleh

# Build Web
flutter build web --release
```

---

## ☁️ نشر Cloudflare Worker

### Development

```bash
cd mbuy-worker
npm run dev
```

### Production

```bash
cd mbuy-worker

# Deploy
npm run deploy

# أو
wrangler deploy
```

### التحقق من النشر

```bash
# Test endpoint
curl https://your-worker.workers.dev/
```

---

## 🗄️ Database Migrations

### تطبيق Migrations

```bash
# استخدام Supabase CLI
supabase db push

# أو من Dashboard
# SQL Editor → Paste migration → Run
```

### Migrations المطلوبة

1. `20250107000001_create_mbuy_auth_tables.sql`
   - إنشاء `mbuy_users`
   - إنشاء `mbuy_sessions`
   - RLS Policies

---

## 🔐 Environment Variables

### Flutter (.env)

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
WORKER_URL=https://your-worker.workers.dev
```

### Worker (Secrets)

```bash
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_SERVICE_ROLE_KEY
wrangler secret put JWT_SECRET
wrangler secret put PASSWORD_HASH_ROUNDS
```

---

## ✅ التحقق بعد النشر

### 1. Health Check

```bash
curl https://your-worker.workers.dev/
```

**Expected Response:**
```json
{
  "ok": true,
  "message": "MBUY API Gateway",
  "version": "1.0.0"
}
```

### 2. Auth Test

```bash
# Register
curl -X POST https://your-worker.workers.dev/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Login
curl -X POST https://your-worker.workers.dev/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

### 3. Secure Endpoint Test

```bash
# Get user profile (requires JWT)
curl -X GET https://your-worker.workers.dev/secure/users/me \
  -H "Authorization: Bearer <token>"
```

---

## 📊 Monitoring

### Cloudflare Analytics

- Dashboard → Workers → Analytics
- Monitor requests, errors, latency

### Supabase Logs

- Dashboard → Logs
- Monitor database queries

### Flutter Logs

```dart
// استخدام logger
logger.info('Operation', tag: 'App');
logger.error('Error', error: e, tag: 'App');
```

---

## 🔄 Rollback

### Worker Rollback

```bash
cd mbuy-worker

# List deployments
wrangler deployments list

# Rollback to previous version
wrangler rollback
```

### Database Rollback

```sql
-- Rollback migration manually
-- أو استخدام Supabase CLI
supabase db reset
```

---

## 🐛 Troubleshooting

### Worker لا يعمل

1. تحقق من Secrets
2. تحقق من Logs في Cloudflare Dashboard
3. تحقق من CORS settings

### Database Errors

1. تحقق من SERVICE_ROLE_KEY
2. تحقق من RLS Policies
3. تحقق من Migrations

### Flutter App Errors

1. تحقق من .env file
2. تحقق من Worker URL
3. تحقق من Network connectivity

---

</div>

