import React from 'react';
import { Home, LineChart, Wallet, Bell, Settings } from 'lucide-react';
import { Link, useLocation } from 'react-router-dom';

const MenuItem = ({ icon: Icon, label, to, active }) => (
    <Link to={to} className={`flex items-center space-x-3 p-3 rounded-lg transition-colors ${active ? 'bg-primary/20 text-primary' : 'text-gray-400 hover:bg-white/5 hover:text-white'}`}>
        <Icon size={20} />
        <span className="font-medium">{label}</span>
    </Link>
);

const Sidebar = () => {
    const location = useLocation();

    return (
        <div className="h-screen w-64 glass border-r border-white/5 flex flex-col p-4 fixed left-0 top-0 hidden md:flex z-50">
            <div className="flex items-center space-x-2 mb-10 px-2 mt-2">
                <div className="w-8 h-8 bg-gradient-to-tr from-primary to-accent rounded-lg flex items-center justify-center">
                    <span className="font-bold text-white">M</span>
                </div>
                <h1 className="text-xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-white to-gray-400">Melon AI</h1>
            </div>

            <nav className="space-y-2 flex-1">
                <MenuItem icon={Home} label="Dashboard" to="/" active={location.pathname === '/'} />
                <MenuItem icon={LineChart} label="Trading" to="/trading" active={location.pathname === '/trading'} />
                <MenuItem icon={Wallet} label="Wallet" to="/wallet" active={location.pathname === '/wallet'} />
                <MenuItem icon={Bell} label="Notifications" to="/notifications" active={location.pathname === '/notifications'} />
            </nav>

            <div className="pt-4 border-t border-white/5">
                <MenuItem icon={Settings} label="Settings" to="/settings" active={location.pathname === '/settings'} />
            </div>
        </div>
    );
};

export default Sidebar;
