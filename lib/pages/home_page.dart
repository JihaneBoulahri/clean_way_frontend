import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  bool _isLoggedIn() {
    final box = GetStorage();
    final token = box.read('token')?.toString().trim() ?? '';
    final user = box.read('user');
    return token.isNotEmpty || user != null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute != AppRoutes.dashboard) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      });
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    const accent = Color(0xFF00C2A8);
    const deepTeal = Color(0xFF0B5D59);
    final headlineColor = scheme.onPrimary;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B5D59),
                  Color(0xFF148D8A),
                  Color(0xFF25B8D5),
                ],
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -140,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                'images/moroccan_tile_bg_pc.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth.clamp(0, 640).toDouble();
                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: _HeroCard(
                          headlineColor: headlineColor,
                          accent: accent,
                          deepTeal: deepTeal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Color headlineColor;
  final Color accent;
  final Color deepTeal;

  const _HeroCard({
    required this.headlineColor,
    required this.accent,
    required this.deepTeal,
  });

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    double titleSize = 28;
    double subtitleSize = 14;
    double logoSize = 150;

    if (width > 900) {
      titleSize = 40;
      subtitleSize = 18;
      logoSize = 200;
    } else if (width > 600) {
      titleSize = 34;
      subtitleSize = 16;
      logoSize = 170;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: width * 0.04,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// LOGO
          Image.asset(
            'images/app_logo.png',
            width: logoSize,
          ),

          const SizedBox(height: 20),

          /// TITLE
          Text(
            'Clean Way',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: headlineColor,
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// SUBTITLE
          Text(
            'Optimisez la collecte, suivez les tournées et pilotez vos équipes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: headlineColor.withValues(alpha: 0.9),
              fontSize: subtitleSize,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 30),

          /// LOGIN BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: accent,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Accéder à l'app",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// SIGNUP BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Get.toNamed(AppRoutes.signup),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 1.5,
                ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Créer un compte",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}