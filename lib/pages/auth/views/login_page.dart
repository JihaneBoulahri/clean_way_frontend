import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/login_controller.dart';
import '../../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController controller;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LoginController>();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _isLoggedIn() {
    final box = GetStorage();
    final token = box.read('token')?.toString().trim() ?? '';
    final user = box.read('user');
    return token.isNotEmpty || user != null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email obligatoire';
    if (!GetUtils.isEmail(text)) return 'Email invalide';
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Mot de passe obligatoire';
    if (text.length < 6) return '6 caracteres minimum';
    return null;
  }

  InputDecoration _decoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FBFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6E4EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6E4EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color.fromARGB(255, 47, 211, 137)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    );
  }

  void _validateIfNeeded() {
    if (_submitted) {
      _formKey.currentState?.validate();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    controller.email.value = emailController.text.trim();
    controller.password.value = passwordController.text;
    await controller.login();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute != AppRoutes.dashboard) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      });
      return const SizedBox.shrink();
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    const primaryGreen = Color.fromARGB(255, 47, 211, 137);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Welcome Back!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width < 400 ? 22 : 26,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        "Please login to your account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width < 400 ? 14 : 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => _validateIfNeeded(),
                        validator: _validateEmail,
                        decoration: _decoration(
                          "Email",
                          Icons.email_outlined,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      Obx(
                        () => TextFormField(
                          controller: passwordController,
                          obscureText: controller.isPasswordHidden.value,
                          onChanged: (_) => _validateIfNeeded(),
                          validator: _validatePassword,
                          decoration: _decoration(
                            "Password",
                            Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: controller.togglePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => controller.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _submit,
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: height * 0.02),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.signup);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.grey[700]),
                            children: const [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
