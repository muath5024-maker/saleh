'use client';

import Image from 'next/image';

interface StoreHeaderProps {
  store: {
    name: string;
    description?: string;
    logo_url?: string;
    cover_image_url?: string;
  };
  theme: any;
}

export default function StoreHeader({ store, theme }: StoreHeaderProps) {
  return (
    <header className="relative">
      {/* Cover Image */}
      {store.cover_image_url && (
        <div className="h-64 md:h-96 relative overflow-hidden">
          <img
            src={store.cover_image_url}
            alt={store.name}
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent" />
        </div>
      )}

      {/* Store Info */}
      <div className="container mx-auto px-4 py-6">
        <div className="flex items-center gap-6">
          {/* Logo */}
          {store.logo_url ? (
            <div className="w-24 h-24 rounded-full overflow-hidden border-4 border-white shadow-lg">
              <img
                src={store.logo_url}
                alt={store.name}
                className="w-full h-full object-cover"
              />
            </div>
          ) : (
            <div
              className="w-24 h-24 rounded-full flex items-center justify-center text-white text-2xl font-bold shadow-lg"
              style={{ backgroundColor: theme?.colors?.primary || '#2563EB' }}
            >
              {store.name.charAt(0)}
            </div>
          )}

          {/* Store Details */}
          <div className="flex-1">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">{store.name}</h1>
            {store.description && (
              <p className="text-gray-600">{store.description}</p>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}
