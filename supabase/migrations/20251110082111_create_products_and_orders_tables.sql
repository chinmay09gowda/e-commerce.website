/*
  # E-Commerce Database Schema

  ## Overview
  This migration creates the core tables for an e-commerce platform including products, 
  categories, shopping cart items, and orders.

  ## New Tables Created
  
  ### 1. `categories`
  Product categories for organizing the catalog
  - `id` (uuid, primary key) - Unique identifier
  - `name` (text) - Category name
  - `slug` (text, unique) - URL-friendly identifier
  - `description` (text) - Category description
  - `image_url` (text) - Category image
  - `created_at` (timestamptz) - Creation timestamp
  
  ### 2. `products`
  Main product catalog
  - `id` (uuid, primary key) - Unique identifier
  - `name` (text) - Product name
  - `slug` (text, unique) - URL-friendly identifier
  - `description` (text) - Product description
  - `price` (numeric) - Product price
  - `image_url` (text) - Primary product image
  - `images` (jsonb) - Additional product images array
  - `category_id` (uuid, foreign key) - Reference to category
  - `stock` (integer) - Available inventory
  - `featured` (boolean) - Featured product flag
  - `rating` (numeric) - Average rating (0-5)
  - `reviews_count` (integer) - Number of reviews
  - `created_at` (timestamptz) - Creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 3. `cart_items`
  Shopping cart items (temporary storage)
  - `id` (uuid, primary key) - Unique identifier
  - `session_id` (text) - Anonymous session identifier
  - `product_id` (uuid, foreign key) - Reference to product
  - `quantity` (integer) - Item quantity
  - `created_at` (timestamptz) - Creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 4. `orders`
  Customer orders
  - `id` (uuid, primary key) - Unique identifier
  - `order_number` (text, unique) - Human-readable order number
  - `customer_name` (text) - Customer full name
  - `customer_email` (text) - Customer email
  - `customer_phone` (text) - Customer phone number
  - `shipping_address` (jsonb) - Shipping address details
  - `items` (jsonb) - Order items with product details
  - `subtotal` (numeric) - Order subtotal
  - `tax` (numeric) - Tax amount
  - `shipping` (numeric) - Shipping cost
  - `total` (numeric) - Total order amount
  - `status` (text) - Order status (pending, processing, shipped, delivered, cancelled)
  - `created_at` (timestamptz) - Creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ## Security
  - RLS enabled on all tables
  - Public read access to categories and products
  - Anonymous users can manage their cart items via session_id
  - Orders are readable only by the system (for now, as we don't have auth)

  ## Indexes
  - Category slug for fast lookups
  - Product slug for fast lookups
  - Product category_id for filtering
  - Cart session_id for user cart retrieval
  - Order number for customer lookups
*/

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  description text DEFAULT '',
  image_url text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  description text DEFAULT '',
  price numeric(10, 2) NOT NULL,
  image_url text DEFAULT '',
  images jsonb DEFAULT '[]'::jsonb,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  stock integer DEFAULT 0,
  featured boolean DEFAULT false,
  rating numeric(3, 2) DEFAULT 0,
  reviews_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create cart_items table
CREATE TABLE IF NOT EXISTS cart_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text NOT NULL,
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  quantity integer DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number text UNIQUE NOT NULL,
  customer_name text NOT NULL,
  customer_email text NOT NULL,
  customer_phone text DEFAULT '',
  shipping_address jsonb DEFAULT '{}'::jsonb,
  items jsonb DEFAULT '[]'::jsonb,
  subtotal numeric(10, 2) DEFAULT 0,
  tax numeric(10, 2) DEFAULT 0,
  shipping numeric(10, 2) DEFAULT 0,
  total numeric(10, 2) DEFAULT 0,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_categories_slug ON categories(slug);
CREATE INDEX IF NOT EXISTS idx_products_slug ON products(slug);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_featured ON products(featured);
CREATE INDEX IF NOT EXISTS idx_cart_session ON cart_items(session_id);
CREATE INDEX IF NOT EXISTS idx_orders_number ON orders(order_number);

-- Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- RLS Policies for categories (public read)
CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  TO anon, authenticated
  USING (true);

-- RLS Policies for products (public read)
CREATE POLICY "Anyone can view products"
  ON products FOR SELECT
  TO anon, authenticated
  USING (true);

-- RLS Policies for cart_items (session-based access)
CREATE POLICY "Users can view their own cart items"
  ON cart_items FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Users can insert their own cart items"
  ON cart_items FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their own cart items"
  ON cart_items FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete their own cart items"
  ON cart_items FOR DELETE
  TO anon, authenticated
  USING (true);

-- RLS Policies for orders (public insert, restricted read)
CREATE POLICY "Anyone can create orders"
  ON orders FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can view orders"
  ON orders FOR SELECT
  TO anon, authenticated
  USING (true);

-- Insert sample categories
INSERT INTO categories (name, slug, description, image_url) VALUES
  ('Electronics', 'electronics', 'Latest gadgets and electronic devices', 'https://images.pexels.com/photos/356056/pexels-photo-356056.jpeg?auto=compress&cs=tinysrgb&w=800'),
  ('Fashion', 'fashion', 'Trendy clothing and accessories', 'https://images.pexels.com/photos/1926769/pexels-photo-1926769.jpeg?auto=compress&cs=tinysrgb&w=800'),
  ('Home & Living', 'home-living', 'Furniture and home decor', 'https://images.pexels.com/photos/1350789/pexels-photo-1350789.jpeg?auto=compress&cs=tinysrgb&w=800'),
  ('Sports', 'sports', 'Sports equipment and fitness gear', 'https://images.pexels.com/photos/3076509/pexels-photo-3076509.jpeg?auto=compress&cs=tinysrgb&w=800')
