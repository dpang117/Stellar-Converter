import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import '../models/walkthrough_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalkthroughScreen extends StatefulWidget {
  @override
  _WalkthroughScreenState createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> walkthroughData = [
    'assets/walkthrough/walkthrough_1.svg',
    'assets/walkthrough/walkthrough_2.svg',
    'assets/walkthrough/walkthrough_3.svg',
    'assets/walkthrough/walkthrough_4.svg',
    'assets/walkthrough/walkthrough_5.svg',
    'assets/walkthrough/walkthrough_6.svg',
  ];

  void _goToNextPage() {
    if (_currentPage < walkthroughData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Set white icons for blue background
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.light, // Light icons for dark background
      statusBarBrightness: Brightness.dark, // Dark background (iOS)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0156FE),
      appBar: AppBar(
        systemOverlayStyle:
            SystemUiOverlayStyle.light, // Force light icons for dark background
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Content
            Container(
              color: Color(0xFF0156FE),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: walkthroughData.length,
                itemBuilder: (context, index) {
                  return SvgPicture.asset(
                    walkthroughData[index],
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
            // Story-style progress indicator
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stellar Converter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        walkthroughData.length,
                        (index) => Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            height: 2,
                            child: LinearProgressIndicator(
                              value: index < _currentPage
                                  ? 1.0
                                  : index == _currentPage
                                      ? 1.0
                                      : 0.0,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Touch areas for navigation
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _goToPreviousPage,
                      behavior: HitTestBehavior.opaque,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _goToNextPage,
                      behavior: HitTestBehavior.opaque,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom buttons
            Positioned(
              bottom: 40,
              left: 30,
              right: 30,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(initiallyShowSignUp: false),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(initiallyShowSignUp: true),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF0156FE),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeWalkthrough() async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_walkthrough', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
