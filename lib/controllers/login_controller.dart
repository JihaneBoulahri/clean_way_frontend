import 'package:get/get.dart';
import '../services/auth_service.dart';

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
    // 1️⃣ Validate fields
    final emailError = validateEmail(email.value);
    final passError = validatePassword(password.value);

    if (emailError != null) {
      Get.snackbar("Error", emailError);
      return;
    }

    if (passError != null) {
      Get.snackbar("Error", passError);
      return;
    }

    // 2️⃣ Call API
    try {
      isLoading.value = true;

      final result = await AuthService.login(email.value, password.value);

      if (result['success']) {
        Get.snackbar("Success", "Login successful");

        // Optional: store token
        // final token = result['data']['token'];
        // await SharedPreferences.getInstance().then((prefs) {
        //   prefs.setString("token", token);
        // });

        // Navigate to home page
        // Get.toNamed("/home");
      } else {
        Get.snackbar("Error", result['message']);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
