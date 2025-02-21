from flask import Flask, request, jsonify
from services.conversion import convert_currency
from services.exchange_rates import get_available_currencies
from services.crypto_prices import get_supported_cryptos

app = Flask(__name__)

@app.route('/api/currencies', methods=['GET'])
def get_all_currencies():
    """Fetch and return both fiat and crypto currencies."""
    print("🔍 Fetching fiat currencies...")
    fiat_currencies = get_available_currencies()
    
    print("🔍 Fetching crypto currencies...")
    crypto_currencies = get_supported_cryptos()

    if "error" in fiat_currencies or "error" in crypto_currencies:
        return jsonify({"error": "Failed to load currency data"}), 500

    # Merge fiat and crypto lists
    combined_currencies = {**fiat_currencies, **crypto_currencies}
    
    print("✅ Combined Currencies Loaded")
    return jsonify(combined_currencies)

@app.route('/convert', methods=['GET'])
def convert():
    """Handles all currency conversion requests."""
    from_currency = request.args.get('from')
    to_currency = request.args.get('to')
    amount = request.args.get('amount', 1)

    print(f"🛠️ Debug - Received Request: from={from_currency}, to={to_currency}, amount={amount}")

    if not from_currency or not to_currency:
        return jsonify({"error": "Missing required parameters"}), 400

    try:
        amount = float(amount)
        if amount <= 0:
            return jsonify({"error": "Amount must be greater than zero"}), 400
    except ValueError:
        return jsonify({"error": "Invalid amount. Must be a number"}), 400

    result = convert_currency(from_currency, to_currency, amount)

    if result:
        return jsonify(result)
    else:
        return jsonify({"error": "Conversion failed"}), 400

if __name__ == '__main__':
    app.run(debug=True)
