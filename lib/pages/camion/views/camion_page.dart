import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/core/constants/filter_constants.dart';
import 'package:clean_way_frontend/widgets/filter_bottom_sheet.dart';
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
    final isChauffeur = _isChauffeur();
    return AppLayout(
      pageName: "Camions",
      floatingActionButton: isChauffeur
          ? null
          : FloatingActionButton(
              onPressed: () => Get.dialog(const CamionFormDialog()),
   
              child: const Icon(Icons.add),
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.textLight,
            ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Obx(
              () => SearchBarField(
                hint: 'Rechercher par immatriculation, type, statut, ville...',
                onChanged: (v) => controller.searchQuery.value = v,
                onFilterTap: () => _openFilters(context),
                filterActive: controller.hasActiveFilters,
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.accentColor),
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
                      ElevatedButton(
                        onPressed: () => controller.fetchCamions(),
                        child: const Icon(Icons.refresh),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.login),
                        child: const Icon(Icons.logout),
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
                  action: (!isChauffeur && controller.camions.isEmpty)
                      ? ElevatedButton(
                          onPressed: () => Get.dialog(const CamionFormDialog()),
                          child: const Icon(Icons.add),
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
                    child: CamionCard(camion: camion),
                  );
                },
              ),
            );
          }),
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

  void _openFilters(BuildContext context) {
    FilterBottomSheet.show(
      context: context,
      title: 'Filtrer les camions',
      sections: [
        FilterSection(
          id: 'type',
          title: 'Type de camion',
          options: [FilterDefaults.all, ...controller.typeOptions],
          selected: controller.filterType.value,
          defaultValue: FilterDefaults.all,
        ),
        FilterSection(
          id: 'statut',
          title: 'Statut',
          options: [FilterDefaults.all, ...controller.statusOptions],
          selected: controller.filterStatus.value,
          defaultValue: FilterDefaults.all,
        ),
      ],
      onApply: (values) {
        controller.applyFilters(
          type: values['type'] ?? FilterDefaults.all,
          status: values['statut'] ?? FilterDefaults.all,
        );
      },
    );
  }
}
