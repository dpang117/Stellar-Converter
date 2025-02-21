from flask import Flask, request, jsonify
from services.crypto_prices import get_supported_cryptos, get_crypto_price
from services.exchange_rates import get_available_currencies, get_fiat_conversion

app = Flask(__name__)

@app.route('/api/currencies', methods=['GET'])
def get_all_currencies():
    """Fetch both fiat and crypto currencies."""
    print("🔍 Fetching fiat currencies...")
    fiat_currencies = get_available_currencies()
    print("Fiat Response:", fiat_currencies)

    print("🔍 Fetching crypto currencies...")
    crypto_currencies = get_supported_cryptos()
    print("Crypto Response:", crypto_currencies)

    if "error" in fiat_currencies or "error" in crypto_currencies:
        print("❌ Currency API failed")
        return jsonify({"error": "Failed to load currency data"}), 500

    combined_currencies = {**fiat_currencies, **crypto_currencies}
    print("✅ Combined Currencies Loaded")

    return jsonify(combined_currencies)

@app.route('/api/crypto_price', methods=['GET'])
def get_crypto_price_endpoint():
    """Fetch the price of a specific cryptocurrency."""
    crypto_id = request.args.get('crypto_id')
    vs_currency = request.args.get('vs_currency', 'usd')

    if not crypto_id:
        return jsonify({"error": "Missing crypto_id parameter"}), 400

    result = get_crypto_price(crypto_id, vs_currency)
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True)
