import 'package:flutter/material.dart';

class StellarPayInvite extends StatefulWidget {
  @override
  _StellarPayInviteState createState() => _StellarPayInviteState();
}

class _StellarPayInviteState extends State<StellarPayInvite> {
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    // Ensure focus is removed (to prevent yellow lines)
    FocusScope.of(context).unfocus();

    return Material(  // Wrap with Material widget
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () => Navigator.pop(context), // Tap outside to close
        child: Container(
          color: Colors.black.withOpacity(0.5), // Semi-transparent background
          child: DraggableScrollableSheet(
            initialChildSize: 0.9, // Takes up 90% of the screen
            minChildSize: 0.9,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Color(0xFF0156FE),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(  // Add ClipRRect to ensure content is clipped
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: MediaQuery.removePadding(  // Remove top padding
                    context: context,
                    removeTop: true,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: _showSuccess
                          ? _buildSuccessContent()
                          : _buildMainContent(scrollController),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            // Close Button
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Success Title
            const Text(
              "You're in!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Success Message
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Check your email and stay tuned for an email from us with the link to get you started',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // Done Button
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(45),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 17,
                color: Color(0xFF0156FE),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(ScrollController scrollController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,  // Force left alignment for the column
      children: [
        // Header section with left alignment
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,  // Force left alignment
            children: [
              // Close Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
              
              const SizedBox(height: 20),
              
              // Title - Left aligned
              const Text(
                'Send money with\nthe StellarPay App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Scrollable content
        Flexible(
          child: SingleChildScrollView(
            controller: scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,  // Force left alignment
              children: [
                _buildFeatureCard(
                  title: 'Get the mid-market rate',
                  description: 'StellarPay will always show you a clear and transparent fee so you know exactly what you are going to pay.',
                  imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RpF6FSRdmiMICj6rvpB%2Fc9ce9649-12bd-4356-8b90-afbc05b7b650.png',
                  tag: 'New',
                ),
                _buildFeatureCard(
                  title: 'Track your transfers on the go',
                  description: 'Send to friends, family or businesses on the go and track it all in just a couple of taps',
                  imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RpF6FSRdmiMICj6rvpB%2Fa2819e33-a7ba-44f4-86dd-9c6c1a0d008a.png',
                  tag: 'Social',
                ),
                _buildFeatureCard(
                  title: 'Transfer from crypto to fiat or fiat to crypto',
                  description: 'Send funds from multiple currencies however the receiver wants to receive it',
                  imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RpF6FSRdmiMICj6rvpB%2Fcc1b7851-28bb-4887-8933-e2339715d72a.png',
                  tag: 'Modern',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // RSVP Button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 45),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _showSuccess = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(45),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'RSVP Now',
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Feature Card Widget
  Widget _buildFeatureCard({
    required String title,
    required String description,
    required String imageUrl,
    required String tag,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF737A86),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.open_in_new,
                          size: 12, color: Colors.black),
                      const SizedBox(width: 5),
                      Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black, // Changed from red to black
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 60,
            height: 60,
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
