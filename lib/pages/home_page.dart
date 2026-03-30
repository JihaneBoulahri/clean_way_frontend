import 'dart:ui';
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
    const accent = Color(0xFF26D07C);
    const deepTeal = Color(0xFF0A5D5A);
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
                  Color(0xFF0A5D5A),
                  Color(0xFF148A88),
                  Color(0xFF1FA8AA),
                  Color(0xFF2BBE96),
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
              opacity: 0.07,
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
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 860;

    final titleSize = isWide ? 44.0 : (width > 600 ? 36.0 : 30.0);
    final subtitleSize = isWide ? 18.0 : (width > 600 ? 16.0 : 14.0);
    final logoSize = isWide ? 200.0 : (width > 600 ? 170.0 : 140.0);

    final headlineStyle = TextStyle(
      color: headlineColor,
      fontSize: titleSize,
      fontWeight: FontWeight.w800,
      height: 1.05,
      letterSpacing: -0.4,
    );
    final subtitleStyle = TextStyle(
      color: headlineColor.withValues(alpha: 0.9),
      fontSize: subtitleSize,
      height: 1.5,
      fontWeight: FontWeight.w500,
    );

    final content = Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Clean Way',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: headlineStyle,
        ),
        const SizedBox(height: 12),
        Text(
          'Optimisez la collecte, suivez les tournées et pilotez vos équipes en temps réel.',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: subtitleStyle,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _badge('Suivi GPS', headlineColor),
            _badge('Optimisation', headlineColor),
            _badge('Alertes instantanées', headlineColor),
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: isWide ? 320 : double.infinity,
          height: 54,
          child: _primaryButton(
            label: "Accéder à l'app",
            onTap: () => Get.toNamed(AppRoutes.login),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: isWide ? 320 : double.infinity,
          height: 50,
          child: _secondaryButton(
            label: 'Créer un compte',
            onTap: () => Get.toNamed(AppRoutes.signup),
          ),
        ),
      ],
    );

    final logoBlock = _logoBlock(logoSize, scheme);

    final child = isWide
        ? Row(
            children: [
              Expanded(child: content),
              const SizedBox(width: 36),
              logoBlock,
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              logoBlock,
              const SizedBox(height: 24),
              content,
            ],
          );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.97, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, card) =>
          Transform.scale(scale: value, child: card),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 44 : 28,
              vertical: isWide ? 40 : 28,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _logoBlock(double size, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            deepTeal.withValues(alpha: 0.18),
            scheme.surface.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          'images/logo_home_page.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent,
                accent.withValues(alpha: 0.9),
                const Color(0xFF45E39A),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.5,
        ),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
