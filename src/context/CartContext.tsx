import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { supabase, Product } from '../lib/supabase';

interface CartItem {
  product: Product;
  quantity: number;
}

interface CartContextType {
  items: CartItem[];
  addToCart: (product: Product, quantity?: number) => void;
  removeFromCart: (productId: string) => void;
  updateQuantity: (productId: string, quantity: number) => void;
  clearCart: () => void;
  total: number;
  itemCount: number;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

function getSessionId(): string {
  let sessionId = localStorage.getItem('session_id');
  if (!sessionId) {
    sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    localStorage.setItem('session_id', sessionId);
  }
  return sessionId;
}

export function CartProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<CartItem[]>([]);

  useEffect(() => {
    loadCart();
  }, []);

  const loadCart = async () => {
    const sessionId = getSessionId();
    const { data: cartItems } = await supabase
      .from('cart_items')
      .select('*, product:products(*)')
      .eq('session_id', sessionId);

    if (cartItems) {
      const formattedItems = cartItems.map((item: any) => ({
        product: item.product,
        quantity: item.quantity,
      }));
      setItems(formattedItems);
    }
  };

  const addToCart = async (product: Product, quantity: number = 1) => {
    const sessionId = getSessionId();
    const existingItem = items.find((item) => item.product.id === product.id);

    if (existingItem) {
      await updateQuantity(product.id, existingItem.quantity + quantity);
    } else {
      await supabase.from('cart_items').insert({
        session_id: sessionId,
        product_id: product.id,
        quantity,
      });

      setItems([...items, { product, quantity }]);
    }
  };

  const removeFromCart = async (productId: string) => {
    const sessionId = getSessionId();
    await supabase
      .from('cart_items')
      .delete()
      .eq('session_id', sessionId)
      .eq('product_id', productId);

    setItems(items.filter((item) => item.product.id !== productId));
  };

  const updateQuantity = async (productId: string, quantity: number) => {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    const sessionId = getSessionId();
    await supabase
      .from('cart_items')
      .update({ quantity, updated_at: new Date().toISOString() })
      .eq('session_id', sessionId)
      .eq('product_id', productId);

    setItems(
      items.map((item) =>
        item.product.id === productId ? { ...item, quantity } : item
      )
    );
  };

  const clearCart = async () => {
    const sessionId = getSessionId();
    await supabase.from('cart_items').delete().eq('session_id', sessionId);
    setItems([]);
  };

  const total = items.reduce(
    (sum, item) => sum + item.product.price * item.quantity,
    0
  );

  const itemCount = items.reduce((sum, item) => sum + item.quantity, 0);

  return (
    <CartContext.Provider
      value={{
        items,
        addToCart,
        removeFromCart,
        updateQuantity,
        clearCart,
        total,
        itemCount,
      }}
    >
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  const context = useContext(CartContext);
  if (context === undefined) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
}
