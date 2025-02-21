import requests
from config import EXCHANGE_RATE_API_KEY

EXCHANGE_API_URL = f"https://v6.exchangerate-api.com/v6/{EXCHANGE_RATE_API_KEY}"

# Initially empty, will be populated dynamically
FIAT_CURRENCIES = set()

def fetch_fiat_currencies():
    """Fetches all supported fiat currencies from ExchangeRate API and updates FIAT_CURRENCIES."""
    global FIAT_CURRENCIES
    url = f"{EXCHANGE_API_URL}/codes"

    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            if "supported_codes" in data:
                # Extract fiat currency codes
                FIAT_CURRENCIES = {code for code, _ in data["supported_codes"]}
                print(f"✅ Successfully loaded {len(FIAT_CURRENCIES)} fiat currencies.")
            else:
                print("⚠️ Unexpected API response format while fetching fiat currencies.")
        else:
            print(f"⚠️ Failed to fetch fiat currencies (Status: {response.status_code})")

    except requests.exceptions.RequestException as e:
        print(f"⚠️ Error fetching fiat currencies: {e}")

# Fetch fiat currencies when the module loads
fetch_fiat_currencies()

def get_fiat_conversion(from_currency, to_currency, amount):
    """Converts an amount from one fiat currency to another."""
    url = f"{EXCHANGE_API_URL}/pair/{from_currency}/{to_currency}/{amount}"
    
    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            if "conversion_result" in data and "conversion_rate" in data:
                return {
                    "from": from_currency,
                    "to": to_currency,
                    "original_amount": amount,
                    "converted_amount": round(data["conversion_result"], 2),
                    "rate": data["conversion_rate"]
                }
        print(f"⚠️ Failed to fetch fiat conversion {from_currency} → {to_currency}")
        return None

    except requests.exceptions.RequestException as e:
        print(f"⚠️ Error fetching fiat conversion: {e}")
        return None
