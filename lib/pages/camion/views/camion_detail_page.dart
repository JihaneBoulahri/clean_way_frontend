import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import '../models/camion_model.dart';
import '../controllers/camion_controller.dart';
import '../widgets/camion_form_dialog.dart';
import '../../../widgets/app_layout.dart';

class CamionDetailPage extends StatelessWidget {
  const CamionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final camionArg = Get.arguments as Camion;
    final controller = Get.find<CamionController>();
    final isChauffeur = _isChauffeur();

    return AppLayout(
      pageName: 'Détails du camion',
      child: FutureBuilder<Camion?>(
        future: controller.getCamionDetails(camionArg.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final camion = snapshot.data ?? camionArg;
          final scheme = Theme.of(context).colorScheme;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back, color: scheme.primary),
                     
                      style: IconButton.styleFrom(
                        backgroundColor: scheme.surface,
                        side: BorderSide(
                          color: scheme.outline.withOpacity(0.2),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        camion.immatriculation,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                      ),
                    ),
                    if (!isChauffeur)
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Get.dialog(CamionFormDialog(camion: camion)),
                            icon: const Icon(Icons.edit),
                           
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            onPressed: () =>
                                _showDeleteDialog(context, camion, controller),
                            icon: const Icon(Icons.delete),
                        
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

            // Details card with icons
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.directions_car,
                    label: 'Immatriculation',
                    value: camion.immatriculation,
                    scheme: scheme,
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.category,
                    label: 'Type',
                    value: camion.typeCamion,
                    scheme: scheme,
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.storage,
                    label: 'Capacité',
                    value: '${camion.capaciteCamion} m³',
                    scheme: scheme,
                  ),
                  const Divider(),
                  if (camion.dateMiseEnService != null)
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date de mise en service',
                      value: _formatDate(camion.dateMiseEnService!),
                      scheme: scheme,
                    ),
                  if (camion.dateMiseEnService != null) const Divider(),
                  _DetailRow(
                    icon: Icons.info,
                    label: 'Statut',
                    value: camion.status,
                    scheme: scheme,
                  ),
                  const Divider(),
                  if (camion.zone != null) ...[
                    _DetailRow(
                      icon: Icons.map_outlined,
                      label: 'Zone',
                      value: camion.zone!.nomZone.isNotEmpty
                          ? camion.zone!.nomZone
                          : '#${camion.zone!.id}',
                      scheme: scheme,
                    ),
                    const Divider(),
                  ],
                  _DetailRow(
                    icon: Icons.location_city,
                    label: 'Ville',
                    value: camion.villeNom ?? (camion.zone?.idVille != null ? '#${camion.zone!.idVille}' : 'Non renseignee'),
                    scheme: scheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Map section
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Localisation',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: scheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: scheme.outline.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined, size: 64, color: scheme.onSurfaceVariant),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Carte non disponible',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Aucune donnée de localisation',
                            style: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.7), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Camion camion,
    CamionController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le camion "${camion.immatriculation}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Icon(Icons.close),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteCamion(camion.id);
              Get.back(); // Close dialog
              Get.back(); // Go back to list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
                color: scheme.onSurface.withOpacity(0.7),
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
