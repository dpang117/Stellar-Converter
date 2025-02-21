import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for vibration
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String selectedCurrencyFrom = 'USD';
  String selectedCurrencyTo = 'BTC';
  String inputAmount = ''; // Stores user input
  String convertedAmount = ''; // Stores the result after conversion

  /// **Handles number input from numpad with vibration feedback**
  void onNumberPressed(String number) {
    HapticFeedback.lightImpact(); // ✅ Short vibration for feedback
    setState(() {
      if (number == '.' && inputAmount.contains('.'))
        return; // Prevent multiple decimals
      inputAmount += number;
    });
  }

  /// **Handles backspace on numpad with vibration feedback**
  void onBackspacePressed() {
    HapticFeedback.lightImpact(); // ✅ Short vibration for feedback
    setState(() {
      if (inputAmount.isNotEmpty) {
        inputAmount = inputAmount.substring(0, inputAmount.length - 1);
      }
    });
  }

  /// **Convert currency using backend API**
  Future<void> _convertCurrency() async {
    if (inputAmount.isEmpty) return; // No input means no conversion

    final url = Uri.parse(
        'http://127.0.0.1:5000/convert?from=$selectedCurrencyFrom&to=$selectedCurrencyTo&amount=$inputAmount');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          convertedAmount = data['converted_amount'].toString();
        });
      } else {
        setState(() {
          convertedAmount = 'Error';
        });
      }
    } catch (e) {
      setState(() {
        convertedAmount = 'Error';
      });
    }
  }

  /// **Handles screen transition when clicking back button**
  void _goBack() {
    Navigator.of(context).pop(); // Default pop transition (slides in from left)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Triggers back transition
          },
          child: Icon(Icons.arrow_back),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title (UNCHANGED)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Converter',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 20),

          // **Fields Moved Down**
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            child: Column(
              children: [
                // **First Currency Row (FROM) - Editable**
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCurrencyFrom,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          inputAmount.isEmpty ? "0" : inputAmount,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // Arrow icon (points down)
                Center(
                  child: Icon(
                    Icons.arrow_downward,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),

                SizedBox(height: 10),

                // **Second Currency Row (TO) - Non-editable**
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCurrencyTo,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          convertedAmount.isEmpty ? "0" : convertedAmount,
                          style: TextStyle(
                              fontSize: 18,
                              color: convertedAmount.isEmpty
                                  ? Colors.black54
                                  : Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40),

                // **Updated Convert Button**
                Center(
                  child: ElevatedButton(
                    onPressed: _convertCurrency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Convert',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          // **Number Pad**
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) {
              if (index == 9) {
                return _buildNumPadButton('.');
              } else if (index == 11) {
                return _buildBackspaceButton();
              } else {
                String number = index == 10 ? '0' : '${index + 1}';
                return _buildNumPadButton(number);
              }
            },
          ),
        ],
      ),
    );
  }

  /// **Creates a number button with vibration feedback**
  Widget _buildNumPadButton(String value) {
    return GestureDetector(
      onTap: () => onNumberPressed(value),
      behavior: HitTestBehavior.opaque, // ✅ Makes the whole area tappable
      child: Center(
        child: Text(
          value,
          style: TextStyle(fontSize: 30), // ✅ Restored font weight
        ),
      ),
    );
  }

  /// **Creates a backspace button with vibration feedback**
  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: onBackspacePressed,
      behavior: HitTestBehavior.opaque, // ✅ Makes the whole area tappable
      child: Center(
        child: Icon(Icons.backspace, size: 24),
      ),
    );
  }
}
