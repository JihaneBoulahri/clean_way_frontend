import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import '../../../models/tournee_model.dart';
import '../controllers/tournee_controller.dart';
import '../widgets/tournee_form_dialog.dart';
import '../../../widgets/app_layout.dart';

class TourneeDetailPage extends StatelessWidget {
  const TourneeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tournee = Get.arguments as Tournee;
    final controller = Get.find<TourneeController>();
    final scheme = Theme.of(context).colorScheme;

    return AppLayout(
      pageName: 'Détails de la tournée',
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
                    'Tournée ${tournee.id}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.dialog(TourneeFormDialog(tournee: tournee)),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Modifier',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: () => _showDeleteDialog(context, tournee, controller),
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
              'Informations Tournée',
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
                    label: 'ID Tournée',
                    value: '${tournee.id}',
                    scheme: scheme,
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: tournee.dateTournee.toString().split(' ').first,
                    scheme: scheme,
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.schedule,
                    label: 'Heure début',
                    value: tournee.heureDebut,
                    scheme: scheme,
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.schedule_send,
                    label: 'Heure fin',
                    value: tournee.heureFin ?? 'Non définie',
                    scheme: scheme,
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.flag,
                    label: 'Statut',
                    value: tournee.status,
                    scheme: scheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Ressources assignées
            if (tournee.camion != null || tournee.zone != null) ...[
              Text(
                'Ressources Assignées',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Camion Details Section
              if (tournee.camion != null) ...[
                Text(
                  'Informations Camion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.confirmation_number,
                        label: 'ID Camion',
                        value: '${tournee.camion!.id}',
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.local_shipping,
                        label: 'Immatriculation',
                        value: tournee.camion!.immatriculation,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.directions_car,
                        label: 'Type',
                        value: tournee.camion!.typeCamion,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.storage,
                        label: 'Capacité',
                        value: '${tournee.camion!.capaciteCamion} m³',
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Mise en service',
                        value: tournee.camion!.dateMiseEnService != null
                            ? tournee.camion!.dateMiseEnService.toString().split(' ').first
                            : 'Non définie',
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.info,
                        label: 'Statut',
                        value: tournee.camion!.status,
                        scheme: scheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Zone Details Section
              if (tournee.zone != null) ...[
                Text(
                  'Informations Zone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.confirmation_number,
                        label: 'ID Zone',
                        value: '${tournee.zone!.id}',
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.location_on,
                        label: 'Nom Zone',
                        value: tournee.zone!.nomZone,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.category,
                        label: 'Type Zone',
                        value: tournee.zone!.typeZone,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.public,
                        label: 'Latitude',
                        value: tournee.zone!.latitude,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.public,
                        label: 'Longitude',
                        value: tournee.zone!.longitude,
                        scheme: scheme,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Tournee tournee, TourneeController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la tournée "${tournee.id}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteTournee(tournee.id);
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