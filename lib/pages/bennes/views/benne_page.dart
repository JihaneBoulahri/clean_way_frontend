import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/core/constants/filter_constants.dart';
import 'package:clean_way_frontend/widgets/filter_bottom_sheet.dart';
import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/benne_controller.dart';
import '../widgets/benne_card.dart';
import '../widgets/benne_form_dialog.dart';

class BennesPage extends GetView<BennesController> {
  const BennesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isChauffeur = _isChauffeur();
    return AppLayout(
      pageName: "Bennes",
      floatingActionButton: isChauffeur
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Get.dialog(const BenneFormDialog()),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une benne'),
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.textLight,
            ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Obx(
              () => SearchBarField(
                hint: 'Rechercher par type, capacite, coordonnees...',
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
                  child: CircularProgressIndicator(
                    color: AppTheme.accentColor,
                  ),
                );
              }
              if (controller.bennes.isEmpty) {
                return EmptyState(
                  icon: Icons.delete_outline,
                  title: 'Aucune benne',
                  subtitle: 'Commencez par ajouter votre première benne',
                  action: isChauffeur
                      ? null
                      : ElevatedButton.icon(
                          onPressed: () => Get.dialog(const BenneFormDialog()),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                        ),
                );
              }
              final list = controller.filteredBennes;
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off,
                  title: 'Aucun résultat',
                  subtitle: 'Modifiez vos critères de recherche',
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
                  final benne = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: BenneCard(
                      benne: benne,
                      onDelete: () => controller.deleteBenne(benne.id),
                      onEdit: () => Get.dialog(BenneFormDialog(benne: benne)),
                      showActions: !isChauffeur,
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
      title: 'Filtrer les bennes',
      sections: [
        FilterSection(
          id: 'type',
          title: 'Type de benne',
          options: [FilterDefaults.all, ...controller.typeOptions],
          selected: controller.filterType.value,
          defaultValue: FilterDefaults.all,
        ),
        FilterSection(
          id: 'capteur',
          title: 'Capteur',
          options: const [
            FilterDefaults.all,
            FilterDefaults.withCapteur,
            FilterDefaults.withoutCapteur,
          ],
          selected: controller.filterCapteur.value,
          defaultValue: FilterDefaults.all,
        ),
        FilterSection(
          id: 'statut',
          title: 'Statut capteur',
          options: [FilterDefaults.all, ...controller.capteurStatusOptions],
          selected: controller.filterCapteurStatus.value,
          defaultValue: FilterDefaults.all,
        ),
      ],
      onApply: (values) {
        controller.applyFilters(
          type: values['type'] ?? FilterDefaults.all,
          capteur: values['capteur'] ?? FilterDefaults.all,
          status: values['statut'] ?? FilterDefaults.all,
        );
      },
    );
  }
}
