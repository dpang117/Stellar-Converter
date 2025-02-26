import 'package:flutter/material.dart';
import 'currency_list.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/currency_service.dart';
import 'package:intl/intl.dart';

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
  final _currencyService = CurrencyService();

  /// **Show Bottom Sheet for Currency Selection**
  Future<void> _showBottomSheet(bool isSelectingFrom) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyListScreen(
        mode: isSelectingFrom ? "From" : "To",
      ),
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

  /// **Handles number input from numpad with haptic feedback**
  void onNumberPressed(String number) {
    HapticFeedback.mediumImpact(); // Changed from lightImpact
    setState(() {
      if (number == '.' && inputAmount.contains('.'))
        return;
      inputAmount += number;
    });
  }

  /// **Handles backspace on numpad with haptic feedback**
  void onBackspacePressed() {
    HapticFeedback.mediumImpact(); // ✅ Slightly stronger vibration for backspace
    setState(() {
      if (inputAmount.isNotEmpty) {
        inputAmount = inputAmount.substring(0, inputAmount.length - 1);
      }
    });
  }

  /// **Convert currency using backend API**
  Future<void> _convertCurrency() async {
    HapticFeedback.mediumImpact(); // Add haptic feedback
    if (inputAmount.isEmpty) return;

    try {
      final conversions = await _currencyService.convertCurrency(
        selectedCurrencyFrom,
        double.parse(inputAmount),
        [selectedCurrencyTo],
      );
      
      setState(() {
        if (conversions.isNotEmpty) {
          // Get the first (and only) conversion result
          final conversion = conversions.first;
          convertedAmount = _formatNumber(double.parse(conversion.amount));
        } else {
          convertedAmount = 'Error';
        }
      });
    } catch (e) {
      setState(() {
        convertedAmount = 'Error';
      });
    }
  }

  String _formatNumber(double number) {
    final formatter = NumberFormat.decimalPattern();
    if (number >= 1) {
      return formatter.format(number);
    } else {
      return number.toStringAsFixed(6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light, // iOS
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,  // Add this
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

            SizedBox(height: 30), // Change from 40 (after 'Converter' text)

            // **First Currency Row (FROM) - Editable**
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () => _showBottomSheet(true),
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
                onTap: () => _showBottomSheet(false),
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

            SizedBox(height: 30), // Change from 40

            // **Convert Button**
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _convertCurrency,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12), // Increased padding
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Convert',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),

            Spacer(),

            // **Number Pad**
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 8), // Add bottom padding
              itemCount: 12,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.4, // Adjust from 1.3 to make buttons slightly less tall
              ),
              itemBuilder: (context, index) {
                if (index == 9) {
                  return GestureDetector(
                    onTap: () => onNumberPressed('.'),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(23),
                      child: Center(
                        child: Text('.', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                } else if (index == 11) {
                  return GestureDetector(
                    onTap: onBackspacePressed,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(25),
                      child: Center(
                        child: Icon(Icons.backspace),
                      ),
                    ),
                  );
                } else {
                  String number = index == 10 ? '0' : '${index + 1}';
                  return GestureDetector(
                    onTap: () => onNumberPressed(number),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(25),
                      child: Center(
                        child: Text(number, style: TextStyle(fontSize: 30)),
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
