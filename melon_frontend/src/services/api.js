import axios from 'axios';

const API_URL = 'http://localhost:8000/api'; // Adjust if needed

const api = axios.create({
    baseURL: API_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Add interceptor for JWT if needed
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('accessToken');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

export const endpoints = {
    login: '/token/',
    refresh: '/token/refresh/',
    assets: '/assets/', // Placeholder, ensure ViewSet exists
    trades: '/trades/', // Placeholder
    signals: '/signals/', // Placeholder
};

export default api;
