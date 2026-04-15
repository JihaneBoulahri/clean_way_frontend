import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../camion/models/camion_model.dart';
import '../../zone/models/zone_model.dart';
import '../models/tournee_model.dart';
import '../controllers/tournee_controller.dart';
import '../../../widgets/snackbar_helper.dart';

class TourneeFormDialog extends StatefulWidget {
  final Tournee? tournee;

  const TourneeFormDialog({super.key, this.tournee});

  @override
  State<TourneeFormDialog> createState() => _TourneeFormDialogState();
}

class _TourneeFormDialogState extends State<TourneeFormDialog> {
  static const List<String> _statusOptions = [
    'planifiee',
    'en_cours',
    'terminee',
  ];

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late final TextEditingController _dateController;
  late final TextEditingController _idCamionController;
  late final TextEditingController _idZoneController;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: widget.tournee != null
          ? widget.tournee!.dateTournee.toIso8601String().split('T').first
          : '',
    );
    _selectedStatus = _normalizeStatus(widget.tournee?.status);
    _idCamionController = TextEditingController(
      text:
          (widget.tournee?.idCamion ?? widget.tournee?.camion?.id)
              ?.toString() ??
          '',
    );
    _idZoneController = TextEditingController(
      text:
          (widget.tournee?.idZone ?? widget.tournee?.zone?.id)?.toString() ??
          '',
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _idCamionController.dispose();
    _idZoneController.dispose();
    super.dispose();
  }

  String? _normalizeStatus(String? rawStatus) {
    final value = (rawStatus ?? '').trim().toLowerCase();
    if (value.isEmpty) return null;
    final compact = value
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');
    if (compact.contains('plan')) return 'planifiee';
    if (compact.contains('cours')) return 'en_cours';
    if (compact.contains('term') || compact.contains('fini')) return 'terminee';
    if (_statusOptions.contains(value)) return value;
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final date = DateTime.tryParse(_dateController.text.trim());
    if (date == null) {
      showNadiSnackbar(
        title: "Erreur",
        message: "Date invalide (AAAA-MM-JJ)",
        type: NadiSnackbarType.error,
      );
      return;
    }
    final idCamion = _idCamionController.text.trim().isEmpty
        ? null
        : int.tryParse(_idCamionController.text.trim());
    final idZone = _idZoneController.text.trim().isEmpty
        ? null
        : int.tryParse(_idZoneController.text.trim());

    if (_idCamionController.text.trim().isNotEmpty && idCamion == null) {
      showNadiSnackbar(
        title: "Erreur",
        message: "L'ID camion doit être un nombre entier",
        type: NadiSnackbarType.error,
      );
      return;
    }
    if (_idZoneController.text.trim().isNotEmpty && idZone == null) {
      showNadiSnackbar(
        title: "Erreur",
        message: "L'ID zone doit être un nombre entier",
        type: NadiSnackbarType.error,
      );
      return;
    }

    final controller = Get.find<TourneeController>();
    setState(() => _saving = true);
    try {
      if (widget.tournee == null) {
        await controller.addTournee(
          Tournee(
            id: 0,
            dateTournee: date,
            heureDebut: '',
            heureFin: null,
            status: _selectedStatus!,
            camion: idCamion != null
                ? Camion(
                    id: idCamion,
                    immatriculation: '',
                    typeCamion: '',
                    capaciteCamion: 0,
                    status: '',
                  )
                : null,
            zone: idZone != null
                ? Zone(
                    id: idZone,
                    nomZone: '',
                    typeZone: '',
                    latitude: '',
                    longitude: '',
                  )
                : null,
          ),
        );
      } else {
        await controller.updateTournee(
          Tournee(
            id: widget.tournee!.id,
            dateTournee: date,
            heureDebut: widget.tournee!.heureDebut,
            heureFin: widget.tournee!.heureFin,
            status: _selectedStatus!,
            camion: idCamion != null
                ? Camion(
                    id: idCamion,
                    immatriculation: '',
                    typeCamion: '',
                    capaciteCamion: 0,
                    status: '',
                  )
                : null,
            zone: idZone != null
                ? Zone(
                    id: idZone,
                    nomZone: '',
                    typeZone: '',
                    latitude: '',
                    longitude: '',
                  )
                : null,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      showNadiSnackbar(
        title: "Erreur",
        message: "Échec de l'enregistrement: ${e.toString()}",
        type: NadiSnackbarType.error,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.tournee != null;
    final isCreate = !isEdit;
    return AlertDialog(
      title: Text(isEdit ? 'Modifier la tournée' : 'Ajouter une tournée'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (AAAA-MM-JJ)',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!regex.hasMatch(v.trim())) return 'Format invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: _statusOptions
                    .map(
                      (status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedStatus = value),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idCamionController,
                decoration: InputDecoration(
                  labelText: isCreate ? 'ID camion' : 'ID camion (optionnel)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return isCreate ? 'Requis' : null;
                  }
                  if (int.tryParse(v.trim()) == null) {
                    return 'Doit être un entier';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idZoneController,
                decoration: InputDecoration(
                  labelText: isCreate ? 'ID zone' : 'ID zone (optionnel)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return isCreate ? 'Requis' : null;
                  }
                  if (int.tryParse(v.trim()) == null) {
                    return 'Doit être un entier';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Modifier' : 'Ajouter'),
        ),
      ],
    );
  }
}
