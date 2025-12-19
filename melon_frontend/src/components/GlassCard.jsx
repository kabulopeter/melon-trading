import React from 'react';
import { motion } from 'framer-motion';

const GlassCard = ({ children, className = '', hover = true }) => {
    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className={`glass-card bg-surface/50 backdrop-blur-md border border-white/5 shadow-xl ${className} ${hover ? 'hover:border-primary/50 hover:shadow-primary/10' : ''}`}
        >
            {children}
        </motion.div>
    );
};

export default GlassCard;
