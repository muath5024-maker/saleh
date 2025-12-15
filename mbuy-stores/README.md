# MBUY Multi-Tenant Store Platform

نظام متاجر ويب Multi-Tenant باستخدام Next.js

## الميزات

- ✅ Wildcard subdomain routing: `{slug}.mbuy.pro`
- ✅ Onboarding flow كامل (5 خطوات)
- ✅ 3 ثيمات جاهزة (عصري، كلاسيكي، بسيط)
- ✅ تكامل كامل مع Worker API
- ✅ لا اتصال مباشر بـ Supabase من Next.js

## البنية

```
mbuy-stores/
├── app/
│   ├── onboarding/          # تدفق إنشاء المتجر
│   ├── store/[slug]/         # صفحة المتجر
│   └── page.tsx              # Home page
├── components/
│   ├── onboarding/           # مكونات Onboarding
│   └── store/                # مكونات المتجر
├── lib/
│   ├── api/                  # Worker API Client
│   ├── themes/               # Themes & Templates
│   └── utils/                # Utilities
└── middleware.ts             # Subdomain routing
```

## التثبيت

```bash
cd mbuy-stores
npm install
```

## الإعداد

1. انسخ `.env.local.example` إلى `.env.local`
2. حدّث `NEXT_PUBLIC_WORKER_API_URL` و `NEXT_PUBLIC_MAIN_DOMAIN`

## التشغيل

```bash
npm run dev
```

## DNS Setup

قم بإعداد Wildcard DNS:
- `*.mbuy.pro` → Next.js deployment URL

## Onboarding Flow

1. **Step 1:** إدخال بيانات المتجر (اسم، slug، وصف)
2. **Step 2:** شاشة ترحيب + كرت هدية (5 عناصر)
3. **Step 3:** أسئلة ذكية عن المتجر
4. **Step 4:** اقتراحات AI (شعارات، ألوان، قوالب)
5. **Step 5:** شات لإكمال الهوية

## Themes

- **Modern:** تصميم عصري مع ألوان زاهية
- **Classic:** تصميم كلاسيكي وأنيق
- **Minimal:** تصميم بسيط وحديث

## Worker APIs

جميع APIs متاحة عبر Worker:
- `GET /public/store/{slug}` - بيانات المتجر
- `GET /public/store/{slug}/theme` - إعدادات الثيم
- `GET /public/store/{slug}/branding` - الهوية البصرية
- `GET /secure/store/check-slug` - التحقق من Slug
- `POST /secure/store/create` - إنشاء متجر
- `PUT /secure/store/{id}/branding` - تحديث الهوية
- `POST /secure/store/{id}/ai-suggestions` - اقتراحات AI
