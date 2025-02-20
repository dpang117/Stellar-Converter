import 'package:flutter/material.dart';

class CurrencyListScreen extends StatelessWidget {
  final List<Map<String, String>> currencies = [
    {"name": "Australian Dollar", "code": "AUD"},
    {"name": "Bulgarian Lev", "code": "BGN"},
    {"name": "Canadian Dollar", "code": "CAD"},
    {"name": "Chilean Peso", "code": "CLP"},
    {"name": "Colombian Peso", "code": "COP"},
    {"name": "Czech Koruna", "code": "CZK"},
    {"name": "Danish Krone", "code": "DKK"},
    {"name": "Egyptian Pound", "code": "EGP"},
    {"name": "Euro", "code": "EUR"},
    {"name": "Hong Kong Dollar", "code": "HKD"},
    {"name": "Hungarian Forint", "code": "HUF"},
    {"name": "Icelandic Krona", "code": "ISK"},
    {"name": "Indian Rupee", "code": "INR"},
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75, // Starts at 75% of the screen height
      minChildSize: 0.5, // Can shrink to 50%
      maxChildSize: 0.9, // Can expand to 90%
      builder: (_, scrollController) => Container(
        padding: const EdgeInsets.all(17),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Indicator
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Title
            const Text(
              'Currency',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Color(0xFF191B1E),
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 20),

            // Currency List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.monetization_on,
                        color: Colors.blue), // Replace with flags
                    title: Text(
                      currencies[index]["name"]!,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    subtitle: Text(
                      currencies[index]["code"]!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF737A86),
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(
                          context, currencies[index]["name"]); // Return data
                    },
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
