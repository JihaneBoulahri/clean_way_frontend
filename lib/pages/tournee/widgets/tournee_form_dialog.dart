import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/camion_service.dart';
import '../../../core/services/ville_service.dart';
import '../../../core/services/zone_service.dart';
import '../../../widgets/snackbar_helper.dart';
import '../../camion/models/camion_model.dart';
import '../../ville/models/ville_model.dart';
import '../../zone/models/zone_model.dart';
import '../controllers/tournee_controller.dart';
import '../models/tournee_model.dart';

class TourneeFormDialog extends StatefulWidget {
  final Tournee? tournee;

  const TourneeFormDialog({super.key, this.tournee});

  @override
  State<TourneeFormDialog> createState() => _TourneeFormDialogState();
}

class _TourneeFormDialogState extends State<TourneeFormDialog> {
  static const List<String> _statusOptions = [
    'planifiee',
    'en_cours',
    'terminee',
  ];

  final _formKey = GlobalKey<FormState>();
  final _villeService = VilleService();
  final _zoneService = ZoneService();
  final _camionService = CamionService();

  bool _saving = false;
  bool _loadingRefs = true;
  String? _loadError;

  late final TextEditingController _dateController;

  List<Ville> _villes = [];
  List<Zone> _zones = [];
  List<Camion> _camions = [];

