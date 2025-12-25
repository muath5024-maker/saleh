'use client';

import { useState } from 'react';

interface Step3Props {
  onNext: (data: any) => void;
  onBack: () => void;
  storeData: any;
}

const questions = [
  {
    id: 'target_audience',
    question: 'من هو جمهورك المستهدف؟',
    options: [
      'رجال',
      'نساء',
      'أطفال',
      'جميع الفئات',
    ],
  },
  {
    id: 'product_type',
    question: 'ما نوع المنتجات التي تبيعها؟',
    options: [
      'أزياء وملابس',
      'إلكترونيات',
      'منتجات منزلية',
      'أطعمة ومشروبات',
      'أخرى',
    ],
  },
  {
    id: 'price_range',
    question: 'ما نطاق الأسعار؟',
    options: [
      'اقتصادي (أقل من 100 ر.س)',
      'متوسط (100-500 ر.س)',
      'راقي (500-2000 ر.س)',
      'فاخر (أكثر من 2000 ر.س)',
    ],
  },
  {
    id: 'style',
    question: 'ما هو أسلوب متجرك؟',
    options: [
      'عصري ومبتكر',
      'كلاسيكي وأنيق',
      'شبابي وحيوي',
      'فاخر ومميز',
    ],
  },
];

export default function OnboardingStep3({ onNext, onBack, storeData }: Step3Props) {
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);

  const handleAnswer = (questionId: string, answer: string) => {
    setAnswers((prev) => ({ ...prev, [questionId]: answer }));
  };

  const handleNext = () => {
    if (currentQuestionIndex < questions.length - 1) {
      setCurrentQuestionIndex((prev) => prev + 1);
    } else {
      // All questions answered
      onNext({ answers });
    }
  };

  const handleBack = () => {
    if (currentQuestionIndex > 0) {
      setCurrentQuestionIndex((prev) => prev - 1);
    } else {
      onBack();
    }
  };

  const currentQuestion = questions[currentQuestionIndex];
  const isAnswered = answers[currentQuestion.id];
  const isLastQuestion = currentQuestionIndex === questions.length - 1;

  return (
    <div className="max-w-2xl mx-auto bg-white rounded-lg shadow-lg p-8">
      <div className="mb-6">
        <div className="flex items-center justify-between mb-2">
          <span className="text-sm font-medium text-gray-700">
            السؤال {currentQuestionIndex + 1} من {questions.length}
          </span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-2">
          <div
            className="bg-blue-600 h-2 rounded-full transition-all duration-300"
            style={{ width: `${((currentQuestionIndex + 1) / questions.length) * 100}%` }}
          />
        </div>
      </div>

      <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">
        {currentQuestion.question}
      </h2>

      <div className="space-y-3 mb-8">
        {currentQuestion.options.map((option) => (
          <button
            key={option}
            onClick={() => handleAnswer(currentQuestion.id, option)}
            className={`w-full text-right px-6 py-4 border-2 rounded-lg transition-all ${
              answers[currentQuestion.id] === option
                ? 'border-blue-600 bg-blue-50 dark:bg-blue-900/30 text-blue-900 dark:text-blue-100'
                : 'border-gray-200 dark:border-gray-700 hover:border-blue-300 hover:bg-gray-50 dark:hover:bg-gray-800'
            }`}
            aria-pressed={answers[currentQuestion.id] === option}
          >
            {option}
          </button>
        ))}
      </div>

      <div className="flex flex-col gap-3">
        <div className="flex gap-4">
          <button
            onClick={handleBack}
            className="flex-1 bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-200 py-3 px-6 rounded-lg font-medium hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors min-h-[48px]"
            aria-label={currentQuestionIndex === 0 ? 'العودة للخطوة السابقة' : 'العودة للسؤال السابق'}
          >
            {currentQuestionIndex === 0 ? 'السابق' : 'السؤال السابق'}
          </button>
          <button
            onClick={handleNext}
            disabled={!isAnswered}
            className="flex-1 bg-blue-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors min-h-[48px]"
            aria-label={isLastQuestion ? 'الانتقال للخطوة التالية' : 'الانتقال للسؤال التالي'}
            aria-disabled={!isAnswered}
          >
            {isLastQuestion ? 'التالي' : 'السؤال التالي'}
          </button>
        </div>
        <button
          onClick={() => onNext({ answers: {}, skipped: true })}
          className="text-gray-500 dark:text-gray-400 text-sm hover:text-gray-700 dark:hover:text-gray-200 py-2 transition-colors"
          aria-label="تخطي هذه الخطوة"
        >
          تخطي →
        </button>
      </div>
          className="flex-1 bg-blue-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
          aria-label={isLastQuestion ? 'الانتقال للخطوة التالية' : 'الانتقال للسؤال التالي'}
          aria-disabled={!isAnswered}
        >
          {isLastQuestion ? 'التالي' : 'السؤال التالي'}
        </button>
      </div>
    </div>
  );
}
