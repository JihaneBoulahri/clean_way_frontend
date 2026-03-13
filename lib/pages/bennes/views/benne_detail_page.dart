import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/benne_model.dart';
import '../../../widgets/app_layout.dart';
import '../../../widgets/modern_widgets.dart';
import '../controllers/benne_controller.dart';
import '../widgets/benne_form_dialog.dart';

class BenneDetailPage extends StatefulWidget {
  const BenneDetailPage({super.key});

  @override
  State<BenneDetailPage> createState() => _BenneDetailPageState();
}

class _BenneDetailPageState extends State<BenneDetailPage> {
  @override
  Widget build(BuildContext context) {
    final benneArg = Get.arguments as Benne;
    final controller = Get.find<BennesController>();
    final isChauffeur = _isChauffeur();

    return AppLayout(
      pageName: 'Details de la benne',
      child: FutureBuilder<Benne?>(
        future: controller.getBenneDetails(benneArg.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final benne = snapshot.data ?? benneArg;
          final scheme = Theme.of(context).colorScheme;
          final fillLevel =
              (benne.capteur?.niveauRemplissage ?? 0).clamp(0, 100).toDouble();

          return SingleChildScrollView(
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
                        side: BorderSide(color: scheme.outline.withValues(alpha: 0.2)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Benne #${benne.id}',
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
                              await Get.dialog(BenneFormDialog(benne: benne));
                              // Force le rebuild pour rappeler getBenneDetails
                              setState(() {});
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
                            onPressed: () => _showDeleteDialog(context, benne, controller),
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

                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.confirmation_number,
                        label: 'ID',
                        value: '${benne.id}',
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.category,
                        label: 'Type',
                        value: benne.typeBenne,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.inventory_2,
                        label: 'Capacite',
                        value: '${benne.capacite} m3',
                        scheme: scheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sensors, color: scheme.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Coordonnées geographiques',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _DetailRow(
                        icon: Icons.public,
                        label: 'Latitude',
                        value: benne.latitude,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.public,
                        label: 'Longitude',
                        value: benne.longitude,
                        scheme: scheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sensors, color: scheme.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Capteur et remplissage',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _DetailRow(
                        icon: Icons.memory,
                        label: 'Type capteur',
                        value: benne.capteur?.typeCapteur ?? 'Non disponible',
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.info_outline,
                        label: 'Status capteur',
                        value: benne.capteur?.status ?? 'Non disponible',
                        scheme: scheme,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: fillLevel / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(_statusColor(fillLevel)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Niveau de remplissage: ${fillLevel.toInt()}% (${_statusText(fillLevel)})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _statusColor(fillLevel),
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

  void _showDeleteDialog(BuildContext context, Benne benne, BennesController controller) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous supprimer la benne #${benne.id} ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteBenne(benne.id);
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

  Color _statusColor(double fillLevel) {
    if (fillLevel >= 70) return AppTheme.errorColor;
    if (fillLevel >= 50) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  String _statusText(double fillLevel) {
    if (fillLevel >= 90) return 'Critical';
    if (fillLevel >= 70) return 'Warning';
    return 'Normal';
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
