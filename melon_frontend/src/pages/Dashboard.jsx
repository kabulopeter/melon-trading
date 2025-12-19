import React, { useEffect, useState } from 'react';
import GlassCard from '../components/GlassCard';
import socketService from '../services/socket';
import { Activity, TrendingUp, DollarSign, AlertTriangle } from 'lucide-react';
import { motion } from 'framer-motion';

const StatCard = ({ title, value, change, icon: Icon, color = 'primary' }) => (
    <GlassCard className="flex items-center space-x-4">
        <div className={`p-3 rounded-xl bg-${color}/20 text-${color}`}>
            <Icon size={24} />
        </div>
        <div>
            <p className="text-gray-400 text-sm">{title}</p>
            <h3 className="text-2xl font-bold text-white">{value}</h3>
            {change && <p className={`text-xs ${change >= 0 ? 'text-secondary' : 'text-danger'}`}>{change > 0 ? '+' : ''}{change}%</p>}
        </div>
    </GlassCard>
);

const Dashboard = () => {
    const [signals, setSignals] = useState([]);
    const [notifications, setNotifications] = useState([]);

    useEffect(() => {
        socketService.connect();

        const handleUpdate = (data) => {
            // Handle WebSocket messages
            if (data.type === 'notification') {
                const msg = data.data;
                setNotifications(prev => [msg, ...prev].slice(0, 5));

                // If it's a signal, update signals list too (mock logic)
                if (msg.type === 'TRADE') {
                    // In real app, refetch or parse signal
                }
            }
        };

        socketService.subscribe(handleUpdate);

        // Fetch initial data (Mock for now or call API)
        // api.get(endpoints.signals).then(...)

        return () => socketService.unsubscribe(handleUpdate);
    }, []);

    return (
        <div className="p-6 space-y-6">
            <header className="mb-8">
                <h1 className="text-3xl font-bold text-white">Market Overview</h1>
                <p className="text-gray-400">Welcome back, Trader.</p>
            </header>

            {/* KPI Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <StatCard title="Portfolio Value" value="$12,450.00" change={2.5} icon={DollarSign} color="secondary" />
                <StatCard title="Active Signals" value="4" change={0} icon={Activity} color="primary" />
                <StatCard title="Win Rate" value="68%" change={1.2} icon={TrendingUp} color="accent" />
                <StatCard title="Risk Exposure" value="Low" icon={AlertTriangle} color="warning" />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Signals Feed */}
                <div className="lg:col-span-2 space-y-6">
                    <h2 className="text-xl font-semibold text-white">Recent Signals</h2>
                    {notifications.length === 0 && (
                        <div className="text-gray-500 italic">Waiting for market signals...</div>
                    )}
                    {notifications.map((notif, idx) => (
                        <GlassCard key={idx} className="flex justify-between items-center">
                            <div>
                                <h4 className="font-bold text-white">{notif.title}</h4>
                                <p className="text-sm text-gray-400">{notif.body}</p>
                            </div>
                            <span className="text-xs text-gray-500">{new Date(notif.timestamp).toLocaleTimeString()}</span>
                        </GlassCard>
                    ))}
                </div>

                {/* Status Panel */}
                <GlassCard className="h-fit">
                    <h3 className="font-bold text-white mb-4">System Status</h3>
                    <div className="space-y-4">
                        <div className="flex justify-between items-center">
                            <span className="text-gray-400">AI Engine</span>
                            <span className="flex items-center text-secondary text-sm"><div className="w-2 h-2 bg-secondary rounded-full mr-2"></div> Online</span>
                        </div>
                        <div className="flex justify-between items-center">
                            <span className="text-gray-400">Scrapers</span>
                            <span className="flex items-center text-secondary text-sm"><div className="w-2 h-2 bg-secondary rounded-full mr-2"></div> Active</span>
                        </div>
                        <div className="flex justify-between items-center">
                            <span className="text-gray-400">Broker</span>
                            <span className="flex items-center text-warning text-sm"><div className="w-2 h-2 bg-warning rounded-full mr-2"></div> Standby</span>
                        </div>
                    </div>
                </GlassCard>
            </div>
        </div>
    );
};

export default Dashboard;
