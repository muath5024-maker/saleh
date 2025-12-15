'use client';

import { useState, useEffect } from 'react';
import { Sparkles, Palette, Layout } from 'lucide-react';
import { workerClient } from '@/lib/api/worker-client';

interface Step4Props {
  onNext: (data: any) => void;
  onBack: () => void;
  storeData: any;
}

export default function OnboardingStep4({ onNext, onBack, storeData }: Step4Props) {
  const [loading, setLoading] = useState(true);
  const [suggestions, setSuggestions] = useState<{
    logos: string[];
    gradients: Array<{ name: string; colors: string[] }>;
    themes: Array<{ id: string; name: string; preview: string }>;
  } | null>(null);
  const [selected, setSelected] = useState<{
    logo?: string;
    gradient?: string;
    theme?: string;
  }>({});

  useEffect(() => {
    loadSuggestions();
  }, []);

  const loadSuggestions = async () => {
    setLoading(true);
    try {
      // TODO: Get auth token and store ID
      const token = '';
      const storeId = '';
      
      const response = await workerClient.getAISuggestions(
        storeId,
        {
          store_name: storeData.name,
          description: storeData.description,
          answers: storeData.answers,
        },
        token
      );

      if (response.ok && response.data) {
        setSuggestions(response.data);
      } else {
        // Fallback to default suggestions
        setSuggestions({
          logos: [
            'https://via.placeholder.com/200x200/2563EB/FFFFFF?text=Logo+1',
            'https://via.placeholder.com/200x200/7C3AED/FFFFFF?text=Logo+2',
            'https://via.placeholder.com/200x200/059669/FFFFFF?text=Logo+3',
          ],
          gradients: [
            { name: 'أزرق كلاسيكي', colors: ['#2563EB', '#1D4ED8'] },
            { name: 'بنفسجي عصري', colors: ['#7C3AED', '#9333EA'] },
            { name: 'أخضر طبيعي', colors: ['#059669', '#047857'] },
          ],
          themes: [
            { id: 'modern', name: 'عصري', preview: 'modern-preview.jpg' },
            { id: 'classic', name: 'كلاسيكي', preview: 'classic-preview.jpg' },
            { id: 'minimal', name: 'بسيط', preview: 'minimal-preview.jpg' },
          ],
        });
      }
    } catch (error) {
      console.error('Error loading suggestions:', error);
      // Use fallback
      setSuggestions({
        logos: [],
        gradients: [],
        themes: [],
      });
    } finally {
      setLoading(false);
    }
  };

  const handleNext = () => {
    onNext({
      branding: {
        logo_url: selected.logo,
        primary_color: selected.gradient,
        theme_id: selected.theme,
      },
    });
  };

  if (loading) {
    return (
      <div className="max-w-3xl mx-auto bg-white rounded-lg shadow-lg p-8 text-center">
        <Sparkles className="w-16 h-16 mx-auto mb-4 text-blue-600 animate-pulse" />
        <p className="text-gray-600">جاري توليد الاقتراحات الذكية...</p>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto bg-white rounded-lg shadow-lg p-8">
      <h2 className="text-2xl font-bold text-gray-900 mb-2">
        اقتراحات ذكية لمتجرك
      </h2>
      <p className="text-gray-600 mb-8">
        اختر من بين الاقتراحات المولدة بالذكاء الاصطناعي
      </p>

      {/* Logos */}
      <div className="mb-8">
        <div className="flex items-center gap-2 mb-4">
          <Sparkles className="w-5 h-5 text-blue-600" />
          <h3 className="text-lg font-semibold text-gray-900">الشعارات</h3>
        </div>
        <div className="grid grid-cols-3 gap-4">
          {suggestions?.logos.map((logo, index) => (
            <button
              key={index}
              onClick={() => setSelected((prev) => ({ ...prev, logo }))}
              className={`border-2 rounded-lg p-4 hover:border-blue-500 transition-all ${
                selected.logo === logo ? 'border-blue-600 bg-blue-50' : 'border-gray-200'
              }`}
            >
              <img src={logo} alt={`Logo ${index + 1}`} className="w-full h-32 object-contain" />
            </button>
          ))}
        </div>
      </div>

      {/* Gradients */}
      <div className="mb-8">
        <div className="flex items-center gap-2 mb-4">
          <Palette className="w-5 h-5 text-blue-600" />
          <h3 className="text-lg font-semibold text-gray-900">الألوان</h3>
        </div>
        <div className="grid grid-cols-3 gap-4">
          {suggestions?.gradients.map((gradient, index) => (
            <button
              key={index}
              onClick={() => setSelected((prev) => ({ ...prev, gradient: gradient.colors[0] }))}
              className={`border-2 rounded-lg p-4 hover:border-blue-500 transition-all ${
                selected.gradient === gradient.colors[0] ? 'border-blue-600 bg-blue-50' : 'border-gray-200'
              }`}
            >
              <div
                className="w-full h-24 rounded mb-2"
                style={{
                  background: `linear-gradient(135deg, ${gradient.colors[0]}, ${gradient.colors[1]})`,
                }}
              />
              <p className="text-sm font-medium text-gray-700">{gradient.name}</p>
            </button>
          ))}
        </div>
      </div>

      {/* Themes */}
      <div className="mb-8">
        <div className="flex items-center gap-2 mb-4">
          <Layout className="w-5 h-5 text-blue-600" />
          <h3 className="text-lg font-semibold text-gray-900">القوالب</h3>
        </div>
        <div className="grid grid-cols-3 gap-4">
          {suggestions?.themes.map((theme) => (
            <button
              key={theme.id}
              onClick={() => setSelected((prev) => ({ ...prev, theme: theme.id }))}
              className={`border-2 rounded-lg p-4 hover:border-blue-500 transition-all ${
                selected.theme === theme.id ? 'border-blue-600 bg-blue-50' : 'border-gray-200'
              }`}
            >
              <div className="w-full h-32 bg-gray-100 rounded mb-2 flex items-center justify-center">
                <span className="text-gray-400">{theme.name}</span>
              </div>
              <p className="text-sm font-medium text-gray-700">{theme.name}</p>
            </button>
          ))}
        </div>
      </div>

      <div className="flex gap-4">
        <button
          onClick={onBack}
          className="flex-1 bg-gray-200 text-gray-700 py-3 px-6 rounded-lg font-medium hover:bg-gray-300 transition-colors"
        >
          السابق
        </button>
        <button
          onClick={handleNext}
          className="flex-1 bg-blue-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-700 transition-colors"
        >
          التالي
        </button>
      </div>
    </div>
  );
}
