# ✅ تقرير إصلاح مشكلة "لم يتم العثور على متجر لهذا الحساب"

## 📋 ملخص المشكلة

**المشكلة:** ظهور رسالة خطأ "لم يتم العثور على متجر لهذا الحساب، يرجى إنشاء متجر أولاً من قائمة 'إعداد المتجر'" رغم وجود المتجر في قاعدة البيانات.

**المعطيات:**
- `user_profiles.id` = `af5ce06e-c2e8-4de0-ad74-c432ff...` (role = merchant)
- `stores.owner_id` = `af5ce06e-c2e8-4de0-ad74-c432ff...`
- `stores.id` = `98f67597-ad0f-459c-9f3f-4b8984a37a05`
- `stores.name` = `mbuy`
- `stores.status` = `active`
- `stores.is_active` = `true`

---

## ✅ التعديلات المنفذة

### 1. تعديل Worker Endpoint (`/secure/merchant/store`)

**الملف:** `mbuy-worker/src/index.ts`

**التعديلات:**
- ✅ تغيير من استخدام REST API مباشرة مع `ANON_KEY` إلى استخدام Edge Function
- ✅ إضافة logging شامل في Worker
- ✅ تمرير Authorization header إلى Edge Function

**الكود النهائي:**
```typescript
app.get('/secure/merchant/store', async (c) => {
  try {
    const userId = c.get('userId'); // auth.users.id (from JWT)
    const userEmail = c.get('userEmail'); // user email from JWT
    
    console.log('[Worker] GET /secure/merchant/store - Request received:', {
      userId,
      userEmail: userEmail || 'N/A',
      timestamp: new Date().toISOString(),
    });

    if (!userId) {
      console.error('[Worker] GET /secure/merchant/store - No userId found');
      return c.json({ ok: false, error: 'Unauthorized', detail: 'User ID not found' }, 401);
    }

    // Use Edge Function instead of direct REST API (bypasses RLS with SERVICE_ROLE_KEY)
    const authHeader = c.req.header('Authorization');
    if (!authHeader) {
      console.error('[Worker] GET /secure/merchant/store - No Authorization header');
      return c.json({ ok: false, error: 'Unauthorized', detail: 'Missing Authorization header' }, 401);
    }

    console.log('[Worker] GET /secure/merchant/store - Calling Edge Function with userId:', userId);

    const response = await fetch(
      `${c.env.SUPABASE_URL}/functions/v1/merchant_store`,
      {
        method: 'POST',
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
          'x-internal-key': c.env.EDGE_INTERNAL_KEY,
        },
      }
    );

    const data = await response.json();
    
    console.log('[Worker] GET /secure/merchant/store - Edge Function response:', {
      status: response.status,
      ok: data.ok,
      hasData: !!data.data,
      storeId: data.data?.id || null,
      storeName: data.data?.name || null,
      ownerId: data.data?.owner_id || null,
      error: data.error || null,
    });

    // Forward the response from Edge Function
    return c.json(data, response.status);
  } catch (error: any) {
    console.error('[Worker] GET /secure/merchant/store - Error:', {
      message: error.message,
      stack: error.stack,
    });
    return c.json({ 
      ok: false, 
      error: 'Internal server error', 
      detail: error.message 
    }, 500);
  }
});
```

---

### 2. تحديث Edge Function (`merchant_store`)

**الملف:** `mbuy-backend/functions/merchant_store/index.ts`

**التعديلات:**
- ✅ استخدام `SUPABASE_SERVICE_ROLE_KEY` بدلاً من `ANON_KEY` (يتجاوز RLS)
- ✅ استخراج `userId` من JWT بشكل صحيح
- ✅ إضافة logging شامل في كل مرحلة
- ✅ معالجة الأخطاء بشكل صحيح
- ✅ إضافة CORS headers

