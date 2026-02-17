import 'package:get/get.dart';

import '../../services/auth_service.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (nom.isEmpty || prenom.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }
    if (password != confirmPassword) {
      Get.snackbar('Erreur', 'Les mots de passe ne correspondent pas');
      return;
    }

    errorMessage.value = '';
    try {
      isLoading.value = true;
      final res = await AuthService.register({
        'nom': nom,
        'prenom': prenom,
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
        errorMessage.value = '';
        Get.snackbar('Succès', 'Inscription réussie');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Connection refused') ||
          msg.contains('SocketException') ||
          msg.contains('ClientException')) {
        errorMessage.value =
            'Serveur inaccessible. Vérifiez que le backend est démarré sur http://127.0.0.1:8000';
        Get.snackbar('Erreur', errorMessage.value);
      } else {
        errorMessage.value = msg;
        Get.snackbar('Erreur', msg);
      }
    } finally {
      isLoading.value = false;
    }
  }
}