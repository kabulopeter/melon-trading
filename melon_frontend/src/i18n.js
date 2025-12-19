import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

const resources = {
    en: {
        translation: {
            "welcome": "Welcome to Melon Trading",
            "dashboard": "Dashboard",
            "assets": "Assets",
            "trades": "Trades",
            "settings": "Settings",
            "connect": "Connect Wallet",
            "balance": "Total Balance",
            "pnl": "P&L (24h)",
            "active_trades": "Active Trades",
            "market_overview": "Market Overview",
        }
    },
    fr: {
        translation: {
            "welcome": "Bienvenue sur Melon Trading",
            "dashboard": "Tableau de Bord",
            "assets": "Actifs",
            "trades": "Positions",
            "settings": "Paramètres",
            "connect": "Connecter",
            "balance": "Solde Total",
            "pnl": "P&L (24h)",
            "active_trades": "Trades Actifs",
            "market_overview": "Aperçu du Marché",
        }
    }
};

i18n
    .use(initReactI18next)
    .init({
        resources,
        lng: "fr", // Langue par défaut : Français
        interpolation: {
            escapeValue: false
        }
    });

export default i18n;
