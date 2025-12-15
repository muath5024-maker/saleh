'use client';

import { Gift, Sparkles, Zap, Heart } from 'lucide-react';

interface Step2Props {
  onNext: () => void;
  onBack: () => void;
  storeData: any;
}

export default function OnboardingStep2({ onNext, onBack, storeData }: Step2Props) {
  const giftItems = [
    { icon: Gift, title: '5 منتجات مجانية', description: 'ابدأ بمنتجاتك الأولى مجاناً' },
    { icon: Sparkles, title: 'شعار احترافي', description: 'نصمم لك شعاراً فورياً' },
    { icon: Zap, title: 'إعداد سريع', description: 'متجرك جاهز في دقائق' },
    { icon: Heart, title: 'دعم فني', description: 'فريقنا معك في كل خطوة' },
  ];

  return (
    <div className="max-w-3xl mx-auto bg-white rounded-lg shadow-lg p-8">
      <div className="text-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          مرحباً بك في {storeData.name || 'متجرك'}! 🎉
        </h1>
        <p className="text-gray-600">
          لقد أنشأت متجرك بنجاح. إليك هدية ترحيبية:
        </p>
      </div>

      {/* Gift Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        {giftItems.map((item, index) => {
          const Icon = item.icon;
          return (
            <div
              key={index}
              className="border-2 border-dashed border-blue-300 bg-blue-50 rounded-lg p-6 text-center"
            >
              <Icon className="w-12 h-12 mx-auto mb-3 text-blue-600" />
              <h3 className="font-bold text-gray-900 mb-1">{item.title}</h3>
              <p className="text-sm text-gray-600">{item.description}</p>
            </div>
          );
        })}
      </div>

      {/* Store URL Preview */}
      <div className="bg-gradient-to-r from-blue-500 to-indigo-600 rounded-lg p-6 text-white text-center mb-8">
        <p className="text-sm mb-2">رابط متجرك:</p>
        <p className="text-2xl font-bold font-mono">
          {storeData.slug || 'store-name'}.mbuy.pro
        </p>
      </div>

      <div className="flex gap-4">
        <button
          onClick={onBack}
          className="flex-1 bg-gray-200 text-gray-700 py-3 px-6 rounded-lg font-medium hover:bg-gray-300 transition-colors"
        >
          السابق
        </button>
        <button
          onClick={onNext}
          className="flex-1 bg-blue-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-700 transition-colors"
        >
          التالي
        </button>
      </div>
    </div>
  );
}
