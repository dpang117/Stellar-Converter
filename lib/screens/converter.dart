import 'package:flutter/material.dart';

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String selectedCurrencyFrom = 'USD';
  String selectedCurrencyTo = 'FCFA';
  String inputAmount = ''; // Stores user input

  // List of available currencies
  final List<String> fiatCurrencies = ['USD', 'EUR', 'GBP'];
  final List<String> cryptoCurrencies = ['FCFA', 'NGN', 'KES'];

  void onNumberPressed(String number) {
    setState(() {
      // Prevent multiple decimals
      if (number == '.' && inputAmount.contains('.')) return;
      inputAmount += number;
    });
  }

  void onBackspacePressed() {
    setState(() {
      if (inputAmount.isNotEmpty) {
        inputAmount = inputAmount.substring(0, inputAmount.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        actions: [Icon(Icons.arrow_drop_down)],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Converter',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // First currency row
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: selectedCurrencyFrom,
                    items: fiatCurrencies
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCurrencyFrom = newValue!;
                      });
                    },
                  ),
                  Text(
                    '\$${inputAmount.isEmpty ? "0" : inputAmount}', // Display user input
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Arrow icon (now pointing down)
            Center(
              child: Icon(
                Icons.arrow_downward, // ✅ Now points down
                color: Colors.blue,
              ),
            ),

            SizedBox(height: 10),

            // Second currency row
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: selectedCurrencyTo,
                    items: cryptoCurrencies
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCurrencyTo = newValue!;
                      });
                    },
                  ),
                  Text(
                    selectedCurrencyTo +
                        " " +
                        (inputAmount.isEmpty
                            ? "0"
                            : inputAmount), // Placeholder for converted value
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print(
                      "Convert $inputAmount $selectedCurrencyFrom to $selectedCurrencyTo");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Send money with StellarPay',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            Spacer(),

            // Number Pad (Now Includes Decimal Button)
            GridView.builder(
              shrinkWrap: true,
              physics:
                  NeverScrollableScrollPhysics(), // Prevents scrolling inside GridView
              itemCount: 12,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
              ),
              itemBuilder: (context, index) {
                if (index == 9) {
                  return GestureDetector(
                    onTap: () => onNumberPressed('.'),
                    child: Center(
                      child: Text(
                        '.',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                } else if (index == 11) {
                  return GestureDetector(
                    onTap: onBackspacePressed,
                    child: Icon(Icons.backspace),
                  );
                } else {
                  String number = index == 10 ? '0' : '${index + 1}';
                  return GestureDetector(
                    onTap: () => onNumberPressed(number),
                    child: Center(
                      child: Text(
                        number,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
