import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/startup.dart';
import 'screens/home.dart';
import 'screens/walkthrough_screen.dart';
import 'services/currency_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ensure system overlays are visible
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  await CurrencyService.getDefaultCurrency();
  final isLoggedIn = await AuthService.isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
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
      home: StartupScreen(isLoggedIn: isLoggedIn),
    );
  }
}