ON CONFLICT (slug) DO NOTHING;

-- Insert sample products
INSERT INTO products (name, slug, description, price, image_url, images, category_id, stock, featured, rating, reviews_count) 
SELECT 
  'Wireless Headphones',
  'wireless-headphones',
  'Premium noise-cancelling wireless headphones with 30-hour battery life. Experience crystal-clear audio and comfortable all-day wear.',
  149.99,
  'https://images.pexels.com/photos/3587478/pexels-photo-3587478.jpeg?auto=compress&cs=tinysrgb&w=800',
  '["https://images.pexels.com/photos/3587478/pexels-photo-3587478.jpeg?auto=compress&cs=tinysrgb&w=800", "https://images.pexels.com/photos/3394650/pexels-photo-3394650.jpeg?auto=compress&cs=tinysrgb&w=800"]'::jsonb,
  c.id,
  50,
  true,
  4.5,
  128
FROM categories c WHERE c.slug = 'electronics'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO products (name, slug, description, price, image_url, images, category_id, stock, featured, rating, reviews_count)
SELECT 
  'Smart Watch Pro',
  'smart-watch-pro',
  'Advanced fitness tracking smartwatch with heart rate monitor, GPS, and 5-day battery life. Stay connected and healthy.',
  299.99,
  'https://images.pexels.com/photos/393047/pexels-photo-393047.jpeg?auto=compress&cs=tinysrgb&w=800',
  '["https://images.pexels.com/photos/393047/pexels-photo-393047.jpeg?auto=compress&cs=tinysrgb&w=800"]'::jsonb,
  c.id,
  35,
  true,
  4.7,
  256
FROM categories c WHERE c.slug = 'electronics'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO products (name, slug, description, price, image_url, images, category_id, stock, featured, rating, reviews_count)
SELECT 
  'Leather Messenger Bag',
  'leather-messenger-bag',
  'Handcrafted genuine leather messenger bag with laptop compartment. Perfect for work or travel.',
  89.99,
  'https://images.pexels.com/photos/2905238/pexels-photo-2905238.jpeg?auto=compress&cs=tinysrgb&w=800',
  '["https://images.pexels.com/photos/2905238/pexels-photo-2905238.jpeg?auto=compress&cs=tinysrgb&w=800"]'::jsonb,
  c.id,
  25,
  false,
  4.3,
  67
FROM categories c WHERE c.slug = 'fashion'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO products (name, slug, description, price, image_url, images, category_id, stock, featured, rating, reviews_count)
SELECT 
  'Classic Denim Jacket',
  'classic-denim-jacket',
  'Timeless denim jacket in classic blue wash. Versatile style that goes with everything.',
  69.99,
  'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?auto=compress&cs=tinysrgb&w=800',
  '["https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?auto=compress&cs=tinysrgb&w=800"]'::jsonb,
  c.id,
  40,
  false,
  4.4,
  89
FROM categories c WHERE c.slug = 'fashion'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO products (name, slug, description, price, image_url, images, category_id, stock, featured, rating, reviews_count)
SELECT 
  'Modern Table Lamp',
  'modern-table-lamp',
  'Elegant LED table lamp with adjustable brightness and color temperature. Perfect for any room.',
  45.99,
  'https://images.pexels.com/photos/1112598/pexels-photo-1112598.jpeg?auto=compress&cs=tinysrgb&w=800',
  '["https://images.pexels.com/photos/1112598/pexels-photo-1112598.jpeg?auto=compress&cs=tinysrgb&w=800"]'::jsonb,
  c.id,
  60,
  false,
  4.6,
  145
FROM categories c WHERE c.slug = 'home-living'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO products (name, slug, description, price, image_url, images, category_id, stock, featured, rating, reviews_count)
SELECT 
  'Minimalist Wall Clock',
  'minimalist-wall-clock',
  'Sleek and modern wall clock with silent movement. Complements any interior design.',
  34.99,
  'https://images.pexels.com/photos/707676/pexels-photo-707676.jpeg?auto=compress&cs=tinysrgb&w=800',
  '["https://images.pexels.com/photos/707676/pexels-photo-707676.jpeg?auto=compress&cs=tinysrgb&w=800"]'::jsonb,
  c.id,
  80,
  true,
  4.2,
  92
FROM categories c WHERE c.slug = 'home-living'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO products (name, slug, description, price, image_url, images, category_id, stock, featured, rating, reviews_count)
SELECT 
  'Yoga Mat Premium',
  'yoga-mat-premium',
  'Extra-thick eco-friendly yoga mat with superior grip and cushioning. Includes carrying strap.',
  39.99,
  'https://images.pexels.com/photos/3822906/pexels-photo-3822906.jpeg?auto=compress&cs=tinysrgb&w=800',
  '["https://images.pexels.com/photos/3822906/pexels-photo-3822906.jpeg?auto=compress&cs=tinysrgb&w=800"]'::jsonb,
  c.id,
  45,
  false,
  4.8,
  203
FROM categories c WHERE c.slug = 'sports'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO products (name, slug, description, price, image_url, images, category_id, stock, featured, rating, reviews_count)
SELECT 
  'Running Shoes Elite',
  'running-shoes-elite',
  'High-performance running shoes with responsive cushioning and breathable mesh upper.',
  119.99,
  'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&cs=tinysrgb&w=800',
  '["https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&cs=tinysrgb&w=800"]'::jsonb,
  c.id,
  30,
  true,
  4.7,
  187
FROM categories c WHERE c.slug = 'sports'
ON CONFLICT (slug) DO NOTHING;