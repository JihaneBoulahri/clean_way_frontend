import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';

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
    Get.snackbar(
      "Error",
      emailError,
      icon: Icon(Icons.error, color: Colors.white),
      backgroundColor: const Color.fromARGB(255, 214, 52, 40),
      colorText: Colors.white,
    );
    return;
  }

  if (passError != null) {
    Get.snackbar(
      icon: Icon(Icons.error, color: Colors.white),
      "Error", passError,
      backgroundColor: const Color.fromARGB(255, 214, 52, 40),
      colorText: Colors.white);
    return;
  }

  try {
    isLoading.value = true;

    final result = await AuthService.login(email.value, password.value);
    print("Login response: $result");

    if (result['success'] == true) {
      final box = GetStorage();

      // Direct access with !
      final token = result['data']['token'];
      final user = User.fromJson(result['data']['data']);

      await box.write('token', token);
      await box.write('user', user.toJson());

      Get.snackbar(
        icon: Icon(Icons.check_circle, color: Colors.white),
        "Success","Login successful",
        backgroundColor: const Color.fromARGB(255, 82, 171, 85),
        colorText: Colors.white,
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.snackbar(
        icon: Icon(Icons.error, color: Colors.white),
        "Error", result['message'] ?? "Login failed",
        backgroundColor: const Color.fromARGB(255, 214, 52, 40),
        colorText: Colors.white,
      );
    }
  } catch (e) {
    print("Login error: $e");
    Get.snackbar(
      icon: Icon(Icons.error, color: Colors.white),
        "Error","Something went wrong",
      backgroundColor: const Color.fromARGB(255, 214, 52, 40),
        colorText: Colors.white,);
  } finally {
    isLoading.value = false;
  }
  }

  // Logout function
  Future<void> logout() async {
    try {
      final box = GetStorage();
      
      // Clear stored data
      await box.remove('token');
      await box.remove('user');
      final result = await AuthService.logout();

      if (result['success'] != true) {
        Get.snackbar(
          icon: Icon(Icons.error, color: Colors.white),
          "Error", result['message'] ?? "Logout failed",
          backgroundColor: const Color.fromARGB(255, 214, 52, 40),
          colorText: Colors.white,
        );
        // Navigate to login
        Get.offAllNamed(AppRoutes.login);
      }
      
      else{
        Get.snackbar(
          icon: Icon(Icons.check_circle, color: Colors.white),
          "Success","Logged out successfully",
          backgroundColor: const Color.fromARGB(255, 82, 171, 85),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        icon: Icon(Icons.error, color: Colors.white),
        "Error","Logout failed",
        backgroundColor: const Color.fromARGB(255, 214, 52, 40),
        colorText: Colors.white,
      );
    }
  }
}