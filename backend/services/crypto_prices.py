import requests

COINGECKO_API_URL = "https://api.coingecko.com/api/v3"

def get_supported_cryptos():
    """Fetch the top 100 cryptocurrencies by market cap from CoinGecko API."""
    url = f"{COINGECKO_API_URL}/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1"
    
    try:
        response = requests.get(url)
        
        if response.status_code == 200:
            data = response.json()
            
            crypto_dict = {}
            for coin in data:
                symbol = coin["symbol"].upper()
                name = coin["name"]

                # Ensure Bitcoin is correctly labeled
                if symbol == "BTC" and coin["id"] == "bitcoin":
                    crypto_dict[symbol] = "Bitcoin"
                elif symbol not in crypto_dict:
                    crypto_dict[symbol] = name  # Add only unique symbols

            print(f"✅ Successfully fetched {len(crypto_dict)} cryptos.")
            return crypto_dict

        else:
            print(f"⚠️ Crypto API failed! Status: {response.status_code}")
            return {"error": f"Failed to fetch crypto currencies (Status: {response.status_code})"}

    except requests.exceptions.RequestException as e:
        print(f"⚠️ Request failed: {e}")
        return {"error": f"Request failed: {e}"}


def get_crypto_price(crypto_id):
    """Fetches the price of a given cryptocurrency in USD."""
    url = f"{COINGECKO_API_URL}/simple/price?ids={crypto_id}&vs_currencies=usd"

    try:
        response = requests.get(url)
        
        if response.status_code == 200:
            data = response.json()
            return data.get(crypto_id, {}).get("usd", None)

        print(f"⚠️ Price request failed for {crypto_id} (Status: {response.status_code})")
        return None

    except requests.exceptions.RequestException as e:
        print(f"⚠️ Error fetching price for {crypto_id}: {e}")
        return None


def get_crypto_conversion(from_currency, to_currency, amount):
    """Converts one cryptocurrency to another using CoinGecko prices."""
    price_from = get_crypto_price(from_currency)
    price_to = get_crypto_price(to_currency)

    if price_from and price_to:
        return round((amount * price_from) / price_to, 8)  # Rounded for precision
    
    print(f"⚠️ Conversion failed: {from_currency} → {to_currency}")
    return None
