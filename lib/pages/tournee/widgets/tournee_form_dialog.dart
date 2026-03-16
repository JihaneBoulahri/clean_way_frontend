import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/camion_model.dart';
import '../../../models/zone_model.dart';
import '../../../models/tournee_model.dart';
import '../controllers/tournee_controller.dart';
import '../../../widgets/snackbar_helper.dart'; 

class TourneeFormDialog extends StatefulWidget {
  final Tournee? tournee;

  const TourneeFormDialog({super.key, this.tournee});

  @override
  State<TourneeFormDialog> createState() => _TourneeFormDialogState();
}

class _TourneeFormDialogState extends State<TourneeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late final TextEditingController _dateController;
  late final TextEditingController _heureDebutController;
  late final TextEditingController _heureFinController;
  late final TextEditingController _statusController;
  late final TextEditingController _idCamionController;
  late final TextEditingController _idZoneController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
        text: widget.tournee != null
            ? widget.tournee!.dateTournee.toIso8601String().split('T').first
            : '');
    _heureDebutController =
        TextEditingController(text: widget.tournee?.heureDebut ?? '');
    _heureFinController =
        TextEditingController(text: widget.tournee?.heureFin ?? '');
    _statusController = TextEditingController(text: widget.tournee?.status ?? '');
    _idCamionController = TextEditingController(
        text: widget.tournee?.camion?.id.toString() ?? '');
    _idZoneController = TextEditingController(
        text: widget.tournee?.zone?.id.toString() ?? '');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _heureDebutController.dispose();
    _heureFinController.dispose();
    _statusController.dispose();
    _idCamionController.dispose();
    _idZoneController.dispose();
    super.dispose();
  }

  static final _timeRegex = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d(:[0-5]\d)?$');

  String _formatTime(String input) {
    final parts = input.trim().split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return input.trim();
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
    final debut = _formatTime(_heureDebutController.text);
    final fin = _formatTime(_heureFinController.text);
    setState(() => _saving = true);
    try {
      if (widget.tournee == null) {
        await controller.addTournee(Tournee(
          id: 0,
          dateTournee: date,
          heureDebut: debut,
          heureFin: fin,
          status: _statusController.text.trim(),
          camion: idCamion != null ? Camion(id: idCamion, immatriculation: '', typeCamion: '', capaciteCamion: 0, status: '') : null,
          zone: idZone != null ? Zone(id: idZone, nomZone: '', typeZone: '', latitude: '', longitude: '') : null,
        ));
      } else {
        await controller.updateTournee(Tournee(
          id: widget.tournee!.id,
          dateTournee: date,
          heureDebut: debut,
          heureFin: fin,
          status: _statusController.text.trim(),
          camion: idCamion != null ? Camion(id: idCamion, immatriculation: '', typeCamion: '', capaciteCamion: 0, status: '') : null,
          zone: idZone != null ? Zone(id: idZone, nomZone: '', typeZone: '', latitude: '', longitude: '') : null,
        ));
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
                decoration: const InputDecoration(labelText: 'Date (AAAA-MM-JJ)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!regex.hasMatch(v.trim())) return 'Format invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heureDebutController,
                decoration: const InputDecoration(labelText: 'Heure début (HH:mm)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (!_timeRegex.hasMatch(v.trim())) return 'Format invalide (HH:mm)';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heureFinController,
                decoration: const InputDecoration(labelText: 'Heure fin (HH:mm)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (!_timeRegex.hasMatch(v.trim())) return 'Format invalide (HH:mm)';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Statut'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idCamionController,
                decoration: const InputDecoration(labelText: 'ID camion (optionnel)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (int.tryParse(v.trim()) == null) return 'Doit être un entier';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idZoneController,
                decoration: const InputDecoration(labelText: 'ID zone (optionnel)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (int.tryParse(v.trim()) == null) return 'Doit être un entier';
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