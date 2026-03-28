import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/search_bar_field.dart';
import '../controllers/chauffeur_controller.dart';
import '../widgets/chauffeur_data_list.dart';
import '../widgets/chauffeur_form_dialog.dart';

class ChauffeurPage extends GetView<ChauffeurController> {
  const ChauffeurPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isChauffeur = _isChauffeur();
    return AppLayout(
      pageName: "Chauffeurs",
      floatingActionButton: isChauffeur
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Get.dialog(ChauffeurFormDialog()),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un chauffeur'),
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.textLight,
            ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SearchBarField(
              hint: 'Rechercher par nom, email, téléphone, CNI...',
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentColor),
                );
              }

              if (controller.error.value != null) {
                return EmptyState(
                  icon: Icons.error_outline,
                  title: 'Erreur de chargement',
                  subtitle: controller.error.value ?? 'Une erreur est survenue',
                  action: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchChauffeurs(),
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
                );
              }

              if (controller.chauffeurs.isEmpty) {
                return EmptyState(
                  icon: Icons.person_outline,
                  title: 'Aucun chauffeur',
                  subtitle: 'Commencez par ajouter votre premier chauffeur',
                  action: isChauffeur
                      ? null
                      : ElevatedButton.icon(
                          onPressed: () => Get.dialog(ChauffeurFormDialog()),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                        ),
                );
              }

              final list = controller.filteredChauffeurs;
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off,
                  title: 'Aucun résultat',
                  subtitle: 'Modifiez vos critères de recherche',
                );
              }

              return Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  children: [ChauffeurDataList(chauffeurs: list)],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _isChauffeur() {
    final storedUser = GetStorage().read('user');
    if (storedUser is Map) {
      return storedUser['role']?.toString().toLowerCase() == 'chauffeur';
    }
    return false;
  }
}
