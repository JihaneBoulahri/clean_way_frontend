import 'package:clean_way_frontend/models/chauffeur_model.dart';
import 'package:clean_way_frontend/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';
import '../widgets/snackbar_helper.dart'; // <-- AJOUTÉ

class LoginController extends GetxController {
  // Fields
  var email = ''.obs;
  var password = ''.obs;

  // UI States
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  // Validation functions
  String? validateEmail(String value) {
    if (value.isEmpty) return "Email is required";
    if (!GetUtils.isEmail(value)) return "Invalid email";
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 6) return "Minimum 6 characters";
    return null;
  }

  // Toggle password visibility
  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Login function
  Future<void> login() async {
    final emailError = validateEmail(email.value);
    final passError = validatePassword(password.value);

    if (emailError != null) {
      // MODIFIÉ : utilisation du helper
      showNadiSnackbar(
        title: "Erreur",
        message: emailError,
        type: NadiSnackbarType.error,
      );
      return;
    }

    if (passError != null) {
      // MODIFIÉ
      showNadiSnackbar(
        title: "Erreur",
        message: passError,
        type: NadiSnackbarType.error,
      );
      return;
    }

    try {
      isLoading.value = true;
      final result = await AuthService.login(email.value, password.value);

      if (result['success'] == true) {
        final box = GetStorage();
        final root = _asMap(result['data']);
        final payload = _asMap(root['data']);
        final token = (root['token'] ?? payload['token'])?.toString();

        if (token != null && token.isNotEmpty) {
          await box.write('token', token);
        }

        // Prevent stale role data from previous sessions.
        await box.remove('user');
        await box.remove('chauffeur');

        final role = _extractRole(root, payload);

        if (role == 'chauffeur') {
          final chauffeurMap = _asMap(payload['chauffeur'] ?? payload);
          final chauffeur = Chauffeur.fromJson(chauffeurMap);
          await box.write('chauffeur', chauffeur.toJson());

          final userMap = _asMap(payload['user'] ?? chauffeurMap['user']);
          if (userMap.isNotEmpty) {
            userMap['role'] = (userMap['role'] ?? 'chauffeur').toString();
            await box.write('user', userMap);
          }
        } else {
          final userMap = _asMap(payload['user'] ?? payload);
          final user = User.fromJson(userMap);
          await box.write('user', user.toJson());
        }

        // MODIFIÉ
        showNadiSnackbar(
          title: "Succès",
          message: "Connexion réussie",
          type: NadiSnackbarType.success,
        );
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        // MODIFIÉ
        showNadiSnackbar(
          title: "Erreur",
          message: result['message'] ?? "Échec de la connexion",
          type: NadiSnackbarType.error,
        );
      }
    } catch (e) {
      debugPrint("Login error: $e");
      // MODIFIÉ
      showNadiSnackbar(
        title: "Erreur",
        message: "Quelque chose s'est mal passé",
        type: NadiSnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout function
  Future<void> logout() async {
    try {
      final box = GetStorage();

      final result = await AuthService.logout();
      await box.remove('token');
      await box.remove('user');
      await box.remove('chauffeur');

      if (result['success'] != true) {
        // MODIFIÉ
        showNadiSnackbar(
          title: "Erreur",
          message: result['message'] ?? "Échec de la déconnexion",
          type: NadiSnackbarType.error,
        );
      } else {
        // MODIFIÉ
        showNadiSnackbar(
          title: "Succès",
          message: "Déconnexion réussie",
          type: NadiSnackbarType.success,
        );
      }
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      // MODIFIÉ
      showNadiSnackbar(
        title: "Erreur",
        message: "Échec de la déconnexion",
        type: NadiSnackbarType.error,
      );
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _extractRole(Map<String, dynamic> root, Map<String, dynamic> payload) {
    final role = (root['type'] ??
            root['role'] ??
            payload['type'] ??
            payload['role'] ??
            _asMap(payload['user'])['role'])
        ?.toString()
        .toLowerCase();
    return role ?? '';
  }
}