import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/navigator.dart'; // ✅ Import BottomNavigationBarWidget
import 'currency_list.dart'; // ✅ Import currency selection list

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCurrencyMode = "Crypto"; // Default to Crypto
  int _currentIndex = 0; // ✅ Keeps track of selected tab
  List<String> addedFiatCurrencies = [];
  List<String> addedCryptoCurrencies = [];

  /// **Handles navigation between tabs**
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// **Open Currency List Modal**
  void _openCurrencyList() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyListScreen(),
    );

    if (result != null) {
      setState(() {
        if (selectedCurrencyMode == "Fiat") {
          addedFiatCurrencies.add(result);
        } else {
          addedCryptoCurrencies.add(result);
        }
      });
    }
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
          addCurrencyOrCoinButton(),
          Expanded(child: currencyListView()), // ✅ Displays added currencies
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

  /// **Dynamic "Add Currency / Add Coin" Button**
  Widget addCurrencyOrCoinButton() {
    String buttonText =
        selectedCurrencyMode == "Fiat" ? "Add currency" : "Add coin";
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10),
      child: ElevatedButton.icon(
        onPressed: _openCurrencyList, // ✅ Opens the modal
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

  /// **Displays List of Added Currencies**
  Widget currencyListView() {
    List<String> displayedCurrencies = selectedCurrencyMode == "Fiat"
        ? addedFiatCurrencies
        : addedCryptoCurrencies;

    return displayedCurrencies.isEmpty
        ? Center(
            child: Text("No ${selectedCurrencyMode.toLowerCase()}s added yet"))
        : ListView.builder(
            itemCount: displayedCurrencies.length,
            itemBuilder: (context, index) {
              return currencyCard(displayedCurrencies[index]);
            },
          );
  }

  /// **Card for a Currency**
  Widget currencyCard(String currency) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue, // ✅ Same blue color as the UI
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currency,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              "\$0.00", // Placeholder for price
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **App Bar with Settings Icon**
  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text('Home', style: Theme.of(context).textTheme.titleLarge),
      leading: IconButton(
        icon: Icon(Icons.settings, size: 26, color: Colors.black),
        onPressed: () {
          Navigator.pushNamed(context, "/settings");
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
