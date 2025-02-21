import requests
from config import EXCHANGE_RATE_API_KEY

EXCHANGE_API_URL = f"https://v6.exchangerate-api.com/v6/{EXCHANGE_RATE_API_KEY}"

FIAT_CURRENCIES = {
    "USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "INR", "SGD",
    "NZD", "HKD", "SEK", "NOK", "DKK", "MXN", "ZAR", "RUB", "BRL", "TRY",
    "KRW", "IDR"
}

def get_available_currencies():
    """Fetches all supported fiat currencies from ExchangeRate API."""
    url = f"{EXCHANGE_API_URL}/codes"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        if "supported_codes" in data:
            return {code: name for code, name in data["supported_codes"]}
        else:
            return {"error": "Unexpected API response format"}
    return {"error": f"Failed to fetch fiat currencies (Status: {response.status_code})"}

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
