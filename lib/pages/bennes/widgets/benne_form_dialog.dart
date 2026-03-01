import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/benne_model.dart';
import '../controllers/benne_controller.dart';

class BenneFormDialog extends StatefulWidget {
  final Benne? benne;

  const BenneFormDialog({super.key, this.benne});

  @override
  State<BenneFormDialog> createState() => _BenneFormDialogState();
}

class _BenneFormDialogState extends State<BenneFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _typeController;
  late final TextEditingController _capaciteController;
  late final TextEditingController _latController;
  late final TextEditingController _longController;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.benne?.typeBenne ?? '');
    _capaciteController = TextEditingController(
        text: widget.benne?.capacite.toString() ?? '');
    _latController = TextEditingController(text: widget.benne?.latitude ?? '');
    _longController = TextEditingController(text: widget.benne?.longitude ?? '');
  }

  @override
  void dispose() {
    _typeController.dispose();
    _capaciteController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final cap = double.tryParse(_capaciteController.text);
    if (cap == null || cap <= 0) {
      Get.snackbar('Erreur', 'Capacité invalide');
      return;
    }
    final controller = Get.find<BennesController>();
    if (widget.benne == null) {
      controller.addBenne(Benne(
        id: 0,
        typeBenne: _typeController.text.trim(),
        capacite: cap,
        latitude: _latController.text.trim(),
        longitude: _longController.text.trim(),
      ));
    } else {
      controller.updateBenne(
        widget.benne!.id,
        Benne(
          id: widget.benne!.id,
          typeBenne: _typeController.text.trim(),
          capacite: cap,
          latitude: _latController.text.trim(),
          longitude: _longController.text.trim(),
        ),
      );
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.benne != null;
    return AlertDialog(
      title: Text(isEdit ? 'Modifier la benne' : 'Ajouter une benne'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type benne'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capaciteController,
                decoration: const InputDecoration(labelText: 'Capacité (m³)'),
                keyboardType: TextInputType.number,
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
