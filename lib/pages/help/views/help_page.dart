import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/help_controller.dart';

class HelpPage extends GetView<HelpController> {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    // use current theme so the page reacts to dark mode and accent color
    final scheme = Theme.of(context).colorScheme;
    // hero card uses primary color, cards use surface/background
    final primaryColor = scheme.primary;
    final heroColor = primaryColor.withOpacity(0.85);

    return Scaffold(
      backgroundColor: scheme.background,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                String imagePath;
                if (constraints.maxWidth < 600) {
                  imagePath = 'images/moroccan_tile_bg1.jpeg';
                } else {
                  imagePath = 'images/moroccan_tile_bg_pc.jpeg';
                }
                return Image.asset(imagePath, fit: BoxFit.cover);
              },
            ),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.42
                    : 0.12,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ================= Back Arrow =================
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: heroColor,
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
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 48,
                          color: scheme.onPrimary,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Find FAQs, contact support, or send your feedback here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: scheme.onPrimary.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // FAQs section
                  _buildSectionTitle('FAQs', primaryColor),
                  _faqCard(
                    context,
                    'How do I add a new tour?',
                    'Go to the Tours page, click Add, fill in required fields, then save.',
                    primaryColor,
                  ),
                  _faqCard(
                    context,
                    'What if I forget a required field?',
                    'Make sure required fields like Date, Start Time, and Status are filled.',
                    primaryColor,
                  ),
                  const SizedBox(height: 24),

                  // Contact Support
                  _buildSectionTitle('Contact Support', primaryColor),
                  _contactCard(
                    context,
                    Icons.email,
                    'Email Us',
                    'cleanwaycontact77@gmail.com',
                    primaryColor,
                  ),
                  _contactCard(
                    context,
                    Icons.phone,
                    'Call Support',
                    '+212 600 123 456',
                    primaryColor,
                  ),
                  const SizedBox(height: 24),

                  // Contact Us
                  _buildSectionTitle('Contact Us', primaryColor),
                  _feedbackCard(context, primaryColor),
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

  Widget _faqCard(
    BuildContext context,
    String question,
    String answer,
    Color primaryColor,
  ) {
    // use cardColor for background and scheme colors for text
    final scheme = Theme.of(context).colorScheme;
    final cardColor = scheme.surface;
    final titleColor = primaryColor;
    final shadow = primaryColor.withOpacity(0.15);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(fontWeight: FontWeight.bold, color: titleColor),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(answer, style: TextStyle(color: scheme.onSurface)),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(
    BuildContext context,
    IconData icon,
    String title,
    String info,
    Color primaryColor,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor = scheme.surface;
    final onCard = scheme.onSurface;
    final shadow = primaryColor.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                info,
                style: TextStyle(color: onCard.withOpacity(0.7), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feedbackCard(BuildContext context, Color primaryColor) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor = scheme.surface;
    final onCard = scheme.onSurface;
    final shadow = primaryColor.withOpacity(0.15);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: controller.messageController,
            maxLines: 4,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Write your message here...',
              hintStyle: TextStyle(color: onCard.withOpacity(0.6)),
            ),
            style: TextStyle(color: onCard),
          ),
          const SizedBox(height: 12),
          Obx(
            () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: controller.isSending.value
                  ? null
                  : controller.sendSupportMessage,
              child: controller.isSending.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Icon(Icons.send, color: scheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
