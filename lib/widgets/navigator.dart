import 'package:flutter/material.dart';
import '../screens/default_currency.dart';
import '../screens/converter.dart';
import '../screens/home.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const BottomNavigationBarWidget({
    Key? key,
    required this.onTap,
    required this.currentIndex,
  }) : super(key: key);

  void _handleSettingsTap(BuildContext context) async {
    final homeState = context.findAncestorStateOfType<HomeScreenState>();
    if (homeState != null) {
      homeState.openDefaultCurrency();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DefaultCurrency()),
      );
    }
  }

  void _handleTransferTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CurrencyConverterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 2) { // Settings tab
          _handleSettingsTap(context);
        } else if (index == 1) { // Transfer tab
          _handleTransferTap(context);
        } else {
          onTap(index);
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.network(
            'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RpF6FSRdmiMICj6rvpB%2F86a38a16-eb77-42f5-9559-b3be44f70834.png',
            width: 24,
            height: 24,
          ),
          label: 'Convert',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}
