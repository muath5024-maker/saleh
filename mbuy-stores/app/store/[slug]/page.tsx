import { notFound } from 'next/navigation';
import { workerClient } from '@/lib/api/worker-client';
import StoreHeader from '@/components/store/StoreHeader';
import ProductCard from '@/components/store/ProductCard';
import { getTheme } from '@/lib/themes/themes';

interface StorePageProps {
  params: {
    slug: string;
  };
}

export default async function StorePage({ params }: StorePageProps) {
  const { slug } = params;

  try {
    // Fetch store data
    const storeResponse = await workerClient.getStoreBySlug(slug);
    if (!storeResponse.ok || !storeResponse.data) {
      notFound();
    }

    const store = storeResponse.data;

    // Fetch store theme
    const themeResponse = await workerClient.getStoreTheme(slug);
    const themeData = themeResponse.ok ? themeResponse.data : null;
    const theme = themeData?.theme_id
      ? getTheme(themeData.theme_id)
      : getTheme('modern');

    // Fetch store products
    const productsResponse = await workerClient.getStoreProducts(slug, {
      limit: 20,
      offset: 0,
    });
    const products = productsResponse.ok ? productsResponse.data : [];

    // Apply theme styles
    const themeStyles = theme
      ? `
        :root {
          --color-primary: ${theme.colors.primary};
          --color-secondary: ${theme.colors.secondary};
          --color-accent: ${theme.colors.accent};
          --color-background: ${theme.colors.background};
          --color-surface: ${theme.colors.surface};
          --color-text: ${theme.colors.text};
          --color-text-secondary: ${theme.colors.textSecondary};
        }
        body {
          font-family: ${theme.typography.fontFamily};
          background-color: ${theme.colors.background};
          color: ${theme.colors.text};
        }
      `
      : '';

    return (
      <>
        <style dangerouslySetInnerHTML={{ __html: themeStyles }} />
        <div className="min-h-screen" style={{ backgroundColor: theme?.colors.background || '#FFFFFF' }}>
          <StoreHeader store={store} theme={theme} />

          {/* Products Section */}
          <section className="container mx-auto px-4 py-12">
            <h2 className="text-2xl font-bold mb-6" style={{ color: theme?.colors.text || '#111827' }}>
              المنتجات
            </h2>

            {products.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-gray-500">لا توجد منتجات متاحة حالياً</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {products.map((product: any) => (
                  <ProductCard key={product.id} product={product} theme={theme} />
                ))}
              </div>
            )}
          </section>
        </div>
      </>
    );
  } catch (error) {
    console.error('Error loading store:', error);
    notFound();
  }
}
