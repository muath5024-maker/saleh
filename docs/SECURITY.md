# 🔒 دليل الأمان - MBUY

<div dir="rtl">

## 🛡️ نظرة عامة

MBUY يستخدم طبقات أمان متعددة لحماية البيانات والعمليات.

---

## 🔐 Authentication

### JWT Tokens

- **Expiration**: 30 يوم
- **Algorithm**: HS256
- **Claims**: `sub` (user.id), `email`, `type`

### Password Security

- **Hashing**: PBKDF2
- **Rounds**: 100,000 iterations
- **Salt**: Random 16 bytes

### Session Management

- **Tracking**: في `mbuy_sessions` table
- **Revocation**: يمكن إلغاء الجلسات
- **Expiration**: تلقائي بعد 30 يوم

---

## 🔒 Authorization

### JWT Middleware

جميع الـ endpoints التي تبدأ بـ `/secure/*` محمية بـ JWT middleware:

```typescript
app.use('/secure/*', mbuyAuthMiddleware);
```

### Role-based Access

- **Customer**: يمكنه الوصول لـ customer endpoints
- **Merchant**: يمكنه الوصول لـ merchant endpoints
- **Verification**: في Worker قبل كل عملية

---

## 🛡️ Data Protection

### Client-side Protection

- ✅ **لا يرسل العميل**: `user_id`, `store_id`, `owner_id`
- ✅ **Token Storage**: في `flutter_secure_storage`
- ✅ **HTTPS Only**: جميع الاتصالات مشفرة

### Server-side Protection

- ✅ **Body Cleaning**: Worker ينظف body قبل الإدراج
- ✅ **Input Validation**: Zod schemas للتحقق
- ✅ **SQL Injection**: محمي عبر Supabase Client Helper

---

## 🔐 Secrets Management

### Flutter

```env
# .env file (لا ترفع إلى Git!)
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=...
WORKER_URL=https://...
```

### Worker

```bash
# Cloudflare Secrets (محمية)
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_SERVICE_ROLE_KEY
wrangler secret put JWT_SECRET
wrangler secret put PASSWORD_HASH_ROUNDS
```

---

## 🚫 Security Best Practices

### 1. لا ترسل بيانات حساسة من Flutter

```dart
// ❌ Bad: Sending user_id from client
await ApiService.post('/secure/products', data: {
  'name': 'Product',
  'user_id': userId,  // ❌ لا ترسل هذا!
});

// ✅ Good: Worker extracts from JWT
await ApiService.post('/secure/products', data: {
  'name': 'Product',
  // Worker will extract userId from JWT
});
```

### 2. نظف Body في Worker

```typescript
// ✅ Good: Clean body before insert
const cleanBody: any = { ...body };
delete cleanBody.id;
delete cleanBody.store_id;
delete cleanBody.user_id;
delete cleanBody.owner_id;
```

### 3. تحقق من الصلاحيات

```typescript
// ✅ Good: Verify permissions
const userId = c.get('userId');
const store = await supabase.findById('stores', storeId, 'owner_id');
if (store.owner_id !== userId) {
  return c.json({
    ok: false,
    code: 'FORBIDDEN',
    message: 'You do not have permission',
  }, 403);
}
```

---

## 🔍 Security Checklist

### قبل النشر:

- [ ] جميع Secrets محددة في Cloudflare
- [ ] .env file في .gitignore
- [ ] JWT_SECRET قوي (32+ characters)
- [ ] PASSWORD_HASH_ROUNDS = 100000
- [ ] CORS محدود للـ origins المطلوبة
- [ ] Rate limiting مفعل
- [ ] Error messages لا تكشف معلومات حساسة

---

## 🐛 Security Issues

### إذا اكتشفت ثغرة أمنية:

1. **لا تفتح Issue عام**
2. **تواصل مباشرة** مع فريق الأمان
3. **قدم تفاصيل** عن الثغرة
4. **انتظر الإصلاح** قبل الكشف

---

## 📚 Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [JWT Best Practices](https://datatracker.ietf.org/doc/html/rfc8725)
- [Password Hashing](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)

---

</div>

