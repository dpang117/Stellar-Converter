import requests
import time

COINGECKO_API_URL = "https://api.coingecko.com/api/v3"
crypto_cache = {}  # Store CoinGecko IDs and timestamps

def get_supported_cryptos():
    """Fetches and caches the top 100 cryptocurrencies by market cap from CoinGecko API."""
    global crypto_cache

    # If cache is fresh (less than 10 minutes old), return it
    if crypto_cache and (time.time() - crypto_cache["timestamp"] < 600):
        return crypto_cache["data"]

    url = f"{COINGECKO_API_URL}/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1"
    
    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            crypto_dict = {}

            for coin in data:
                symbol = coin["symbol"].upper()
                coin_id = coin["id"]
                crypto_dict[symbol] = coin_id  # Store symbol → CoinGecko ID mapping

            print(f"✅ Successfully fetched {len(crypto_dict)} cryptos.")

            # Cache results
            crypto_cache = {"data": crypto_dict, "timestamp": time.time()}
            return crypto_dict

        print(f"⚠️ Crypto API failed! Status: {response.status_code}")
        return {}

    except requests.exceptions.RequestException as e:
        print(f"⚠️ Request failed: {e}")
        return {}

def get_crypto_price(symbol):
    """Fetches the current price of a cryptocurrency in USD using CoinGecko ID."""
    cryptos = get_supported_cryptos()

    if symbol.upper() not in cryptos:
        print(f"⚠️ No coin_id found for symbol: {symbol}")
        return None

    coin_id = cryptos[symbol.upper()]
    url = f"{COINGECKO_API_URL}/simple/price?ids={coin_id}&vs_currencies=usd"

    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            price = data.get(coin_id, {}).get("usd", None)

            if price is None:
                print(f"⚠️ No price found for {coin_id}")
            return price

        print(f"⚠️ Failed to fetch price for {coin_id} (Status: {response.status_code})")
        return None

    except requests.exceptions.RequestException as e:
        print(f"⚠️ Error fetching price for {coin_id}: {e}")
        return None
