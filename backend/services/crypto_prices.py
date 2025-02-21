import requests
from config import COINGECKO_API_URL

def get_crypto_price(crypto):
    response = requests.get(f"{COINGECKO_API_URL}?ids={crypto}&vs_currencies=usd")
    data = response.json()
    return data.get(crypto, {}).get("usd", None)

def get_crypto_conversion(from_currency, to_currency, amount):
    price_from = get_crypto_price(from_currency)
    price_to = get_crypto_price(to_currency)

    if price_from and price_to:
        return (amount * price_from) / price_to
    return None
