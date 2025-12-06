# MBUY - تطبيق التجارة الإلكترونية

<div dir="rtl">

## 📱 نظرة عامة

**MBUY** هو تطبيق تجارة إلكترونية متكامل يدعم وضعي العميل والتاجر، مبني على معمارية حديثة وآمنة.

### الميزات الرئيسية

- 🛍️ **وضع العميل**: تصفح المنتجات، الطلبات، المحفظة، النقاط
- 🏪 **وضع التاجر**: إدارة المتجر، المنتجات، الطلبات، الإحصائيات
- 🔐 **نظام Auth مخصص**: JWT-based authentication
- 🌐 **API Gateway**: Cloudflare Workers كواجهة وحيدة
- 📊 **Real-time Analytics**: إحصائيات متقدمة للتجار
- 🤖 **AI Integration**: دعم Google Gemini

</div>

---

## 🏗️ البنية المعمارية

```
┌─────────────────┐
│   Flutter App   │  (saleh/)
│   - Customer UI │
│   - Merchant UI │
└────────┬────────┘
         │ HTTPS + JWT
         │
         ▼
┌─────────────────┐
│ Cloudflare      │  (mbuy-worker/)
│ Worker          │
│ - API Gateway   │
│ - Auth Handler  │
│ - JWT Middleware│
└────────┬────────┘
         │ SERVICE_ROLE_KEY
         │
         ▼
┌─────────────────┐
│   Supabase      │  (mbuy-backend/)
│   PostgreSQL    │
│   - mbuy_users  │
│   - products    │
│   - orders      │
└─────────────────┘
```

---

## 📁 هيكل المشروع

```
mbuy/
├── saleh/                    # Flutter Application
│   ├── lib/
│   │   ├── core/            # Core services & utilities
│   │   ├── features/       # Feature modules
│   │   │   ├── auth/       # Authentication
│   │   │   ├── customer/  # Customer features
│   │   │   └── merchant/   # Merchant features
│   │   └── shared/         # Shared components
│   └── README.md
│
├── mbuy-worker/             # Cloudflare Worker (Backend)
│   ├── src/
│   │   ├── endpoints/      # API endpoints
│   │   ├── middleware/     # Middlewares
│   │   ├── utils/          # Utilities
│   │   └── index.ts        # Main entry point
│   └── README.md
│
└── mbuy-backend/            # Supabase Backend
    ├── migrations/          # Database migrations
    └── README.md
```

---

## 🚀 البدء السريع

### المتطلبات

- **Flutter**: SDK ^3.10.0
- **Node.js**: v18+ (لـ Worker)
- **Supabase**: حساب نشط
- **Cloudflare**: حساب مع Workers

### التثبيت

#### 1. Flutter App

```bash
cd saleh
flutter pub get
flutter run
```

#### 2. Cloudflare Worker

```bash
cd mbuy-worker
npm install
npm run dev
```

#### 3. Supabase Database

```bash
cd mbuy-backend
# تطبيق migrations من مجلد migrations/
```

---

## 🔐 الإعداد

### 1. Flutter Environment

