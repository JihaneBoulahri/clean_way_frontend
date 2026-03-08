import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
          : FloatingActionButton.extended(
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
              hint: 'Rechercher par nom, type, coordonnées...',
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
              if (controller.zones.isEmpty) {
                return EmptyState(
                  icon: Icons.location_on_outlined,
                  title: 'Aucune zone',
                  subtitle: 'Commencez par ajouter votre première zone',
                  action: isChauffeur
                      ? null
                      : ElevatedButton.icon(
                          onPressed: () => Get.dialog(const ZoneFormDialog()),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                        ),
                );
              }
              final list = controller.filteredZones;
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off,
                  title: 'Aucun résultat',
                  subtitle: 'Essayez avec d\'autres critères',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  if (i >= list.length) return const SizedBox.shrink();
                  final zone = list[i];
                  return ZoneCard(
                    zone: zone,
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
}
