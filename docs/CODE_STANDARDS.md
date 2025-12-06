# 📝 معايير الكود - MBUY

<div dir="rtl">

## 🎯 المبادئ العامة

- ✅ **وضوح الكود**: الكود يجب أن يكون واضحاً ومفهوماً
- ✅ **Consistency**: اتبع نفس النمط في جميع أنحاء المشروع
- ✅ **Documentation**: أضف comments للكود المعقد
- ✅ **Error Handling**: تعامل مع الأخطاء بشكل صحيح

---

## 📱 Flutter (Dart)

### Naming Conventions

```dart
// Classes: PascalCase
class AuthRepository {}
class OrderService {}

// Variables & Functions: camelCase
final userId = '123';
Future<void> login() async {}

// Constants: camelCase with const
const String baseUrl = 'https://...';

// Private: _prefix
String _privateVariable;
Future<void> _privateMethod() {}
```

### File Organization

```dart
// 1. Dart SDK imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 3. Package imports
import 'package:http/http.dart' as http;

// 4. Local imports
import '../core/services/api_service.dart';
import '../features/auth/data/auth_repository.dart';

// 5. Class definition
class MyWidget extends StatefulWidget {
  // ...
}
```

### Code Style

```dart
// ✅ Good: Clear and readable
Future<void> login(String email, String password) async {
  try {
    final response = await AuthRepository.login(
      email: email,
      password: password,
    );
    if (response['ok'] == true) {
      // Success handling
    }
  } catch (e) {
    // Error handling
  }
}

// ❌ Bad: Unclear and hard to read
Future<void> login(String e, String p) async {
  try {
    final r = await AuthRepository.login(email: e, password: p);
    if (r['ok'] == true) {}
  } catch (e) {}
}
```

### Error Handling

```dart
// ✅ Good: Specific error handling
try {
  final response = await ApiService.get('/secure/endpoint');
  if (response['ok'] == true) {
    return response['data'];
  } else {
    throw Exception(response['message'] ?? 'Error occurred');
  }
} on AppException catch (e) {
  logger.error('API Error', error: e);
  rethrow;
} catch (e) {
  logger.error('Unexpected error', error: e);
  throw Exception('An unexpected error occurred');
}

// ❌ Bad: Generic error handling
try {
  final response = await ApiService.get('/secure/endpoint');
  return response;
} catch (e) {
  print(e);
}
```

---

## ☁️ Worker (TypeScript)

### Naming Conventions

```typescript
// Functions: camelCase
async function getUserProfile() {}
async function createOrder() {}

// Types/Interfaces: PascalCase
interface UserProfile {}
type OrderStatus = 'pending' | 'confirmed';

// Constants: UPPER_SNAKE_CASE
const MAX_RETRIES = 3;
const DEFAULT_TIMEOUT = 30000;

// Private functions: _prefix (if needed)
function _helperFunction() {}
```

### File Organization

```typescript
// 1. External imports
import { Hono } from 'hono';
import { z } from 'zod';

// 2. Internal imports
import { Env } from './types';
import { createSupabaseClient } from './utils/supabase';
import { mbuyAuthMiddleware } from './middleware/authMiddleware';

// 3. Helper functions
async function helperFunction() {}

// 4. Endpoint handlers
app.get('/endpoint', async (c) => {
  // ...
});
```

### Code Style

```typescript
// ✅ Good: Clear and readable
app.get('/secure/users/me', async (c) => {
  try {
    const userId = c.get('userId');
    if (!userId) {
      return c.json({
        ok: false,
        code: 'UNAUTHORIZED',
        error: 'User ID not found',
        message: 'Authentication required',
      }, 401);
    }

    const supabase = createSupabaseClient(c.env);
    const profile = await supabase.findById('user_profiles', userId, '*');

    return c.json({
      ok: true,
      data: profile,
    }, 200, {
      'Content-Type': 'application/json; charset=utf-8',
    });
  } catch (error: any) {
    console.error('[Worker] Error:', error);
    return c.json({
      ok: false,
      code: 'INTERNAL_ERROR',
      error: 'Failed to get user profile',
      message: error.message || 'An error occurred',
    }, 500);
  }
});

// ❌ Bad: Unclear and hard to read
app.get('/secure/users/me', async (c) => {
  const u = c.get('userId');
  const s = createSupabaseClient(c.env);
  const p = await s.findById('user_profiles', u, '*');
  return c.json({ ok: true, data: p });
});
```

### Error Handling

```typescript
// ✅ Good: Comprehensive error handling
try {
  const result = await someOperation();
  return c.json({
    ok: true,
    data: result,
  }, 200, {
    'Content-Type': 'application/json; charset=utf-8',
  });
} catch (error: any) {
  console.error('[Worker] Operation failed:', error);
  return c.json({
    ok: false,
    code: 'INTERNAL_ERROR',
    error: 'Operation failed',
    message: error.message || 'An error occurred',
  }, 500, {
    'Content-Type': 'application/json; charset=utf-8',
  });
}

// ❌ Bad: No error handling
app.get('/endpoint', async (c) => {
  const result = await someOperation();
  return c.json({ ok: true, data: result });
});
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

## 📝 Comments

### Flutter

```dart
/// تسجيل الدخول
/// 
/// Parameters:
/// - email: البريد الإلكتروني
/// - password: كلمة المرور
/// 
/// Returns: Map with user and token data
/// Throws: Exception في حالة الفشل
static Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  // Implementation
}
```

### Worker

```typescript
/**
 * GET /secure/users/me
 * Get current user profile (protected route)
 * 
 * Requires: JWT token in Authorization header
 * Returns: User profile data
 */
app.get('/secure/users/me', async (c) => {
  // Implementation
});
```

---

## 🧪 Testing

### Flutter

```dart
// test/features/auth/auth_repository_test.dart
void main() {
  group('AuthRepository', () {
    test('login should return user and token', () async {
      // Arrange
      final email = 'test@example.com';
      final password = 'password123';
      
      // Act
      final result = await AuthRepository.login(
        email: email,
        password: password,
      );
      
      // Assert
      expect(result['ok'], true);
      expect(result['user'], isNotNull);
      expect(result['token'], isNotNull);
    });
  });
}
```

### Worker

```typescript
// tests/auth.test.ts
describe('Auth Endpoints', () => {
  it('should register new user', async () => {
    // Test implementation
  });
  
  it('should login with valid credentials', async () => {
    // Test implementation
  });
});
```

---

## 📚 Resources

- [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- [Clean Code Principles](https://github.com/ryanmcdermott/clean-code-javascript)

---

</div>

