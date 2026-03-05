import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF064635); // Dark Moroccan green
    const whiteColor = Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
  child: LayoutBuilder(
    builder: (context, constraints) {
      // Ici tu regardes la largeur de l'écran
      String imagePath;
      if (constraints.maxWidth < 600) {
        // écran mobile
        imagePath = 'images/moroccan_tile_bg1.jpeg';
      } else {
        // écran plus large (PC)
        imagePath = 'images/moroccan_tile_bg_pc.jpeg';
      }

      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
      );
    },
  ),
),
          // Semi-transparent overlay to darken background
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Hero card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: darkGreen.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.help_outline, size: 48, color: Colors.white),
                        SizedBox(height: 12),
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Find FAQs, contact support, or send your feedback here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // FAQs section
                  _buildSectionTitle('FAQs', darkGreen),
                  _faqCard(
                    'How do I add a new tour?',
                    'Go to the Tours page, click Add, fill in required fields, then save.',
                    darkGreen,
                  ),
                  _faqCard(
                    'What if I forget a required field?',
                    'Make sure required fields like Date, Start Time, and Status are filled.',
                    darkGreen,
                  ),
                  const SizedBox(height: 24),

                  // Contact Support
                  _buildSectionTitle('Contact Support', darkGreen),
                  _contactCard(Icons.email, 'Email Us', 'support@example.com', darkGreen),
                  _contactCard(Icons.phone, 'Call Support', '+212 600 123 456', darkGreen),
                  const SizedBox(height: 24),

                  // Feedback
                  _buildSectionTitle('Send Feedback', darkGreen),
                  _feedbackCard(darkGreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _faqCard(String question, String answer, Color darkGreen) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(fontWeight: FontWeight.bold, color: darkGreen),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(IconData icon, String title, String info, Color darkGreen) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: darkGreen, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              Text(info, style: TextStyle(color: darkGreen.withOpacity(0.7), fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feedbackCard(Color darkGreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Write your feedback here...',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}