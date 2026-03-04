import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

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
      _showError(nomError);
      return;
    }

    final prenomError = validatePrenom(prenom);
    if (prenomError != null) {
      errorMessage.value = prenomError;
      _showError(prenomError);
      return;
    }

    final emailError = validateEmail(email);
    if (emailError != null) {
      errorMessage.value = emailError;
      _showError(emailError);
      return;
    }

    final passError = validatePassword(password);
    if (passError != null) {
      errorMessage.value = passError;
      _showError(passError);
      return;
    }

    if (password != confirmPassword) {
      errorMessage.value = "Passwords do not match";
      _showError("Passwords do not match");
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

        // Check if data has nested structure (token + data)
        if (data is Map) {
          if (data.containsKey('token') && data.containsKey('data')) {
            token = data['token'];
            userData = Map<String, dynamic>.from(data['data'] ?? {});
          } else {
            // Direct user data
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

        _showSuccess("Registration successful");
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        final message = result['message'] ?? "Registration failed";
        errorMessage.value = message;
        _showError(message);
      }
    } catch (e) {
      print("Register error: $e");
      errorMessage.value = "Something went wrong";
      _showError("Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      icon: const Icon(Icons.error, color: Colors.white),
      backgroundColor: const Color.fromARGB(255, 214, 52, 40),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      "Success",
      message,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      backgroundColor: const Color.fromARGB(255, 82, 171, 85),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
