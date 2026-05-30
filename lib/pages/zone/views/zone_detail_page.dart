import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../widgets/modern_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../models/zone_model.dart';
import '../controllers/zone_controller.dart';
import '../widgets/zone_form_dialog.dart';
import '../../../widgets/app_layout.dart';
import '../../../widgets/location_map_card.dart';

class ZoneDetailPage extends StatefulWidget {
  const ZoneDetailPage({super.key});

  @override
  State<ZoneDetailPage> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  late Zone zone;

  @override
  void initState() {
    super.initState();
    zone = Get.arguments as Zone;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ZoneController>();
    final scheme = Theme.of(context).colorScheme;
    final isChauffeur = _isChauffeur();

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
                    side: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.2),
                    ),
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
                if (!isChauffeur)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final result = await Get.dialog(
                            ZoneFormDialog(zone: zone),
                          );
                          if (result != null && result is Zone) {
                            setState(() => zone = result);
                          }
                        },
                        icon: const Icon(Icons.edit),
                        tooltip: 'Modifier',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        onPressed: () =>
                            _showDeleteDialog(context, zone, controller),
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
                      const Divider(),
                      _DetailRow(
                        icon: Icons.location_city,
                        label: 'Ville',
                        value: zone.villeNom ?? (zone.idVille != null ? '#${zone.idVille}' : 'Non renseignee'),
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
            const SizedBox(height: AppSpacing.xl),
            LocationMapCard(
              title: 'Carte de la zone',
              latitude: zone.latitude,
              longitude: zone.longitude,
              markerTitle: zone.nomZone,
              markerSubtitle: '${zone.latitude}, ${zone.longitude}',
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Zone zone,
    ZoneController controller,
  ) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la zone "${zone.nomZone}" ?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteZone(zone.id);
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

  bool _isChauffeur() {
    final storedUser = GetStorage().read('user');
    if (storedUser is Map) {
      return storedUser['role']?.toString().toLowerCase() == 'chauffeur';
    }
    return false;
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
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
