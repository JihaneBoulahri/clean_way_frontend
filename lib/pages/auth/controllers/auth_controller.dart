import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/snackbar_helper.dart'; 

class AuthController extends GetxController {
  // Fields
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var nom = ''.obs;
  var prenom = ''.obs;

  // UI States
  var isLoading = false.obs;
  var errorMessage = ''.obs;

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

  String? validateNom(String value) {
    if (value.isEmpty) return "Nom is required";
    return null;
  }

  String? validatePrenom(String value) {
    if (value.isEmpty) return "Prénom is required";
    return null;
  }

  // Register function
  Future<void> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Validation
    final nomError = validateNom(nom);
    if (nomError != null) {
      errorMessage.value = nomError;
      showNadiSnackbar(
        title: "Erreur",
        message: nomError,
        type: NadiSnackbarType.error,
      );
      return;
    }

    final prenomError = validatePrenom(prenom);
    if (prenomError != null) {
      errorMessage.value = prenomError;
      showNadiSnackbar(
        title: "Erreur",
        message: prenomError,
        type: NadiSnackbarType.error,
      );
      return;
    }

    final emailError = validateEmail(email);
    if (emailError != null) {
      errorMessage.value = emailError;
      showNadiSnackbar(
        title: "Erreur",
        message: emailError,
        type: NadiSnackbarType.error,
      );
      return;
    }

    final passError = validatePassword(password);
    if (passError != null) {
      errorMessage.value = passError;
      showNadiSnackbar(
        title: "Erreur",
        message: passError,
        type: NadiSnackbarType.error,
      );
      return;
    }

    if (password != confirmPassword) {
      errorMessage.value = "Passwords do not match";
      showNadiSnackbar(
        title: "Erreur",
        message: "Les mots de passe ne correspondent pas",
        type: NadiSnackbarType.error,
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Call register service
      final result = await AuthService.register(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        final box = GetStorage();
        final data = result['data'];

        // Handle different response formats
        String? token;
        Map<String, dynamic> userData = {};

        if (data is Map) {
          if (data.containsKey('token') && data.containsKey('data')) {
            token = data['token'];
            userData = Map<String, dynamic>.from(data['data'] ?? {});
          } else {
            userData = Map<String, dynamic>.from(data);
            token = data['token'];
          }
        }

        // Save to storage
        if (token != null) {
          await box.write('token', token);
        }
        if (userData.isNotEmpty) {
          await box.write('user', userData);
        }

        showNadiSnackbar(
          title: "Succès",
          message: "Inscription réussie",
          type: NadiSnackbarType.success,
        );
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        final message = result['message'] ?? "Registration failed";
        errorMessage.value = message;
        showNadiSnackbar(
          title: "Erreur",
          message: message,
          type: NadiSnackbarType.error,
        );
      }
    } catch (e) {
      print("Register error: $e");
      errorMessage.value = "Something went wrong";
      showNadiSnackbar(
        title: "Erreur",
        message: "Quelque chose s'est mal passé",
        type: NadiSnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}