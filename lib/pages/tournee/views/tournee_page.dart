import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/core/constants/filter_constants.dart';
import 'package:clean_way_frontend/widgets/filter_bottom_sheet.dart';
import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/tournee_controller.dart';
import '../widgets/tournee_card.dart';
import '../widgets/tournee_form_dialog.dart';

class TourneePage extends GetView<TourneeController> {
  const TourneePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isChauffeur = _isChauffeur();
    return AppLayout(
      pageName: "Tournées",
      floatingActionButton: isChauffeur
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Get.dialog(const TourneeFormDialog()),
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle tournée'),
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.textLight,
            ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Obx(
              () => SearchBarField(
                hint: 'Rechercher une tournee...',
                onChanged: (v) => controller.searchOrFetch(v),
                onFilterTap: () => _openFilters(context),
                filterActive: controller.hasActiveFilters,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentColor,
                  ),
                );
              }
              if (controller.tournees.isEmpty) {
                return EmptyState(
                  icon: Icons.directions_bus,
                  title: 'Aucune tournée',
                  subtitle: 'Commencez par créer votre première tournée',
                  action: isChauffeur
                      ? null
                      : ElevatedButton.icon(
                          onPressed: () => Get.dialog(const TourneeFormDialog()),
                          icon: const Icon(Icons.add),
                          label: const Text('Créer'),
                        ),
                );
              }
              final list = controller.filteredTournees;
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'Aucun resultat',
                  subtitle: 'Modifiez vos criteres de recherche',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  if (i < 0 || i >= list.length) return const SizedBox.shrink();
                  final tournee = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: TourneeCard(
                      tournee: tournee,
                    ),
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
      title: 'Filtrer les tournees',
      sections: [
        FilterSection(
          id: 'statut',
          title: 'Statut',
          options: [FilterDefaults.all, ...controller.statusOptions],
          selected: controller.filterStatus.value,
          defaultValue: FilterDefaults.all,
        ),
        FilterSection(
          id: 'periode',
          title: 'Periode',
          options: controller.periodOptions,
          selected: controller.filterPeriod.value,
          defaultValue: FilterDefaults.all,
        ),
      ],
      onApply: (values) {
        controller.applyFilters(
          status: values['statut'] ?? FilterDefaults.all,
          period: values['periode'] ?? FilterDefaults.all,
        );
      },
    );
  }

}
