'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import OnboardingStep1 from '@/components/onboarding/Step1-StoreInfo';
import OnboardingStep2 from '@/components/onboarding/Step2-Welcome';
import OnboardingStep3 from '@/components/onboarding/Step3-Questions';
import OnboardingStep4 from '@/components/onboarding/Step4-AISuggestions';
import OnboardingStep5 from '@/components/onboarding/Step5-Chat';

const STORAGE_KEY = 'mbuy-onboarding-data';

export default function OnboardingPage() {
  const router = useRouter();
  const [currentStep, setCurrentStep] = useState(1);
  const [storeData, setStoreData] = useState<any>({});
  const [isHydrated, setIsHydrated] = useState(false);

  // Load saved data from localStorage on mount
  useEffect(() => {
    const savedData = localStorage.getItem(STORAGE_KEY);
    if (savedData) {
      try {
        const parsed = JSON.parse(savedData);
        setStoreData(parsed.storeData || {});
        setCurrentStep(parsed.currentStep || 1);
      } catch (e) {
        console.error('Error loading saved onboarding data:', e);
      }
    }
    setIsHydrated(true);
  }, []);

  // Save data to localStorage whenever it changes
  useEffect(() => {
    if (isHydrated) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({
        storeData,
        currentStep,
        lastUpdated: new Date().toISOString(),
      }));
    }
  }, [storeData, currentStep, isHydrated]);

  // Warn user before leaving the page if they have unsaved progress
  useEffect(() => {
    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      if (Object.keys(storeData).length > 0 && currentStep < 5) {
        e.preventDefault();
        e.returnValue = 'لديك تقدم غير محفوظ. هل أنت متأكد من المغادرة؟';
        return e.returnValue;
      }
    };

    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => window.removeEventListener('beforeunload', handleBeforeUnload);
  }, [storeData, currentStep]);

  // Clear saved data on completion
  const clearSavedData = useCallback(() => {
    localStorage.removeItem(STORAGE_KEY);
  }, []);

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
    // Clear saved data on completion
    clearSavedData();
    // Store is ready, redirect to store URL
    const slug = storeData.slug || finalData.slug;
    if (slug) {
      window.location.href = `https://${slug}.mbuy.pro`;
    }
  };

  // Don't render until hydrated to avoid hydration mismatch
  if (!isHydrated) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
        <div className="animate-pulse text-gray-600">جاري التحميل...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-8">
        {/* Progress Bar */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium text-gray-700" id="progress-label">
              الخطوة {currentStep} من 5
            </span>
            <span className="text-sm text-gray-500">
              {Math.round((currentStep / 5) * 100)}%
            </span>
          </div>
          <div 
            className="w-full bg-gray-200 rounded-full h-2"
            role="progressbar"
            aria-valuenow={currentStep}
            aria-valuemin={1}
            aria-valuemax={5}
            aria-labelledby="progress-label"
            aria-label={`التقدم: الخطوة ${currentStep} من 5`}
          >
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
