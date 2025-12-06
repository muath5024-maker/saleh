# 🔑 خطوات إعادة تعيين EDGE_INTERNAL_KEY

## 📊 الوضع الحالي

✅ المفتاح موجود في:
- Worker (Cloudflare)
- Supabase

⚠️ المشكلة المحتملة: القيم قد لا تكون متطابقة.

---

## 🎯 الحل: إعادة تعيين بنفس القيمة

### الطريقة السريعة:

#### 1. اختر مفتاحاً جديداً (أو استخدم هذا):
```
mbuy-secure-key-2025-xyz123
```

#### 2. في Supabase:
```bash
cd C:\muath\mbuy-backend
supabase secrets set EDGE_INTERNAL_KEY=mbuy-secure-key-2025-xyz123
```

#### 3. في Worker (نفس القيمة):
```bash
cd C:\muath\mbuy-worker
wrangler secret put EDGE_INTERNAL_KEY
# أدخل: mbuy-secure-key-2025-xyz123
```

#### 4. إعادة النشر:
```bash
# Edge Function
cd C:\muath\mbuy-backend
supabase functions deploy product_create

# Worker
cd C:\muath\mbuy-worker
wrangler deploy
```

---

## 💡 نصيحة

**استخدم مفتاحاً قوياً في Production:**
- طول: 32+ حرف
- يحتوي على: أرقام + حروف كبيرة + حروف صغيرة
- بدون مسافات أو أحرف خاصة

---

**جاهز للتنفيذ!** 🚀

