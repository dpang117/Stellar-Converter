import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'default_currency.dart';
import '../widgets/navigator.dart';
import '../widgets/currency_card.dart';
import 'currency_list.dart';
import '../services/currency_service.dart';
import 'dart:async';
import '../screens/currency_detail.dart';
import '../screens/settings_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'stellarpay_invite.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDefaultCurrency();
    _loadSavedWatchlist();
    _startPriceUpdates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDefaultCurrency() async {
    final currency = await CurrencyService.getDefaultCurrency();
    setState(() {
      defaultCurrency = currency;
    });
  }

  Future<void> _loadSavedWatchlist() async {
    final savedWatchlist = await CurrencyService.loadWatchlist();
    setState(() {
      displayedCurrencies.clear();
      displayedCurrencies.addAll(savedWatchlist);
    });
  }

  Future<void> _updatePrices() async {
    if (!mounted) return;
    
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

      // Check mounted again before updating state
      if (!mounted) return;

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
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startPriceUpdates() {
    // Cancel any existing timer
    _refreshTimer?.cancel();
    
    // Update prices immediately
    _updatePrices();
    
    // Then update every 30 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (mounted) {
        _updatePrices();
      }
    });
  }

  void _addCurrency() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyListScreen(
        mode: selectedCurrencyMode,
      ),
    );
    
    if (selected != null) {
      try {
        final data = await _currencyService.getCurrencyData(selected);
        setState(() {
          if (!displayedCurrencies.any((c) => c['symbol'] == selected)) {
            displayedCurrencies.add(data);
            CurrencyService.saveWatchlist(displayedCurrencies);
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
          initialChartData: const [], // Empty list since we're not using charts in cards anymore
        ),
      ),
    );

    if (result != null && result is Map && result['action'] == 'delete') {
      setState(() {
        displayedCurrencies.removeWhere(
          (c) => c['symbol'] == result['symbol']
        );
        CurrencyService.saveWatchlist(displayedCurrencies);
      });
    }
  }

  List<Map<String, dynamic>> getFilteredCurrencies() {
    if (_searchQuery.isEmpty) {
      return displayedCurrencies.where((currency) {
        final isCrypto = CurrencyService.cryptoCurrencies.contains(currency['symbol']);
        return (selectedCurrencyMode == "Crypto") == isCrypto;
      }).toList();
    }

    return displayedCurrencies.where((currency) {
      final isCrypto = CurrencyService.cryptoCurrencies.contains(currency['symbol']);
      final matchesType = (selectedCurrencyMode == "Crypto") == isCrypto;
      
      final matchesSearch = 
        currency['symbol'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        currency['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings, size: 26, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          },
        ),
        title: Text('Home', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color(0xFF0156FE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => StellarPayInvite(),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top section with search and toggle
          Container(
            color: Colors.white,
            child: Column(
              children: [
                searchField(),
                FiatCryptoToggle(),
                addCurrencyOrCoinButton(),
              ],
            ),
          ),
          
          // List view section
          Expanded(
            child: Container(
              color: Colors.white,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: currencyListView(),
              ),
            ),
          ),
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
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: CupertinoSegmentedControl<String>(
            padding: EdgeInsets.zero,
            groupValue: selectedCurrencyMode,
            borderColor: Colors.transparent,  // Remove rounded borders
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
      ),
    );
  }

  /// **Add Currency / Add Coin Button**
  Widget addCurrencyOrCoinButton() {
    String buttonText = selectedCurrencyMode == "Fiat" ? "Add currency" : "Add coin";
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
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
      ),
    );
  }

  /// **Displays List of Added Currencies or Placeholder Message**
  Widget currencyListView() {
    if (_isLoading) {
      return Center(
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
      );
    }

    final filteredCurrencies = getFilteredCurrencies();

    return filteredCurrencies.isEmpty
        ? Center(
            child: Text(
              _searchQuery.isEmpty
                  ? "${selectedCurrencyMode == 'Fiat' ? 'No currencies' : 'No cryptos'} added yet"
                  : "No matches found",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
        : ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: filteredCurrencies.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final currency = filteredCurrencies[index];
              return GestureDetector(
                onTap: () => _openCurrencyDetail(currency),
                child: CurrencyCard(
                  name: currency["name"],
                  symbol: currency["symbol"],
                  price: currency["price"],
                  iconUrl: currency["iconUrl"],
                  chartData: (currency["chartData"] as List?)?.cast<double>() ?? [],
                ),
              );
            },
          );
  }

  /// **Search Bar**
  Container searchField() {
    return Container(
      margin: EdgeInsets.only(top: 7, bottom: 6, left: 10, right: 10),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFEDEFF2),
          contentPadding: EdgeInsets.all(5),
          prefixIcon: Icon(Icons.search),
          hintText: 'Search ${selectedCurrencyMode.toLowerCase()}s',
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
