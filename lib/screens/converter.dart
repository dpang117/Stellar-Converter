import 'package:flutter/material.dart';
import 'currency_list.dart';
import 'package:flutter/services.dart';
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

  /// **Show Bottom Sheet for Currency Selection**
  Future<void> _selectCurrency(bool isSelectingFrom) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CurrencyListScreen(); // ✅ Currency selection list
      },
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        if (isSelectingFrom) {
          selectedCurrencyFrom = selected;
        } else {
          selectedCurrencyTo = selected;
        }
        convertedAmount = ''; // Reset conversion result
      });
    }
  }

  /// **Handles number input from numpad**
  /// **Handles number input from numpad with haptic feedback**
  void onNumberPressed(String number) {
    HapticFeedback.lightImpact(); // ✅ Trigger light vibration on press
    setState(() {
      if (number == '.' && inputAmount.contains('.'))
        return; // Prevent multiple decimals
      inputAmount += number;
    });
  }

  /// **Handles backspace on numpad with haptic feedback**
  void onBackspacePressed() {
    HapticFeedback
        .mediumImpact(); // ✅ Slightly stronger vibration for backspace
    setState(() {
      if (inputAmount.isNotEmpty) {
        inputAmount = inputAmount.substring(0, inputAmount.length - 1);
      }
    });
  }

  /// **Convert currency using backend API**
  Future<void> _convertCurrency() async {
    if (inputAmount.isEmpty) return;

    final url = Uri.parse(
        'https://stellar-converter.onrender.com/convert?from=$selectedCurrencyFrom&to=$selectedCurrencyTo&amount=$inputAmount');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Converter',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 40), // ✅ Moves fields down

          // **First Currency Row (FROM) - Editable**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () => _selectCurrency(true),
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
                      selectedCurrencyFrom, // ✅ Updated Selection
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      inputAmount.isEmpty
                          ? "0"
                          : inputAmount, // ✅ Shows user input
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10),

          // **Arrow Icon (Indicates Direction)**
          Center(
            child: Icon(Icons.arrow_downward,
                color: const Color.fromARGB(255, 0, 0, 0)),
          ),

          SizedBox(height: 10),

          // **Second Currency Row (TO) - Editable**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () => _selectCurrency(false),
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
                      selectedCurrencyTo, // ✅ Updated Selection
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      convertedAmount.isEmpty
                          ? "0"
                          : convertedAmount, // ✅ Updates after conversion
                      style: TextStyle(
                        fontSize: 18,
                        color: convertedAmount.isEmpty
                            ? Colors.black54
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 40),

          // **Convert Button**
          Center(
            child: ElevatedButton(
              onPressed: _convertCurrency,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 9),
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
                return GestureDetector(
                  onTap: () => onNumberPressed('.'),
                  child: Center(
                    child: Text('.', style: TextStyle(fontSize: 24)),
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
                    child: Text(number, style: TextStyle(fontSize: 30)),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
