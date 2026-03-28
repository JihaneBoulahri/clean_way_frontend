import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/camion_model.dart';
import '../controllers/camion_controller.dart';
import '../../../widgets/snackbar_helper.dart';

class CamionFormDialog extends StatefulWidget {
  final Camion? camion;

  const CamionFormDialog({super.key, this.camion});

  @override
  State<CamionFormDialog> createState() => _CamionFormDialogState();
}

class _CamionFormDialogState extends State<CamionFormDialog> {
  static const List<String> _statusOptions = [
    'disponible',
    'en-collecte',
    'hors-service',
  ];
  static const List<String> _typeOptions = [
    'compacteur',
    'semi-remorque',
    'leger',
  ];

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late final TextEditingController _immatController;
  late final TextEditingController _capaciteController;
  late final TextEditingController _dateController;
  String? _selectedStatus;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _immatController = TextEditingController(
      text: widget.camion?.immatriculation ?? '',
    );
    _capaciteController = TextEditingController(
      text: widget.camion?.capaciteCamion.toString() ?? '',
    );
    _dateController = TextEditingController(
      text: widget.camion?.dateMiseEnService != null
          ? '${widget.camion!.dateMiseEnService!.year}-${widget.camion!.dateMiseEnService!.month.toString().padLeft(2, '0')}-${widget.camion!.dateMiseEnService!.day.toString().padLeft(2, '0')}'
          : '',
    );
    _selectedStatus = _normalizeStatus(widget.camion?.status);
    _selectedType = _normalizeType(widget.camion?.typeCamion);
  }

  @override
  void dispose() {
    _immatController.dispose();
    _capaciteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String? _normalizeStatus(String? rawStatus) {
    final value = (rawStatus ?? '').trim().toLowerCase();
    if (value.isEmpty) return null;

    final compact = value.replaceAll('_', '-').replaceAll(' ', '-');
    if (compact.contains('hors') || compact.contains('panne')) {
      return 'hors-service';
    }
    if (compact.contains('collecte')) {
      return 'en-collecte';
    }
    if (compact.contains('disponible')) {
      return 'disponible';
    }
    return _statusOptions.contains(compact) ? compact : null;
  }

  String? _normalizeType(String? rawType) {
    final value = (rawType ?? '').trim().toLowerCase();
    if (value.isEmpty) return null;

    final compact = value.replaceAll('_', '-').replaceAll(' ', '-');
    if (compact.contains('semi') && compact.contains('remorque')) {
      return 'semi-remorque';
    }
    if (compact.contains('compacteur')) {
      return 'compacteur';
    }
    if (compact.contains('leger') || compact.contains('légé')) {
      return 'leger';
    }
    return _typeOptions.contains(compact) ? compact : null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.camion?.dateMiseEnService ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
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

    DateTime? date;
    if (_dateController.text.trim().isNotEmpty) {
      date = DateTime.tryParse(_dateController.text.trim());
    }

    setState(() => _saving = true);
    final controller = Get.find<CamionController>();
    try {
      final payload = Camion(
        id: widget.camion?.id ?? 0,
        immatriculation: _immatController.text.trim(),
        typeCamion: _selectedType!,
        capaciteCamion: cap,
        dateMiseEnService: date,
        status: _selectedStatus!,
      );

      if (widget.camion == null) {
        await controller.addCamion(payload);
      } else {
        await controller.updateCamion(payload);
      }

      if (mounted) Navigator.of(context).pop();
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
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Type camion'),
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
              TextFormField(
                controller: _capaciteController,
                decoration: const InputDecoration(labelText: 'Capacité (m³)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date mise en service',
                        hintText: 'AAAA-MM-JJ',
                      ),
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ],
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
