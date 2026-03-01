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

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final controller = Get.find<ZoneController>();
    if (widget.zone == null) {
      controller.addZone(Zone(
        id: 0,
        nomZone: _nomController.text.trim(),
        typeZone: _typeController.text.trim(),
        latitude: _latController.text.trim(),
        longitude: _longController.text.trim(),
      ));
    } else {
      controller.updateZone(
        widget.zone!.id,
        Zone(
          id: widget.zone!.id,
          nomZone: _nomController.text.trim(),
          typeZone: _typeController.text.trim(),
          latitude: _latController.text.trim(),
          longitude: _longController.text.trim(),
        ),
      );
    }
    Get.back();
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
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _longController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
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