  String? _selectedStatus;
  int? _selectedVilleId;
  int? _selectedZoneId;
  int? _selectedCamionId;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: widget.tournee != null
          ? widget.tournee!.dateTournee.toIso8601String().split('T').first
          : '',
    );
    _selectedStatus = _normalizeStatus(widget.tournee?.status);
    _selectedVilleId =
        widget.tournee?.zone?.idVille ??
        widget.tournee?.zone?.ville?.id ??
        widget.tournee?.camion?.zone?.idVille ??
        widget.tournee?.camion?.zone?.ville?.id;
    _selectedZoneId = widget.tournee?.idZone ?? widget.tournee?.zone?.id;
    _selectedCamionId =
        widget.tournee?.idCamion ?? widget.tournee?.camion?.id;
    _loadReferences();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  bool get _isCreate => widget.tournee == null;

  Future<void> _loadReferences() async {
    try {
      final results = await Future.wait([
        _villeService.getAll(),
        _zoneService.getAll(),
        _camionService.getAll(),
      ]);

      final villes = (results[0] as List)
          .map((json) => Ville.fromJson(json))
          .toList();
      final zones = (results[1] as List)
          .map((json) => Zone.fromJson(json))
          .toList();
      final camions = (results[2] as List)
          .map((json) => Camion.fromJson(json))
          .toList();

      _ensureCurrentSelectionPresent(villes, zones, camions);

      if (mounted) {
        setState(() {
          _villes = villes;
          _zones = zones;
          _camions = camions;
          _loadingRefs = false;
          _loadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingRefs = false;
          _loadError = e.toString();
        });
      }
    }
  }

  void _ensureCurrentSelectionPresent(
    List<Ville> villes,
    List<Zone> zones,
    List<Camion> camions,
  ) {
    final currentVille = widget.tournee?.zone?.ville ??
        widget.tournee?.camion?.zone?.ville;
    if (currentVille != null &&
        villes.every((ville) => ville.id != currentVille.id)) {
      villes.insert(0, currentVille);
    } else if (_selectedVilleId != null &&
        villes.every((ville) => ville.id != _selectedVilleId)) {
      villes.insert(
        0,
        Ville(id: _selectedVilleId!, nomVille: 'Ville #$_selectedVilleId'),
      );
    }

    final currentZone = widget.tournee?.zone;
    if (currentZone != null && zones.every((zone) => zone.id != currentZone.id)) {
      zones.insert(0, currentZone);
    }

    final currentCamion = widget.tournee?.camion;
    if (currentCamion != null &&
        camions.every((camion) => camion.id != currentCamion.id)) {
      camions.insert(0, currentCamion);
    }
  }

  String? _normalizeStatus(String? rawStatus) {
    final value = (rawStatus ?? '').trim().toLowerCase();
    if (value.isEmpty) return null;
    final compact = value
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');
    if (compact.contains('plan')) return 'planifiee';
    if (compact.contains('cours')) return 'en_cours';
    if (compact.contains('term') || compact.contains('fini')) return 'terminee';
    if (_statusOptions.contains(value)) return value;
    return null;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.tournee?.dateTournee ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  int? _cityIdForZone(Zone? zone) {
    if (zone == null) return null;
    return zone.idVille ?? zone.ville?.id;
  }

  int? _cityIdForCamion(Camion? camion) {
    if (camion == null) return null;
    return camion.zone?.idVille ?? camion.zone?.ville?.id;
  }

  Zone? _zoneById(int? id, {List<Zone>? from}) {
    if (id == null) return null;
    final zones = from ?? _zones;
    for (final zone in zones) {
      if (zone.id == id) return zone;
    }
    if (widget.tournee?.zone?.id == id) return widget.tournee?.zone;
    return null;
  }

  Camion? _camionById(int? id, {List<Camion>? from}) {
    if (id == null) return null;
    final camions = from ?? _camions;
    for (final camion in camions) {
      if (camion.id == id) return camion;
    }
    if (widget.tournee?.camion?.id == id) return widget.tournee?.camion;
    return null;
  }

  List<Zone> _availableZones() {
    if (_selectedVilleId == null) return List<Zone>.from(_zones);
    return _zones.where((zone) => _cityIdForZone(zone) == _selectedVilleId).toList();
  }

  List<Camion> _availableCamions() {
    if (_selectedVilleId == null) return List<Camion>.from(_camions);
    return _camions
        .where((camion) => _cityIdForCamion(camion) == _selectedVilleId)
        .toList();
  }

  void _onCityChanged(int? value) {
    setState(() {
      _selectedVilleId = value;
      final zone = _zoneById(_selectedZoneId);
      final camion = _camionById(_selectedCamionId);
      if (value != null && zone != null && _cityIdForZone(zone) != value) {
        _selectedZoneId = null;
      }
      if (value != null && camion != null && _cityIdForCamion(camion) != value) {
        _selectedCamionId = null;
      }
    });
  }

  void _onZoneChanged(int? value) {
    setState(() {
      _selectedZoneId = value;
      final zone = _zoneById(value);
      final zoneCityId = _cityIdForZone(zone);
      if (zoneCityId != null) {
        _selectedVilleId = zoneCityId;
      }
      final camion = _camionById(_selectedCamionId);
      if (_selectedVilleId != null &&
          camion != null &&
          _cityIdForCamion(camion) != _selectedVilleId) {
        _selectedCamionId = null;
      }
    });
  }

  void _onCamionChanged(int? value) {
    setState(() {
      _selectedCamionId = value;
      final camion = _camionById(value);
      final camionCityId = _cityIdForCamion(camion);
      if (camionCityId != null) {
        _selectedVilleId = camionCityId;
      }
      final zone = _zoneById(_selectedZoneId);
      if (_selectedVilleId != null &&
          zone != null &&
          _cityIdForZone(zone) != _selectedVilleId) {
        _selectedZoneId = null;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final date = DateTime.tryParse(_dateController.text.trim());
    if (date == null) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'Date invalide (AAAA-MM-JJ)',
        type: NadiSnackbarType.error,
      );
      return;
    }

    final selectedZone = _zoneById(_selectedZoneId);
    final selectedCamion = _camionById(_selectedCamionId);
    final zoneCityId = _cityIdForZone(selectedZone);
    final camionCityId = _cityIdForCamion(selectedCamion);
    final effectiveCityId = _selectedVilleId ?? zoneCityId ?? camionCityId;

    if (_isCreate &&
        (selectedZone == null ||
            selectedCamion == null ||
            effectiveCityId == null)) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'La ville, la zone et le camion sont obligatoires',
        type: NadiSnackbarType.error,
      );
      return;
    }

    if (selectedZone != null &&
        selectedCamion != null &&
        zoneCityId != null &&
        camionCityId != null &&
        zoneCityId != camionCityId) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'La zone et le camion doivent appartenir a la meme ville',
        type: NadiSnackbarType.error,
      );
      return;
    }

    if (_selectedVilleId != null &&
        ((zoneCityId != null && zoneCityId != _selectedVilleId) ||
            (camionCityId != null && camionCityId != _selectedVilleId))) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'La zone et le camion doivent appartenir a la meme ville',
        type: NadiSnackbarType.error,
      );
      return;
    }

    final controller = Get.find<TourneeController>();
    setState(() => _saving = true);
    try {
      final payload = Tournee(
        id: widget.tournee?.id ?? 0,
        dateTournee: date,
        heureDebut: widget.tournee?.heureDebut ?? '',
        heureFin: widget.tournee?.heureFin,
        status: _selectedStatus!,
        camion: selectedCamion,
        zone: selectedZone,
      );

      if (widget.tournee == null) {
        await controller.addTournee(payload);
      } else {
        await controller.updateTournee(payload);
      }

      if (mounted) Navigator.of(context).pop(payload);
    } catch (e) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'Echec de l\'enregistrement: ${e.toString()}',
        type: NadiSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int? _selectedVilleValue() {
    if (_selectedVilleId == null) return null;
    if (_villes.any((ville) => ville.id == _selectedVilleId)) {
      return _selectedVilleId;
    }
    return null;
  }

  int? _selectedZoneValue(List<Zone> zones) {
    if (_selectedZoneId == null) return null;
    if (zones.any((zone) => zone.id == _selectedZoneId)) return _selectedZoneId;
    return widget.tournee?.zone?.id == _selectedZoneId ? _selectedZoneId : null;
  }

  int? _selectedCamionValue(List<Camion> camions) {
    if (_selectedCamionId == null) return null;
    if (camions.any((camion) => camion.id == _selectedCamionId)) {
      return _selectedCamionId;
    }
    return widget.tournee?.camion?.id == _selectedCamionId
        ? _selectedCamionId
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.tournee != null;
    final availableZones = _availableZones();
    final availableCamions = _availableCamions();
    final selectedVilleId = _selectedVilleValue();
    final selectedZoneId = _selectedZoneValue(availableZones);
    final selectedCamionId = _selectedCamionValue(availableCamions);

    return AlertDialog(
      title: Text(isEdit ? 'Modifier la tournee' : 'Ajouter une tournee'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loadingRefs)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
              if (_loadError != null && _villes.isEmpty && _zones.isEmpty && _camions.isEmpty)
                Text(
                  'Impossible de charger les donnees de reference',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (AAAA-MM-JJ)',
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!regex.hasMatch(v.trim())) return 'Format invalide';
                  return null;
                },
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
                initialValue: selectedVilleId,
                decoration: const InputDecoration(labelText: 'Ville'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Choisir une ville'),
                  ),
                  ..._villes.map(
                    (ville) => DropdownMenuItem<int?>(
                      value: ville.id,
                      child: Text(
                        ville.createdAt != null
                            ? '${ville.nomVille} - ${ville.createdAt}'
                            : ville.nomVille,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: _onCityChanged,
                validator: (v) {
                  if (v == null && (_selectedZoneId != null || _selectedCamionId != null || _isCreate)) {
                    return 'Requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: selectedZoneId,
                decoration: InputDecoration(
                  labelText: _isCreate ? 'Zone' : 'Zone (optionnelle)',
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(_isCreate ? 'Choisir une zone' : 'Aucune zone'),
                  ),
                  ...availableZones.map(
                    (zone) => DropdownMenuItem<int?>(
                      value: zone.id,
                      child: Text(
                        '#${zone.id} - ${zone.nomZone}${zone.villeNom != null ? ' (${zone.villeNom})' : ''}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: _onZoneChanged,
                validator: (v) {
                  if (_isCreate && v == null) return 'Requis';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: selectedCamionId,
                decoration: InputDecoration(
                  labelText: _isCreate ? 'Camion' : 'Camion (optionnel)',
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(_isCreate ? 'Choisir un camion' : 'Aucun camion'),
                  ),
                  ...availableCamions.map(
                    (camion) => DropdownMenuItem<int?>(
                      value: camion.id,
                      child: Text(
                        '${camion.immatriculation}${camion.villeNom != null ? ' (${camion.villeNom})' : ''}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: _onCamionChanged,
                validator: (v) {
                  if (_isCreate && v == null) return 'Requis';
                  return null;
                },
              ),
              if (selectedVilleId == null && !_loadingRefs) ...[
                const SizedBox(height: 10),
                Text(
                  'La ville est deduite de la zone ou du camion si possible.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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
