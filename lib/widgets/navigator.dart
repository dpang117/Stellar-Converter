import 'package:flutter/material.dart';
import '../screens/converter.dart'; // ✅ Import the Converter screen

class BottomNavigationBarWidget extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const BottomNavigationBarWidget({
    Key? key,
    required this.onTap,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ✅ Adjust width to be flexible
      height: 91,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255), // ✅ Background color
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity, // ✅ Full width
            height: 57,
            decoration: BoxDecoration(
              color: Color.fromARGB(
                  255, 255, 255, 255), // ✅ Match navbar background
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // ✅ More spacing between icons
              children: [
                _buildNavItem(
                  context: context,
                  iconUrl:
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RpF6FSRdmiMICj6rvpB%2F744271db-4caf-47a9-b3a0-475418495f2f.png',
                  label: "Rates",
                  index: 0,
                  destination: null, // No navigation for this yet
                ),
                _buildNavItem(
                  context: context,
                  iconUrl:
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RpF6FSRdmiMICj6rvpB%2F86a38a16-eb77-42f5-9559-b3be44f70834.png',
                  label: "Convert",
                  index: 1,
                  destination:
                      CurrencyConverterScreen(), // ✅ Navigates to Converter
                ),
                _buildNavItem(
                  context: context,
                  iconUrl:
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RpF6FSRdmiMICj6rvpB%2Fd9cb1c6f-dea2-4bfb-85cf-2d67709faf0b.png',
                  label: "Settings",
                  index: 2,
                  destination: null, // No navigation for this yet
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String iconUrl,
    required String label,
    required int index,
    Widget? destination, // ✅ Allows navigation to a new screen
  }) {
    return GestureDetector(
      onTap: () {
        onTap(index);
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20), // ✅ Adds more spacing
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              iconUrl,
              width: 24, // ✅ Slightly bigger icon for better visibility
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 6), // ✅ More spacing between icon & text
            Text(
              label,
              style: TextStyle(
                color: currentIndex == index ? Colors.black : Color(0xFF777F89),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
