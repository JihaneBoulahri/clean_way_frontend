import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/modern_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/zone_model.dart';
import '../controllers/zone_controller.dart';
import '../widgets/zone_form_dialog.dart';
import '../../../widgets/app_layout.dart';

class ZoneDetailPage extends StatelessWidget {
  const ZoneDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final zone = Get.arguments as Zone;
    final controller = Get.find<ZoneController>();
    final scheme = Theme.of(context).colorScheme;

    return AppLayout(
      pageName: 'Détails de la zone',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back, color: scheme.primary),
                  tooltip: 'Retour',
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.surface,
                    side: BorderSide(color: scheme.outline.withOpacity(0.2)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    zone.nomZone,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.dialog(ZoneFormDialog(zone: zone)),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Modifier',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: () => _showDeleteDialog(context, zone, controller),
                      icon: const Icon(Icons.delete),
                      tooltip: 'Supprimer',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Informations principales
            Text(
              'Informations Zone',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.confirmation_number,
                    label: 'ID Zone',
                    value: '${zone.id}',
                    scheme: scheme,
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Nom Zone',
                    value: zone.nomZone,
                    scheme: scheme,
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.category,
                    label: 'Type Zone',
                    value: zone.typeZone,
                    scheme: scheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Coordonnées géographiques
            Text(
              'Coordonnées Géographiques',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.public,
                    label: 'Latitude',
                    value: zone.latitude,
                    scheme: scheme,
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.public,
                    label: 'Longitude',
                    value: zone.longitude,
                    scheme: scheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Zone zone, ZoneController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la zone "${zone.nomZone}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteZone(zone.id);
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
