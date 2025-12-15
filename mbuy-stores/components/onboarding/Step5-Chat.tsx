'use client';

import { useState } from 'react';
import { Send, MessageCircle } from 'lucide-react';

interface Step5Props {
  onComplete: (data: any) => void;
  onBack: () => void;
  storeData: any;
}

export default function OnboardingStep5({ onComplete, onBack, storeData }: Step5Props) {
  const [messages, setMessages] = useState<Array<{ role: 'user' | 'assistant'; content: string }>>([
    {
      role: 'assistant',
      content: `مرحباً! أنا مساعدك الذكي. سأساعدك في إكمال هوية متجرك "${storeData.name}". هل لديك أي أسئلة أو تريد إضافة أي تفاصيل؟`,
    },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSend = async () => {
    if (!input.trim()) return;

    const userMessage = { role: 'user' as const, content: input };
    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    // TODO: Call AI chat API
    setTimeout(() => {
      const assistantMessage = {
        role: 'assistant' as const,
        content: 'شكراً لك! سأقوم بتحديث هوية متجرك بناءً على ما ذكرته.',
      };
      setMessages((prev) => [...prev, assistantMessage]);
      setLoading(false);
    }, 1000);
  };

  const handleComplete = () => {
    onComplete({
      chat_history: messages,
    });
  };

  return (
    <div className="max-w-3xl mx-auto bg-white rounded-lg shadow-lg p-8">
      <h2 className="text-2xl font-bold text-gray-900 mb-2">
        أكمل هوية متجرك
      </h2>
      <p className="text-gray-600 mb-6">
        تحدث مع مساعدنا الذكي لإكمال تفاصيل متجرك
      </p>

      {/* Chat Messages */}
      <div className="border border-gray-200 rounded-lg h-96 overflow-y-auto p-4 mb-4 bg-gray-50">
        {messages.map((message, index) => (
          <div
            key={index}
            className={`mb-4 flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[80%] rounded-lg p-3 ${
                message.role === 'user'
                  ? 'bg-blue-600 text-white'
                  : 'bg-white text-gray-900 border border-gray-200'
              }`}
            >
              {message.role === 'assistant' && (
                <MessageCircle className="w-4 h-4 inline-block mr-2 mb-1" />
              )}
              {message.content}
            </div>
          </div>
        ))}
        {loading && (
          <div className="flex justify-start">
            <div className="bg-white text-gray-900 border border-gray-200 rounded-lg p-3">
              <span className="animate-pulse">جاري الكتابة...</span>
            </div>
          </div>
        )}
      </div>

      {/* Input */}
      <div className="flex gap-2 mb-6">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && handleSend()}
          placeholder="اكتب رسالتك..."
          className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
        <button
          onClick={handleSend}
          disabled={loading || !input.trim()}
          className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
        >
          <Send className="w-5 h-5" />
        </button>
      </div>

      <div className="flex gap-4">
        <button
          onClick={onBack}
          className="flex-1 bg-gray-200 text-gray-700 py-3 px-6 rounded-lg font-medium hover:bg-gray-300 transition-colors"
        >
          السابق
        </button>
        <button
          onClick={handleComplete}
          className="flex-1 bg-green-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-green-700 transition-colors"
        >
          إنهاء وإنشاء المتجر
        </button>
      </div>
    </div>
  );
}
