import 'package:get/get.dart';
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
    Get.snackbar("Error", emailError);
    return;
  }

  if (passError != null) {
    Get.snackbar("Error", passError);
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
      final user = result['data']['user'];

      await box.write('token', token);
      await box.write('user', user);

      print('Token stored: ${box.read('token')}'); // now should print token

      Get.snackbar("Success", "Login successful");
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.snackbar("Error", result['message'] ?? "Login failed");
    }
  } catch (e) {
    print("Login error: $e");
    Get.snackbar("Error", "Something went wrong");
  } finally {
    isLoading.value = false;
  }
}
}