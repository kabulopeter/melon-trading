import asyncio
import websockets
import json
import os
from dotenv import load_dotenv
import logging
from typing import Dict, Any

# =================================================================
# CONFIGURATION
# =================================================================
load_dotenv()
# Configuration du système de journalisation (Logging) pour le monitoring
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    handlers=[
                        logging.FileHandler("deriv_execution.log"), # Sauvegarde dans un fichier
                        logging.StreamHandler() # Affichage en console
                    ])

# Constantes Deriv
API_TOKEN = os.getenv("DERIV_API_TOKEN")
APP_ID = os.getenv("DERIV_APP_ID")
API_URL = os.getenv("DERIV_API_BASE_URL", "wss://ws.binaryws.com/websockets/v3")

# =================================================================
# CLASSE D'EXÉCUTION ET DE LOGGING
# =================================================================
class DerivExecutor:
    
    def __init__(self):
        if not API_TOKEN:
            logging.error("❌ Le jeton DERIV_API_TOKEN est manquant. Vérifiez le fichier .env.")
            raise ValueError("Token Deriv manquant.")
        
        self.uri = f"{API_URL}?app_id={APP_ID}"
        self.connection = None

    async def connect(self):
        """ Établit et maintient la connexion WebSocket. """
        try:
            logging.info(f"🌐 Tentative de connexion à Deriv via URI: {self.uri}")
            self.connection = await websockets.connect(self.uri)
            logging.info("✅ Connexion WebSocket établie avec succès.")
            
            # Authentification immédiate après la connexion
            await self._authenticate()
            return True
            
        except Exception as e:
            logging.error(f"❌ Échec de la connexion WebSocket : {e}")
            return False

    async def _authenticate(self):
        """ Envoie le jeton d'authentification à Deriv. """
        auth_request = {
            "authorize": API_TOKEN
        }
        await self.connection.send(json.dumps(auth_request))
        response = await self.connection.recv()
        data = json.loads(response)
        
        if 'error' in data:
            logging.error(f"❌ Erreur d'authentification Deriv : {data['error']['message']}")
            return False
        
        logging.info(f"🔑 Authentification réussie pour l'utilisateur: {data['authorize']['loginid']}")
        return True


    async def place_order(self, signal: Dict[str, Any]):
        """
        Reçoit un signal validé et passe un ordre réel avec SL/TP.
        Le signal vient du moteur (Étape 7) et est déjà filtré à >= 97% de confiance.
        """
        if not self.connection:
            logging.warning("⚠️ Connexion non établie. Tentative de reconnexion...")
            if not await self.connect():
                return
        
        # Déballage du signal
        symbol = signal.get('symbol', 'R_100') # Exemple d'indice synthétique (Volatility 100 Index)
        side = signal.get('side', 'buy')
        amount = signal.get('amount', 10.0) # Taille du contrat ($)
        sl_price = signal.get('sl_price') # Prix calculé par le Money Management (Étape 6)
        tp_price = signal.get('tp_price')

        if not sl_price or not tp_price:
            logging.error("❌ Ordre rejeté : Prix SL/TP manquant du Money Management.")
            return

        # Construction de la requête Deriv (achat ou vente)
        # Utilisation de 'proposal_open_contract' pour placer un ordre basé sur le prix
        order_request = {
            "buy": 1, # Achète (Utiliser 'sell' pour la vente)
            "price": amount,
            "amount": 1, # Quantité de contrat (dépend du type de trading)
            "basis": "stake", # Montant en USD misé par trade
            "contract_type": "CALL" if side == 'buy' else "PUT",
            "currency": "USD",
            "symbol": symbol,
            "take_profit": tp_price,
            "stop_loss": sl_price
        }

        logging.info(f"➡️ Tentative de placer un ordre {side.upper()} de {amount}$ sur {symbol} (SL: {sl_price}, TP: {tp_price})")

        try:
            await self.connection.send(json.dumps(order_request))
            response = await self.connection.recv()
            data = json.loads(response)

            if 'error' in data:
                logging.error(f"❌ Échec de l'ordre Deriv : {data['error']['message']} (Code: {data['error']['code']})")
                return
            
            # Succès
            logging.critical(f"⭐ ORDRE EXÉCUTÉ (CONF: {signal.get('confidence', 0)*100:.2f}%)!")
            logging.critical(f"ID du Contrat: {data['buy']['contract_id']} | Gain potentiel: {data['buy']['payout']}")
            
            # Vous devrez ensuite ajouter une boucle pour surveiller l'état du contrat (via 'portfolio')
            
        except websockets.exceptions.ConnectionClosedOK:
            logging.error("❌ Connexion WebSocket fermée pendant l'exécution de l'ordre.")
        except Exception as e:
            logging.error(f"❌ Erreur inattendue lors de l'exécution de l'ordre : {e}")

# ==========================================
# SIMULATION DE FLUX DE TRAVAIL
# ==========================================
async def main_trading_loop():
    executor = DerivExecutor()
    if await executor.connect():
        
        # Simuler un signal AI validé (confidence >= 97%)
        # Ces données viendraient directement de votre BacktestEngine (Étape 7)
        validated_signal = {
            'symbol': 'R_100', # Volatility 100 Index
            'side': 'buy',
            'amount': 25.0, # Miser 25 USD
            'sl_price': 80.0, # Exemple de Stop Loss calculé par MM
            'tp_price': 120.0, # Exemple de Take Profit calculé par MM
            'confidence': 0.985 # Score de Confiance élevé
        }
        
        # Exécuter l'ordre réel
        await executor.place_order(validated_signal)

if __name__ == "__main__":
    # La librairie websockets requiert asyncio
    asyncio.run(main_trading_loop())
