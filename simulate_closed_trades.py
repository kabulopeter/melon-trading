import os
import django
import random
from datetime import datetime, timedelta
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Trade, User

def simulate_closed_trades():
    print("🧹 CLÔTURE DES TRADES POUR ANALYSES...")
    
    user = User.objects.first()
    if not user:
        print("Aucun utilisateur trouvé.")
        return

    trades = Trade.objects.filter(user=user).exclude(status='CLOSED')
    
    count = 0
    now = datetime.now()
    
    for t in trades:
        # On simule un trade fermé il y a quelques minutes/heures
        t.status = Trade.Status.CLOSED
        
        # Simulation PnL: 70% de chances d'être gagnant pour la démo
        is_winner = random.random() < 0.7
        if is_winner:
            t.pnl = Decimal(str(random.uniform(5, 50)))
        else:
            t.pnl = Decimal(str(-random.uniform(2, 20)))
            
        t.closed_at = now - timedelta(minutes=random.randint(10, 500))
        t.exit_price = t.entry_price + (t.pnl / Decimal("10")) # Simple simul
        t.save()
        count += 1
        
    print(f"✅ {count} trades ont été clôturés avec succès.")

if __name__ == "__main__":
    simulate_closed_trades()
