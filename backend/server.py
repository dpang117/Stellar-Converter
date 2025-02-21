from flask import Flask, request, jsonify
from services.exchange_rates import get_fiat_conversion
from services.crypto_prices import get_crypto_conversion

app = Flask(__name__)

# List of common fiat currencies for accurate detection
FIAT_CURRENCIES = {"USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "INR"}

@app.route('/convert', methods=['GET'])
def convert_currency():
    """Handles currency conversion requests for fiat and crypto currencies."""
    
    from_currency = request.args.get('from')
    to_currency = request.args.get('to')
    amount = request.args.get('amount', 1)

    # Debugging info to check incoming requests
    print(f"🛠️ Debug - Received Request: from={from_currency}, to={to_currency}, amount={amount}")

    # Validate amount (ensure it's a number)
    try:
        amount = float(amount)
        if amount <= 0:
            return jsonify({"error": "Amount must be greater than zero"}), 400
    except ValueError:
        return jsonify({"error": "Invalid amount. Must be a number"}), 400

    # Validate input parameters
    if not from_currency or not to_currency:
        return jsonify({"error": "Missing required parameters"}), 400

    # Determine conversion type
    is_fiat_from = from_currency.upper() in FIAT_CURRENCIES
    is_fiat_to = to_currency.upper() in FIAT_CURRENCIES

    # **Fiat → Fiat Conversion**
    if is_fiat_from and is_fiat_to:
        print("🔍 Detected Fiat → Fiat conversion")
        result = get_fiat_conversion(from_currency.upper(), to_currency.upper(), amount)
        return jsonify({"converted_amount": result}) if result else jsonify({"error": "Invalid fiat conversion"}), 400

    # **Fiat → Crypto Conversion**
    elif is_fiat_from and not is_fiat_to:
        print("🔍 Detected Fiat → Crypto conversion")
        result = get_crypto_conversion(from_currency.lower(), to_currency.lower(), amount)
        return jsonify({"converted_amount": result}) if result else jsonify({"error": "Invalid fiat to crypto conversion"}), 400

    # **Crypto → Crypto Conversion**
    elif not is_fiat_from and not is_fiat_to:
        print("🔍 Detected Crypto → Crypto conversion")
        result = get_crypto_conversion(from_currency.lower(), to_currency.lower(), amount)
        return jsonify({"converted_amount": result}) if result else jsonify({"error": "Invalid crypto conversion"}), 400

    print("⚠️ No valid conversion type detected")
    return jsonify({"error": "Invalid conversion request"}), 400

if __name__ == '__main__':
    app.run(debug=True)
