import 'package:flutter/material.dart';
import 'currency_list.dart';
import 'home.dart'; // ✅ Import HomeScreen for navigation

class DefaultCurrency extends StatefulWidget {
  @override
  _CurrencySelectionScreenState createState() =>
      _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<DefaultCurrency> {
  String selectedCurrency = "Canadian Dollar"; // Default selection

  void _openCurrencyList() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyListScreen(),
    );

    if (result != null) {
      setState(() {
        selectedCurrency = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // ✅ Takes user back to HomeScreen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose main \ncurrency',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Color(0xFF191B1E),
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose your main currency',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF737A86),
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 30),

            // **Currency Selection Box**
            GestureDetector(
              onTap: _openCurrencyList,
              child: Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEFF2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCurrency,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Color(0xFF191B1E),
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          size: 24, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // **Confirm Button (Returns to HomeScreen)**
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // ✅ Go back to HomeScreen
              },
              child: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
