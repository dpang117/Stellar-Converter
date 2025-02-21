import services.exchange_rates as exchange_rates
import services.crypto_prices as crypto_prices

def convert_currency(from_currency, to_currency, amount):
    """Handles all types of currency conversions with improved error handling."""

    from_currency = from_currency.upper()
    to_currency = to_currency.upper()
    
    try:
        amount = float(amount)
        if amount <= 0:
            return {"error": "Amount must be greater than zero"}
    except ValueError:
        return {"error": "Invalid amount. Must be a number"}
    
    is_fiat_from = from_currency.upper() in exchange_rates.FIAT_CURRENCIES
    is_fiat_to = to_currency.upper() in exchange_rates.FIAT_CURRENCIES

    # **Fiat → Fiat Conversion**
    if is_fiat_from and is_fiat_to:
        print("🔍 Detected Fiat → Fiat conversion")
        return exchange_rates.get_fiat_conversion(from_currency, to_currency, amount)

    # **Fiat → Crypto Conversion**
    elif is_fiat_from and not is_fiat_to:
        print(f"🔍 Detected Fiat → Crypto conversion: {from_currency} → {to_currency}, amount={amount}")
        
        usd_conversion = exchange_rates.get_fiat_conversion(from_currency, "USD", amount)
        if not usd_conversion:
            return {"error": "Failed to get USD conversion rate"}

        crypto_price = crypto_prices.get_crypto_price(to_currency.lower())
        if not crypto_price:
            return {"error": f"No price found for crypto: {to_currency}"}

        converted_amount = usd_conversion["converted_amount"] / crypto_price
        return {"converted_amount": round(converted_amount, 8)}

    # **Crypto → Crypto Conversion**
    elif not is_fiat_from and not is_fiat_to:
        print(f"🔍 Detected Crypto → Crypto conversion: {from_currency} → {to_currency}, amount={amount}")

        price_from = crypto_prices.get_crypto_price(from_currency.lower())
        price_to = crypto_prices.get_crypto_price(to_currency.lower())

        if not price_from:
            return {"error": f"No price found for crypto: {from_currency}"}
        if not price_to:
            return {"error": f"No price found for crypto: {to_currency}"}

        converted_amount = (amount * price_from) / price_to
        return {"converted_amount": round(converted_amount, 8)}

    # **Crypto → Fiat Conversion**
    elif not is_fiat_from and is_fiat_to:
        print(f"🔍 Detected Crypto → Fiat conversion: {from_currency} → {to_currency}, amount={amount}")

        crypto_price = crypto_prices.get_crypto_price(from_currency.lower())
        if not crypto_price:
            return {"error": f"No price found for crypto: {from_currency}"}

        converted_amount = amount * crypto_price
        return {"converted_amount": round(converted_amount, 2)}

    return {"error": "Invalid conversion request"}
