import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/zone_model.dart';
import '../controllers/zone_controller.dart';

class ZoneFormDialog extends StatefulWidget {
  final Zone? zone;

  const ZoneFormDialog({super.key, this.zone});

  @override
  State<ZoneFormDialog> createState() => _ZoneFormDialogState();
}

class _ZoneFormDialogState extends State<ZoneFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late final TextEditingController _nomController;
  late final TextEditingController _typeController;
  late final TextEditingController _latController;
  late final TextEditingController _longController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.zone?.nomZone ?? '');
    _typeController = TextEditingController(text: widget.zone?.typeZone ?? '');
    _latController = TextEditingController(text: widget.zone?.latitude ?? '');
    _longController = TextEditingController(text: widget.zone?.longitude ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _typeController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation supplémentaire des coordonnées (optionnelle mais recommandée)
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_longController.text.trim());
    if (lat == null || lng == null) {
      Get.snackbar('Erreur', 'Coordonnées invalides');
      return;
    }

    setState(() => _saving = true);
    final controller = Get.find<ZoneController>();
    try {
      if (widget.zone == null) {
        // Ajout
        await controller.addZone(Zone(
          id: 0,
          nomZone: _nomController.text.trim(),
          typeZone: _typeController.text.trim(),
          latitude: _latController.text.trim(),
          longitude: _longController.text.trim(),
        ));
      } else {
        // Modification : utilisation de la nouvelle signature
        await controller.updateZone(Zone(
          id: widget.zone!.id,
          nomZone: _nomController.text.trim(),
          typeZone: _typeController.text.trim(),
          latitude: _latController.text.trim(),
          longitude: _longController.text.trim(),
        ));
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.zone != null;
    return AlertDialog(
      title: Text(isEdit ? 'Modifier la zone' : 'Ajouter une zone'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom zone'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type zone'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (double.tryParse(v.trim()) == null) return 'Doit être un nombre';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _longController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (double.tryParse(v.trim()) == null) return 'Doit être un nombre';
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