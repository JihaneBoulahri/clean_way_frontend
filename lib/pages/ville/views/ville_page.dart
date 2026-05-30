import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_layout.dart';
import '../../../widgets/modern_widgets.dart';
import '../../../widgets/search_bar_field.dart';
import '../controllers/ville_controller.dart';
import '../models/ville_model.dart';
import '../widgets/ville_form_dialog.dart';

class VillePage extends GetView<VilleController> {
  const VillePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isChauffeur = _isChauffeur();

    return AppLayout(
      pageName: 'Villes',
      floatingActionButton: isChauffeur
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Get.dialog(const VilleFormDialog()),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une ville'),
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.textLight,
            ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Obx(
              () => SearchBarField(
                hint: 'Rechercher par nom ou ID...',
                onChanged: (value) => controller.searchQuery.value = value,
                filterActive: controller.searchQuery.value.trim().isNotEmpty,
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

              if (controller.error.value != null) {
                return EmptyState(
                  icon: Icons.error_outline,
                  title: 'Erreur',
                  subtitle: controller.error.value ?? 'Echec du chargement',
                  action: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchVilles(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reessayer'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton.icon(
                        onPressed: () => controller.fetchVilles(),
                        icon: const Icon(Icons.sync),
                        label: const Text('Actualiser'),
                      ),
                    ],
                  ),
                );
              }

              final list = controller.filteredVilles;
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.location_city_outlined,
                  title: 'Aucune ville',
                  subtitle: controller.villes.isEmpty
                      ? 'Commencez par ajouter votre premiere ville'
                      : 'Aucun resultat',
                  action: isChauffeur
                      ? null
                      : ElevatedButton.icon(
                          onPressed: () => Get.dialog(const VilleFormDialog()),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                        ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                itemCount: list.length,
                itemBuilder: (_, index) {
                  final ville = list[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: _VilleCard(
                      ville: ville,
                      isChauffeur: isChauffeur,
                      onEdit: () => Get.dialog(VilleFormDialog(ville: ville)),
                      onDelete: () => controller.deleteVille(ville.id),
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
}

class _VilleCard extends StatelessWidget {
  final Ville ville;
  final bool isChauffeur;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VilleCard({
    required this.ville,
    required this.isChauffeur,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.location_city_outlined,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ville.nomVille,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${ville.id}',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                if (ville.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Created: ${ville.createdAt}',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isChauffeur) ...[
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier',
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              tooltip: 'Supprimer',
              color: Colors.red,
            ),
          ],
        ],
      ),
    );
  }
}
