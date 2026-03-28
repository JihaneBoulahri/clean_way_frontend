import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/zone_model.dart';
import '../controllers/zone_controller.dart';
import '../../../widgets/snackbar_helper.dart';

class ZoneFormDialog extends StatefulWidget {
  final Zone? zone;

  const ZoneFormDialog({super.key, this.zone});

  @override
  State<ZoneFormDialog> createState() => _ZoneFormDialogState();
}

class _ZoneFormDialogState extends State<ZoneFormDialog> {
  static const List<String> _typeZoneOptions = [
    'decharge',
    'recyclage',
  ];

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late final TextEditingController _nomController;
  late final TextEditingController _latController;
  late final TextEditingController _longController;
  String? _selectedTypeZone;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.zone?.nomZone ?? '');
    _latController = TextEditingController(text: widget.zone?.latitude ?? '');
    _longController = TextEditingController(text: widget.zone?.longitude ?? '');
    _selectedTypeZone = _normalizeTypeZone(widget.zone?.typeZone);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  String? _normalizeTypeZone(String? rawType) {
    final value = (rawType ?? '').trim().toLowerCase();
    if (value.isEmpty) return null;
    final compact = value.replaceAll('_', '').replaceAll('-', '');
    if (compact.contains('decharge')) return 'decharge';
    if (compact.contains('recyclage')) return 'recyclage';
    if (_typeZoneOptions.contains(value)) return value;
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final nomText = _nomController.text.trim();
    final typeText = (_selectedTypeZone ?? '').trim();
    final latText = _latController.text.trim();
    final longText = _longController.text.trim();

    // Validation stricte
    if (nomText.isEmpty || typeText.isEmpty || latText.isEmpty || longText.isEmpty) {
      
      showNadiSnackbar(
        title: "Erreur",
        message: "Tous les champs sont obligatoires",
        type: NadiSnackbarType.error,
      );
      return;
    }

    final lat = double.tryParse(latText);
    final lng = double.tryParse(longText);
    if (lat == null || lng == null) {
     
      showNadiSnackbar(
        title: "Erreur",
        message: "Latitude et Longitude doivent être des nombres valides",
        type: NadiSnackbarType.error,
      );
      return;
    }

    setState(() => _saving = true);
    final controller = Get.find<ZoneController>();
    try {
      Zone? result;
      if (widget.zone == null) {
        // Ajout
        await controller.addZone(Zone(
          id: 0,
          nomZone: nomText,
          typeZone: typeText,
          latitude: latText,
          longitude: longText,
        ));
      } else {
        // Modification
        result = Zone(
          id: widget.zone!.id,
          nomZone: nomText,
          typeZone: typeText,
          latitude: latText,
          longitude: longText,
        );
        await controller.updateZone(result);
      }
      if (mounted) Navigator.of(context).pop(result);
    } catch (e) {
    
      showNadiSnackbar(
        title: "Erreur",
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
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
              DropdownButtonFormField<String>(
                value: _selectedTypeZone,
                decoration: const InputDecoration(labelText: 'Type zone'),
                items: _typeZoneOptions
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedTypeZone = value),
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
