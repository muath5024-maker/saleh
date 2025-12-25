'use client';

import Image from 'next/image';
import { useState } from 'react';
import { ShoppingCart, Check } from 'lucide-react';

interface ProductCardProps {
  product: {
    id: string;
    name: string;
    price: number;
    main_image_url?: string;
    description?: string;
    stock?: number;
  };
  theme: any;
  onAddToCart?: (productId: string) => void;
}

export default function ProductCard({ product, theme, onAddToCart }: ProductCardProps) {
  const [imageError, setImageError] = useState(false);
  const [imageLoading, setImageLoading] = useState(true);
  const [isAdding, setIsAdding] = useState(false);
  const [justAdded, setJustAdded] = useState(false);

  const handleAddToCart = async () => {
    if (isAdding || justAdded) return;
    
    setIsAdding(true);
    
    try {
      if (onAddToCart) {
        await onAddToCart(product.id);
      }
      
      setJustAdded(true);
      setTimeout(() => {
        setJustAdded(false);
      }, 2000);
    } catch (error) {
      console.error('Error adding to cart:', error);
    } finally {
      setIsAdding(false);
    }
  };

  return (
    <div
      className="bg-white rounded-lg overflow-hidden shadow-md hover:shadow-lg transition-shadow"
      style={{
        borderRadius: theme?.components?.card?.borderRadius || '16px',
        boxShadow: theme?.components?.card?.shadow || '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
      }}
    >
      {/* Product Image */}
      <div className="relative w-full h-64 bg-gray-100">
        {product.main_image_url && !imageError ? (
          <>
            {imageLoading && (
              <div className="absolute inset-0 animate-pulse bg-gray-200" />
            )}
            <Image
              src={product.main_image_url}
              alt={product.name}
              fill
              className={`object-cover transition-opacity duration-300 ${imageLoading ? 'opacity-0' : 'opacity-100'}`}
              onLoad={() => setImageLoading(false)}
              onError={() => setImageError(true)}
              sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 25vw"
            />
          </>
        ) : (
          <div className="w-full h-full flex items-center justify-center text-gray-400">
            <svg className="w-16 h-16" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <span className="sr-only">لا توجد صورة</span>
          </div>
        )}
      </div>

      {/* Product Info */}
      <div className="p-4">
        <h3 className="font-semibold text-gray-900 dark:text-white mb-2 line-clamp-2">{product.name}</h3>
        {product.description && (
          <p className="text-sm text-gray-600 dark:text-gray-400 mb-3 line-clamp-2">{product.description}</p>
        )}
        <div className="flex items-center justify-between">
          <span
            className="text-xl font-bold"
            style={{ color: theme?.colors?.primary || '#2563EB' }}
          >
            {product.price.toFixed(2)} ر.س
          </span>
          <button
            onClick={handleAddToCart}
            disabled={isAdding || product.stock === 0}
            className={`px-4 py-2 text-white font-medium rounded-lg transition-all min-h-[44px] min-w-[100px] flex items-center justify-center gap-2 ${
              justAdded 
                ? 'bg-green-600 hover:bg-green-700' 
                : product.stock === 0 
                  ? 'bg-gray-400 cursor-not-allowed' 
                  : 'hover:opacity-90 hover:scale-105 active:scale-95'
            }`}
            style={{
              backgroundColor: justAdded ? undefined : (product.stock === 0 ? undefined : theme?.colors?.primary || '#2563EB'),
              borderRadius: theme?.components?.button?.borderRadius || '12px',
            }}
            aria-label={
              justAdded 
                ? `تمت إضافة ${product.name} إلى السلة`
                : product.stock === 0 
                  ? `${product.name} غير متوفر حالياً`
                  : `إضافة ${product.name} إلى السلة`
            }
            aria-live="polite"
          >
            {justAdded ? (
              <>
                <Check className="w-4 h-4" aria-hidden="true" />
                <span>تمت الإضافة</span>
              </>
            ) : isAdding ? (
              <span className="animate-pulse">جاري...</span>
            ) : product.stock === 0 ? (
              <span>غير متوفر</span>
            ) : (
              <>
                <ShoppingCart className="w-4 h-4" aria-hidden="true" />
                <span>أضف للسلة</span>
              </>
            )}
          </button>
        </div>
        {product.stock !== undefined && (
          <p className="text-xs text-gray-500 mt-2">
            المتوفر: {product.stock}
          </p>
        )}
      </div>
    </div>
  );
}
