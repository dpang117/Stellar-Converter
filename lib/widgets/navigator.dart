import 'package:flutter/material.dart';

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
              color: Color.fromARGB(255, 255, 255,
                  255), // ✅ Same background as navbar (removes border)
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // ✅ More spacing between icons
              children: [
                _buildNavItem(
                  iconUrl:
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RpF6FSRdmiMICj6rvpB%2F744271db-4caf-47a9-b3a0-475418495f2f.png',
                  label: "Rates",
                  index: 0,
                ),
                _buildNavItem(
                  iconUrl:
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RpF6FSRdmiMICj6rvpB%2F86a38a16-eb77-42f5-9559-b3be44f70834.png',
                  label: "Convert",
                  index: 1,
                ),
                _buildNavItem(
                  iconUrl:
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RpF6FSRdmiMICj6rvpB%2Fd9cb1c6f-dea2-4bfb-85cf-2d67709faf0b.png',
                  label: "Settings",
                  index: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconUrl,
    required String label,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
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
