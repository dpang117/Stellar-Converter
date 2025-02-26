import 'package:flutter/material.dart';
import '../widgets/currency_card.dart';
import '../services/currency_service.dart';
import '../models/price_data.dart';
import 'currency_list.dart';
import 'dart:async';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final _currencyService = CurrencyService();
  List<Map<String, dynamic>> watchlist = [];
  bool isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Set up periodic refresh
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _refreshWatchlistData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      // Clear any cached data
      CurrencyService.clearCache();
      
      // Load watchlist with fresh data
      final freshWatchlist = await CurrencyService.loadWatchlist();
      
      if (mounted) {
        setState(() {
          watchlist = freshWatchlist;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadWatchlist() async {
    if (!mounted) return;
    
    final loadedWatchlist = await CurrencyService.loadWatchlist();
    setState(() {
      watchlist = loadedWatchlist;
    });
  }

  Future<void> _refreshWatchlistData() async {
    if (!mounted || watchlist.isEmpty) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      // Get the default currency once for all requests
      final defaultCurrency = await CurrencyService.getDefaultCurrency();
      print('Refreshing watchlist with default currency: $defaultCurrency');

      final updatedWatchlist = await Future.wait(
        watchlist.map((currency) async {
          final updatedData = await _currencyService.getCurrencyData(currency['symbol']);
          print('Updated data for ${currency['symbol']}: $updatedData');
          return {
            ...currency,
            ...updatedData,
          };
        }),
      );

      if (mounted) {
        setState(() {
          watchlist = updatedWatchlist;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error refreshing watchlist: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Add a method to handle currency changes
  void onDefaultCurrencyChanged() {
    _refreshWatchlistData();
  }

  void _addCurrency() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyListScreen(
        mode: watchlist.isNotEmpty
            ? watchlist[0]['isCrypto']
                ? "Crypto"
                : "Fiat"
            : "Crypto",
      ),
    );

    if (selected != null &&
        !watchlist.any((currency) => currency['symbol'] == selected)) {
      setState(() {
        watchlist.add({
          'symbol': selected,
          'isCrypto': CurrencyService.cryptoCurrencies.contains(selected)
        });
      });
      _refreshWatchlistData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          // Fiat/Crypto Toggle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => watchlist
                      .forEach((currency) => currency['isCrypto'] = false)),
                  child: Text(
                    'Fiat',
                    style: TextStyle(
                      color:
                          watchlist.every((currency) => !currency['isCrypto'])
                              ? Colors.blue
                              : Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => watchlist
                      .forEach((currency) => currency['isCrypto'] = true)),
                  child: Text(
                    'Crypto',
                    style: TextStyle(
                      color: watchlist.every((currency) => currency['isCrypto'])
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Add Coin Button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _addCurrency,
              icon: Icon(Icons.add),
              label: Text(
                  'Add ${watchlist.isNotEmpty ? (watchlist[0]['isCrypto'] ? "coin" : "currency") : "coin"}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // Watchlist
          Expanded(
            child: isLoading
                ? CircularProgressIndicator()
                : ListView.builder(
                    itemCount: watchlist.length,
                    itemBuilder: (context, index) {
                      final currency = watchlist[index];
                      if (!currency['isCrypto'] &&
                          !watchlist.every((c) => c['isCrypto']))
                        return SizedBox.shrink();

                      return CurrencyCard(
                        name: currency['name'],
                        symbol: currency['symbol'],
                        price: currency['price'],
                        iconUrl: currency['iconUrl'],
                        chartData: (currency['chartData'] as List?)?.cast<double>() ?? [],
                        onRemove: () {
                          setState(() {
                            watchlist.removeAt(index);
                          });
                          _refreshWatchlistData();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
