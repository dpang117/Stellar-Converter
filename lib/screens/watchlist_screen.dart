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
  final List<String> watchlist = [];
  final CurrencyService _currencyService = CurrencyService();
  final Map<String, PriceData> priceData = {};
  Timer? _refreshTimer;
  bool showCrypto = true;

  @override
  void initState() {
    super.initState();
    _startPriceUpdates();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPriceUpdates() {
    _updatePrices();
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _updatePrices();
    });
  }

  Future<void> _updatePrices() async {
    for (final currency in watchlist) {
      try {
        final data = await _currencyService.getCurrencyData(currency);
        setState(() {
          priceData[currency] = PriceData.fromJson(data);
        });
      } catch (e) {
        print('Error fetching price for $currency: $e');
      }
    }
  }

  void _addCurrency() async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => CurrencyListScreen()),
    );
    
    if (selected != null && !watchlist.contains(selected)) {
      setState(() {
        watchlist.add(selected);
      });
      _updatePrices();
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
                  onPressed: () => setState(() => showCrypto = false),
                  child: Text('Fiat',
                    style: TextStyle(
                      color: !showCrypto ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => showCrypto = true),
                  child: Text('Crypto',
                    style: TextStyle(
                      color: showCrypto ? Colors.blue : Colors.grey,
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
              label: Text('Add ${showCrypto ? "coin" : "currency"}'),
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
            child: ListView.builder(
              itemCount: watchlist.length,
              itemBuilder: (context, index) {
                final currency = watchlist[index];
                final data = priceData[currency];
                if (data == null) return SizedBox.shrink();
                
                final isCrypto = CurrencyService.cryptoCurrencies.contains(currency);
                if (showCrypto != isCrypto) return SizedBox.shrink();
                
                return CurrencyCard(
                  name: data.name,
                  symbol: currency,
                  price: data.price,
                  change: data.change,
                  iconUrl: data.iconUrl,
                  isPositive: data.isPositive,
                  chartData: data.chartData,
                  onRemove: () {
                    setState(() {
                      watchlist.remove(currency);
                      priceData.remove(currency);
                    });
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