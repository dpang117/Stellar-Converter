import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'walkthrough_screen.dart';

class StartupScreen extends StatefulWidget {
  final bool isLoggedIn;
  
  const StartupScreen({
    super.key,
    required this.isLoggedIn,
  });

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => widget.isLoggedIn 
          ? HomeScreen() 
          : WalkthroughScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0156FE),
      body: Center(
        child: Text(
          'Converter',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'SF Pro Display',
          ),
        ),
      ),
    );
  }
}
