import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final AuthController controller;
  final _formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final cniController = TextEditingController();
  final permisController = TextEditingController();
  final camionIdController = TextEditingController();

  bool showPassword = false;
  bool showConfirm = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    cniController.dispose();
    permisController.dispose();
    camionIdController.dispose();
    super.dispose();
  }

  bool _isLoggedIn() {
    final box = GetStorage();
    final token = box.read('token')?.toString().trim() ?? '';
    final user = box.read('user');
    return token.isNotEmpty || user != null;
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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWide = screenWidth >= 900;

    const primaryGreen = Color.fromARGB(255, 47, 211, 137);
    final cardMaxWidth = isWide ? 980.0 : 420.0;
    final gap = isWide ? 12.0 : 16.0;
    final titleSize = isWide ? 24.0 : (screenWidth < 400 ? 22.0 : 26.0);
    final subtitleSize = isWide ? 14.0 : (screenWidth < 400 ? 14.0 : 16.0);
    final fieldIconSize = isWide ? 18.0 : 22.0;
    final fieldPadding = isWide
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 16);

    void revalidateIfNeeded() {
      if (_submitted) {
        _formKey.currentState?.validate();
      }
    }

    String? requiredField(String? value, String label) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) {
        return '$label obligatoire';
      }
      return null;
    }

    String? validateEmail(String? value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return 'Email obligatoire';
      if (!GetUtils.isEmail(text)) return 'Email invalide';
      return null;
    }

    String? validatePassword(String? value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return 'Mot de passe obligatoire';
      if (text.length < 6) return '6 caracteres minimum';
      return null;
    }

    String? validateConfirmPassword(String? value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return 'Confirmation obligatoire';
      if (text != passwordController.text.trim()) {
        return 'Les mots de passe ne correspondent pas';
      }
      return null;
    }

    String? validatePhone(String? value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return 'Numero de telephone obligatoire';
      if (!RegExp(r'^[0-9+\s-]{8,}$').hasMatch(text)) {
        return 'Numero de telephone invalide';
      }
      return null;
    }

    InputDecoration decoration(
      String label,
      IconData icon, {
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: fieldIconSize),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FBFC),
        isDense: isWide,
        contentPadding: fieldPadding,
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
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 47, 211, 137),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
      );
    }

    Widget buildField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      required String? Function(String?) validator,
      TextInputType keyboardType = TextInputType.text,
      Widget? suffixIcon,
      bool obscureText = false,
      VoidCallback? onSuffixTap,
    }) {
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: (_) => revalidateIfNeeded(),
        validator: validator,
        decoration: decoration(
          label,
          icon,
          suffixIcon: suffixIcon == null
              ? null
              : IconButton(
                  icon: suffixIcon,
                  onPressed: onSuffixTap,
                ),
        ),
      );
    }

    Future<void> submitRegister() async {
      setState(() => _submitted = true);
      FocusScope.of(context).unfocus();

      final isValid = _formKey.currentState?.validate() ?? false;
      if (!isValid) return;

      await controller.register(
        nom: nomController.text,
        prenom: prenomController.text,
        email: emailController.text,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        numTelephone: phoneController.text,
        cni: cniController.text,
        permis: permisController.text,
        camionId: camionIdController.text,
      );
    }

    Widget twoCol(Widget left, Widget right) {
      return Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      );
    }

    final nomField = buildField(
      controller: nomController,
      label: 'Nom',
      icon: Icons.badge_outlined,
      validator: (value) => requiredField(value, 'Nom'),
    );

    final prenomField = buildField(
      controller: prenomController,
      label: 'Prenom',
      icon: Icons.person_outline,
      validator: (value) => requiredField(value, 'Prenom'),
    );

    final emailField = buildField(
      controller: emailController,
      label: 'Email',
      icon: Icons.email_outlined,
      validator: validateEmail,
      keyboardType: TextInputType.emailAddress,
    );

    final passwordField = buildField(
      controller: passwordController,
      label: 'Password',
      icon: Icons.lock_outline,
      validator: validatePassword,
      obscureText: !showPassword,
      suffixIcon: Icon(
        showPassword ? Icons.visibility : Icons.visibility_off,
      ),
      onSuffixTap: () {
        setState(() {
          showPassword = !showPassword;
        });
        revalidateIfNeeded();
      },
    );

    final confirmPasswordField = buildField(
      controller: confirmPasswordController,
      label: 'Confirm Password',
      icon: Icons.lock_outline,
      validator: validateConfirmPassword,
      obscureText: !showConfirm,
      suffixIcon: Icon(
        showConfirm ? Icons.visibility : Icons.visibility_off,
      ),
      onSuffixTap: () {
        setState(() {
          showConfirm = !showConfirm;
        });
        revalidateIfNeeded();
      },
    );

    final phoneField = buildField(
      controller: phoneController,
      label: 'Numero de telephone',
      icon: Icons.phone_outlined,
      validator: validatePhone,
      keyboardType: TextInputType.phone,
    );

    final cniField = buildField(
      controller: cniController,
      label: 'CNI',
      icon: Icons.credit_card,
      validator: (value) => requiredField(value, 'CNI'),
    );

    final permisField = buildField(
      controller: permisController,
      label: 'Permis',
      icon: Icons.card_membership,
      validator: (value) => requiredField(value, 'Permis'),
    );

    final camionIdField = buildField(
      controller: camionIdController,
      label: 'ID camion',
      icon: Icons.local_shipping_outlined,
      validator: (value) => requiredField(value, 'ID camion'),
      keyboardType: TextInputType.number,
    );

    Widget buildFields({required bool twoColumn}) {
      if (twoColumn) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            twoCol(nomField, prenomField),
            SizedBox(height: gap),
            twoCol(emailField, phoneField),
            SizedBox(height: gap),
            twoCol(passwordField, confirmPasswordField),
            SizedBox(height: gap),
            twoCol(cniField, permisField),
            SizedBox(height: gap),
            camionIdField,
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          nomField,
          SizedBox(height: gap),
          prenomField,
          SizedBox(height: gap),
          emailField,
          SizedBox(height: gap),
          phoneField,
          SizedBox(height: gap),
          cniField,
          SizedBox(height: gap),
          permisField,
          SizedBox(height: gap),
          camionIdField,
          SizedBox(height: gap),
          passwordField,
          SizedBox(height: gap),
          confirmPasswordField,
        ],
      );
    }

    Widget buildForm({required bool twoColumn}) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: isWide ? 24 : 32,
          horizontal: isWide ? 28 : 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Create Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "Register to start using the app",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 22),
              buildFields(twoColumn: twoColumn),
              const SizedBox(height: 22),
              Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: isWide ? 46 : 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: submitRegister,
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
              ),
              SizedBox(height: gap),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.grey[700]),
                    children: const [
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildSidePanel() {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2FD389),
              Color(0xFF0EA5E9),
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -45,
              right: -35,
              child: _GlowOrb(
                size: 160,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -65,
              left: -55,
              child: _GlowOrb(
                size: 190,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Text(
                        "Clean Way",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Create your account and manage operations in minutes.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "A cleaner workspace for your fleet, routes and monitoring.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.90),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FeatureRow(
                      icon: Icons.route_outlined,
                      label: "Optimisation des tournees",
                    ),
                    SizedBox(height: 10),
                    _FeatureRow(
                      icon: Icons.sensors_outlined,
                      label: "Suivi des capteurs en temps reel",
                    ),
                    SizedBox(height: 10),
                    _FeatureRow(
                      icon: Icons.shield_outlined,
                      label: "Acces securise pour chaque equipe",
                    ),
                  ],
                ),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TagChip(text: "Dashboard"),
                    _TagChip(text: "Tournees"),
                    _TagChip(text: "Monitoring"),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardMaxWidth),
              child: Container(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: isWide
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 5, child: buildSidePanel()),
                              Expanded(
                                flex: 6,
                                child: buildForm(twoColumn: true),
                              ),
                            ],
                          ),
                        )
                      : buildForm(twoColumn: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;

  const _TagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
