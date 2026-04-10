import { Package } from "lucide-react";

const App = () => (
  <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 text-white p-6" dir="rtl">
    <div className="text-center max-w-lg space-y-8">
      <div className="flex justify-center">
        <img src="/lovable-uploads/logo.png" alt="R&O Express" className="h-24 w-24 rounded-2xl shadow-2xl" 
          onError={(e) => { e.currentTarget.style.display = 'none'; }}
        />
      </div>
      <h1 className="text-4xl font-bold tracking-tight">R&O Express</h1>
      <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 space-y-4 border border-white/20">
        <div className="flex justify-center">
          <Package className="h-16 w-16 text-red-400" />
        </div>
        <h2 className="text-2xl font-semibold text-red-400">النظام متوقف مؤقتاً</h2>
        <p className="text-gray-300 text-lg leading-relaxed">
          النظام متوقف لحين طلب التعديلات
        </p>
        <div className="border-t border-white/20 pt-4 mt-4">
          <p className="text-yellow-400 font-medium text-lg">
            ⚡ النظام قابل للبيع لأي جهة أخرى في أي وقت
          </p>
        </div>
      </div>
      <p className="text-gray-500 text-sm">R&O Express © 2026</p>
    </div>
  </div>
);

export default App;
