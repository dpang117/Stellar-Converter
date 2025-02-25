import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stellar_converter/screens/converter.dart';
import 'package:stellar_converter/screens/default_currency.dart';
import 'package:stellar_converter/screens/startup.dart';
import 'screens/login_screen.dart';
import '../screens/currency_list.dart';
import 'widgets/navigator.dart';
import 'screens/home.dart';
import 'screens/stellarpay_invite.dart';

void main() {
  // Ensure Flutter is fully initialized before applying UI changes
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar icons to black (for light backgrounds)
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent, // Fully transparent status bar
    statusBarIconBrightness:
        Brightness.dark, // Dark icons (for light background)
    statusBarBrightness: Brightness.light, // Adjusts appearance in iOS
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // Makes AppBar white
          elevation: 0, // Removes shadow for a cleaner look
          iconTheme:
              IconThemeData(color: Colors.black), // Ensures icons are visible
          titleTextStyle:
              TextStyle(color: Colors.black, fontSize: 20), // AppBar text
        ),
        fontFamily: Theme.of(context).platform == TargetPlatform.iOS
            ? '.SF Pro Display' // iOS/macOS System Font
            : 'Roboto', // Fallback for Android/Web
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          titleLarge: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600), // Figma Semibold 18
          bodyLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w400), // Normal body text
          bodyMedium: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400), // Smaller body text
          labelLarge: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500), // Button text
        ),
      ),
      home: StartupScreen(),
    );
  }
}
