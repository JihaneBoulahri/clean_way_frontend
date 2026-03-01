import 'package:clean_way_frontend/pages/chauffeur/controllers/chauffeur_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chauffeur_controller.dart';
import '../widgets/chauffeur_card.dart';
import '../../../routes/app_routes.dart';

class ChauffeurPage extends GetView<ChauffeurController> {
  const ChauffeurPage({super.key});

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
                    onPressed: () => controller.fetchChauffeurs(),
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

          if (controller.chauffeurs.isEmpty) {
            return const Text("No Data");
          }
          
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: controller.chauffeurs.map((chauffeur) {
                    return ChauffeurCard(chauffeur: chauffeur, onDelete: () {
                      controller.deleteChauffeur(chauffeur.id);
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