import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_layout.dart';
import '../controllers/zone_controller.dart';
import '../widgets/zone_card.dart';
import '../widgets/zone_form_dialog.dart';

class ZonePage extends GetView<ZoneController> {
  const ZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: 'Zones de depot',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(const ZoneFormDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une zone'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: AppTheme.textLight,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SearchBarField(
              hint: 'Rechercher par nom ou type de zone...',
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
                        onPressed: () => controller.fetchZones(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reessayer'),
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

              if (controller.zones.isEmpty) {
                return EmptyState(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Aucune zone',
                  subtitle: 'Commencez par ajouter votre premiere zone',
                  action: ElevatedButton.icon(
                    onPressed: () => Get.dialog(const ZoneFormDialog()),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
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

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1450),
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: isMobile ? 700 : 340,
                          childAspectRatio: isMobile ? 2.1 : 1.2,
                          mainAxisSpacing: AppSpacing.lg,
                          crossAxisSpacing: AppSpacing.lg,
                        ),
                        itemCount: list.length,
                        itemBuilder: (_, i) => ZoneCard(zone: list[i]),
                      ),
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
