import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import '../../../routes/app_routes.dart';
import '../controllers/camion_controller.dart';
import '../widgets/camion_card.dart';
import '../widgets/camion_form_dialog.dart';
import '../../../widgets/app_layout.dart';

class CamionPage extends GetView<CamionController> {
  const CamionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: "Camions",
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(const CamionFormDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      child: Column(
        children: [
          SearchBarField(
            hint: 'Rechercher par immatriculation, type, statut...',
            onChanged: (v) => controller.searchQuery.value = v,
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Expanded(child: Center(child: CircularProgressIndicator()));
            }

            if (controller.error.value != null) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text('Erreur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Échec du chargement des camions', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
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
                ),
              );
            }

            final list = controller.filteredCamions;
            if (list.isEmpty) {
              return const Expanded(child: Center(child: Text('Aucun résultat')));
            }

            return Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  // Sécurité : vérifier que l'index est valide (évite les RangeError)
                  if (i >= list.length) return const SizedBox.shrink();
                  final camion = list[i];
                  return CamionCard(
                    camion: camion,
                    onDelete: () => controller.deleteCamion(camion.id),
                    onEdit: () => Get.dialog(CamionFormDialog(camion: camion)),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}