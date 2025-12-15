'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import OnboardingStep1 from '@/components/onboarding/Step1-StoreInfo';
import OnboardingStep2 from '@/components/onboarding/Step2-Welcome';
import OnboardingStep3 from '@/components/onboarding/Step3-Questions';
import OnboardingStep4 from '@/components/onboarding/Step4-AISuggestions';
import OnboardingStep5 from '@/components/onboarding/Step5-Chat';

export default function OnboardingPage() {
  const router = useRouter();
  const [currentStep, setCurrentStep] = useState(1);
  const [storeData, setStoreData] = useState<any>({});

  const handleNext = (data?: any) => {
    if (data) {
      setStoreData((prev: any) => ({ ...prev, ...data }));
    }
    setCurrentStep((prev) => prev + 1);
  };

  const handleBack = () => {
    setCurrentStep((prev) => prev - 1);
  };

  const handleComplete = async (finalData: any) => {
    // Store is ready, redirect to store URL
    const slug = storeData.slug || finalData.slug;
    if (slug) {
      window.location.href = `https://${slug}.mbuy.pro`;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-8">
        {/* Progress Bar */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium text-gray-700">
              الخطوة {currentStep} من 5
            </span>
            <span className="text-sm text-gray-500">
              {Math.round((currentStep / 5) * 100)}%
            </span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-blue-600 h-2 rounded-full transition-all duration-300"
              style={{ width: `${(currentStep / 5) * 100}%` }}
            />
          </div>
        </div>

        {/* Steps */}
        {currentStep === 1 && (
          <OnboardingStep1 onNext={handleNext} initialData={storeData} />
        )}
        {currentStep === 2 && (
          <OnboardingStep2
            onNext={handleNext}
            onBack={handleBack}
            storeData={storeData}
          />
        )}
        {currentStep === 3 && (
          <OnboardingStep3
            onNext={handleNext}
            onBack={handleBack}
            storeData={storeData}
          />
        )}
        {currentStep === 4 && (
          <OnboardingStep4
            onNext={handleNext}
            onBack={handleBack}
            storeData={storeData}
          />
        )}
        {currentStep === 5 && (
          <OnboardingStep5
            onComplete={handleComplete}
            onBack={handleBack}
            storeData={storeData}
          />
        )}
      </div>
    </div>
  );
}
