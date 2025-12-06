# 🎯 خطة تنفيذ البنية الأساسية الشاملة - MBUY

## 📋 ملخص المشروع

تهيئة البنية الأساسية لـ 12 ميزة رئيسية مع التركيز على:
- الميزات المفقودة التي تحتاج UI + Route + Service → إنشاء كامل
- الميزات التي تحتاج Structure فقط → إنشاء الهياكل الأساسية

---

## 📊 تحليل الحالة الحالية

### ✅ موجود بالفعل:
1. Products (merchant) - ✅
2. Orders (merchant + customer) - ✅
3. Wallet (customer + merchant) - ✅
4. Points (customer + merchant) - ✅
5. Coupons (customer + merchant) - ✅
6. Favorites (customer) - ✅ (ملاحظة: Wishlist مختلف)
7. Stories (merchant) - ✅
8. Banners (merchant) - ✅
9. Categories (customer) - ✅

### ❌ مفقود (يحتاج إنشاء):
1. **Wishlist** - ❌ (مختلف عن Favorites)
2. **Recently Viewed** - ❌
3. **Product Variants** - ❌
4. **Bulk Operations** - ❌
5. **Product Attributes** - ❌
6. **Product Bundles** - ❌
7. **Store Settings** - ❌
8. **Staff & Roles** - ❌
9. **Returns/Refunds** - ❌
10. **BNPL Support** - ❌
11. **Saved Cards** - ❌
12. **AI/Advanced Features** - ❌

---

## 🚀 خطة التنفيذ المرحلية

### المرحلة 1: Customer Features المفقودة (الأولوية) ⏱️ 2-3 ساعات

#### 1.1 Wishlist (كامل)
- [x] Model: `wishlist_model.dart`
- [x] Service: `wishlist_service.dart`
- [x] Screen: `wishlist_screen.dart`
- [x] Route: `/wishlist`
- [x] Button في Product Details

#### 1.2 Recently Viewed (كامل)
- [x] Model: `recently_viewed_model.dart`
- [x] Service: `recently_viewed_service.dart`
- [x] Screen: `recently_viewed_screen.dart`
- [x] Route: `/recently-viewed`
- [x] Integration مع Product Details

---

### المرحلة 2: Product Management (الأولوية) ⏱️ 4-5 ساعات

#### 2.1 Product Variants (كامل)
- [x] Model: `product_variant_model.dart`
- [x] Service: `product_variant_service.dart`
- [x] Screen: `product_variants_screen.dart`
- [x] Route: `/merchant/products/variants`
- [x] Button في Merchant Products

#### 2.2 Bulk Operations (كامل)
- [x] Model: `bulk_operation_model.dart`
- [x] Service: `bulk_operations_service.dart`
- [x] Screen: `bulk_operations_screen.dart`
- [x] Route: `/merchant/products/bulk`
- [x] Button في Merchant Products

#### 2.3 Product Attributes (Structure)
- [x] Model: `product_attribute_model.dart`
- [x] Service: `product_attribute_service.dart`
- [ ] TODO: UI integration

#### 2.4 Product Bundles (Structure)
- [x] Model: `product_bundle_model.dart`
- [x] Service: `product_bundle_service.dart`
- [ ] TODO: UI integration

#### 2.5 SKU Management (Enhancement)
- [x] Service enhancement
- [ ] TODO: UI enhancement

---

### المرحلة 3: Store Management ⏱️ 2-3 ساعات

#### 3.1 Store Settings (Structure)
- [x] Model: `store_settings_model.dart`
- [x] Service: `store_settings_service.dart`
- [ ] TODO: UI screen

#### 3.2 Staff & Roles (Structure)
- [x] Model: `store_staff_model.dart`
- [x] Service: `store_staff_service.dart`
- [ ] TODO: UI screen

---

### المرحلة 4: Order Management ⏱️ 2-3 ساعات

