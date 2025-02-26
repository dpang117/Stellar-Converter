import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/currency_conversion.dart';

// Move _CacheEntry class to top level, before CurrencyService class
class _CacheEntry {
  final List<double> data;
  final DateTime timestamp;
  final String timeframe;
  
  _CacheEntry(this.data, this.timestamp, this.timeframe);
  
  bool isValid() {
    final now = DateTime.now();
    // Cache validity periods based on timeframe
    switch (timeframe) {
      case '1d': return now.difference(timestamp).inMinutes < 5;  // 5 minutes
      case '1w': return now.difference(timestamp).inHours < 1;    // 1 hour
      case '2w': return now.difference(timestamp).inHours < 2;    // 2 hours
      case '1m': return now.difference(timestamp).inHours < 6;    // 6 hours
      default: return false;
    }
  }
}

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

  // Add a static field to cache the default currency
  static String? _cachedDefaultCurrency;

  // Add cache for historical data
  static final Map<String, _CacheEntry> _timeseriesCache = {};

  Future<List<CurrencyConversion>> convertCurrency(
      String baseCurrency, 
      double amount, 
      List<String> targetCurrencies
  ) async {
    try {
      final queryParams = {
        'base': baseCurrency.toLowerCase(),
        'amount': amount.toString(),
        'targets': targetCurrencies.join(',').toLowerCase(),
      };

      final uri = Uri.http('api.stellarpay.app', '/conversion/convert', queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        
        // Access the body array through the response object
        final List<dynamic> conversions = decodedResponse['response']['body'];
        
        return conversions.map((conversion) => CurrencyConversion.fromJson(conversion)).toList();
      } else {
        throw Exception('Failed to convert currency');
      }
    } catch (e) {
      throw Exception('Error converting currency: $e');
    }
  }

  // Modify getDefaultCurrency to cache the result
  static Future<String> getDefaultCurrency() async {
    if (_cachedDefaultCurrency != null) {
      return _cachedDefaultCurrency!;
    }
    final prefs = await SharedPreferences.getInstance();
    _cachedDefaultCurrency = prefs.getString(DEFAULT_CURRENCY_KEY) ?? 'USD';
    return _cachedDefaultCurrency!;
  }

  // Add a method to update the cached default currency
  static Future<void> setDefaultCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(DEFAULT_CURRENCY_KEY, currency);
    _cachedDefaultCurrency = currency;
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

  // Add a method to clear cached data
  static void clearCache() {
    _cachedDefaultCurrency = null;
  }

  // Modify loadWatchlist to include full currency data
  static Future<List<Map<String, dynamic>>> loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlistJson = prefs.getString(_watchlistKey);
    
    if (watchlistJson != null) {
      try {
        final List<dynamic> decoded = json.decode(watchlistJson);
        watchlist = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        
        // Immediately fetch fresh data for each currency
        final currencyService = CurrencyService();
        final updatedWatchlist = await Future.wait(
          watchlist.map((currency) async {
            final freshData = await currencyService.getCurrencyData(currency['symbol']);
            return {
              ...currency,
              ...freshData,
            };
          }),
        );
        
        return updatedWatchlist;
      } catch (e) {
        print('Error loading watchlist: $e');
      }
    }
    return [];
  }

  // Modify getCurrencyData to only fetch current price
  Future<Map<String, dynamic>> getCurrencyData(String symbol) async {
    final defaultCurrency = await getDefaultCurrency();
    
    try {
      final queryParams = {
        'base': symbol.toLowerCase(),
        'amount': '1',
        'targets': defaultCurrency.toLowerCase(),
      };

      final uri = Uri.http('api.stellarpay.app', '/conversion/convert', queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response']['status'] == 'success') {
          final List<dynamic> conversions = data['response']['body'];
          if (conversions.isNotEmpty) {
            final conversion = conversions.first;
            final price = double.parse(conversion['amount']);
            final formattedPrice = '$defaultCurrency ${_formatNumber(price)}';
            
            return {
              'name': symbol,
              'symbol': symbol,
              'price': formattedPrice,
              'iconUrl': 'assets/crypto_icons/${symbol.toLowerCase()}.svg',
              // Generate simple mock data for the mini chart
              'chartData': _generateSimpleMockData(price),
            };
          }
        }
      }
      throw Exception('Failed to fetch currency data');
    } catch (e) {
      print('Error fetching data for $symbol: $e');
      return {
        'name': symbol,
        'symbol': symbol,
        'price': 'Error',
        'iconUrl': 'assets/crypto_icons/${symbol.toLowerCase()}.svg',
        'chartData': <double>[],
      };
    }
  }

  // Add a simple mock data generator for mini charts
  List<double> _generateSimpleMockData(double currentPrice) {
    final random = Random();
    final List<double> data = [];
    double price = currentPrice;
    
    for (int i = 0; i < 10; i++) {
      data.add(price);
      price += price * 0.001 * (random.nextDouble() - 0.5);
    }
    
    return data;
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

  // Optimize timeseries data request
  Future<List<double>> getTimeseriesData(String symbol, DateTime startDate, DateTime endDate, String targetCurrency) async {
    try {
      // For longer periods, split into smaller chunks to avoid timeout
      if (endDate.difference(startDate).inDays > 30) {
        List<double> allData = [];
        DateTime chunkStart = startDate;
        
        // Use smaller chunks (7 days) for more granular data
        while (chunkStart.isBefore(endDate)) {
          DateTime chunkEnd = chunkStart.add(Duration(days: 7));
          if (chunkEnd.isAfter(endDate)) {
            chunkEnd = endDate;
          }

          final queryParams = {
            'baseCurrency': symbol.toLowerCase(),
            'startDate': chunkStart.toIso8601String().split('T')[0],
            'endDate': chunkEnd.toIso8601String().split('T')[0],
            'targetCurrency': targetCurrency.toLowerCase(),
          };

          final uri = Uri.http('api.stellarpay.app', '/conversion/timeseries', queryParams);
          
          final response = await http.get(uri).timeout(
            Duration(seconds: 20),
            onTimeout: () {
              print('Chunk request timed out, retrying...');
              return http.get(uri).timeout(
                Duration(seconds: 30),
                onTimeout: () => throw Exception('Request timed out after retry'),
              );
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['response']['status'] == 'success') {
              final List<dynamic> rates = data['response']['body'];
              allData.addAll(rates.map((rate) => double.parse(rate['rate'])));
            }
          }

          // Shorter delay between chunks
          await Future.delayed(Duration(milliseconds: 200));
          chunkStart = chunkEnd;  // Remove the +1 day to get continuous data
        }

        if (allData.isNotEmpty) {
          // Don't reduce the data points, keep all of them
          return allData;
        }
        throw Exception('Failed to fetch timeseries data');
      } else {
        // For shorter periods, get all available data points
        final queryParams = {
          'baseCurrency': symbol.toLowerCase(),
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          'targetCurrency': targetCurrency.toLowerCase(),
        };

        final uri = Uri.http('api.stellarpay.app', '/conversion/timeseries', queryParams);
        
        final response = await http.get(uri).timeout(
          Duration(seconds: 10),
          onTimeout: () => throw Exception('Request timed out'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['response']['status'] == 'success') {
            final List<dynamic> rates = data['response']['body'];
            return rates.map((rate) => double.parse(rate['rate'])).toList();
          }
        }
        throw Exception('Failed to fetch timeseries data');
      }
    } catch (e) {
      print('Error fetching timeseries data: $e');
      rethrow;
    }
  }

  // Add this helper method to reduce data points
  List<double> _reduceDataPoints(List<double> data, int targetPoints) {
    if (data.length <= targetPoints) return data;
    
    final step = data.length ~/ targetPoints;
    final reduced = <double>[];
    
    for (int i = 0; i < data.length; i += step) {
      // Take average of points in this step to smooth the data
      final chunk = data.sublist(i, (i + step).clamp(0, data.length));
      final avg = chunk.reduce((a, b) => a + b) / chunk.length;
      reduced.add(avg);
    }
    
    return reduced;
  }

  Future<List<double>> getHistoricalPrices(String symbol, String timeframe) async {
    final cacheKey = '${symbol}_${timeframe}';
    final now = DateTime.now();
    
    // Check cache first for the requested timeframe
    final cachedData = _timeseriesCache[cacheKey];
    if (cachedData != null && cachedData.isValid()) {
      print('Using cached data for $symbol $timeframe');
      return cachedData.data;
    }

    // Try to reuse data from longer timeframes
    if (timeframe == '1w') {
      // Try to use data from 2w or 1m
      final twoWeekData = _timeseriesCache['${symbol}_2w'];
      final monthData = _timeseriesCache['${symbol}_1m'];
      
      if (twoWeekData?.isValid() ?? false) {
        print('Reusing 2w data for 1w view');
        final weekData = twoWeekData!.data.sublist(max(0, twoWeekData.data.length - 7));
        _timeseriesCache[cacheKey] = _CacheEntry(weekData, now, timeframe);
        return weekData;
      } else if (monthData?.isValid() ?? false) {
        print('Reusing 1m data for 1w view');
        final weekData = monthData!.data.sublist(max(0, monthData.data.length - 7));
        _timeseriesCache[cacheKey] = _CacheEntry(weekData, now, timeframe);
        return weekData;
      }
    }

    if (timeframe == '2w') {
      final monthData = _timeseriesCache['${symbol}_1m'];
      if (monthData != null && monthData.isValid()) {
        print('Reusing 1m data for 2w view');
        final twoWeeksData = monthData.data.sublist(max(0, monthData.data.length - 14));
        _timeseriesCache[cacheKey] = _CacheEntry(twoWeeksData, now, timeframe);
        return twoWeeksData;
      }
    }
    
    if (timeframe == '1m') {
      final twoWeekData = _timeseriesCache['${symbol}_2w'];
      if (twoWeekData != null && twoWeekData.isValid()) {
        print('Using 2w data for partial 1m view');
        // Only fetch the remaining days
        final remainingStartDate = now.subtract(Duration(days: 30));
        final twoWeeksAgo = now.subtract(Duration(days: 14));
        
        try {
          final defaultCurrency = await getDefaultCurrency();
          final remainingData = await getTimeseriesData(
            symbol, 
            remainingStartDate, 
            twoWeeksAgo,
            defaultCurrency
          );
          
          // Combine old and new data
          final fullMonthData = [...remainingData, ...twoWeekData.data];
          _timeseriesCache[cacheKey] = _CacheEntry(fullMonthData, now, timeframe);
          return fullMonthData;
        } catch (e) {
          print('Error fetching remaining data: $e');
          return twoWeekData.data;
        }
      }
    }

    DateTime startDate;
    
    switch (timeframe) {
      case '1d':
        final currentPrice = await _getCurrentPrice(symbol);
        final data = _generateHourlyPrices(currentPrice, 24);
        _timeseriesCache[cacheKey] = _CacheEntry(data, now, timeframe);
        return data;
      case '1w':
        startDate = now.subtract(Duration(days: 7));
        break;
      case '2w':
        startDate = now.subtract(Duration(days: 14));
        break;
      case '1m':
        startDate = now.subtract(Duration(days: 30));
        break;
      default:
        startDate = now.subtract(Duration(days: 1));
    }

    try {
      final defaultCurrency = await getDefaultCurrency();
      final data = await getTimeseriesData(symbol, startDate, now, defaultCurrency);
      
      // Cache the data and create caches for shorter timeframes
      _timeseriesCache[cacheKey] = _CacheEntry(data, now, timeframe);

      // Cache subsets of data for shorter timeframes
      if (timeframe == '1m') {
        final twoWeeksData = data.sublist(max(0, data.length - 14));
        final weekData = data.sublist(max(0, data.length - 7));
        _timeseriesCache['${symbol}_2w'] = _CacheEntry(twoWeeksData, now, '2w');
        _timeseriesCache['${symbol}_1w'] = _CacheEntry(weekData, now, '1w');
      } else if (timeframe == '2w') {
        final weekData = data.sublist(max(0, data.length - 7));
        _timeseriesCache['${symbol}_1w'] = _CacheEntry(weekData, now, '1w');
      }

      return data;
    } catch (e) {
      print('Error fetching historical data: $e');
      if (cachedData != null) {
        print('Using expired cache data as fallback');
        return cachedData.data;
      }
      rethrow;
    }
  }

  // Helper method to get current price
  Future<double> _getCurrentPrice(String symbol) async {
    final defaultCurrency = await getDefaultCurrency();
    final data = await getCurrencyData(symbol);
    final priceStr = data['price'].split(' ')[1].replaceAll(',', '');
    return double.parse(priceStr);
  }

  // Generate hourly prices for 1-day view
  List<double> _generateHourlyPrices(double currentPrice, int hours) {
    final random = Random();
    final List<double> prices = [];
    double price = currentPrice;
    
    // Generate prices going backwards from current price
    for (int i = 0; i < hours; i++) {
      prices.add(price);
      // Smaller volatility for more realistic hourly changes
      final change = price * 0.001 * (random.nextDouble() - 0.45); // Slight downward bias
      price -= change;
    }
    
    return prices.reversed.toList(); // Return in chronological order
  }

  // Save watchlist to storage
  static Future<void> saveWatchlist(List<Map<String, dynamic>> currencies) async {
    final prefs = await SharedPreferences.getInstance();
    final watchlistJson = json.encode(currencies);
    await prefs.setString(_watchlistKey, watchlistJson);
    watchlist = currencies; // Update the in-memory watchlist
  }
} 