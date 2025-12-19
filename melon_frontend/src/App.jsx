import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';

function App() {
  return (
    <Router>
      <div className="flex min-h-screen bg-background text-white font-sans selection:bg-primary/30">
        <Sidebar />
        <main className="flex-1 md:ml-64 relative z-0 overflow-y-auto">
          {/* Background Gradient Blob */}
          <div className="fixed top-0 left-0 w-full h-full overflow-hidden -z-10 pointer-events-none">
            <div className="absolute top-[-10%] right-[-5%] w-[500px] h-[500px] bg-primary/20 rounded-full blur-[120px] opacity-50"></div>
            <div className="absolute bottom-[-10%] left-[-5%] w-[400px] h-[400px] bg-accent/20 rounded-full blur-[100px] opacity-40"></div>
          </div>

          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/trading" element={<div className="p-10">Trading View Coming Soon</div>} />
            <Route path="/wallet" element={<div className="p-10">Wallet View Coming Soon</div>} />
            <Route path="/settings" element={<div className="p-10">Settings View Coming Soon</div>} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
