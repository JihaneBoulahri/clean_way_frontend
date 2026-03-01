import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/search_bar_field.dart';
import '../controllers/chauffeur_controller.dart';
import '../widgets/chauffeur_card.dart';
import '../widgets/chauffeur_form_dialog.dart';

class ChauffeurPage extends GetView<ChauffeurController> {
  const ChauffeurPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chauffeurs'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SearchBarField(
            hint: 'Rechercher par téléphone, CNI, permis...',
            onChanged: (v) => controller.searchQuery.value = v,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.error.value != null) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Failed to load chauffeurs',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
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
                return const Center(child: Text('No Data'));
              }

              final list = controller.filteredChauffeurs;
              if (list.isEmpty) {
                return const Center(child: Text('No results'));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final chauffeur = list[i];
                  return ChauffeurCard(
                    chauffeur: chauffeur,
                    onDelete: () => controller.deleteChauffeur(chauffeur.id),
                    onEdit: () =>
                        Get.dialog(ChauffeurFormDialog(chauffeur: chauffeur)),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(const ChauffeurFormDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }
}