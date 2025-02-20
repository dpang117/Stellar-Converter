import 'package:flutter/material.dart';
import 'currency_list.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Page Title
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Color(0xFF191B1E),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 20),

              // Social Login Buttons
              buildSocialButton(
                text: 'Sign in with Google',
                backgroundColor: Colors.white,
                textColor: Colors.black,
              ),
              const SizedBox(height: 12),
              buildSocialButton(
                text: 'Sign in with Apple',
                backgroundColor: Colors.black,
                textColor: Colors.white,
              ),
              const SizedBox(height: 20),

              // Divider
              const Divider(color: Color(0xFFC6C6C8), thickness: 1),
              const SizedBox(height: 11),

              // Email Login Section
              const Text(
                'Or log in with email',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF737A86),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 11),

              // Input Fields
              buildInputField('Email', _emailController),
              const SizedBox(height: 11),
              buildInputField('Password', _passwordController),
              const SizedBox(height: 30),

              // Continue Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to Currency Selection Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CurrencySelectionScreen()),
                  );
                },
                child: const Text("Continue"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
    );
  }

  // Social Login Button
  Widget buildSocialButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                color: textColor,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input Field
  Widget buildInputField(String label, TextEditingController controller) {
    return Container(
      width: double.infinity,
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0x288B929B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

/// CURRENCY SELECTION SCREEN
class CurrencySelectionScreen extends StatefulWidget {
  @override
  _CurrencySelectionScreenState createState() =>
      _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  String selectedCurrency = "Canadian Dollar"; // Default selection

  void _openCurrencyList() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // Allows it to be draggable
      backgroundColor: Colors.transparent, // Maintains round edges
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
            Navigator.pop(context);
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

            // Currency Selection Box
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

            // Next Button
            ElevatedButton(
              onPressed: () {},
              child: const Text("Next"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
