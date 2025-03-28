import 'package:flutter/material.dart';
import 'currency_list.dart';
import 'home.dart'; // ✅ Import HomeScreen for navigation
import 'package:shared_preferences/shared_preferences.dart';
import '../services/currency_service.dart';
import 'package:flutter/services.dart';
import '../widgets/navigator.dart';  // Add this import
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import '../models/register_request.dart';

class DefaultCurrency extends StatefulWidget {
  final RegisterRequest? registrationData;
  final bool isSignUp;

  const DefaultCurrency({
    Key? key, 
    this.registrationData,
    this.isSignUp = false,
  }) : super(key: key);

  @override
  _DefaultCurrencyState createState() => _DefaultCurrencyState();
}

class _DefaultCurrencyState extends State<DefaultCurrency> {
  String selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadCurrentCurrency();
  }

  Future<void> _loadCurrentCurrency() async {
    final currency = await CurrencyService.getDefaultCurrency();
    setState(() {
      selectedCurrency = currency;
    });
  }

  void _showCurrencyPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyListScreen(
        mode: "From",  // Show all currencies for default selection
      ),
    );

    if (selected != null) {
      setState(() {
        selectedCurrency = selected;
      });
    }
  }

  Future<void> _updateDefaultCurrency(String currency) async {
    await CurrencyService.setDefaultCurrency(currency);
    if (context.mounted) {
      Navigator.pop(context, currency); // Just return the currency string
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isSignUp) {
          // Go back to signup screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(initiallyShowSignUp: true),
            ),
          );
          return false;
        }
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light, // iOS
          statusBarIconBrightness: Brightness.dark, // Android
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (widget.isSignUp) {
                  // Go back to signup screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(initiallyShowSignUp: true),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
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
                  onTap: _showCurrencyPicker,
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
                  onPressed: () async {
                    if (selectedCurrency.isNotEmpty) {
                      if (widget.isSignUp && widget.registrationData != null) {
                        // First register the user
                        final success = await AuthService.register(widget.registrationData!);
                        if (success) {
                          // Then set the default currency
                          await CurrencyService.setDefaultCurrency(selectedCurrency);
                          // Navigate to HomeScreen
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                            );
                          }
                        }
                      } else {
                        // Normal default currency change
                        await CurrencyService.setDefaultCurrency(selectedCurrency);
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                          );
                        }
                      }
                    }
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
        ),
      ),
    );
  }
}
