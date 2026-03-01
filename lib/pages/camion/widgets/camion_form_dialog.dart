import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/camion_model.dart';
import '../controllers/camion_controller.dart';

class CamionFormDialog extends StatefulWidget {
  final Camion? camion;

  const CamionFormDialog({super.key, this.camion});

  @override
  State<CamionFormDialog> createState() => _CamionFormDialogState();
}

class _CamionFormDialogState extends State<CamionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late final TextEditingController _immatController;
  late final TextEditingController _typeController;
  late final TextEditingController _capaciteController;
  late final TextEditingController _dateController;
  late final TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    _immatController = TextEditingController(
        text: widget.camion?.immatriculation ?? '');
    _typeController = TextEditingController(text: widget.camion?.typeCamion ?? '');
    _capaciteController = TextEditingController(
        text: widget.camion?.capaciteCamion.toString() ?? '');
    _dateController = TextEditingController(
        text: widget.camion?.dateMiseEnService != null
            ? '${widget.camion!.dateMiseEnService!.year}-${widget.camion!.dateMiseEnService!.month.toString().padLeft(2, '0')}-${widget.camion!.dateMiseEnService!.day.toString().padLeft(2, '0')}'
            : '');
    _statusController = TextEditingController(text: widget.camion?.status ?? '');
  }

  @override
  void dispose() {
    _immatController.dispose();
    _typeController.dispose();
    _capaciteController.dispose();
    _dateController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cap = double.tryParse(_capaciteController.text);
    if (cap == null || cap <= 0) {
      Get.snackbar('Erreur', 'Capacité invalide');
      return;
    }
    DateTime? date;
    if (_dateController.text.trim().isNotEmpty) {
      date = DateTime.tryParse(_dateController.text.trim());
    }
    setState(() => _saving = true);
    final controller = Get.find<CamionController>();
    try {
      if (widget.camion == null) {
        await controller.addCamion(Camion(
          id: 0,
          immatriculation: _immatController.text.trim(),
          typeCamion: _typeController.text.trim(),
          capaciteCamion: cap,
          dateMiseEnService: date,
          status: _statusController.text.trim(),
        ));
      } else {
        await controller.updateCamion(
          widget.camion!.id,
          Camion(
            id: widget.camion!.id,
            immatriculation: _immatController.text.trim(),
            typeCamion: _typeController.text.trim(),
            capaciteCamion: cap,
            dateMiseEnService: date,
            status: _statusController.text.trim(),
          ),
        );
      }
      Get.back();
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.camion != null;
    return AlertDialog(
      title: Text(isEdit ? 'Modifier le camion' : 'Ajouter un camion'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _immatController,
                decoration: const InputDecoration(labelText: 'Immatriculation'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type camion'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capaciteController,
                decoration: const InputDecoration(labelText: 'Capacité (kg)'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                    labelText: 'Date mise en service (AAAA-MM-JJ)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Statut'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
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
