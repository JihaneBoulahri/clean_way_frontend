import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/benne_controller.dart';
import '../widgets/benne_card.dart';
import '../widgets/benne_form_dialog.dart';

class BennesPage extends GetView<BennesController> {
  const BennesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: "Bennes",
      floatingActionButton: FloatingActionButton.extended(
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
            child: SearchBarField(
              hint: 'Rechercher par type, capacité, coordonnées...',
              onChanged: (v) => controller.searchQuery.value = v,
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
                  action: ElevatedButton.icon(
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
}