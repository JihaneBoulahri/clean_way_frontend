import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/camion_model.dart';
import '../../../models/zone_model.dart';
import '../../../models/tournee_model.dart';
import '../controllers/tournee_controller.dart';

class TourneeFormDialog extends StatefulWidget {
  final Tournee? tournee;

  const TourneeFormDialog({super.key, this.tournee});

  @override
  State<TourneeFormDialog> createState() => _TourneeFormDialogState();
}

class _TourneeFormDialogState extends State<TourneeFormDialog> {
  final _formKey = GlobalKey<FormState>();
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final date = DateTime.tryParse(_dateController.text.trim());
    if (date == null) {
      Get.snackbar('Erreur', 'Date invalide (AAAA-MM-JJ)');
      return;
    }
    final idCamion = int.tryParse(_idCamionController.text.trim());
    final idZone = int.tryParse(_idZoneController.text.trim());
    final controller = Get.find<TourneeController>();
    if (widget.tournee == null) {
      controller.addTournee(Tournee(
        id: 0,
        dateTournee: date,
        heureDebut: _heureDebutController.text.trim(),
        heureFin: _heureFinController.text.trim().isEmpty
            ? null
            : _heureFinController.text.trim(),
        status: _statusController.text.trim(),
        camion: idCamion != null ? Camion(id: idCamion, immatriculation: '', typeCamion: '', capaciteCamion: 0, status: '') : null,
        zone: idZone != null ? Zone(id: idZone, nomZone: '', typeZone: '', latitude: '', longitude: '') : null,
      ));
    } else {
      controller.updateTournee(
        widget.tournee!.id,
        Tournee(
          id: widget.tournee!.id,
          dateTournee: date,
          heureDebut: _heureDebutController.text.trim(),
          heureFin: _heureFinController.text.trim().isEmpty
              ? null
              : _heureFinController.text.trim(),
          status: _statusController.text.trim(),
          camion: idCamion != null ? Camion(id: idCamion, immatriculation: '', typeCamion: '', capaciteCamion: 0, status: '') : null,
          zone: idZone != null ? Zone(id: idZone, nomZone: '', typeZone: '', latitude: '', longitude: '') : null,
        ),
      );
    }
    Get.back();
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
                decoration: const InputDecoration(
                    labelText: 'Date (AAAA-MM-JJ)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heureDebutController,
                decoration: const InputDecoration(
                    labelText: 'Heure début (ex: 20:31:15)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heureFinController,
                decoration: const InputDecoration(
                    labelText: 'Heure fin (optionnel)'),
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
                decoration: const InputDecoration(labelText: 'ID camion'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idZoneController,
                decoration: const InputDecoration(labelText: 'ID zone'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
        FilledButton(onPressed: _save, child: Text(isEdit ? 'Modifier' : 'Ajouter')),
      ],
    );
  }
}
