import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/camion_controller.dart';
import '../widgets/camion_card.dart';
import '../widgets/camion_form_dialog.dart';

class CamionPage extends GetView<CamionController> {
  const CamionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camions'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SearchBarField(
            hint: 'Rechercher par immatriculation, type, statut...',
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
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text('Erreur',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Échec du chargement des camions',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchCamions(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => Get.offAllNamed(AppRoutes.login),
                        icon: const Icon(Icons.login),
                        label: const Text('Retour connexion'),
                      ),
                    ],
                  ),
                );
              }
              if (controller.camions.isEmpty) {
                return const Center(child: Text('Aucun camion'));
              }
              final list = controller.filteredCamions;
              if (list.isEmpty) {
                return const Center(child: Text('Aucun résultat'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final camion = list[i];
                  return CamionCard(
                    camion: camion,
                    onDelete: () => controller.deleteCamion(camion.id),
                    onEdit: () => Get.dialog(CamionFormDialog(camion: camion)),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(const CamionFormDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }
}
