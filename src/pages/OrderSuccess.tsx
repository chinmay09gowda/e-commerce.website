import { useLocation, Link } from 'react-router-dom';
import { CheckCircle, Home } from 'lucide-react';

export function OrderSuccess() {
  const location = useLocation();
  const orderNumber = location.state?.orderNumber;

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 flex items-center justify-center px-4">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-xl p-8 text-center">
        <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
          <CheckCircle className="w-12 h-12 text-green-600" />
        </div>

        <h1 className="text-3xl font-bold text-gray-900 mb-4">
          Order Placed Successfully!
        </h1>

        <p className="text-gray-600 mb-6">
          Thank you for your purchase. Your order has been received and is being
          processed.
        </p>

        {orderNumber && (
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-8">
            <div className="text-sm text-gray-600 mb-1">Order Number</div>
            <div className="text-xl font-bold text-blue-600">{orderNumber}</div>
          </div>
        )}

        <div className="space-y-4">
          <p className="text-sm text-gray-600">
            You will receive an email confirmation shortly with your order details.
          </p>

          <Link
            to="/"
            className="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 rounded-xl font-semibold transition-all duration-200 hover:shadow-lg hover:scale-105"
          >
            <Home className="w-5 h-5" />
            Back to Home
          </Link>
        </div>
      </div>
    </div>
  );
}
