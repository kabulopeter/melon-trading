import requests
import json

BASE_URL = "http://127.0.0.1:8000"

def run_test(method, path, data=None, name=""):
    url = f"{BASE_URL}{path}"
    try:
        if method == "GET":
            r = requests.get(url)
        else:
            r = requests.post(url, json=data)
        
        success = r.status_code in [200, 201]
        status_text = "OK" if success else "FAILED"
        print(f"[{status_text}] {name} ({method} {path}) - Status: {r.status_code}")
        
        if not success:
            print(f"      Response: {r.text[:200]}")
        return r
    except Exception as e:
        print(f"[ERROR] {name} - {e}")
        return None

def main():
    print("=== RAPPORT DE TEST DES APIS MELON ===\n")
    
    # 1. Assets
    r_assets = run_test("GET", "/api/v1/assets/", name="Liste des Actifs")
    asset_id = None
    if r_assets and r_assets.status_code == 200:
        data = r_assets.json()
        results = data.get('results', data)
        if results:
            asset_id = results[0]['id']
            run_test("GET", f"/api/v1/assets/{asset_id}/", name="Détail d'un Actif")
            run_test("GET", f"/api/v1/assets/{asset_id}/signals/", name="Signaux d'un Actif")

    # 2. Prices
    run_test("GET", "/api/v1/prices/", name="Historique des Prix")
    
    # 3. Trades
    run_test("GET", "/api/v1/trades/", name="Liste des Trades")
    if asset_id:
        trade_data = {
            "asset": asset_id,
            "side": "BUY",
            "entry_price": "150.00",
            "size": "0.1",
            "stop_loss": "145.00",
            "take_profit": "160.00",
            "status": "PENDING",
            "confidence_score": 0.9
        }
        run_test("POST", "/api/v1/trades/", data=trade_data, name="Création d'un Trade")

    # 4. Documentation
    run_test("GET", "/api/schema/", name="Schéma OpenAPI (YAML/JSON)")
    run_test("GET", "/api/docs/", name="Swagger UI (Documentation)")
    run_test("GET", "/api/redoc/", name="ReDoc (Documentation)")

    print("\n=== FIN DU RAPPORT ===")

if __name__ == "__main__":
    main()
