import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final AuthController controller = Get.put(AuthController());

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: "Confirm Password"),
            ),
            const SizedBox(height: 20),

            Obx(() {
              return controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        controller.register(
                          name: nameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                          confirmPassword:
                              confirmPasswordController.text,
                        );
                      },
                      child: const Text("Register"),
                    );
            })
          ],
        ),
      ),
    );
  }
}
