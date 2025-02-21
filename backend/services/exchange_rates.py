import requests
from config import EXCHANGE_RATE_API_KEY

def get_fiat_conversion(from_currency, to_currency, amount):
    url = f"https://v6.exchangerate-api.com/v6/{EXCHANGE_RATE_API_KEY}/pair/{from_currency}/{to_currency}/{amount}"
    response = requests.get(url)
    data = response.json()

    if "conversion_result" in data:
        return data["conversion_result"]
    return None
