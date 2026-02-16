import 'package:get/get.dart';

import '../../services/auth_service.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }
    if (password != confirmPassword) {
      Get.snackbar('Erreur', 'Les mots de passe ne correspondent pas');
      return;
    }

    try {
      isLoading.value = true;
      final res = await AuthService.register({
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      });

      if (res == null) {
        Get.snackbar('Erreur', 'Aucune réponse du serveur');
      } else if (res is Map && (res['error'] != null || res['message'] != null && res['message'].toString().toLowerCase().contains('error'))) {
        final msg = res['error'] ?? res['message'];
        Get.snackbar('Erreur', msg.toString());
      } else {
        Get.snackbar('Succès', 'Inscription réussie');
      }
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}