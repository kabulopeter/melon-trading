import requests
import json
import subprocess
import time

BASE_URL = "http://127.0.0.1:8000/api/v1"

def test_payment_flow():
    print("--- TESTING MOBILE MONEY PAYMENT FLOW (M-PESA/AIRTEL) ---")
    
    # 1. Initiate Deposit
    deposit_data = {
        "amount": "50.00",
        "payment_method": "MPESA",
        "phone_number": "0812345678"
    }
    print(f"\n1. Initiating Deposit of 50.00 via MPESA...")
    r = requests.post(f"{BASE_URL}/wallet/deposit/", json=deposit_data)
    
    if r.status_code != 201:
        print(f"FAILED: {r.text}")
        return
    
    tx_data = r.json()
    ref = tx_data['provider_ref']
    print(f"SUCCESS: Transaction created with Ref: {ref}")
    
    # 2. Check Balance (Should be 0 if new)
    r_bal = requests.get(f"{BASE_URL}/wallet/balance/")
    print(f"Current Balance: {r_bal.json()['balance']}")

    # 3. Simulate Provider Callback (using management command)
    print(f"\n3. Simulating M-Pesa Success Callback for {ref}...")
    subprocess.run(["venv\\Scripts\\python.exe", "manage.py", "simulate_payment", ref])

    # 4. Check Balance again (Should be 50.00)
    print("\n4. Verifying new balance...")
    r_bal_new = requests.get(f"{BASE_URL}/wallet/balance/")
    new_bal = r_bal_new.json()['balance']
    print(f"New Balance: {new_bal}")
    
    if float(new_bal) >= 50.0:
        print("\n✅ PAYMENT MODULE INTEGRATION VERIFIED!")
    else:
        print("\n❌ BALANCE UPDATE FAILED.")

if __name__ == "__main__":
    test_payment_flow()
