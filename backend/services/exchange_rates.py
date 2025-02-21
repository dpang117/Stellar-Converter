import requests
from config import EXCHANGE_RATE_API_KEY

def get_available_currencies():
    """Fetches all supported fiat currencies from ExchangeRate API."""
    url = f"https://v6.exchangerate-api.com/v6/{EXCHANGE_RATE_API_KEY}/codes"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        if "supported_codes" in data:
            return {code: name for code, name in data["supported_codes"]}
        else:
            return {"error": "Unexpected API response format"}
    else:
        return {"error": f"Failed to fetch currencies (Status: {response.status_code})"}

def get_fiat_conversion(from_currency, to_currency, amount):
    """Converts an amount from one fiat currency to another using ExchangeRate API."""
    url = f"https://v6.exchangerate-api.com/v6/{EXCHANGE_RATE_API_KEY}/pair/{from_currency}/{to_currency}/{amount}"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        if "conversion_result" in data and "conversion_rate" in data:
            return {
                "from": from_currency,
                "to": to_currency,
                "original_amount": amount,
                "converted_amount": data["conversion_result"],
                "rate": data["conversion_rate"]
            }
        return {"error": "Unexpected API response format"}
    else:
        return {"error": f"Failed to fetch conversion rate (Status: {response.status_code})"}
