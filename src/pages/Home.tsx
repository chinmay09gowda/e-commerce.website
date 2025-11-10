import { useEffect, useState } from 'react';
import { supabase, Product } from '../lib/supabase';
import { ProductCard } from '../components/ProductCard';
import { Loader2 } from 'lucide-react';

export function Home() {
  const [products, setProducts] = useState<Product[]>([]);
  const [featuredProducts, setFeaturedProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadProducts();
  }, []);

  const loadProducts = async () => {
    setLoading(true);
    const { data: allProducts } = await supabase
      .from('products')
      .select('*')
      .order('created_at', { ascending: false });

    if (allProducts) {
      setProducts(allProducts);
      setFeaturedProducts(allProducts.filter((p) => p.featured));
    }
    setLoading(false);
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
      <div className="relative bg-gradient-to-r from-blue-600 to-cyan-600 text-white py-20 px-4 overflow-hidden">
        <div className="absolute inset-0 bg-black opacity-10"></div>
        <div className="relative max-w-7xl mx-auto text-center">
          <h1 className="text-5xl md:text-6xl font-bold mb-6 animate-fade-in">
            Welcome to ShopHub
          </h1>
          <p className="text-xl md:text-2xl text-blue-50 max-w-2xl mx-auto">
            Discover amazing products at unbeatable prices
          </p>
        </div>
      </div>

      {featuredProducts.length > 0 && (
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="flex items-center justify-between mb-8">
            <h2 className="text-3xl font-bold text-gray-900">
              Featured Products
            </h2>
            <div className="h-1 flex-1 ml-8 bg-gradient-to-r from-blue-600 to-transparent rounded-full"></div>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {featuredProducts.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        </div>
      )}

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="flex items-center justify-between mb-8">
          <h2 className="text-3xl font-bold text-gray-900">All Products</h2>
          <div className="h-1 flex-1 ml-8 bg-gradient-to-r from-cyan-600 to-transparent rounded-full"></div>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {products.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      </div>
    </div>
  );
}
