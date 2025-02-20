import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CurrencyConverterScreen(),
  ));
}

class CurrencyConverterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing:
            0, // Ensures the title is aligned right below the back button
        title: const Padding(
          padding:
              EdgeInsets.only(left: 5), // Keeps it aligned with the back arrow
          child: Text(
            'Converter',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Currency Selector Stack (For Overlapping Arrow)
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    _buildCurrencySelector(
                      label: 'USD',
                      value: '\$15',
                      height: 80, // Increased field height
                    ),
                    const SizedBox(height: 5), // Closer together
                    _buildCurrencySelector(
                      label: 'FCFA',
                      value: 'FCFA9,545.40',
                      height: 80, // Increased field height
                    ),
                  ],
                ),

                // Overlapping Arrow Button
                Positioned(
                  top: 55, // Adjusted to overlap both fields
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_upward,
                        size: 18, color: Colors.blue),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 70),
                ),
                child: const Text(
                  'Send money with StellarPay',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Currency Selector Widget (Larger with Custom Height)
  Widget _buildCurrencySelector({
    required String label,
    required String value,
    double height = 70, // Default height, customizable
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
