import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/camion_controller.dart';
import '../widgets/camion_card.dart';
import '../../../routes/app_routes.dart';

class CamionPage extends GetView<CamionController> {
  const CamionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          }

          if (controller.error.value != null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Failed to load camions', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchCamions(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                    icon: const Icon(Icons.login),
                    label: const Text('Back to Login'),
                  ),
                ],
              ),
            );
          }

          if (controller.camions.isEmpty) {
            return const Text("No Data");
          }
          
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: controller.camions.map((camion) {
                    return CamionCard(camion: camion, onDelete: () {
                      controller.deleteCamion(camion.id);
                    });
                  }).toList(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}