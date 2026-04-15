import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../widgets/modern_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../models/chauffeur_model.dart';
import '../controllers/chauffeur_controller.dart';
import '../widgets/chauffeur_form_dialog.dart';
import '../../../widgets/app_layout.dart';

class ChauffeurDetailPage extends StatelessWidget {
  const ChauffeurDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chauffeurArg = Get.arguments as Chauffeur;
    final controller = Get.find<ChauffeurController>();
    final isChauffeur = _isChauffeur();

    return AppLayout(
      pageName: 'Détails du chauffeur',
      child: FutureBuilder<Chauffeur?>(
        future: controller.getChauffeurDetails(chauffeurArg.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chauffeur = snapshot.data ?? chauffeurArg;
          final scheme = Theme.of(context).colorScheme;
          final hasUserRelation = chauffeur.user != null;
          final hasCamionRelation = chauffeur.camion != null;
          final hasUserIdOnly = !hasUserRelation && chauffeur.userId != null;
          final hasCamionIdOnly =
              !hasCamionRelation && chauffeur.camionId != null;

          final userName = chauffeur.user != null
              ? chauffeur.user!.fullName
              : hasUserIdOnly
              ? 'Utilisateur #${chauffeur.userId}'
              : 'Chauffeur #${chauffeur.id}';

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
                        userName,
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
                            onPressed: () => Get.dialog(
                              ChauffeurFormDialog(chauffeur: chauffeur),
                            ),
                            icon: const Icon(Icons.edit),
                          
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            onPressed: () => _showDeleteDialog(
                              context,
                              chauffeur,
                              controller,
                            ),
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

                // User Information Section
                Text(
                  'Informations Utilisateur',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (hasUserRelation)
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(
                          icon: Icons.badge,
                          label: 'ID Utilisateur',
                          value: '${chauffeur.user!.id}',
                          scheme: scheme,
                        ),
                        const Divider(),
                        _DetailRow(
                          icon: Icons.person,
                          label: 'Nom',
                          value: chauffeur.user!.nom,
                          scheme: scheme,
                        ),
                        const Divider(),
                        _DetailRow(
                          icon: Icons.person_outline,
                          label: 'Prénom',
                          value: chauffeur.user!.prenom,
                          scheme: scheme,
                        ),
                        const Divider(),
                        _DetailRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: chauffeur.user!.email,
                          scheme: scheme,
                        ),
                        const Divider(),
                        _DetailRow(
                          icon: Icons.work,
                          label: 'Rôle',
                          value: chauffeur.user!.role,
                          scheme: scheme,
                        ),
                      ],
                    ),
                  )
                else if (hasUserIdOnly)
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(
                          icon: Icons.badge,
                          label: 'ID Utilisateur',
                          value: '${chauffeur.userId}',
                          scheme: scheme,
                        ),
                      ],
                    ),
                  )
                else
                  ModernCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_off,
                              size: 48,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Aucun utilisateur assigné',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),

                // Chauffeur Information Section
                Text(
                  'Informations Chauffeur',
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
                        icon: Icons.badge,
                        label: 'CNI',
                        value: chauffeur.cni,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.card_travel,
                        label: 'Permis',
                        value: chauffeur.permis,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.phone,
                        label: 'Téléphone',
                        value: chauffeur.numTelephone,
                        scheme: scheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Camion Information Section
                if (hasCamionRelation) ...[
                  Text(
                    'Camion Assigné',
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
                          icon: Icons.local_shipping,
                          label: 'Immatriculation',
                          value: chauffeur.camion!.immatriculation,
                          scheme: scheme,
                        ),
                        const Divider(),
                        _DetailRow(
                          icon: Icons.category,
                          label: 'Type',
                          value: chauffeur.camion!.typeCamion,
                          scheme: scheme,
                        ),
                        const Divider(),
                        _DetailRow(
                          icon: Icons.storage,
                          label: 'Capacité',
                          value: '${chauffeur.camion!.capaciteCamion} m³',
                          scheme: scheme,
                        ),
                        const Divider(),
                        _DetailRow(
                          icon: Icons.info,
                          label: 'Statut',
                          value: chauffeur.camion!.status,
                          scheme: scheme,
                        ),
                      ],
                    ),
                  ),
                ] else if (hasCamionIdOnly)
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(
                          icon: Icons.local_shipping,
                          label: 'ID Camion',
                          value: '${chauffeur.camionId}',
                          scheme: scheme,
                        ),
                      ],
                    ),
                  )
                else
                  ModernCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              size: 48,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Aucun camion assigné',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
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
    Chauffeur chauffeur,
    ChauffeurController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce chauffeur ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Icon(Icons.close),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteChauffeur(chauffeur.id);
              Get.back();
              Get.back();
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
    final displayValue = value.trim().isEmpty ? 'Non renseigne' : value;
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
              displayValue,
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
