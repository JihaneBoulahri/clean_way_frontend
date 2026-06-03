import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../capteur_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/capteur_service.dart';
import '../models/benne_model.dart';
import '../../../widgets/app_layout.dart';
import '../../../widgets/modern_widgets.dart';
import '../../../widgets/location_map_card.dart';
import '../../../widgets/snackbar_helper.dart';
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
                          color: scheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Benne ${benne.id}',
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
                            onPressed: () async {
                              await Get.dialog(BenneFormDialog(benne: benne));
                              // Force le rebuild pour rappeler getBenneDetails
                              setState(() {});
                            },
                            icon: const Icon(Icons.edit),
                           
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            onPressed: () =>
                                _showDeleteDialog(context, benne, controller),
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
                        icon: Icons.info_outline,
                        label: 'statut',
                        value: benne.status,
                        scheme: scheme,
                      ),
                      _DetailRow(
                        icon: Icons.inventory_2,
                        label: 'Capacite',
                        value: '${benne.capacite} m3',
                        scheme: scheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                LocationMapCard(
                  title: 'Carte de la benne',
                  latitude: benne.latitude,
                  longitude: benne.longitude,
                  markerTitle: 'Benne ${benne.id}',
                  markerSubtitle: '${benne.latitude}, ${benne.longitude}',
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
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
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
                _buildCapteursSection(
                  context: context,
                  scheme: scheme,
                  benne: benne,
                  isChauffeur: isChauffeur,
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
    Benne benne,
    BennesController controller,
  ) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous supprimer la benne ${benne.id} ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Icon(Icons.close),
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
            child: const Icon(Icons.delete),
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

  Widget _buildCapteursSection({
    required BuildContext context,
    required ColorScheme scheme,
    required Benne benne,
    required bool isChauffeur,
  }) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.sensors, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Capteurs liés à la benne',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          FutureBuilder<List<Capteur>>(
            future: _fetchCapteursForBenne(benne),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text(
                  'Erreur chargement capteurs: ${snapshot.error}',
                  style: TextStyle(color: scheme.error),
                );
              }

              final capteurs = snapshot.data ?? const [];
              if (capteurs.isEmpty) {
                return Text(
                  'Aucun capteur lié à cette benne',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                );
              }

              return Column(
                children: List.generate(capteurs.length, (index) {
                  final capteur = capteurs[index];
                  final fillLevel = capteur.niveauRemplissage
                      .clamp(0, 100)
                      .toDouble();
                  final installationDate = capteur.dateInstallation == null
                      ? 'Non disponible'
                      : _formatDate(capteur.dateInstallation!);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index > 0) const Divider(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Capteur ${capteur.id}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.primary,
                                  ),
                            ),
                          ),
                          if (!isChauffeur)
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _openAddCapteurDialog(
                                    context,
                                    benne.id,
                                    existingCapteur: capteur,
                                  ),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Modifier'),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                OutlinedButton(
                                  onPressed: () => _deleteCapteurWithConfirm(
                                    context,
                                    capteur,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                  ),
                                  child: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _DetailRow(
                        icon: Icons.memory,
                        label: 'Type capteur',
                        value: capteur.typeCapteur,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.info_outline,
                        label: 'Statut',
                        value: capteur.status,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Date installation',
                        value: installationDate,
                        scheme: scheme,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: fillLevel / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            _statusColor(fillLevel),
                          ),
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
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Capteur>> _fetchCapteursForBenne(Benne benne) async {
    if (benne.capteurs.isNotEmpty) {
      return benne.capteurs;
    }
    if (benne.capteur != null) {
      return [benne.capteur!];
    }

    final raw = await CapteurService.getCapteursByBenne(benne.id);
    final rows = _extractList(raw);
    return rows
        .whereType<Map>()
        .map((e) => Capteur.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) {
      return response;
    }
    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final data = map['data'];
      if (data is List) {
        return data;
      }
    }
    return const [];
  }

  Future<void> _openAddCapteurDialog(
    BuildContext context,
    int benneId, {
    Capteur? existingCapteur,
  }) async {
    const typeOptions = [
      'niveau',
      'temperature',
      'gaz',
      'humidite',
      'pression',
    ];
    const statusOptions = ['actif', 'inactif', 'panne', 'maintenance'];
    final formKey = GlobalKey<FormState>();
    final isEdit = existingCapteur != null;
    final niveauController = TextEditingController(
      text: (existingCapteur?.niveauRemplissage ?? 0).toString(),
    );
    DateTime selectedDate = existingCapteur?.dateInstallation ?? DateTime.now();
    String selectedType = typeOptions.contains(existingCapteur?.typeCapteur)
        ? existingCapteur!.typeCapteur
        : typeOptions.first;
    String selectedStatus = statusOptions.contains(existingCapteur?.status)
        ? existingCapteur!.status
        : statusOptions.first;

    try {
      final created = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              bool saving = false;

              Future<void> pickDate() async {
                final picked = await showDatePicker(
                  context: dialogContext,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setDialogState(() => selectedDate = picked);
                }
              }

              Future<void> handleSave() async {
                if (!formKey.currentState!.validate()) return;
                final niveau = double.parse(
                  niveauController.text.trim().replaceAll(',', '.'),
                );
                setDialogState(() => saving = true);
                
                try {
                  final payload = {
                    'type_capteur': selectedType,
                    'status': selectedStatus,
                    'date_installation': _formatDate(selectedDate),
                    'id_benne': benneId,
                    'niveau_remplissage': niveau,
                  };

                  if (isEdit) {
                    await CapteurService.update(
                      existingCapteur.id,
                      payload,
                    );
                  } else {
                    await CapteurService.create(payload);
                  }
                  
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    setDialogState(() => saving = false);
                    showNadiSnackbar(
                      title: 'Erreur',
                      message: e.toString(),
                      type: NadiSnackbarType.error,
                    );
                  }
                }
              }

              return Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEdit ? 'Modifier Capteur' : 'Ajouter Capteur',
                          style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Type capteur',
                                    style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: selectedType,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      isDense: true,
                                    ),
                                    items: typeOptions
                                        .map(
                                          (type) => DropdownMenuItem<String>(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setDialogState(() => selectedType = value);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Statut',
                                    style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: selectedStatus,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      isDense: true,
                                    ),
                                    items: statusOptions
                                        .map(
                                          (status) => DropdownMenuItem<String>(
                                            value: status,
                                            child: Text(status),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setDialogState(() => selectedStatus = value);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Niveau remplissage (%)',
                                    style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: niveauController,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      isDense: true,
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    validator: (v) {
                                      final raw = (v ?? '').trim().replaceAll(',', '.');
                                      if (raw.isEmpty) return 'Requis';
                                      final parsed = double.tryParse(raw);
                                      if (parsed == null) return 'Doit être un nombre';
                                      if (parsed < 0 || parsed > 100) {
                                        return 'Doit être entre 0 et 100';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Date installation',
                                    style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: pickDate,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 20, color: Theme.of(dialogContext).colorScheme.primary),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(_formatDate(selectedDate)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: saving
                                  ? null
                                  : () => Navigator.of(dialogContext).pop(false),
                              child: const Text('Annuler'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: saving ? null : handleSave,
                              child: saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(isEdit ? 'Modifier' : 'Ajouter'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      if (created == true) {
        Get.find<BennesController>().fetchBennes();
        showNadiSnackbar(
          title: 'Succès',
          message: isEdit
              ? 'Capteur modifié avec succès'
              : 'Capteur ajouté avec succès',
          type: NadiSnackbarType.success,
        );
        // Small delay to ensure dialog is fully closed before rebuilding
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 200));
          if (mounted) setState(() {});
        }
      }
    } finally {
      niveauController.dispose();
    }
  }

  String _formatDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${pad(date.month)}-${pad(date.day)}';
  }

  Future<void> _deleteCapteurWithConfirm(
    BuildContext context,
    Capteur capteur,
  ) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer le capteur'),
        content: Text('Voulez-vous supprimer le capteur ${capteur.id} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Icon(Icons.close),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await CapteurService.delete(capteur.id);
      if (mounted) setState(() {});
      showNadiSnackbar(
        title: 'Succès',
        message: 'Capteur supprimé avec succès',
        type: NadiSnackbarType.success,
      );
    } catch (e) {
      showNadiSnackbar(
        title: 'Erreur',
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    }
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
