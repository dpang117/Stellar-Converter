import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stellar_converter/screens/converter.dart';
import 'package:stellar_converter/screens/default_currency.dart';
import 'screens/login_screen.dart';
import '../screens/currency_list.dart';
import 'widgets/navigator.dart';
import 'screens/home.dart';
import 'screens/stellarpay_invite.dart';
import 'screens/startup.dart';
import 'services/currency_service.dart';
import 'services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/walkthrough_screen.dart';

void main() async {
  // Ensure Flutter is fully initialized before applying UI changes
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load the default currency
  await CurrencyService.getDefaultCurrency();

  final prefs = await SharedPreferences.getInstance();
  // For testing: Clear the walkthrough flag
  await prefs.remove('has_seen_walkthrough');

  final hasSeenWalkthrough = prefs.getBool('has_seen_walkthrough') ?? false;
  final isLoggedIn = await AuthService.isLoggedIn();

  // Add debug print statements
  print('Has seen walkthrough: $hasSeenWalkthrough');
  print('Is logged in: $isLoggedIn');

  Widget initialScreen;
  if (isLoggedIn) {
    initialScreen = HomeScreen();
  } else if (hasSeenWalkthrough) {
    initialScreen = LoginScreen();
  } else {
    initialScreen = WalkthroughScreen();
  }

  print('Initial screen: ${initialScreen.runtimeType}');

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

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
      home: initialScreen, // Use the Widget directly instead of a route string
    );
  }
}
