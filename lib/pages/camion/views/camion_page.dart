import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
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
        label: const Text('Ajouter un camion'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: AppTheme.textLight,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SearchBarField(
              hint: 'Rechercher par immatriculation, type, statut...',
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentColor,
                  ),
                ),
              );
            }

            if (controller.error.value != null) {
              return Expanded(
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Erreur',
                  subtitle: controller.error.value ?? 'Échec du chargement',
                  action: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchCamions(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton.icon(
                        onPressed: () => Get.offAllNamed(AppRoutes.login),
                        icon: const Icon(Icons.logout),
                        label: const Text('Retour'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final list = controller.filteredCamions;
            if (list.isEmpty) {
              return Expanded(
                child: EmptyState(
                  icon: Icons.local_shipping,
                  title: 'Aucun camion',
                  subtitle: controller.camions.isEmpty 
                      ? 'Commencez par ajouter votre premier camion'
                      : 'Aucun résultat trouvé',
                  action: controller.camions.isEmpty
                      ? ElevatedButton.icon(
                          onPressed: () => Get.dialog(const CamionFormDialog()),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                        )
                      : null,
                ),
              );
            }

            return Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  if (i >= list.length) return const SizedBox.shrink();
                  final camion = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: CamionCard(
                      camion: camion,
                      onDelete: () => controller.deleteCamion(camion.id),
                      onEdit: () => Get.dialog(CamionFormDialog(camion: camion)),
                    ),
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