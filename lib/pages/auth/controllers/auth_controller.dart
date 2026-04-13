import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
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
    final nomValue = nom.trim();
    final prenomValue = prenom.trim();
    final emailValue = email.trim();
    final passwordValue = password.trim();
    final confirmPasswordValue = confirmPassword.trim();

    // Validation
    final nomError = validateNom(nomValue);
    if (nomError != null) {
      errorMessage.value = nomError;
      showNadiSnackbar(
        title: "Erreur",
        message: nomError,
        type: NadiSnackbarType.error,
      );
      return;
    }

    final prenomError = validatePrenom(prenomValue);
    if (prenomError != null) {
      errorMessage.value = prenomError;
      showNadiSnackbar(
        title: "Erreur",
        message: prenomError,
        type: NadiSnackbarType.error,
      );
      return;
    }

    final emailError = validateEmail(emailValue);
    if (emailError != null) {
      errorMessage.value = emailError;
      showNadiSnackbar(
        title: "Erreur",
        message: emailError,
        type: NadiSnackbarType.error,
      );
      return;
    }

    final passError = validatePassword(passwordValue);
    if (passError != null) {
      errorMessage.value = passError;
      showNadiSnackbar(
        title: "Erreur",
        message: passError,
        type: NadiSnackbarType.error,
      );
      return;
    }

    if (passwordValue != confirmPasswordValue) {
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
        nom: nomValue,
        prenom: prenomValue,
        email: emailValue,
        password: passwordValue,
        confirmPassword: confirmPasswordValue,
      );

      if (result['success'] == true) {
        final box = GetStorage();
        final data = result['data'];

        // Handle different response formats
        String? token;
        Map<String, dynamic> userData = {};

        if (data is Map) {
          if (data.containsKey('data')) {
            userData = Map<String, dynamic>.from(data['data'] ?? {});
          } else {
            userData = Map<String, dynamic>.from(data);
          }
          token = _extractToken(_asMap(data), userData);
        }

        // Save to storage
        final normalizedToken = token?.trim();
        if (normalizedToken != null && normalizedToken.isNotEmpty) {
          await box.write('token', normalizedToken);
        }
        if (userData.isNotEmpty) {
          await box.write('user', userData);
        }
        await NotificationService.instance.refreshToken();

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
      Get.log("Register error: $e");
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

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String? _extractToken(
    Map<String, dynamic> root,
    Map<String, dynamic> payload,
  ) {
    const keys = ['token', 'access_token', 'api_token', 'auth_token'];
    for (final key in keys) {
      final value = root[key] ?? payload[key];
      final token = value?.toString().trim();
      if (token != null && token.isNotEmpty) return token;
    }

    final nested = _asMap(payload['data']);
    for (final key in keys) {
      final value = nested[key];
      final token = value?.toString().trim();
      if (token != null && token.isNotEmpty) return token;
    }

    return null;
  }
}
