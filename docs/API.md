# 📡 دليل API - MBUY

<div dir="rtl">

## 🔗 Base URL

```
https://misty-mode-b68b.baharista1.workers.dev
```

---

## 🔐 Authentication

جميع الـ endpoints المحمية تتطلب JWT token في header:

```
Authorization: Bearer <token>
```

---

## 📋 Endpoints

### Auth Endpoints

#### POST /auth/register
تسجيل مستخدم جديد

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "اسم المستخدم",
  "phone": "+966501234567"
}
```

**Response:**
```json
{
  "ok": true,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "اسم المستخدم",
    "is_active": true
  },
  "token": "jwt_token_here"
}
```

#### POST /auth/login
تسجيل الدخول

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "ok": true,
  "user": {...},
  "token": "jwt_token_here"
}
```

#### GET /auth/me
جلب المستخدم الحالي (محمي)

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "ok": true,
  "user": {...}
}
```

#### POST /auth/logout
تسجيل الخروج (محمي)

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "ok": true,
  "message": "Logged out successfully"
}
```

---

### Products Endpoints

#### GET /secure/products
جلب المنتجات (محمي)

**Query Parameters:**
- `limit` (optional): عدد النتائج
- `offset` (optional): الإزاحة

**Response:**
```json
{
  "ok": true,
  "data": [...]
}
```

#### POST /secure/products
إضافة منتج جديد (محمي - تاجر فقط)

**Request:**
```json
{
  "name": "اسم المنتج",
  "price": 100.00,
  "description": "وصف المنتج",
  "category_id": "uuid",
  "main_image_url": "https://..."
}
```

**Response:**
```json
{
  "ok": true,
  "data": {...}
}
```

---

### Orders Endpoints

#### GET /secure/orders
جلب الطلبات (محمي)

**Query Parameters:**
- `status` (optional): فلترة حسب الحالة

**Response:**
```json
{
  "ok": true,
  "data": [...]
}
```

#### POST /secure/orders/create-from-cart
إنشاء طلب من السلة (محمي)

**Request:**
```json
{
  "cart_id": "uuid",
  "delivery_address": "عنوان التوصيل",
  "payment_method": "wallet",
  "total_amount": 500.00
}
```

**Response:**
```json
{
  "ok": true,
  "data": {
    "order_id": "uuid"
  }
}
```

#### PUT /secure/orders/:id/status
تحديث حالة الطلب (محمي - تاجر فقط)

**Request:**
```json
{
  "status": "confirmed",
  "notes": "ملاحظات اختيارية"
}
```

**Response:**
```json
{
  "ok": true,
  "data": {
    "order_id": "uuid",
    "status": "confirmed"
  }
}
```

#### GET /secure/orders/:id/status-history
جلب سجل حالة الطلب (محمي)

**Response:**
```json
{
  "ok": true,
  "data": [
    {
      "id": "uuid",
      "order_id": "uuid",
      "status": "pending",
      "notes": null,
      "changed_by": "uuid",
      "created_at": "2025-01-07T10:00:00Z"
    }
  ]
}
```

---

### User Endpoints

#### GET /secure/users/me
جلب ملف المستخدم (محمي)

**Response:**
```json
{
  "ok": true,
  "data": {
    "id": "uuid",
    "role": "customer",
    "display_name": "اسم المستخدم",
    "email": "user@example.com"
  }
}
```

---

### Cart Endpoints

#### GET /secure/carts/active
جلب السلة النشطة (محمي)

**Response:**
```json
{
  "ok": true,
  "data": {
    "id": "uuid",
    "user_id": "uuid",
    "items": [...]
  }
}
```

---

## ⚠️ Error Responses

جميع الـ errors تستخدم format موحد:

```json
{
  "ok": false,
  "code": "ERROR_CODE",
  "error": "Error description",
  "message": "رسالة الخطأ للمستخدم"
}
```

### Error Codes

- `BAD_REQUEST` - بيانات غير صحيحة
- `UNAUTHORIZED` - يجب تسجيل الدخول
- `FORBIDDEN` - ليس لديك صلاحية الوصول
- `NOT_FOUND` - العنصر غير موجود
- `ORDER_NOT_FOUND` - الطلب غير موجود
- `PRODUCT_NOT_FOUND` - المنتج غير موجود
- `STORE_NOT_FOUND` - المتجر غير موجود
- `INTERNAL_ERROR` - خطأ في الخادم

---

## 📝 Examples

### Flutter Example

```dart
// Login
final response = await ApiService.post(
  '/auth/login',
  data: {
    'email': 'user@example.com',
    'password': 'password123',
  },
  requireAuth: false,
);

if (response['ok'] == true) {
  final token = response['token'];
  await SecureStorageService.saveToken(token);
}

// Get Products
final products = await ApiService.get('/secure/products');

// Create Order
final order = await ApiService.post(
  '/secure/orders/create-from-cart',
  data: {
    'cart_id': cartId,
    'delivery_address': address,
    'payment_method': 'wallet',
    'total_amount': total,
  },
);
```

---

</div>