إنشاء ملف `.env` في `saleh/`:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
WORKER_URL=https://your-worker.workers.dev
```

### 2. Worker Secrets

إعداد Secrets في Cloudflare:

```bash
cd mbuy-worker
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_SERVICE_ROLE_KEY
wrangler secret put JWT_SECRET
wrangler secret put PASSWORD_HASH_ROUNDS
```

### 3. Database Setup

تطبيق migrations:

```sql
-- تطبيق mbuy-backend/migrations/20250107000001_create_mbuy_auth_tables.sql
```

---

## 📚 التوثيق

### التوثيق الرئيسي

- **[تحليل المشروع](./PROJECT_COMPREHENSIVE_ANALYSIS.md)** - تحليل شامل للمشروع
- **[المعمارية](./MBUY_ARCHITECTURE_MIGRATION_COMPLETE.md)** - تفاصيل المعمارية
- **[التوصيات](./PRIORITY_RECOMMENDATIONS_IMPLEMENTATION.md)** - التوصيات المنفذة

### توثيق المكونات

- **[Flutter App](./saleh/README.md)** - دليل تطبيق Flutter
- **[Cloudflare Worker](./mbuy-worker/README.md)** - دليل Worker
- **[Supabase Backend](./mbuy-backend/README.md)** - دليل قاعدة البيانات

---

## 🔄 التدفقات الرئيسية

### تسجيل الدخول

```
User Input → Flutter → POST /auth/login → Worker
→ Verify credentials → Generate JWT → Save token → Navigate to Home
```

### إضافة منتج (تاجر)

```
Merchant Input → Flutter → POST /secure/products → Worker
→ Verify JWT → Extract userId → Get store → Clean body → Insert product
```

### إنشاء طلب

```
Customer → Add to cart → POST /secure/orders/create-from-cart → Worker
→ Verify JWT → Get cart → Create order → Update inventory → Send notifications
```

---

## 🛡️ الأمان

### طبقات الأمان

1. **Authentication**: JWT tokens مع expiration (30 يوم)
2. **Authorization**: JWT Middleware على جميع `/secure/*` routes
3. **Data Protection**: SERVICE_ROLE_KEY محمي في Worker secrets
4. **Network Security**: HTTPS فقط، CORS محدود

### Best Practices

- ✅ لا يرسل العميل `user_id`, `store_id`, `owner_id`
- ✅ Worker ينظف body قبل الإدراج
- ✅ Password hashing باستخدام PBKDF2 (100,000 rounds)
- ✅ Session tracking في `mbuy_sessions`

---

## 📊 API Endpoints

### Auth Endpoints

- `POST /auth/register` - تسجيل مستخدم جديد
- `POST /auth/login` - تسجيل الدخول
- `GET /auth/me` - جلب المستخدم الحالي
- `POST /auth/logout` - تسجيل الخروج

### Secure Endpoints (محمية بـ JWT)

- `GET /secure/products` - جلب المنتجات
- `POST /secure/products` - إضافة منتج
- `GET /secure/orders` - جلب الطلبات
- `POST /secure/orders/create-from-cart` - إنشاء طلب من السلة
- `PUT /secure/orders/:id/status` - تحديث حالة الطلب
- `GET /secure/users/me` - جلب ملف المستخدم

[المزيد من التوثيق](./saleh/MBUY_API_DOCUMENTATION.md)

---

## 🧪 الاختبار

### Flutter Tests

```bash
cd saleh
flutter test
```

### Worker Tests

```bash
cd mbuy-worker
npm test
```

---

## 📈 الأداء

### Optimizations

- ✅ Supabase Client Helper (أسرع من REST مباشرة)
- ✅ JWT caching في Flutter
- ✅ Rate limiting في Worker
- ✅ Database indexes محسّنة

---

## 🐛 Troubleshooting

### مشاكل شائعة

1. **خطأ في الاتصال بالخادم**
   - تحقق من Worker URL
   - تحقق من Secrets في Cloudflare

2. **خطأ في المصادقة**
   - تحقق من JWT_SECRET
   - تحقق من token expiration

3. **خطأ في قاعدة البيانات**
   - تحقق من SERVICE_ROLE_KEY
   - تحقق من RLS policies

[دليل Troubleshooting الكامل](./mbuy-worker/TROUBLESHOOTING.md)

---

## 🤝 المساهمة

### إرشادات الكود

- استخدم TypeScript في Worker
- استخدم Dart في Flutter
- اتبع معايير الكود المحددة
- أضف tests للكود الجديد

---

## 📝 الترخيص

هذا المشروع خاص ومملوك لـ MBUY.

---

## 📞 الدعم

للأسئلة والدعم:
- راجع [التوثيق](./docs/)
- راجع [Troubleshooting](./mbuy-worker/TROUBLESHOOTING.md)

---

**آخر تحديث:** 2025-01-07  
**الإصدار:** 1.0.0

</div>

