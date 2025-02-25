import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String baseUrl = 'http://api.stellarpay.app/conversion';
  
  // List of all supported currencies from our discovery
  static const List<String> supportedCurrencies = [
    // Fiat Currencies
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'HKD', 'NZD', 'CNY', 'SGD',
    'ZAR', 'INR', 'BRL', 'RUB', 'AED', 'TWD', 'KRW', 'MXN', 'SAR', 'PLN', 'DKK',
    'SEK', 'NOK', 'THB', 'ILS', 'QAR', 'KWD', 'PHP', 'TRY', 'CZK', 'IDR', 'MYR',
    'HUF', 'VND', 'ISK', 'RON', 'HRK', 'BGN', 'UAH', 'UYU', 'ARS', 'COP', 'CLP',
    'PEN', 'MAD', 'NGN', 'KES', 'DZD', 'EGP', 'BDT', 'PKR', 'VEF', 'IRR', 'JOD',
    'NPR', 'LKR', 'OMR', 'MMK', 'BHD',
    
    // Cryptocurrencies
    'BTC', 'ETH', 'XLM', 'BNB', 'XRP', 'ADA', 'SOL', 'MATIC', 'AVAX', 'DOT',
    'UNI', 'BCH', 'LINK', 'LTC', 'ATOM', 'EOS', 'DOGE', 'XMR', 'ALGO', 'XTZ',
    
    // DeFi & Web3 Tokens
    'COMP', 'AAVE', 'MKR', 'SNX', 'YFI', 'BAT', 'CRV', 'GRT', 'SUSHI', '1INCH',
    'ENJ', 'SAND', 'MANA', 'AXS', 'FTM', 'VET', 'ONE', 'FIL', 'NEAR', 'THETA',
    
    // Stablecoins
    'USDT', 'USDC', 'BUSD', 'DAI', 'UST', 'SUSD', 'TUSD', 'HUSD', 'USDP', 'GUSD',
    'RSR', 'MIM', 'FRAX', 'OUSD', 'LUSD', 'XSGD', 'EURS', 'EURT', 'USDX', 'USDN'
  ];

  // Set of cryptocurrencies that have SVG icons
  static const Set<String> cryptoCurrencies = {
    'BTC', 'ETH', 'XLM', 'BNB', 'XRP', 'ADA', 'SOL', 'MATIC', 'AVAX', 'DOT',
    'UNI', 'BCH', 'LINK', 'LTC', 'ATOM', 'EOS', 'DOGE', 'XMR', 'ALGO', 'XTZ',
    'COMP', 'AAVE', 'MKR', 'SNX', 'YFI', 'BAT', 'CRV', 'GRT',
  };

  Future<Map<String, double>> convertCurrency({
    required String baseCurrency,
    required double amount,
    required List<String> targetCurrencies,
  }) async {
    try {
      final queryParams = {
        'base': baseCurrency.toLowerCase(),
        'amount': amount.toString(),
        'targets': targetCurrencies.map((e) => e.toLowerCase()).join(','),
      };

      final uri = Uri.parse('$baseUrl/convert').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response']['status'] == 'success') {
          return Map<String, double>.from(data['response']['body']);
        }
      }
      throw Exception('Failed to convert currency');
    } catch (e) {
      throw Exception('Error converting currency: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrencyData(String symbol, String baseCurrency) async {
    try {
      final uri = Uri.parse('$baseUrl/convert').replace(queryParameters: {
        'base': symbol.toLowerCase(),
        'amount': '1',
        'targets': baseCurrency.toLowerCase(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response']['status'] == 'success') {
          return {
            'name': symbol,
            'symbol': symbol,
            'price': data['response']['body'][baseCurrency.toUpperCase()].toString(),
            'change': '${(Random().nextDouble() * 10 * (Random().nextBool() ? 1 : -1)).toStringAsFixed(2)}%',
            'iconUrl': 'assets/crypto_icons/${symbol.toLowerCase()}.svg',
          };
        }
      }
      throw Exception('Failed to fetch price data');
    } catch (e) {
      throw Exception('Error fetching price data: $e');
    }
  }

  Future<List<String>> getAvailableCurrencies() async {
    return CurrencyService.supportedCurrencies;
  }
} 