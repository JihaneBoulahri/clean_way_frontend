import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/benne_model.dart';
import '../controllers/benne_controller.dart';
import '../../../widgets/snackbar_helper.dart';

class BenneFormDialog extends StatefulWidget {
  final Benne? benne;

  const BenneFormDialog({super.key, this.benne});

  @override
  State<BenneFormDialog> createState() => _BenneFormDialogState();
}

class _BenneFormDialogState extends State<BenneFormDialog> {
  static const List<String> _typeOptions = [
    'plastique',
    'verre',
    'organique',
    'papier',
  ];
  static const List<String> _statusOptions = [
    'active',
    'inactive',
    'maintenance',
  ];

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late final TextEditingController _capaciteController;
  late final TextEditingController _latController;
  late final TextEditingController _longController;
  String? _selectedType;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedType = _normalizeType(widget.benne?.typeBenne);
    _selectedStatus = _normalizeStatus(widget.benne?.status);
    _capaciteController = TextEditingController(
      text: widget.benne?.capacite.toString() ?? '',
    );
    _latController = TextEditingController(text: widget.benne?.latitude ?? '');
    _longController = TextEditingController(
      text: widget.benne?.longitude ?? '',
    );
  }

  @override
  void dispose() {
    _capaciteController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  String? _normalizeType(String? rawType) {
    final value = (rawType ?? '').trim().toLowerCase();
    if (value.isEmpty) return null;
    return _typeOptions.contains(value) ? value : null;
  }

  String? _normalizeStatus(String? rawStatus) {
    final value = (rawStatus ?? '').trim().toLowerCase();
    if (value.isEmpty) return null;
    return _statusOptions.contains(value) ? value : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final cap = double.tryParse(_capaciteController.text);
    if (cap == null || cap <= 0) {
      showNadiSnackbar(
        title: "Erreur",
        message: "Capacité invalide",
        type: NadiSnackbarType.error,
      );
      return;
    }

    setState(() => _saving = true);
    final controller = Get.find<BennesController>();
    try {
      final payload = Benne(
        id: widget.benne?.id ?? 0,
        typeBenne: _selectedType!,
        status: _selectedStatus!,
        capacite: cap,
        latitude: _latController.text.trim(),
        longitude: _longController.text.trim(),
      );

      if (widget.benne == null) {
        await controller.addBenne(payload);
      } else {
        await controller.updateBenne(payload);
      }

      if (mounted) Navigator.of(context).pop();
    } finally {
      setState(() => _saving = false);
    }
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
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Type benne'),
                items: _typeOptions
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
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
                controller: _capaciteController,
                decoration: const InputDecoration(labelText: 'Capacité (m³)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (double.tryParse(v.trim()) == null)
                    return 'Doit être un nombre';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _longController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (double.tryParse(v.trim()) == null)
                    return 'Doit être un nombre';
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
