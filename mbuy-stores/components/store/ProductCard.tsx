'use client';

import Image from 'next/image';

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
}

export default function ProductCard({ product, theme }: ProductCardProps) {
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
        {product.main_image_url ? (
          <img
            src={product.main_image_url}
            alt={product.name}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-gray-400">
            <span>لا توجد صورة</span>
          </div>
        )}
      </div>

      {/* Product Info */}
      <div className="p-4">
        <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2">{product.name}</h3>
        {product.description && (
          <p className="text-sm text-gray-600 mb-3 line-clamp-2">{product.description}</p>
        )}
        <div className="flex items-center justify-between">
          <span
            className="text-xl font-bold"
            style={{ color: theme?.colors?.primary || '#2563EB' }}
          >
            {product.price.toFixed(2)} ر.س
          </span>
          <button
            className="px-4 py-2 text-white font-medium rounded-lg hover:opacity-90 transition-opacity"
            style={{
              backgroundColor: theme?.colors?.primary || '#2563EB',
              borderRadius: theme?.components?.button?.borderRadius || '12px',
            }}
          >
            أضف للسلة
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
