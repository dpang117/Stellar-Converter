import services.exchange_rates as exchange_rates
import services.crypto_prices as crypto_prices

def convert_currency(from_currency, to_currency, amount):
    """Handles all types of currency conversions."""

    from_currency = from_currency.upper()
    to_currency = to_currency.upper()
    amount = float(amount)

    is_fiat_from = from_currency in exchange_rates.FIAT_CURRENCIES
    is_fiat_to = to_currency in exchange_rates.FIAT_CURRENCIES

    # **Fiat → Fiat Conversion**
    if is_fiat_from and is_fiat_to:
        print("🔍 Detected Fiat → Fiat conversion")
        return exchange_rates.get_fiat_conversion(from_currency, to_currency, amount)

    # **Fiat → Crypto Conversion**
    elif is_fiat_from and not is_fiat_to:
        print(f"🔍 Detected Fiat → Crypto conversion: {from_currency} → {to_currency}, amount={amount}")
        
        usd_conversion = exchange_rates.get_fiat_conversion(from_currency, "USD", amount)
        if not usd_conversion:
            print("⚠️ Failed to get USD conversion rate.")
            return None

        crypto_price = crypto_prices.get_crypto_price(to_currency.lower())
        if not crypto_price:
            print(f"⚠️ No price found for crypto: {to_currency.lower()}")
            return None

        converted_amount = usd_conversion["converted_amount"] / crypto_price
        return {"converted_amount": round(converted_amount, 8)}

    # **Crypto → Crypto Conversion**
    elif not is_fiat_from and not is_fiat_to:
        print(f"🔍 Detected Crypto → Crypto conversion: {from_currency} → {to_currency}, amount={amount}")

        price_from = crypto_prices.get_crypto_price(from_currency.lower())
        price_to = crypto_prices.get_crypto_price(to_currency.lower())

        if not price_from:
            print(f"⚠️ No price found for crypto: {from_currency.lower()}")
            return None
        if not price_to:
            print(f"⚠️ No price found for crypto: {to_currency.lower()}")
            return None

        converted_amount = (amount * price_from) / price_to
        return {"converted_amount": round(converted_amount, 8)}

    print("⚠️ Invalid conversion request")
    return None