**الكود النهائي:**
```typescript
// @ts-ignore - Deno ESM import
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-internal-key',
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify internal key
    const internalKey = req.headers.get('x-internal-key');
    if (!internalKey || internalKey !== Deno.env.get('EDGE_INTERNAL_KEY')) {
      console.error('[merchant_store] Invalid internal key');
      return new Response(
        JSON.stringify({ ok: false, error: 'Forbidden', detail: 'Invalid internal key' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      );
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || Deno.env.get('SB_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || Deno.env.get('SB_SERVICE_ROLE_KEY');
    
    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('[merchant_store] Missing Supabase environment variables');
      throw new Error('Missing Supabase environment variables');
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    console.log('[merchant_store] Request received at:', new Date().toISOString());

    // Extract JWT token from Authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      console.error('[merchant_store] Missing or invalid Authorization header');
      return new Response(
        JSON.stringify({ ok: false, error: 'Unauthorized', detail: 'Missing or invalid Authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      );
    }

    const token = authHeader.replace('Bearer ', '');
    
    console.log('[merchant_store] Extracting user from JWT token...');
    
    // Extract user from JWT token
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      console.error('[merchant_store] Authentication error:', {
        error: authError?.message || 'User not found',
        hasUser: !!user,
      });
      return new Response(
        JSON.stringify({ ok: false, error: 'Unauthorized', detail: authError?.message || 'User not found' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      );
    }

    console.log('[merchant_store] User authenticated:', {
      userId: user.id,
      userEmail: user.email || 'N/A',
      timestamp: new Date().toISOString(),
    });

    // Get merchant's store directly
    // Schema: auth.users.id = user_profiles.id = stores.owner_id
    // So we can query stores directly using user.id as owner_id
    console.log('[merchant_store] Querying stores table for owner_id:', user.id);
    
    const { data: store, error: storeError } = await supabase
      .from('stores')
      .select('id, owner_id, name, status, is_active')
      .eq('owner_id', user.id) // user.id = user_profiles.id = stores.owner_id
      .maybeSingle();

    if (storeError) {
      console.error('[merchant_store] Store query error:', {
        code: storeError.code,
        message: storeError.message,
        details: storeError.details,
        hint: storeError.hint,
      });
      return new Response(
        JSON.stringify({ 
          ok: false, 
          error: storeError.message,
          code: storeError.code || 'STORE_QUERY_ERROR',
          detail: storeError.details || null,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        }
      );
    }

    // If no store found, return null (not an error)
    if (!store) {
      console.log('[merchant_store] No store found for user_id:', user.id);
      return new Response(
        JSON.stringify({ ok: true, data: null }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        }
      );
    }

    console.log('[merchant_store] Store found:', {
      storeId: store.id,
      storeName: store.name,
      ownerId: store.owner_id,
      status: store.status,
      isActive: store.is_active,
      userId: user.id,
      userIdMatches: store.owner_id === user.id,
    });

    return new Response(
      JSON.stringify({ 
        ok: true, 
        data: {
          id: store.id,
          owner_id: store.owner_id,
          name: store.name,
          status: store.status,
          is_active: store.is_active,
        }
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
      }
    );
  } catch (error: any) {
    console.error('[merchant_store] Unexpected error:', {
      message: error.message,
      stack: error.stack,
    });
    return new Response(
      JSON.stringify({ ok: false, error: 'Internal server error', detail: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    );
  }
});
```

---

### 3. إضافة Logging في Flutter

**الملفات المعدلة:**

#### 3.1 `saleh/lib/core/root_widget.dart`
- ✅ إضافة logging شامل عند جلب Store ID
- ✅ طباعة User ID من Flutter
- ✅ طباعة Store ID و Owner ID من API
- ✅ مقارنة User ID مع Owner ID

#### 3.2 `saleh/lib/features/merchant/presentation/screens/merchant_home_screen.dart`
- ✅ إضافة logging شامل عند جلب Store ID
- ✅ طباعة User ID من Flutter
- ✅ طباعة Store ID و Owner ID من API
- ✅ مقارنة User ID مع Owner ID

**مثال Logging في Flutter:**
```dart
debugPrint('🔍 [StoreSession] بدء جلب معلومات المتجر...');
debugPrint('🔍 [StoreSession] User ID من Flutter: $userId');
debugPrint('🔍 [StoreSession] User Email: ${userEmail ?? "N/A"}');
debugPrint('🔍 [StoreSession] Timestamp: ${DateTime.now().toIso8601String()}');
```

---

## 📊 الملفات المعدلة

### Backend:
1. ✅ `mbuy-worker/src/index.ts`
   - تعديل endpoint `/secure/merchant/store`
   - استخدام Edge Function بدلاً من REST API
   - إضافة logging شامل

2. ✅ `mbuy-backend/functions/merchant_store/index.ts`
   - استخدام `SERVICE_ROLE_KEY` (يتجاوز RLS)
   - استخراج `userId` من JWT بشكل صحيح
   - إضافة logging شامل
   - معالجة الأخطاء بشكل صحيح

### Flutter:
3. ✅ `saleh/lib/core/root_widget.dart`
   - إضافة logging شامل

4. ✅ `saleh/lib/features/merchant/presentation/screens/merchant_home_screen.dart`
   - إضافة logging شامل

---

## 🎯 النقاط الرئيسية

### المشاكل التي تم حلها:

1. ✅ **استخدام ANON_KEY بدلاً من SERVICE_ROLE_KEY:**
   - **قبل:** Worker يستخدم REST API مباشرة مع `ANON_KEY` (يفشل بسبب RLS)
   - **بعد:** Worker يستخدم Edge Function التي تستخدم `SERVICE_ROLE_KEY` (يتجاوز RLS)

2. ✅ **عدم استخدام Edge Function:**
   - **قبل:** Worker يستخدم REST API مباشرة
   - **بعد:** Worker يستخدم Edge Function المخصصة

3. ✅ **عدم وجود Logging:**
   - **قبل:** لا يوجد logging
   - **بعد:** Logging شامل في Worker و Edge Function و Flutter

---

## 🧪 خطوات الاختبار

### 1. اختبار Worker Endpoint:

