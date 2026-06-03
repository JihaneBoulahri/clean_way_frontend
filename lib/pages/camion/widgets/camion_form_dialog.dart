import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/zone_service.dart';
import '../../../widgets/snackbar_helper.dart';
import '../../zone/models/zone_model.dart';
import '../controllers/camion_controller.dart';
import '../models/camion_model.dart';

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
  final _zoneService = ZoneService();

  bool _saving = false;
  bool _loadingZones = true;
  String? _zonesError;

  late final TextEditingController _immatController;
  late final TextEditingController _capaciteController;
  late final TextEditingController _dateController;

  List<Zone> _zones = [];
  String? _selectedStatus;
  String? _selectedType;
  int? _selectedZoneId;

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
    _selectedZoneId = widget.camion?.idZone ?? widget.camion?.zone?.id;
    _loadZones();
  }

  @override
  void dispose() {
    _immatController.dispose();
    _capaciteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadZones() async {
    try {
      final data = await _zoneService.getAll();
      final zones = data.map((json) => Zone.fromJson(json)).toList();
      final currentZone = widget.camion?.zone;
      if (currentZone != null &&
          zones.every((zone) => zone.id != currentZone.id)) {
        zones.insert(0, currentZone);
      }

      if (mounted) {
        setState(() {
          _zones = zones;
          // S'assurer que la zone sélectionnée existe dans la liste
          if (_selectedZoneId != null &&
              _zones.every((zone) => zone.id != _selectedZoneId)) {
            _selectedZoneId = null;
          }
          _loadingZones = false;
          _zonesError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingZones = false;
          _zonesError = e.toString();
        });
      }
    }
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
    if (compact.contains('leger') || compact.contains('léger')) {
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

  Zone? _selectedZone() {
    if (_selectedZoneId == null) return null;
    for (final zone in _zones) {
      if (zone.id == _selectedZoneId) return zone;
    }
    if (widget.camion?.zone?.id == _selectedZoneId) return widget.camion?.zone;
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cap = double.tryParse(_capaciteController.text);
    if (cap == null || cap <= 0) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'Capacite invalide',
        type: NadiSnackbarType.error,
      );
      return;
    }

    if (_dateController.text.trim().isEmpty) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'La date de mise en service est requise',
        type: NadiSnackbarType.error,
      );
      return;
    }

    final date = DateTime.tryParse(_dateController.text.trim());
    if (date == null) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'Date invalide',
        type: NadiSnackbarType.error,
      );
      return;
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
        idZone: _selectedZoneId,
        zone: _selectedZone(),
      );

      if (widget.camion == null) {
        await controller.addCamion(payload);
      } else {
        await controller.updateCamion(payload);
      }

      if (mounted) Navigator.of(context).pop(payload);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int? _selectedZoneValue() {
    // La zone sélectionnée est garantie d'exister dans _zones ou est null
    return _selectedZoneId;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.camion != null;
    final selectedZoneId = _selectedZoneValue();

    return AlertDialog(
      title: Text(isEdit ? 'Modifier le camion' : 'Ajouter un camion'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loadingZones)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
              if (_zonesError != null && _zones.isEmpty) ...[
                Text(
                  'Impossible de charger les zones',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
                decoration: const InputDecoration(labelText: 'Capacite (m3)'),
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
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requis' : null,
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
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: selectedZoneId,
                decoration: const InputDecoration(labelText: 'Zone (optionnel)'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Aucune zone'),
                  ),
                  ..._zones.map(
                    (zone) => DropdownMenuItem<int?>(
                      value: zone.id,
                      child: Text(
                        '#${zone.id} - ${zone.nomZone}${zone.villeNom != null ? ' (${zone.villeNom})' : ''}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedZoneId = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.close),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(isEdit ? Icons.check : Icons.add),
        ),
      ],
    );
  }
}
