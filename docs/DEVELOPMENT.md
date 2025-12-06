# 💻 دليل التطوير - MBUY

<div dir="rtl">

## 📝 إرشادات الكود

### Flutter (Dart)

#### Naming Conventions

```dart
// Classes: PascalCase
class AuthRepository {}

// Variables & Functions: camelCase
final userId = '123';
Future<void> login() {}

// Constants: camelCase with const
const String baseUrl = 'https://...';

// Private: _prefix
String _privateVariable;
```

#### Code Organization

```dart
// 1. Imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 2. Local imports
import '../core/services/api_service.dart';
import '../features/auth/data/auth_repository.dart';

// 3. Class definition
class MyWidget extends StatefulWidget {
  // ...
}
```

#### Error Handling

```dart
try {
  final response = await ApiService.get('/secure/endpoint');
  if (response['ok'] == true) {
    // Success
  } else {
    throw Exception(response['message'] ?? 'Error occurred');
  }
} on AppException catch (e) {
  // Handle specific error
  logger.error('Error', error: e);
} catch (e) {
  // Handle generic error
  logger.error('Unexpected error', error: e);
}
```

---

### Worker (TypeScript)

#### Naming Conventions

```typescript
// Functions: camelCase
async function getUserProfile() {}

// Types/Interfaces: PascalCase
interface UserProfile {}

// Constants: UPPER_SNAKE_CASE
const MAX_RETRIES = 3;
```

#### Code Organization

```typescript
// 1. Imports
import { Hono } from 'hono';
import { Env } from './types';

// 2. Helper functions
async function helperFunction() {}

// 3. Endpoint handlers
app.get('/endpoint', async (c) => {
  // ...
});
```

#### Error Handling

```typescript
try {
  const result = await someOperation();
  return c.json({
    ok: true,
    data: result,
  }, 200, {
    'Content-Type': 'application/json; charset=utf-8',
  });
} catch (error: any) {
  console.error('[Worker] Error:', error);
  return c.json({
    ok: false,
    code: 'INTERNAL_ERROR',
    error: 'Operation failed',
    message: error.message || 'An error occurred',
  }, 500, {
    'Content-Type': 'application/json; charset=utf-8',
  });
}
```

---

## ✅ Best Practices

### 1. Security

- ✅ **لا ترسل user_id, store_id, owner_id من Flutter**
- ✅ **استخدم JWT في جميع الطلبات المحمية**
- ✅ **نظف body في Worker قبل الإدراج**
- ✅ **تحقق من الصلاحيات في Worker**

### 2. Performance

- ✅ **استخدم Supabase Client Helper (أسرع)**
- ✅ **Cache البيانات عند الحاجة**
- ✅ **استخدم indexes في Database queries**
- ✅ **Limit results في queries كبيرة**

### 3. Code Quality

- ✅ **استخدم TypeScript types في Worker**
- ✅ **استخدم Dart types في Flutter**
- ✅ **أضف comments للكود المعقد**
- ✅ **اتبع معايير الكود المحددة**

### 4. Error Handling

- ✅ **استخدم error codes موحدة**
- ✅ **أضف رسائل خطأ واضحة**
- ✅ **Log الأخطاء للـ debugging**
- ✅ **لا تعرض تفاصيل تقنية للمستخدم**

---

## 🧪 Testing

### Flutter Tests

```dart
// test/features/auth/auth_repository_test.dart
void main() {
  group('AuthRepository', () {
    test('login should return user and token', () async {
      // Test implementation
    });
  });
}
```

### Worker Tests

```typescript
// tests/auth.test.ts
describe('Auth Endpoints', () => {
  it('should register new user', async () => {
    // Test implementation
  });
});
```

---

## 🐛 Debugging

### Flutter

```dart
// استخدام debugPrint
debugPrint('[AuthRepository] Logging in: $email');

// استخدام logger
logger.info('Operation started', tag: 'Auth');
logger.error('Operation failed', error: e, tag: 'Auth');
```

### Worker

```typescript
// استخدام console.log
console.log('[Worker] Operation started');

// استخدام console.error
console.error('[Worker] Error:', error);
```

---

## 📦 Dependencies

### Flutter

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  flutter_secure_storage: ^9.0.0
  provider: ^6.1.1
```

### Worker

```json
{
  "dependencies": {
    "hono": "^4.6.20",
    "zod": "^4.1.13"
  }
}
```

---

## 🔄 Git Workflow

### Branching Strategy

```
main          # Production
├── develop   # Development
├── feature/*  # Features
└── fix/*     # Bug fixes
```

### Commit Messages

```
feat: add new feature
fix: fix bug
docs: update documentation
refactor: refactor code
test: add tests
```

---

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)
- [Supabase Documentation](https://supabase.com/docs)

---

</div>

