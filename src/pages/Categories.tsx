import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { supabase, Category, Product } from '../lib/supabase';
import { ProductCard } from '../components/ProductCard';
import { Loader2 } from 'lucide-react';

export function Categories() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    if (selectedCategory) {
      loadProductsByCategory(selectedCategory);
    } else {
      loadAllProducts();
    }
  }, [selectedCategory]);

  const loadData = async () => {
    setLoading(true);
    const { data: categoriesData } = await supabase
      .from('categories')
      .select('*')
      .order('name');

    if (categoriesData) {
      setCategories(categoriesData);
    }

    await loadAllProducts();
    setLoading(false);
  };

  const loadAllProducts = async () => {
    const { data } = await supabase
      .from('products')
      .select('*')
      .order('name');

    if (data) {
      setProducts(data);
    }
  };

  const loadProductsByCategory = async (categoryId: string) => {
    const { data } = await supabase
      .from('products')
      .select('*')
      .eq('category_id', categoryId)
      .order('name');

    if (data) {
      setProducts(data);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-gradient-to-r from-blue-600 to-cyan-600 text-white py-16 px-4">
        <div className="max-w-7xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-bold mb-4">
            Shop by Category
          </h1>
          <p className="text-xl text-blue-50">
            Explore our curated collections
          </p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid md:grid-cols-4 gap-4 mb-12">
          <button
            onClick={() => setSelectedCategory(null)}
            className={`p-6 rounded-xl transition-all duration-200 ${
              selectedCategory === null
                ? 'bg-blue-600 text-white shadow-lg scale-105'
                : 'bg-white text-gray-900 hover:shadow-md hover:scale-105'
            }`}
          >
            <div className="font-semibold text-lg">All Products</div>
          </button>
          {categories.map((category) => (
            <button
              key={category.id}
              onClick={() => setSelectedCategory(category.id)}
              className={`p-6 rounded-xl transition-all duration-200 text-left ${
                selectedCategory === category.id
                  ? 'bg-blue-600 text-white shadow-lg scale-105'
                  : 'bg-white text-gray-900 hover:shadow-md hover:scale-105'
              }`}
            >
              <div className="font-semibold text-lg mb-2">{category.name}</div>
              <div
                className={`text-sm ${
                  selectedCategory === category.id
                    ? 'text-blue-100'
                    : 'text-gray-600'
                }`}
              >
                {category.description}
              </div>
            </button>
          ))}
        </div>

        <div className="mb-6">
          <h2 className="text-2xl font-bold text-gray-900">
            {selectedCategory
              ? categories.find((c) => c.id === selectedCategory)?.name
              : 'All Products'}
          </h2>
          <p className="text-gray-600 mt-1">{products.length} products found</p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {products.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>

        {products.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-600 text-lg">
              No products found in this category
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
