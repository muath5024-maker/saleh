# 📋 خطة تهيئة البنية الأساسية - مشروع MBUY

## 🎯 الهدف

تهيئة البنية الأساسية لـ 12 ميزة رئيسية بدون تنفيذ كامل، فقط إنشاء الهياكل الأساسية + الخدمات + الملفات + الربط.

---

## 📊 تحليل البنية الحالية

### ✅ ما هو موجود:
1. ✅ Products (merchant) - موجود
2. ✅ Orders (merchant + customer) - موجود
3. ✅ Wallet (customer + merchant) - موجود
4. ✅ Points (customer + merchant) - موجود
5. ✅ Coupons (customer + merchant) - موجود
6. ✅ Favorites (customer) - موجود
7. ✅ Stories (merchant) - موجود
8. ✅ Banners (merchant) - موجود
9. ✅ Categories (customer) - موجود

### ❌ ما هو مفقود (يحتاج إنشاء كامل):
1. ❌ Wishlist (مختلف عن favorites)
2. ❌ Product Variants
3. ❌ Bulk Operations
4. ❌ Product Attributes
5. ❌ Product Bundles
6. ❌ SKU Management UI
7. ❌ Store Settings Structure
8. ❌ Staff & Roles
9. ❌ Returns/Refunds
10. ❌ Shipping Labels
11. ❌ Recently Viewed
12. ❌ BNPL Support (Tabby/Tamara)
13. ❌ Saved Cards
14. ❌ AI Recommendations
15. ❌ Fraud Detection
16. ❌ Inventory Forecasting
17. ❌ Automation Hooks

---

## 📋 خطة التنفيذ

### المرحلة 1: Product Management (الأولوية العالية)

#### 1.1 Product Variants
- [ ] Create Models (ProductVariant, VariantOption)
- [ ] Create Service (product_variant_service.dart)
- [ ] Create Screen (product_variants_screen.dart)
- [ ] Add Route
- [ ] Link to merchant products screen

#### 1.2 Product Attributes
- [ ] Create Models (ProductAttribute, AttributeValue)
- [ ] Create Service (product_attribute_service.dart)
- [ ] Add to product creation/edit screen

#### 1.3 Product Bundles
- [ ] Create Models (ProductBundle, BundleItem)
- [ ] Create Service (product_bundle_service.dart)
- [ ] Create Screen (product_bundles_screen.dart)
- [ ] Add Route

#### 1.4 SKU Management
- [ ] Enhance existing product screen with SKU management
- [ ] Create SKU validation service

#### 1.5 Bulk Operations
- [ ] Create Service (bulk_operations_service.dart)
- [ ] Create Screen (bulk_operations_screen.dart)
- [ ] Add Route
- [ ] Add buttons to merchant products screen

---

### المرحلة 2: Customer Features (الأولوية العالية)

#### 2.1 Wishlist
- [ ] Create Models (Wishlist, WishlistItem)
- [ ] Create Service (wishlist_service.dart)
- [ ] Create Screen (wishlist_screen.dart)
- [ ] Add Route
- [ ] Add button to product details

#### 2.2 Recently Viewed
- [ ] Create Service (recently_viewed_service.dart)
- [ ] Create Screen (recently_viewed_screen.dart)
- [ ] Add Route
- [ ] Integrate with product details

---

### المرحلة 3: Store Management

#### 3.1 Store Settings
- [ ] Create Service (store_settings_service.dart)
- [ ] Create Screen (store_settings_screen.dart)
- [ ] Add Route

#### 3.2 Staff & Roles
- [ ] Create Models (StoreStaff, StaffRole)
- [ ] Create Service (store_staff_service.dart)
- [ ] Create Screen (store_staff_screen.dart)
- [ ] Add Route

---

### المرحلة 4: Order Management

#### 4.1 Returns/Refunds
- [ ] Create Models (OrderReturn, Refund)
- [ ] Create Service (returns_refunds_service.dart)
- [ ] Create Screen (returns_refunds_screen.dart)
- [ ] Add Route

#### 4.2 Shipping
- [ ] Add shipping label fields to orders
- [ ] Create Service (shipping_service.dart)

---

### المرحلة 5: Payment Features

#### 5.1 BNPL Support
- [ ] Create Models (BNPLProvider, BNPLTransaction)
- [ ] Create Service (bnpl_service.dart)
- [ ] Add to checkout flow

#### 5.2 Saved Cards
- [ ] Create Models (SavedCard)
- [ ] Create Service (saved_cards_service.dart)
- [ ] Create Screen (saved_cards_screen.dart)
- [ ] Add Route

---

### المرحلة 6: Advanced Features

#### 6.1 AI Recommendations
- [ ] Create Service (ai_recommendations_service.dart)
- [ ] Add placeholder methods

#### 6.2 Fraud Detection
- [ ] Create Service (fraud_detection_service.dart)
- [ ] Add hooks

#### 6.3 Inventory Forecasting
- [ ] Create Service (inventory_forecasting_service.dart)
- [ ] Add placeholder methods

#### 6.4 Automation Hooks
- [ ] Create Service (automation_service.dart)
- [ ] Add email/WhatsApp hooks

---

## 📁 البنية المقترحة

```
lib/
├── features/
│   ├── customer/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── wishlist_model.dart
│   │   │   │   └── recently_viewed_model.dart
│   │   │   └── services/
│   │   │       ├── wishlist_service.dart
│   │   │       └── recently_viewed_service.dart
│   │   └── presentation/
│   │       └── screens/
│   │           ├── wishlist_screen.dart
│   │           └── recently_viewed_screen.dart
│   ├── merchant/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── product_variant_model.dart
│   │   │   │   ├── product_attribute_model.dart
│   │   │   │   ├── product_bundle_model.dart
│   │   │   │   ├── store_staff_model.dart
│   │   │   │   └── store_settings_model.dart
│   │   │   └── services/
│   │   │       ├── product_variant_service.dart
│   │   │       ├── product_attribute_service.dart
│   │   │       ├── product_bundle_service.dart
│   │   │       ├── bulk_operations_service.dart
│   │   │       ├── store_staff_service.dart
│   │   │       └── store_settings_service.dart
│   │   └── presentation/
│   │       └── screens/
│   │           ├── product_variants_screen.dart
│   │           ├── product_bundles_screen.dart
│   │           ├── bulk_operations_screen.dart
│   │           ├── store_staff_screen.dart
│   │           └── store_settings_screen.dart
│   └── orders/
│       ├── data/
│       │   ├── models/
│       │   │   ├── order_return_model.dart
│       │   │   └── refund_model.dart
│       │   └── services/
│       │       ├── returns_refunds_service.dart
│       │       └── shipping_service.dart
│       └── presentation/
│           └── screens/
│               └── returns_refunds_screen.dart
├── core/
│   └── services/
│       ├── ai_recommendations_service.dart
│       ├── fraud_detection_service.dart
│       ├── inventory_forecasting_service.dart
│       ├── automation_service.dart
│       ├── bnpl_service.dart
│       └── saved_cards_service.dart
```

---

## 🚀 البدء بالتنفيذ

سأبدأ بإنشاء الهياكل الأساسية للميزات المفقودة بالترتيب حسب الأولوية.

