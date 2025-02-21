import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'default_currency.dart';
import '../widgets/navigator.dart';
import '../widgets/currency_card.dart';
import 'currency_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCurrencyMode = "Crypto"; // Default selection
  int _currentIndex = 0;
  List<Map<String, dynamic>> addedFiatCurrencies = [];
  List<Map<String, dynamic>> addedCryptoCurrencies = [];

  /// **Handles navigation between tabs**
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
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
        onPressed: null, // ✅ Disabled for both Crypto and Fiat
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade400, // ✅ Grayed-out color
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
    List<Map<String, dynamic>> displayedCurrencies =
        selectedCurrencyMode == "Fiat"
            ? addedFiatCurrencies
            : addedCryptoCurrencies;

    return displayedCurrencies.isEmpty
        ? Center(
            child: Text(
              selectedCurrencyMode == "Fiat"
                  ? "No ${selectedCurrencyMode.toLowerCase()}s added yet"
                  : "Price watch is under construction",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
        : ListView.builder(
            itemCount: displayedCurrencies.length,
            itemBuilder: (context, index) {
              final currency = displayedCurrencies[index];
              return CurrencyCard(
                name: currency["name"],
                symbol: currency["symbol"].toUpperCase(),
                price: currency["price"],
                change: currency["change"],
                iconUrl: currency["iconUrl"],
                isPositive: currency["change"].startsWith("-") ? false : true,
              );
            },
          );
  }

  /// **App Bar with Settings Icon**
  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text('Home', style: Theme.of(context).textTheme.titleLarge),
      leading: IconButton(
        icon: Icon(Icons.settings, size: 26, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DefaultCurrency()),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
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
