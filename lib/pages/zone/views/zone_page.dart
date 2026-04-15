import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/core/constants/filter_constants.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/widgets/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_layout.dart';
import '../controllers/zone_controller.dart';
import '../widgets/zone_card.dart';
import '../widgets/zone_form_dialog.dart';

class ZonePage extends GetView<ZoneController> {
  const ZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isChauffeur = _isChauffeur();
    return AppLayout(
      pageName: "Zones",
      floatingActionButton: isChauffeur
          ? null
          : FloatingActionButton(
              onPressed: () => Get.dialog(const ZoneFormDialog()),
       
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
                hint: 'Rechercher par nom, type...',
                onChanged: (v) => controller.searchQuery.value = v,
                onFilterTap: () => _openFilters(context),
                filterActive: controller.hasActiveFilters,
              ),
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
                  title: 'Erreur',
                  subtitle: controller.error.value ?? 'Echec du chargement',
                  action: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => controller.fetchZones(),
                        child: const Icon(Icons.refresh),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.login),
                        child: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                );
              }

              if (controller.zones.isEmpty) {
                return EmptyState(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Aucune zone',
                  subtitle:
                      'Commencez par ajouter votre premiere zone de depot',
                  action: ElevatedButton(
                    onPressed: () => Get.dialog(const ZoneFormDialog()),
                    child: const Icon(Icons.add),
                  ),
                );
              }

              final list = controller.filteredZones;
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'Aucun resultat',
                  subtitle: 'Essayez avec d\'autres criteres',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  if (i >= list.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: ZoneCard(zone: list[i]),
                  );
                },
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

  void _openFilters(BuildContext context) {
    FilterBottomSheet.show(
      context: context,
      title: 'Filtrer les zones',
      sections: [
        FilterSection(
          id: 'type',
          title: 'Type de zone',
          options: [FilterDefaults.all, ...controller.typeOptions],
          selected: controller.filterType.value,
          defaultValue: FilterDefaults.all,
        ),
      ],
      onApply: (values) {
        controller.applyFilters(type: values['type'] ?? FilterDefaults.all);
      },
    );
  }
}
