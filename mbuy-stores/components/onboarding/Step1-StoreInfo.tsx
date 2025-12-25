'use client';

import { useState } from 'react';
import { workerClient } from '@/lib/api/worker-client';
import { validateSlug } from '@/lib/utils/store-slug';

interface Step1Props {
  onNext: (data: any) => void;
  initialData?: any;
}

export default function OnboardingStep1({ onNext, initialData }: Step1Props) {
  const [storeName, setStoreName] = useState(initialData?.name || '');
  const [slug, setSlug] = useState(initialData?.slug || '');
  const [description, setDescription] = useState(initialData?.description || '');
  const [city, setCity] = useState(initialData?.city || '');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [slugAvailable, setSlugAvailable] = useState<boolean | null>(null);

  // Auto-generate slug from store name
  const generateSlug = (name: string) => {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .trim();
  };

  const handleStoreNameChange = (value: string) => {
    setStoreName(value);
    if (!slug || slug === generateSlug(initialData?.name || '')) {
      setSlug(generateSlug(value));
    }
  };

  const checkSlugAvailability = async (slugToCheck: string) => {
    if (!slugToCheck || !validateSlug(slugToCheck)) {
      setSlugAvailable(null);
      return;
    }

    setLoading(true);
    setError('');

    try {
      // TODO: Get auth token from context/cookies
      const token = ''; // Will be implemented with auth
      const response = await workerClient.checkSlugAvailability(slugToCheck, token);
      
      if (response.ok && response.data?.available) {
        setSlugAvailable(true);
      } else {
        setSlugAvailable(false);
        setError('هذا الرابط مستخدم بالفعل');
      }
    } catch (err: any) {
      setError('حدث خطأ أثناء التحقق من الرابط');
      setSlugAvailable(false);
    } finally {
      setLoading(false);
    }
  };

  const handleSlugChange = (value: string) => {
    const cleaned = value.toLowerCase().replace(/[^a-z0-9-]/g, '');
    setSlug(cleaned);
    setSlugAvailable(null);
    setError('');

    if (cleaned && validateSlug(cleaned)) {
      checkSlugAvailability(cleaned);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!storeName.trim()) {
      setError('اسم المتجر مطلوب');
      return;
    }

    if (!slug.trim()) {
      setError('رابط المتجر مطلوب');
      return;
    }

    if (!validateSlug(slug)) {
      setError('رابط المتجر غير صحيح. استخدم أحرف إنجليزية وأرقام وشرطات فقط');
      return;
    }

    if (slugAvailable === false) {
      setError('هذا الرابط مستخدم بالفعل');
      return;
    }

    if (slugAvailable === null) {
      await checkSlugAvailability(slug);
      return;
    }

    onNext({
      name: storeName,
      slug,
      description,
      city,
    });
  };

  return (
    <div className="max-w-2xl mx-auto bg-white rounded-lg shadow-lg p-8">
      <h1 className="text-3xl font-bold text-gray-900 mb-2">
        أنشئ متجرك الإلكتروني
      </h1>
      <p className="text-gray-600 mb-8">
        ابدأ بإنشاء متجرك في دقائق معدودة
      </p>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Store Name */}
        <div>
          <label htmlFor="storeName" className="block text-sm font-medium text-gray-700 mb-2">
            اسم المتجر *
          </label>
          <input
            type="text"
            id="storeName"
            value={storeName}
            onChange={(e) => handleStoreNameChange(e.target.value)}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="مثال: متجر الأزياء الراقية"
            required
          />
        </div>

        {/* Slug */}
        <div>
          <label htmlFor="slug" className="block text-sm font-medium text-gray-700 mb-2">
            رابط المتجر *
          </label>
          <div className="flex items-center">
            <input
              type="text"
              id="slug"
              value={slug}
              onChange={(e) => handleSlugChange(e.target.value)}
              className="flex-1 px-4 py-3 border border-gray-300 rounded-l-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="store-name"
              required
            />
            <span className="px-4 py-3 bg-gray-100 border border-l-0 border-gray-300 rounded-r-lg text-gray-600">
              .mbuy.pro
            </span>
          </div>
          {slug && (
            <div className="mt-2">
              {loading ? (
                <p className="text-sm text-gray-500">جاري التحقق...</p>
              ) : slugAvailable === true ? (
                <p className="text-sm text-green-600">✓ الرابط متاح</p>
              ) : slugAvailable === false ? (
                <p className="text-sm text-red-600">✗ الرابط مستخدم</p>
              ) : null}
            </div>
          )}
          <p className="mt-1 text-sm text-gray-500">
            سيظهر متجرك على: <span className="font-mono">{slug || 'store-name'}.mbuy.pro</span>
          </p>
        </div>

        {/* Description */}
        <div>
          <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
            وصف المتجر (اختياري)
          </label>
          <textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={4}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="اكتب وصفاً مختصراً عن متجرك..."
          />
        </div>

        {/* City */}
        <div>
          <label htmlFor="city" className="block text-sm font-medium text-gray-700 mb-2">
            المدينة (اختياري)
          </label>
          <input
            type="text"
            id="city"
            value={city}
            onChange={(e) => setCity(e.target.value)}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="مثال: الرياض"
          />
        </div>

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
            {error}
          </div>
        )}

        <button
          type="submit"
          disabled={loading || slugAvailable === false}
          className="w-full bg-blue-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
          aria-label={loading ? 'جاري التحقق من البيانات' : 'الانتقال للخطوة التالية'}
          aria-busy={loading}
        >
          {loading ? 'جاري التحقق...' : 'التالي'}
        </button>
      </form>
    </div>
  );
}
