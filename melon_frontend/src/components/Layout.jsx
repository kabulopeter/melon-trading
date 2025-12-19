import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Menu, X, Home, TrendingUp, Activity, Settings, Moon, Sun } from 'lucide-react';
import clsx from 'clsx';

export default function Layout({ children }) {
    const { t, i18n } = useTranslation();
    const [isSidebarOpen, setSidebarOpen] = useState(false);
    const [isDark, setIsDark] = useState(false);

    const toggleTheme = () => {
        setIsDark(!isDark);
        document.documentElement.classList.toggle('dark');
    };

    const changeLanguage = () => {
        i18n.changeLanguage(i18n.language === 'fr' ? 'en' : 'fr');
    };

    const NavItem = ({ icon: Icon, label, active }) => (
        <a href="#" className={clsx(
            "flex items-center space-x-3 px-4 py-3 rounded-xl transition-colors",
            active ? "bg-melon-yellow text-melon-blue font-bold shadow-lg" : "text-melon-offWhite hover:bg-white/10"
        )}>
            <Icon size={20} />
            <span>{label}</span>
        </a>
    );

    return (
        <div className={clsx("min-h-screen flex", isDark ? "dark" : "")}>
            {/* Sidebar (Desktop) */}
            <aside className="hidden lg:flex flex-col w-64 bg-melon-blue text-white fixed h-full z-20 shadow-2xl">
                <div className="p-6">
                    <h1 className="text-2xl font-bold tracking-tighter text-melon-yellow">MELON<span className="text-white">TRADING</span></h1>
                </div>
                <nav className="flex-1 px-4 space-y-2">
                    <NavItem icon={Home} label={t('dashboard')} active />
                    <NavItem icon={TrendingUp} label={t('assets')} />
                    <NavItem icon={Activity} label={t('trades')} />
                    <NavItem icon={Settings} label={t('settings')} />
                </nav>
                <div className="p-4 border-t border-white/10">
                    <div className="flex items-center justify-between">
                        <button onClick={toggleTheme} className="p-2 rounded-full hover:bg-white/10">
                            {isDark ? <Sun size={20} /> : <Moon size={20} />}
                        </button>
                        <button onClick={changeLanguage} className="text-sm font-bold bg-white/10 px-3 py-1 rounded">
                            {i18n.language.toUpperCase()}
                        </button>
                    </div>
                </div>
            </aside>

            {/* Mobile Header */}
            <div className="lg:hidden fixed w-full bg-melon-blue text-white z-20 flex items-center justify-between p-4 shadow-md">
                <h1 className="text-xl font-bold text-melon-yellow">MELON</h1>
                <button onClick={() => setSidebarOpen(!isSidebarOpen)}>
                    {isSidebarOpen ? <X /> : <Menu />}
                </button>
            </div>

            {/* Main Content */}
            <main className="flex-1 lg:ml-64 p-6 mt-16 lg:mt-0 transition-colors duration-300">
                <div className="max-w-7xl mx-auto">
                    {children}
                </div>
            </main>

            {/* Mobile Menu Overlay */}
            {isSidebarOpen && (
                <div className="fixed inset-0 bg-black/50 z-10 lg:hidden" onClick={() => setSidebarOpen(false)} />
            )}
        </div>
    );
}
