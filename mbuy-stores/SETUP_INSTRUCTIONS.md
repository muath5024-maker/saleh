# تعليمات الإعداد - نظام المتاجر Multi-Tenant

## 🚀 الإعداد السريع

### 1. إعداد قاعدة البيانات

قم بتشغيل SQL migration:
```sql
-- في Supabase SQL Editor
-- نفّذ الملف: CREATE_STORE_SETTINGS_TABLE.sql
```

### 2. إعداد Next.js Project

```bash
cd mbuy-stores
npm install
```

### 3. إعداد Environment Variables

أنشئ ملف `.env.local`:
```env
NEXT_PUBLIC_WORKER_API_URL=https://misty-mode-b68b.baharista1.workers.dev
NEXT_PUBLIC_MAIN_DOMAIN=mbuy.pro
```

### 4. إعداد DNS المحلي (للتطوير)

#### Windows:
أضف إلى `C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1 test-store.mbuy.pro
```

#### macOS/Linux:
أضف إلى `/etc/hosts`:
```
127.0.0.1 test-store.mbuy.pro
```

### 5. تشغيل المشروع

```bash
npm run dev
```

افتح: `http://localhost:3000`

---

## 📝 ملاحظات

- جميع البيانات تمر عبر Worker API (لا اتصال مباشر بـ Supabase)
- Onboarding يحتاج JWT token (يجب إضافة Auth context)
- Worker APIs جاهزة ومضافة في `mbuy-worker/src/index.ts`

---

**للتفاصيل الكاملة:** راجع `MBUY_STORES_IMPLEMENTATION_REPORT.md`
