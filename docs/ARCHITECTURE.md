# 🏗️ البنية المعمارية - MBUY

<div dir="rtl">

## 📐 نظرة عامة

MBUY يستخدم معمارية **API Gateway Pattern** حيث Cloudflare Worker يعمل كواجهة وحيدة بين Flutter و Supabase.

---

## 🎯 المبادئ المعمارية

1. **API Gateway Pattern**: Worker كواجهة وحيدة للـ APIs
2. **Custom Auth**: نظام مصادقة مخصص بدون Supabase Auth
3. **JWT-based Security**: جميع الطلبات المحمية بـ JWT
4. **Service Role Access**: Worker يستخدم SERVICE_ROLE_KEY فقط
5. **Separation of Concerns**: فصل واضح بين Frontend و Backend

---

## 🏛️ البنية الكاملة

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
│                  (saleh/lib/)                           │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Auth Screen │  │ Customer UI  │  │ Merchant UI  │ │
│  └──────┬──────┘  └──────┬───────┘  └──────┬───────┘ │
│         │                │                  │          │
│         └────────────────┴──────────────────┘          │
│                         │                               │
│                  ┌──────▼──────┐                        │
│                  │ ApiService  │                        │
│                  │  + JWT      │                        │
│                  └──────┬──────┘                        │
└─────────────────────────┼─────────────────────────────┘
                           │ HTTPS + JWT
                           │
┌──────────────────────────▼─────────────────────────────┐
│            Cloudflare Worker                           │
│            (mbuy-worker/src/)                          │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Auth         │  │ Middleware   │  │ Endpoints    │ │
│  │ Endpoints    │  │ JWT Verify   │  │ Products     │ │
│  └──────┬───────┘  └──────┬───────┘  │ Orders       │ │
│         │                 │          │ Users        │ │
│         └─────────────────┴──────────┴──────┬───────┘ │
│                                              │          │
│                                    ┌─────────▼──────┐  │
│                                    │ Supabase Client │  │
│                                    │ Helper          │  │
│                                    └─────────┬───────┘  │
└──────────────────────────────────────────────┼──────────┘
                                               │ SERVICE_ROLE_KEY
                                               │
┌──────────────────────────────────────────────▼──────────┐
│              Supabase PostgreSQL                         │
│              (mbuy-backend/)                             │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐│
│  │ mbuy_users   │  │ products     │  │ orders       ││
│  │ mbuy_sessions│  │ stores       │  │ wallets      ││
│  └──────────────┘  └──────────────┘  └──────────────┘│
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 تدفقات البيانات

### 1. تدفق تسجيل الدخول

```
User Input (Email + Password)
    ↓
Flutter: AuthRepository.login()
    ↓
POST /auth/login → Worker
    ↓
Worker: Verify credentials in mbuy_users
    ↓
Worker: Create session in mbuy_sessions
    ↓
Worker: Generate JWT token
    ↓
Response: { ok: true, user: {...}, token: "..." }
    ↓
Flutter: Save token in secure storage
    ↓
Flutter: Call /auth/me to verify
    ↓
Flutter: Navigate to Home/Dashboard
```

### 2. تدفق إضافة منتج (تاجر)

```
Merchant: Fill product form
    ↓
Flutter: POST /secure/products
    ↓
Worker: JWT Middleware verifies token
    ↓
Worker: Extract userId from JWT (jwt.sub)
    ↓
Worker: Fetch store from stores table (owner_id = userId)
    ↓
Worker: Clean body (remove id, store_id, user_id, owner_id)
    ↓
Worker: Insert product with store_id
    ↓
Response: { ok: true, data: {...} }
    ↓
Flutter: Update UI
```

### 3. تدفق إنشاء طلب

```
Customer: Add products to cart
    ↓
Flutter: POST /secure/orders/create-from-cart
    ↓
Worker: Verify JWT
    ↓
Worker: Get cart items
    ↓
Worker: Create order
    ↓
Worker: Update inventory
    ↓
Worker: Send notifications
    ↓
Response: { ok: true, data: {...} }
```

---

## 🔐 الأمان

### طبقات الأمان

1. **Authentication Layer**:
   - JWT tokens مع expiration (30 يوم)
   - Password hashing باستخدام PBKDF2 (100,000 rounds)
   - Session tracking في mbuy_sessions

2. **Authorization Layer**:
   - JWT Middleware على جميع `/secure/*` routes
   - User ID extraction من JWT payload
   - Store ownership verification

3. **Data Protection**:
   - SERVICE_ROLE_KEY محمي في Worker secrets
   - Client لا يرسل user_id, store_id, owner_id
   - Body cleaning في Worker قبل الإدراج

4. **Network Security**:
   - HTTPS فقط
   - CORS policies محددة
   - Rate limiting

---

## 📊 المكونات الرئيسية

### Flutter (saleh/lib/)

```
lib/
├── core/
│   ├── services/
│   │   ├── api_service.dart      # API client مع JWT
│   │   └── secure_storage_service.dart
│   ├── root_widget.dart          # نقطة الدخول
│   └── theme/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart  # Worker API calls
│   │   │   └── auth_service.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── auth_screen.dart
│   │
│   ├── customer/                 # واجهة العميل
│   └── merchant/                 # واجهة التاجر
│
└── shared/                       # مكونات مشتركة
```

### Worker (mbuy-worker/src/)

```
src/
├── index.ts                      # نقطة الدخول (3831 سطر)
├── endpoints/
│   └── auth.ts                   # Auth handlers
├── middleware/
│   ├── authMiddleware.ts         # JWT verification
│   └── rateLimiter.ts            # Rate limiting
├── utils/
│   ├── supabase.ts               # Supabase client helper
│   └── auth.ts                   # JWT & password hashing
└── types.ts                      # TypeScript types
```

### Database (mbuy-backend/)

```
migrations/
├── 20250107000001_create_mbuy_auth_tables.sql
└── ...
```

---

## 🎨 Design Patterns

### 1. Repository Pattern
- `AuthRepository` في Flutter
- Abstraction layer للـ API calls

### 2. Service Pattern
- `ApiService` في Flutter
- Centralized HTTP client

### 3. Middleware Pattern
- `mbuyAuthMiddleware` في Worker
- JWT verification قبل الـ handlers

### 4. Gateway Pattern
- Worker كـ API Gateway
- Single entry point

---

## 📈 Scalability

### Flutter:
- ✅ State management مع Provider
- ✅ Lazy loading للشاشات
- ✅ Image caching

### Worker:
- ✅ Cloudflare Workers (auto-scaling)
- ✅ Rate limiting
- ✅ Caching strategies

### Database:
- ✅ Indexes محسّنة
- ✅ Connection pooling
- ✅ Query optimization

---

## 🔄 Data Flow

### Read Operations:
```
Flutter → Worker → Supabase → Response → Flutter
```

### Write Operations:
```
Flutter → Worker (JWT verify) → Worker (clean body) → Supabase → Response → Flutter
```

---

## 🛡️ Security Flow

```
1. User Login
   ↓
2. Worker validates credentials
   ↓
3. Worker generates JWT
   ↓
4. Flutter stores JWT in secure storage
   ↓
5. All subsequent requests include JWT
   ↓
6. Worker middleware verifies JWT
   ↓
7. Worker extracts userId from JWT
   ↓
8. Worker performs operations with userId
```

---

</div>

