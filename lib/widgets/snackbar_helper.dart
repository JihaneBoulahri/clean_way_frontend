import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Types de snackbar disponibles
enum NadiSnackbarType { success, error, info, warning }

/// Affiche un snackbar GetX avec le style "nadi" (3 secondes, arrondi, ombre)
void showNadiSnackbar({
  required String title,
  required String message,
  NadiSnackbarType type = NadiSnackbarType.info,
}) {
  // Définition des couleurs et icônes selon le type
  Color backgroundColor;
  IconData iconData;
  switch (type) {
    case NadiSnackbarType.success:
      backgroundColor = const Color(0xFF2E7D32); // vert foncé
      iconData = Icons.check_circle_outline;
      break;
    case NadiSnackbarType.error:
      backgroundColor = const Color(0xFFC62828); // rouge foncé
      iconData = Icons.error_outline;
      break;
    case NadiSnackbarType.warning:
      backgroundColor = const Color(0xFFEF6C00); // orange foncé
      iconData = Icons.warning_amber_outlined;
      break;
    case NadiSnackbarType.info:
    default:
      backgroundColor = const Color(0xFF1565C0); // bleu foncé
      iconData = Icons.info_outline;
      break;
  }

  Get.snackbar(
    title,
    message,
    icon: Icon(iconData, color: Colors.white),
    backgroundColor: backgroundColor,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
    borderRadius: 12,
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
    // Optionnel : bouton de fermeture personnalisé (si vous voulez remplacer la croix par défaut)
    mainButton: TextButton(
      onPressed: () => Get.back(), // ferme le snackbar
      child: const Icon(Icons.close, color: Colors.white70),
    ),
  );
}