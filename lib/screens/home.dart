import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/navigator.dart'; // ✅ Import the BottomNavigationBarWidget

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userInitials = "HS"; // Placeholder
  String selectedCurrency = "Fiat"; // Default selection
  int _currentIndex = 0; // ✅ Keeps track of which tab is selected

  /// **Handles navigation between tabs**
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // TODO: Implement navigation logic for different screens
    print("Navigated to tab: $_currentIndex");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchField(),
              FiatCryptoToggle(),
              addCurrencyOrCoinButton(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigationBarWidget(
              onTap: _onTabTapped, // ✅ Pass navigation function
              currentIndex: _currentIndex, // ✅ Pass current selected index
            ),
          ),
        ],
      ),
    );
  }

  /// **Restored Cupertino Fiat-Crypto Toggle**
  Padding FiatCryptoToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CupertinoSegmentedControl<String>(
          padding: EdgeInsets.all(6),
          groupValue: selectedCurrency,
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
              selectedCurrency = value;
            });
          },
        ),
      ),
    );
  }

  /// **Dynamic "Add Currency / Add Coin" Button**
  Widget addCurrencyOrCoinButton() {
    String buttonText =
        selectedCurrency == "Fiat" ? "Add currency" : "Add coin";
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10),
      child: ElevatedButton.icon(
        onPressed: () {
          print("$buttonText Clicked!");
        },
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

  /// **Builds Each Segment for Cupertino Toggle**
  Widget _buildSegment(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: selectedCurrency == text ? Colors.white : Colors.black,
        ),
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

  /// **App Bar**
  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text('Home', style: Theme.of(context).textTheme.titleLarge),
      leading: GestureDetector(
        onTap: () {
          print("Settings Clicked!");
        },
        child: Container(
          margin: const EdgeInsets.all(12),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              userInitials,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
