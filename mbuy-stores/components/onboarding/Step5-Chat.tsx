'use client';

import { useState, useRef, useEffect } from 'react';
import { Send, MessageCircle, Bot, User } from 'lucide-react';

interface Step5Props {
  onComplete: (data: any) => void;
  onBack: () => void;
  storeData: any;
}

export default function OnboardingStep5({ onComplete, onBack, storeData }: Step5Props) {
  const [messages, setMessages] = useState<Array<{ role: 'user' | 'assistant'; content: string; id: string }>>([
    {
      role: 'assistant',
      content: `مرحباً! أنا مساعدك الذكي. سأساعدك في إكمال هوية متجرك "${storeData.name}". هل لديك أي أسئلة أو تريد إضافة أي تفاصيل؟`,
      id: 'welcome',
    },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [newMessageAnnouncement, setNewMessageAnnouncement] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSend = async () => {
    if (!input.trim() || loading) return;

    const userMessage = { 
      role: 'user' as const, 
      content: input,
      id: `user-${Date.now()}`,
    };
    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    // TODO: Call AI chat API
    setTimeout(() => {
      const assistantMessage = {
        role: 'assistant' as const,
        content: 'شكراً لك! سأقوم بتحديث هوية متجرك بناءً على ما ذكرته.',
        id: `assistant-${Date.now()}`,
      };
      setMessages((prev) => [...prev, assistantMessage]);
      setNewMessageAnnouncement(assistantMessage.content);
      setLoading(false);
      // Clear announcement after screen reader reads it
      setTimeout(() => setNewMessageAnnouncement(''), 1000);
    }, 1000);
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  const handleComplete = () => {
    onComplete({
      chat_history: messages,
    });
  };

  return (
    <div className="max-w-3xl mx-auto bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8">
      <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
        أكمل هوية متجرك
      </h2>
      <p className="text-gray-600 dark:text-gray-300 mb-6">
        تحدث مع مساعدنا الذكي لإكمال تفاصيل متجرك
      </p>

      {/* Screen reader announcement for new messages */}
      <div 
        role="status" 
        aria-live="polite" 
        aria-atomic="true" 
        className="sr-only"
      >
        {newMessageAnnouncement}
      </div>

      {/* Chat Messages */}
      <div 
        className="border border-gray-200 dark:border-gray-700 rounded-lg h-96 overflow-y-auto p-4 mb-4 bg-gray-50 dark:bg-gray-900"
        role="log"
        aria-label="محادثة المساعد الذكي"
        aria-live="polite"
      >
        {messages.map((message) => (
          <div
            key={message.id}
            className={`mb-4 flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[80%] rounded-lg p-3 ${
                message.role === 'user'
                  ? 'bg-blue-600 text-white'
                  : 'bg-white dark:bg-gray-800 text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700'
              }`}
              role="article"
              aria-label={message.role === 'user' ? 'رسالتك' : 'رد المساعد'}
            >
              <div className="flex items-start gap-2">
                {message.role === 'assistant' ? (
                  <Bot className="w-5 h-5 mt-0.5 text-blue-600 dark:text-blue-400 flex-shrink-0" aria-hidden="true" />
                ) : (
                  <User className="w-5 h-5 mt-0.5 flex-shrink-0" aria-hidden="true" />
                )}
                <span>{message.content}</span>
              </div>
            </div>
          </div>
        ))}
        {loading && (
          <div className="flex justify-start" role="status" aria-label="المساعد يكتب">
            <div className="bg-white dark:bg-gray-800 text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700 rounded-lg p-3">
              <div className="flex items-center gap-2">
                <Bot className="w-5 h-5 text-blue-600 dark:text-blue-400" aria-hidden="true" />
                <span className="flex items-center gap-1">
                  <span className="animate-bounce delay-0">.</span>
                  <span className="animate-bounce delay-100">.</span>
                  <span className="animate-bounce delay-200">.</span>
                </span>
              </div>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="flex gap-2 mb-6">
        <label htmlFor="chat-input" className="sr-only">اكتب رسالتك</label>
        <input
          ref={inputRef}
          id="chat-input"
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="اكتب رسالتك..."
          className="flex-1 px-4 py-3 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          aria-describedby="chat-help"
          disabled={loading}
        />
        <button
          onClick={handleSend}
          disabled={loading || !input.trim()}
          className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors min-w-[52px] min-h-[52px] flex items-center justify-center"
          aria-label="إرسال الرسالة"
          aria-disabled={loading || !input.trim()}
          aria-disabled={loading || !input.trim()}
        >
          <Send className="w-5 h-5" aria-hidden="true" />
        </button>
      </div>

      <div className="flex flex-col gap-3">
        <div className="flex gap-4">
          <button
            onClick={onBack}
            className="flex-1 bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-200 py-3 px-6 rounded-lg font-medium hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors min-h-[48px]"
            aria-label="العودة للخطوة السابقة"
          >
            السابق
          </button>
          <button
            onClick={handleComplete}
            className="flex-1 bg-green-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-green-700 transition-colors min-h-[48px]"
            aria-label="إنهاء الإعداد وإنشاء المتجر"
          >
            إنهاء وإنشاء المتجر
          </button>
        </div>
        <button
          onClick={() => onComplete({ chat_history: [], skipped: true })}
          className="text-gray-500 dark:text-gray-400 text-sm hover:text-gray-700 dark:hover:text-gray-200 py-2 transition-colors"
          aria-label="تخطي المحادثة وإنشاء المتجر"
        >
          تخطي وإنشاء المتجر →
        </button>
      </div>
    </div>
  );
}
