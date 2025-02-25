import aiohttp
import asyncio
import json

# Copy currencies from your CurrencyService class
CURRENCIES = [
    # Fiat Currencies
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'HKD', 'NZD', 'CNY', 'SGD',
    'ZAR', 'INR', 'BRL', 'RUB', 'AED', 'TWD', 'KRW', 'MXN', 'SAR', 'PLN', 'DKK',
    'SEK', 'NOK', 'THB', 'ILS', 'QAR', 'KWD', 'PHP', 'TRY', 'CZK', 'IDR', 'MYR',
    'HUF', 'VND', 'ISK', 'RON', 'HRK', 'BGN', 'UAH', 'UYU', 'ARS', 'COP', 'CLP',
    'PEN', 'MAD', 'NGN', 'KES', 'DZD', 'EGP', 'BDT', 'PKR', 'VEF', 'IRR', 'JOD',
    'NPR', 'LKR', 'OMR', 'MMK', 'BHD',
    
    # Cryptocurrencies
    'BTC', 'ETH', 'XLM', 'BNB', 'XRP', 'ADA', 'SOL', 'MATIC', 'AVAX', 'DOT',
    'UNI', 'BCH', 'LINK', 'LTC', 'ATOM', 'EOS', 'DOGE', 'XMR', 'ALGO', 'XTZ',
    
    # DeFi & Web3 Tokens
    'COMP', 'AAVE', 'MKR', 'SNX', 'YFI', 'BAT', 'CRV', 'GRT', 'SUSHI', '1INCH',
    'ENJ', 'SAND', 'MANA', 'AXS', 'FTM', 'VET', 'ONE', 'FIL', 'NEAR', 'THETA',
    
    # Stablecoins
    'USDT', 'USDC', 'BUSD', 'DAI', 'UST', 'SUSD', 'TUSD', 'HUSD', 'USDP', 'GUSD',
    'RSR', 'MIM', 'FRAX', 'OUSD', 'LUSD', 'XSGD', 'EURS', 'EURT', 'USDX', 'USDN'
]

BASE_URL = 'http://api.stellarpay.app/conversion'

async def test_currency(session, currency):
    params = {
        'base': currency.lower(),
        'amount': '1',
        'targets': 'usd'
    }
    
    try:
        async with session.get(f'{BASE_URL}/convert', params=params) as response:
            if response.status != 200:
                return currency, False, f"HTTP {response.status}"
            
            data = await response.json()
            if data['response']['status'] != 'success':
                return currency, False, "API error"
            
            price = data['response']['body'].get('USD')
            if price is None:
                return currency, False, "No price data"
            
            return currency, True, str(price)
    except Exception as e:
        return currency, False, str(e)

async def main():
    async with aiohttp.ClientSession() as session:
        tasks = [test_currency(session, currency) for currency in CURRENCIES]
        results = await asyncio.gather(*tasks)
        
        print("\nSupported Currencies:")
        print("-------------------")
        supported = [r[0] for r in results if r[1]]
        for curr in supported:
            print(curr)
            
        print("\nUnsupported Currencies:")
        print("---------------------")
        unsupported = [(r[0], r[2]) for r in results if not r[1]]
        for curr, reason in unsupported:
            print(f"{curr}: {reason}")
            
        print(f"\nTotal: {len(CURRENCIES)} currencies")
        print(f"Supported: {len(supported)}")
        print(f"Unsupported: {len(unsupported)}")

if __name__ == '__main__':
    asyncio.run(main()) 