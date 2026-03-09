import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tournee_controller.dart';
import '../widgets/tournee_card.dart';
import '../widgets/tournee_form_dialog.dart';

class TourneePage extends GetView<TourneeController> {
  const TourneePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: "Tournées",
      floatingActionButton: FloatingActionButton.extended(
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
            child: SearchBarField(
              hint: 'Rechercher une tournée...',
              onChanged: (v) => controller.searchOrFetch(v),
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
                  action: ElevatedButton.icon(
                    onPressed: () => Get.dialog(const TourneeFormDialog()),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer'),
                  ),
                );
              }
              final list = controller.tournees;
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
}
