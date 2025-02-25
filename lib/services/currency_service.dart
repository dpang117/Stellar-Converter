import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class CurrencyService {
  static const String baseUrl = 'http://api.stellarpay.app/conversion';
  static const String DEFAULT_CURRENCY_KEY = 'default_currency';
  static const String _watchlistKey = 'watchlist_currencies';
  
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
    'USDT', 'USDC', 'BUSD', 'DAI', 'UST', 'USDP', 'GUSD',
    'RSR', 'FRAX'
  ];

  // Set of cryptocurrencies that have SVG icons
  static const Set<String> cryptoCurrencies = {
    // Original Cryptos
    'BTC', 'ETH', 'XLM', 'BNB', 'XRP', 'ADA', 'SOL', 'MATIC', 'AVAX', 'DOT',
    'UNI', 'BCH', 'LINK', 'LTC', 'ATOM', 'EOS', 'DOGE', 'XMR', 'ALGO', 'XTZ',
    
    // DeFi & Web3 Tokens
    'COMP', 'AAVE', 'MKR', 'SNX', 'YFI', 'BAT', 'CRV', 'GRT', 'SUSHI', '1INCH',
    'ENJ', 'SAND', 'MANA', 'AXS', 'FTM', 'VET', 'ONE', 'FIL', 'NEAR', 'THETA',
    
    // Stablecoins
    'USDT', 'USDC', 'BUSD', 'DAI', 'UST', 'USDP', 'GUSD',
    'RSR', 'FRAX'
  };

  final Dio _dio = Dio();

  // Add this static list to store the watchlist data
  static List<Map<String, dynamic>> watchlist = [];

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

  // Get the user's default currency
  static Future<String> getDefaultCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(DEFAULT_CURRENCY_KEY) ?? 'USD';
  }

  // Add this helper method
  String _formatNumber(double number) {
    final formatter = NumberFormat.decimalPattern();
    if (number >= 1) {
      return formatter.format(number);
    } else {
      // For numbers less than 1, keep more decimal places
      return number.toStringAsFixed(6);
    }
  }

  // Update getCurrencyData to use default currency
  Future<Map<String, dynamic>> getCurrencyData(String symbol) async {
    final defaultCurrency = await getDefaultCurrency();
    try {
      print('Fetching data for $symbol in $defaultCurrency');

      final uri = Uri.parse('$baseUrl/convert').replace(queryParameters: {
        'base': symbol.toLowerCase(),
        'amount': '1',
        'targets': defaultCurrency.toLowerCase(),
      });

      print('Request URL: $uri');

      final response = await http.get(uri);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response']['status'] == 'success') {
          final price = data['response']['body'][defaultCurrency.toUpperCase()];
          
          if (price == null) {
            print('Price not available for $symbol, using mock data');
            return _generateMockData(symbol);
          }

          final random = Random();
          final volatility = 0.02;
          
          double currentPrice = price;
          final List<double> chartData = [];
          
          for (int i = 0; i < 24; i++) {
            chartData.add(currentPrice);
            final change = currentPrice * volatility * (random.nextDouble() - 0.5);
            currentPrice += change;
          }

          final formattedPrice = '$defaultCurrency ${_formatNumber(price)}';
          final changePercent = (random.nextDouble() * 10 * (random.nextBool() ? 1 : -1));
          
          return {
            'name': symbol,
            'symbol': symbol,
            'price': formattedPrice,
            'change': '${changePercent.toStringAsFixed(2)}%',
            'iconUrl': 'assets/crypto_icons/${symbol.toLowerCase()}.svg',
            'chartData': chartData,
          };
        }
      }
      print('Using mock data for $symbol due to API error');
      return _generateMockData(symbol);
    } catch (e) {
      print('Error fetching data for $symbol: $e');
      return _generateMockData(symbol);
    }
  }

  // Add this helper method for mock data
  Map<String, dynamic> _generateMockData(String symbol) {
    final random = Random();
    final basePrice = symbol.contains('USD') ? 1.0 : random.nextDouble() * 1000;
    final List<double> chartData = [];
    double currentPrice = basePrice;
    
    for (int i = 0; i < 24; i++) {
      chartData.add(currentPrice);
      final change = currentPrice * 0.02 * (random.nextDouble() - 0.5);
      currentPrice += change;
    }

    return {
      'name': symbol,
      'symbol': symbol,
      'price': 'USD ${_formatNumber(basePrice)}',
      'change': '${(random.nextDouble() * 10 * (random.nextBool() ? 1 : -1)).toStringAsFixed(2)}%',
      'iconUrl': 'assets/crypto_icons/${symbol.toLowerCase()}.svg',
      'chartData': chartData,
    };
  }

  Future<List<String>> getAvailableCurrencies() async {
    return CurrencyService.supportedCurrencies;
  }

  Future<List<double>> getHistoricalPrices(String symbol, String timeframe) async {
    try {
      // Mock data based on timeframe
      final int points = timeframe == '1d' ? 24 : 
                        timeframe == '1w' ? 7 * 24 : 
                        timeframe == '1m' ? 30 : 
                        timeframe == '6m' ? 180 : 
                        timeframe == '1y' ? 365 : 
                        timeframe == 'all' ? 1825 : 
                        24;

      // Get the raw price data
      final data = await getCurrencyData(symbol);
      // Parse the price string by removing currency symbol and commas
      final priceStr = data['price'].split(' ')[1].replaceAll(',', '');
      final currentPrice = double.parse(priceStr);
      
      final random = Random();
      final volatility = 0.02; // 2% price movement
      
      double price = currentPrice;
      final List<double> prices = [];
      
      for (int i = points - 1; i >= 0; i--) {
        prices.add(price);
        // Random walk with drift
        final change = price * volatility * (random.nextDouble() - 0.5);
        price += change;
      }

      return prices.reversed.toList(); // Return prices in chronological order
    } catch (e) {
      print('Error getting historical prices: $e');
      throw e;
    }
  }

  // Modify loadWatchlist to return the list instead of modifying a global variable
  static Future<List<Map<String, dynamic>>> loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlistJson = prefs.getString(_watchlistKey);
    
    if (watchlistJson != null) {
      try {
        final List<dynamic> decoded = json.decode(watchlistJson);
        watchlist = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        return watchlist;
      } catch (e) {
        print('Error loading watchlist: $e');
      }
    }
    return [];
  }

  // Save watchlist to storage
  static Future<void> saveWatchlist(List<Map<String, dynamic>> currencies) async {
    final prefs = await SharedPreferences.getInstance();
    final watchlistJson = json.encode(currencies);
    await prefs.setString(_watchlistKey, watchlistJson);
    watchlist = currencies; // Update the in-memory watchlist
  }
} 