#### 4.1 Returns/Refunds (Structure)
- [x] Model: `order_return_model.dart`
- [x] Service: `returns_refunds_service.dart`
- [ ] TODO: UI screen

#### 4.2 Shipping Enhancement
- [x] Service: `shipping_service.dart`
- [ ] TODO: UI integration

---

### المرحلة 5: Payment Features ⏱️ 2-3 ساعات

#### 5.1 BNPL Support (Structure)
- [x] Model: `bnpl_model.dart`
- [x] Service: `bnpl_service.dart`
- [ ] TODO: UI integration

#### 5.2 Saved Cards (Structure)
- [x] Model: `saved_card_model.dart`
- [x] Service: `saved_cards_service.dart`
- [ ] TODO: UI screen

---

### المرحلة 6: Advanced Features ⏱️ 2-3 ساعات

#### 6.1 AI Recommendations (Structure)
- [x] Service: `ai_recommendations_service.dart`
- [ ] TODO: Integration

#### 6.2 Fraud Detection (Structure)
- [x] Service: `fraud_detection_service.dart`
- [ ] TODO: Integration

#### 6.3 Inventory Forecasting (Structure)
- [x] Service: `inventory_forecasting_service.dart`
- [ ] TODO: Integration

#### 6.4 Automation Hooks (Structure)
- [x] Service: `automation_service.dart`
- [ ] TODO: Integration

---

## 📁 الهيكل النهائي المقترح

```
lib/
├── features/
│   ├── customer/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── wishlist_model.dart ✨
│   │   │   │   └── recently_viewed_model.dart ✨
│   │   │   └── services/
│   │   │       ├── wishlist_service.dart ✨
│   │   │       └── recently_viewed_service.dart ✨
│   │   └── presentation/
│   │       └── screens/
│   │           ├── wishlist_screen.dart ✨
│   │           └── recently_viewed_screen.dart ✨
│   ├── merchant/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── product_variant_model.dart ✨
│   │   │   │   ├── product_attribute_model.dart ✨
│   │   │   │   ├── product_bundle_model.dart ✨
│   │   │   │   ├── store_staff_model.dart ✨
│   │   │   │   └── store_settings_model.dart ✨
│   │   │   └── services/
│   │   │       ├── product_variant_service.dart ✨
│   │   │       ├── product_attribute_service.dart ✨
│   │   │       ├── product_bundle_service.dart ✨
│   │   │       ├── bulk_operations_service.dart ✨
│   │   │       ├── store_staff_service.dart ✨
│   │   │       └── store_settings_service.dart ✨
│   │   └── presentation/
│   │       └── screens/
│   │           ├── product_variants_screen.dart ✨
│   │           ├── bulk_operations_screen.dart ✨
│   │           ├── store_staff_screen.dart (TODO)
│   │           └── store_settings_screen.dart (TODO)
│   └── shared/
│       ├── models/
│       │   ├── order_return_model.dart ✨
│       │   ├── refund_model.dart ✨
│       │   ├── bnpl_model.dart ✨
│       │   └── saved_card_model.dart ✨
│       └── services/
│           ├── returns_refunds_service.dart ✨
│           ├── shipping_service.dart ✨
│           ├── bnpl_service.dart ✨
│           └── saved_cards_service.dart ✨
└── core/
    └── services/
        ├── ai_recommendations_service.dart ✨
        ├── fraud_detection_service.dart ✨
        ├── inventory_forecasting_service.dart ✨
        └── automation_service.dart ✨
```

---

## ⏱️ الوقت المتوقع

- المرحلة 1: 2-3 ساعات ✅
- المرحلة 2: 4-5 ساعات ✅
- المرحلة 3: 2-3 ساعات ✅
- المرحلة 4: 2-3 ساعات ✅
- المرحلة 5: 2-3 ساعات ✅
- المرحلة 6: 2-3 ساعات ✅

**الإجمالي:** 14-20 ساعة

---

**سيتم التنفيذ الآن بشكل تدريجي ومنظم.**

