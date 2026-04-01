import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/core/services/capteur_service.dart';
import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/filter_constants.dart';
import '../../../widgets/filter_bottom_sheet.dart';
import '../../../widgets/snackbar_helper.dart';
import '../controllers/benne_controller.dart';
import '../models/benne_model.dart';
import '../widgets/benne_card.dart';
import '../widgets/benne_form_dialog.dart';

class BennesPage extends GetView<BennesController> {
  const BennesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isChauffeur = _isChauffeur();
    return AppLayout(
      pageName: "Bennes",
      floatingActionButton: isChauffeur
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => Get.dialog(const BenneFormDialog()),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une benne'),
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: AppTheme.textLight,
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  onPressed: () => _openAddCapteurDialog(
                    context,
                    onAdded: controller.fetchBennes,
                  ),
                  icon: const Icon(Icons.sensors),
                  label: const Text('Ajouter capteur'),
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Obx(
              () => SearchBarField(
                hint: 'Rechercher par type, capacite, coordonnees...',
                onChanged: (v) => controller.searchQuery.value = v,
                onFilterTap: () => _openFilters(context),
                filterActive: controller.hasActiveFilters,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentColor),
                );
              }
              if (controller.bennes.isEmpty) {
                return EmptyState(
                  icon: Icons.delete_outline,
                  title: 'Aucune benne',
                  subtitle: 'Commencez par ajouter votre première benne',
                  action: isChauffeur
                      ? null
                      : ElevatedButton.icon(
                          onPressed: () => Get.dialog(const BenneFormDialog()),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                        ),
                );
              }
              final list = controller.filteredBennes;
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off,
                  title: 'Aucun résultat',
                  subtitle: 'Modifiez vos critères de recherche',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  if (i >= list.length) return const SizedBox.shrink();
                  final benne = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: BenneCard(
                      benne: benne,
                      onDelete: () => controller.deleteBenne(benne.id),
                      onEdit: () => Get.dialog(BenneFormDialog(benne: benne)),
                      showActions: !isChauffeur,
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

  void _openFilters(BuildContext context) {
    FilterBottomSheet.show(
      context: context,
      title: 'Filtrer les bennes',
      sections: [
        FilterSection(
          id: 'type',
          title: 'Type de benne',
          options: [FilterDefaults.all, ...controller.typeOptions],
          selected: controller.filterType.value,
          defaultValue: FilterDefaults.all,
        ),
        FilterSection(
          id: 'capteur',
          title: 'Présence de capteur',
          options: [
            FilterDefaults.all,
            FilterDefaults.withCapteur,
            FilterDefaults.withoutCapteur,
          ],
          selected: controller.filterCapteur.value,
          defaultValue: FilterDefaults.all,
        ),
        FilterSection(
          id: 'status',
          title: 'Statut capteur',
          options: [FilterDefaults.all, ...controller.capteurStatusOptions],
          selected: controller.filterCapteurStatus.value,
          defaultValue: FilterDefaults.all,
        ),
      ],
      onApply: (values) {
        controller.applyFilters(
          type: values['type'] ?? FilterDefaults.all,
          capteur: values['capteur'] ?? FilterDefaults.all,
          status: values['status'] ?? FilterDefaults.all,
        );
      },
    );
  }

  Future<void> _openAddCapteurDialog(
    BuildContext context, {
    int? benneId,
    VoidCallback? onAdded,
  }) async {
    final bennes = List<Benne>.from(Get.find<BennesController>().bennes);
    if (benneId == null && bennes.isEmpty) {
      showNadiSnackbar(
        title: 'Info',
        message: 'Ajoutez d’abord une benne avant de créer un capteur',
        type: NadiSnackbarType.info,
      );
      return;
    }

    const typeOptions = [
      'niveau',
      'temperature',
      'gaz',
      'humidite',
      'pression',
    ];
    const statusOptions = ['actif', 'inactif', 'panne', 'maintenance'];
    final formKey = GlobalKey<FormState>();
    final niveauController = TextEditingController(text: '0');
    DateTime selectedDate = DateTime.now();
    int selectedBenneId = benneId ?? bennes.first.id;
    String selectedType = typeOptions.first;
    String selectedStatus = statusOptions.first;
    bool saving = false;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
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

            return AlertDialog(
              title: const Text('Ajouter Capteur'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (benneId == null) ...[
                        DropdownButtonFormField<int>(
                          initialValue: selectedBenneId,
                          decoration: const InputDecoration(labelText: 'Benne'),
                          items: bennes
                              .map(
                                (b) => DropdownMenuItem<int>(
                                  value: b.id,
                                  child: Text(
                                    'Benne #${b.id} - ${b.typeBenne}',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedBenneId = value);
                            }
                          },
                          validator: (value) => value == null ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type capteur',
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(labelText: 'Statut'),
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: niveauController,
                        decoration: const InputDecoration(
                          labelText: 'Niveau remplissage (%)',
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
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Date installation'),
                        subtitle: Text(_formatDate(selectedDate)),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: pickDate,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final niveau = double.parse(
                            niveauController.text.trim().replaceAll(',', '.'),
                          );
                          setDialogState(() => saving = true);
                          try {
                            await CapteurService.create({
                              'type_capteur': selectedType,
                              'status': selectedStatus,
                              'date_installation': _formatDate(selectedDate),
                              'id_benne': selectedBenneId,
                              'niveau_remplissage': niveau,
                            });
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop(true);
                            }
                          } catch (e) {
                            showNadiSnackbar(
                              title: 'Erreur',
                              message: e.toString(),
                              type: NadiSnackbarType.error,
                            );
                            if (dialogContext.mounted) {
                              setDialogState(() => saving = false);
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );

    niveauController.dispose();

    if (created == true) {
      showNadiSnackbar(
        title: 'Succès',
        message: 'Capteur ajouté avec succès',
        type: NadiSnackbarType.success,
      );
      onAdded?.call();
    }
  }

  String _formatDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${pad(date.month)}-${pad(date.day)}';
  }
}