```bash
# من Flutter DevTools أو Console
# عند تسجيل الدخول كتاجر، يجب أن يظهر:

[Worker] GET /secure/merchant/store - Request received: { userId: "...", userEmail: "..." }
[Worker] GET /secure/merchant/store - Calling Edge Function with userId: ...
[Worker] GET /secure/merchant/store - Edge Function response: { status: 200, ok: true, hasData: true, ... }
```

### 2. اختبار Edge Function:

```bash
# من Supabase Logs أو Worker Logs، يجب أن يظهر:

[merchant_store] Request received at: 2025-01-XX...
[merchant_store] User authenticated: { userId: "af5ce06e-c2e8-4de0-ad74-c432ff...", userEmail: "..." }
[merchant_store] Querying stores table for owner_id: af5ce06e-c2e8-4de0-ad74-c432ff...
[merchant_store] Store found: { storeId: "98f67597-ad0f-459c-9f3f-4b8984a37a05", storeName: "mbuy", ownerId: "af5ce06e-c2e8-4de0-ad74-c432ff...", userIdMatches: true }
```

### 3. اختبار Flutter:

```bash
# من Flutter Debug Console، يجب أن يظهر:

🔍 [StoreSession] بدء جلب معلومات المتجر...
🔍 [StoreSession] User ID من Flutter: af5ce06e-c2e8-4de0-ad74-c432ff...
🔍 [StoreSession] User Email: ...
📥 [StoreSession] استجابة API: ok=true, hasData=true, error=null
📦 [StoreSession] بيانات المتجر: storeId=98f67597-ad0f-459c-9f3f-4b8984a37a05, storeName=mbuy, ownerId=af5ce06e-c2e8-4de0-ad74-c432ff..., userId=af5ce06e-c2e8-4de0-ad74-c432ff..., userIdMatches=true
✅ [StoreSession] تم حفظ Store ID بعد تسجيل الدخول: 98f67597-ad0f-459c-9f3f-4b8984a37a05
```

---

## 📝 التقرير النهائي

### ✅ الكود النهائي للـ Endpoint:

**Worker:** `mbuy-worker/src/index.ts` (السطر 633-692)
**Edge Function:** `mbuy-backend/functions/merchant_store/index.ts` (كامل الملف)

### ✅ المعلومات المتوقعة في Logs:

1. **User ID من Flutter:**
   - يجب أن يكون: `af5ce06e-c2e8-4de0-ad74-c432ff...`

2. **Owner ID من Database:**
   - يجب أن يكون: `af5ce06e-c2e8-4de0-ad74-c432ff...`

3. **تطابق User ID:**
   - يجب أن يكون: `true`

4. **Store ID:**
   - يجب أن يكون: `98f67597-ad0f-459c-9f3f-4b8984a37a05`

5. **Store Name:**
   - يجب أن يكون: `mbuy`

---

## ✅ النتيجة المتوقعة

### قبل التعديل:
- ❌ رسالة خطأ: "لم يتم العثور على متجر لهذا الحساب"
- ❌ لا يتم جلب المتجر
- ❌ StoreSession فارغ

### بعد التعديل:
- ✅ يتم جلب المتجر بنجاح
- ✅ Store ID يتم حفظه في StoreSession
- ✅ لا تظهر رسالة الخطأ
- ✅ يمكن إضافة منتجات جديدة بنجاح

---

## 🔍 التحقق من الحل

### عند اختبار الحساب التاجر:

1. **تسجيل الدخول:**
   - يجب أن يتم جلب Store ID تلقائياً
   - يجب أن يظهر في Logs: `✅ [StoreSession] تم حفظ Store ID بعد تسجيل الدخول: 98f67597-ad0f-459c-9f3f-4b8984a37a05`

2. **فتح شاشة المنتجات:**
   - يجب ألا تظهر رسالة خطأ
   - يجب أن تعرض المنتجات (إن وجدت)

3. **إضافة منتج جديد:**
   - يجب ألا تظهر رسالة "لم يتم العثور على متجر لهذا الحساب"
   - يجب أن يتم الحفظ بنجاح

---

## 📌 ملاحظات مهمة

1. ✅ **استخدام SERVICE_ROLE_KEY:**
   - Edge Function تستخدم `SUPABASE_SERVICE_ROLE_KEY` الذي يتجاوز RLS policies
   - هذا ضروري لضمان جلب البيانات بشكل صحيح

2. ✅ **استخراج User ID من JWT:**
   - يتم استخراج `userId` من JWT في Worker middleware
   - يتم تمريره إلى Edge Function عبر Authorization header
   - Edge Function تستخرجه مرة أخرى من JWT للتحقق

3. ✅ **Logging شامل:**
   - جميع الخطوات مسجلة في Worker و Edge Function و Flutter
   - يسهل تتبع المشاكل في المستقبل

---

**تاريخ التعديل:** يناير 2025  
**الحالة:** ✅ مكتمل وجاهز للاختبار  
**الملفات المعدلة:** 4 ملفات

