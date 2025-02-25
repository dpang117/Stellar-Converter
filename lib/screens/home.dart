import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'default_currency.dart';
import '../widgets/navigator.dart';
import '../widgets/currency_card.dart';
import 'currency_list.dart';
import '../services/currency_service.dart';
import 'dart:async';
import '../screens/currency_detail.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final List<Map<String, dynamic>> displayedCurrencies = [];
  String selectedCurrencyMode = "Crypto"; // Default to Crypto
  int _currentIndex = 0;
  Timer? _refreshTimer;
  String defaultCurrency = 'USD';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultCurrency();
    _startPriceUpdates();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDefaultCurrency() async {
    final currency = await CurrencyService.getDefaultCurrency();
    setState(() {
      defaultCurrency = currency;
    });
  }

  void _startPriceUpdates() {
    // Update prices immediately
    _updatePrices();
    
    // Then update every 30 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _updatePrices();
    });
  }

  Future<void> _updatePrices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update all currencies in parallel
      final futures = displayedCurrencies.map((currency) async {
        try {
          return await _currencyService.getCurrencyData(currency['symbol']);
        } catch (e) {
          print('Error updating price for ${currency['symbol']}: $e');
          return null;
        }
      });

      // Wait for all updates to complete
      final results = await Future.wait(futures);

      // Update state once with all new data
      setState(() {
        for (int i = 0; i < results.length; i++) {
          if (results[i] != null) {
            final index = displayedCurrencies.indexWhere(
              (c) => c['symbol'] == displayedCurrencies[i]['symbol']
            );
            if (index != -1) {
              displayedCurrencies[index] = results[i]!;
            }
          }
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addCurrency() async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencyListScreen(mode: selectedCurrencyMode),
      ),
    );
    
    if (selected != null) {
      try {
        final data = await _currencyService.getCurrencyData(selected);
        setState(() {
          if (!displayedCurrencies.any((c) => c['symbol'] == selected)) {
            displayedCurrencies.add(data);
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add currency: $e')),
        );
      }
    }
  }

  /// **Handles navigation between tabs**
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void openDefaultCurrency() async {
    setState(() {
      _isLoading = true;
    });

    final newCurrency = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => DefaultCurrency()),
    );

    if (newCurrency != null && newCurrency != defaultCurrency) {
      setState(() {
        defaultCurrency = newCurrency;
      });
      await _updatePrices();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openCurrencyDetail(Map<String, dynamic> currency) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencyDetailScreen(
          symbol: currency["symbol"],
          name: currency["name"],
          initialPrice: currency["price"],
          initialChange: currency["change"],
          isPositive: !currency["change"].startsWith("-"),
          initialChartData: currency["chartData"],
        ),
      ),
    );

    if (result != null && result is Map && result['action'] == 'delete') {
      setState(() {
        displayedCurrencies.removeWhere(
          (c) => c['symbol'] == result['symbol']
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          icon: Icon(Icons.settings, size: 26, color: Colors.black),
          onPressed: openDefaultCurrency,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchField(),
          FiatCryptoToggle(),
          addCurrencyOrCoinButton(), // ✅ Now appears for both Crypto & Fiat
          Expanded(child: currencyListView()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }

  /// **Fiat-Crypto Toggle**
  Padding FiatCryptoToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CupertinoSegmentedControl<String>(
          padding: EdgeInsets.all(6),
          groupValue: selectedCurrencyMode,
          borderColor: Colors.grey.shade300,
          selectedColor: Colors.black,
          unselectedColor: Colors.white,
          pressedColor: Colors.grey.shade200,
          children: {
            'Fiat': _buildSegment("Fiat"),
            'Crypto': _buildSegment("Crypto"),
          },
          onValueChanged: (value) {
            setState(() {
              selectedCurrencyMode = value;
            });
          },
        ),
      ),
    );
  }

  /// **Disabled "Add Currency / Add Coin" Button**
  Widget addCurrencyOrCoinButton() {
    String buttonText =
        selectedCurrencyMode == "Fiat" ? "Add currency" : "Add coin";
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10),
      child: ElevatedButton.icon(
        onPressed: _addCurrency,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: Icon(Icons.add, size: 18, color: Colors.white),
        label: Text(
          buttonText,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  /// **Displays List of Added Currencies or Placeholder Message**
  Widget currencyListView() {
    if (_isLoading) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 16),
              Text(
                'Updating prices...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: displayedCurrencies.isEmpty
          ? Center(
              child: Text(
                selectedCurrencyMode == "Fiat"
                    ? "No currencies added yet"
                    : "No cryptos added yet",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              itemCount: displayedCurrencies.length,
              itemBuilder: (context, index) {
                final currency = displayedCurrencies[index];
                final isCrypto = CurrencyService.cryptoCurrencies.contains(currency['symbol']);
                
                if ((selectedCurrencyMode == "Crypto") != isCrypto) {
                  return SizedBox.shrink();
                }

                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CurrencyDetailScreen(
                          symbol: currency["symbol"],
                          name: currency["name"],
                          initialPrice: currency["price"],
                          initialChange: currency["change"],
                          isPositive: !currency["change"].startsWith("-"),
                          initialChartData: (currency["chartData"] as List?)?.cast<double>() ?? [],
                        ),
                      ),
                    );

                    if (result != null && result is Map && result['action'] == 'delete') {
                      setState(() {
                        displayedCurrencies.removeWhere(
                          (c) => c['symbol'] == result['symbol']
                        );
                      });
                    }
                  },
                  child: CurrencyCard(
                    name: currency["name"],
                    symbol: currency["symbol"],
                    price: currency["price"],
                    change: currency["change"],
                    iconUrl: currency["iconUrl"],
                    isPositive: !currency["change"].startsWith("-"),
                    chartData: (currency["chartData"] as List?)?.cast<double>() ?? [],
                  ),
                );
              },
            ),
    );
  }

  /// **Search Bar**
  Container searchField() {
    return Container(
      margin: EdgeInsets.only(top: 7, bottom: 6, left: 10, right: 10),
      child: TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFEDEFF2),
          contentPadding: EdgeInsets.all(5),
          prefixIcon: Icon(Icons.search),
          hintText: 'Search',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// **Helper function for Cupertino Toggle**
  Widget _buildSegment(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: selectedCurrencyMode == text ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
