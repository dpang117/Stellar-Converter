import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart'; // Import your main page

class StartupScreen extends StatefulWidget {
  @override
  _StartupScreenState createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the main page after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen()), // Replace with your main page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons for dark background
        statusBarBrightness: Brightness.dark, // iOS
      ),
      child: Scaffold(
        backgroundColor: Color(0xFF0156FE), // Blue background
        body: Stack(
          children: [
            // Background color
            Container(
              color: Color(0xFF0156FE),
            ),
            // Image
            Center(
              child: Image.asset(
                'assets/images/splash_logo.png',
                fit: BoxFit.contain,
                // Add error builder to debug image loading issues
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading splash image: $error');
                  return Text(
                    'Converter',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
