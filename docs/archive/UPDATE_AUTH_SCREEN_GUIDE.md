# 🔄 دليل تحديث Auth Screen لاستخدام MBUY Auth

**الملف:** `saleh/lib/features/auth/presentation/screens/auth_screen.dart`

---

## 📋 التغييرات المطلوبة

### 1. تحديث الـ Imports

**قبل:**
```dart
import '../../data/auth_service.dart';
import '../../../../core/supabase_client.dart';
```

**بعد:**
```dart
import '../../data/mbuy_auth_service.dart';
// إزالة supabase_client.dart إذا لم يكن مستخدماً في أماكن أخرى
```

---

### 2. تحديث Register Function

**قبل:**
```dart
final user = await AuthService.signUp(
  email: _emailController.text.trim(),
  password: _passwordController.text,
  displayName: _displayNameController.text.trim(),
  role: _selectedRole,
  storeName: _selectedRole == 'merchant'
      ? _storeNameController.text.trim()
      : null,
  city: _selectedRole == 'merchant'
      ? _cityController.text.trim()
      : null,
);

if (mounted) {
  debugPrint('✅ تم تسجيل المستخدم: ${user.email}');
  
  // التحقق من وجود جلسة بعد التسجيل
  final session = supabaseClient.auth.currentSession;
  if (session != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم التسجيل بنجاح! جاري تحميل التطبيق...'),
        backgroundColor: Colors.green,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 500));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إنشاء الحساب! يرجى تسجيل الدخول الآن'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
    setState(() {
      _isSignUp = false;
    });
  }
}
```

**بعد:**
```dart
final result = await MbuyAuthService.register(
  email: _emailController.text.trim(),
  password: _passwordController.text,
  fullName: _displayNameController.text.trim(),
  phone: null, // يمكن إضافة حقل للهاتف لاحقاً
);

if (mounted) {
  final user = result['user'] as Map<String, dynamic>;
  debugPrint('✅ تم تسجيل المستخدم: ${user['email']}');
  
  // التحقق من أن Token محفوظ
  final isLoggedIn = await MbuyAuthService.isLoggedIn();
  if (isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم التسجيل بنجاح! جاري تحميل التطبيق...'),
        backgroundColor: Colors.green,
      ),
    );
    
    // إذا كان تاجر، قم بإنشاء المتجر عبر API
    if (_selectedRole == 'merchant') {
      try {
        // TODO: إضافة API call لإنشاء المتجر
        // await ApiService.createStore(...);
      } catch (e) {
        debugPrint('⚠️ فشل إنشاء المتجر: $e');
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 500));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إنشاء الحساب! يرجى تسجيل الدخول الآن'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
    setState(() {
      _isSignUp = false;
    });
  }
}
```

---

### 3. تحديث Login Function

**قبل:**
```dart
final email = _emailController.text.trim().toLowerCase();
final password = _passwordController.text;

debugPrint('🔐 محاولة تسجيل الدخول: $email');

final session = await AuthService.signIn(
  email: email,
  password: password,
);

if (mounted) {
  debugPrint('✅ تم تسجيل الدخول: ${session.user.email}');
  debugPrint('✅ Session expires: ${session.expiresAt}');
  
  // التحقق من أن Session محفوظة
  final currentSession = supabaseClient.auth.currentSession;
  if (currentSession != null) {
    debugPrint('✅ Session محفوظة بنجاح');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الدخول بنجاح! جاري تحميل التطبيق...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1000));
  } else {
    debugPrint('⚠️ Session غير محفوظة - إعادة المحاولة...');
    throw Exception('فشل حفظ الجلسة. يرجى المحاولة مرة أخرى.');
  }
}
```

**بعد:**
```dart
final email = _emailController.text.trim().toLowerCase();
final password = _passwordController.text;

debugPrint('🔐 محاولة تسجيل الدخول: $email');

final result = await MbuyAuthService.login(
  email: email,
  password: password,
);

if (mounted) {
  final user = result['user'] as Map<String, dynamic>;
  debugPrint('✅ تم تسجيل الدخول: ${user['email']}');
  
  // التحقق من أن Token محفوظ
  final isLoggedIn = await MbuyAuthService.isLoggedIn();
  if (isLoggedIn) {
    debugPrint('✅ Token محفوظ بنجاح');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الدخول بنجاح! جاري تحميل التطبيق...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1000));
  } else {
    debugPrint('⚠️ Token غير محفوظ - إعادة المحاولة...');
    throw Exception('فشل حفظ الجلسة. يرجى المحاولة مرة أخرى.');
  }
}
```

---

## 📝 ملاحظات مهمة

### 1. إزالة Supabase Auth Checks

- إزالة جميع الاستدعاءات لـ `supabaseClient.auth.currentSession`
- استبدالها بـ `MbuyAuthService.isLoggedIn()`

### 2. معالجة الأخطاء

`MbuyAuthService` يرمي `Exception` مع رسائل خطأ واضحة:
- `"البريد الإلكتروني أو كلمة المرور غير صحيحة"` - عند خطأ في Credentials
- `"تم تعطيل حسابك. يرجى التواصل مع الدعم"` - عند تعطيل الحساب

### 3. إنشاء المتجر للتاجر

بعد Register للتاجر، يجب إنشاء المتجر عبر API:
```dart
if (_selectedRole == 'merchant') {
  try {
    await ApiService.createStore(
      name: _storeNameController.text.trim(),
      city: _cityController.text.trim(),
      // ... باقي البيانات
    );
  } catch (e) {
    debugPrint('⚠️ فشل إنشاء المتجر: $e');
  }
}
```

---

## ✅ Checklist بعد التحديث

- [ ] تم تحديث الـ imports
- [ ] تم تحديث Register function
- [ ] تم تحديث Login function
- [ ] تم إزالة `supabaseClient.auth` checks
- [ ] تم إضافة معالجة الأخطاء
- [ ] تم اختبار Register
- [ ] تم اختبار Login
- [ ] تم التحقق من حفظ Token
- [ ] تم التحقق من حفظ User ID و Email

---

## 🧪 اختبار بعد التحديث

1. **اختبار Register:**
   - إنشاء حساب جديد
   - التحقق من ظهور رسالة النجاح
   - التحقق من حفظ Token (استخدم Debug Console)

2. **اختبار Login:**
   - تسجيل الدخول بحساب موجود
   - التحقق من ظهور رسالة النجاح
   - التحقق من حفظ Token

3. **اختبار Error Handling:**
   - محاولة Login بكلمة مرور خاطئة
   - التحقق من ظهور رسالة الخطأ الصحيحة

---

**تاريخ الإنشاء:** 2025-12-06  
**آخر تحديث:** 2025-12-06

