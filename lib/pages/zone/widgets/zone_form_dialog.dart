import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/ville_service.dart';
import '../../../pages/ville/models/ville_model.dart';
import '../../../widgets/snackbar_helper.dart';
import '../controllers/zone_controller.dart';
import '../models/zone_model.dart';

class ZoneFormDialog extends StatefulWidget {
  final Zone? zone;

  const ZoneFormDialog({super.key, this.zone});

  @override
  State<ZoneFormDialog> createState() => _ZoneFormDialogState();
}

class _ZoneFormDialogState extends State<ZoneFormDialog> {
  static const List<String> _typeZoneOptions = ['decharge', 'recyclage'];

  final _formKey = GlobalKey<FormState>();
  final _villeService = VilleService();

  bool _saving = false;
  bool _loadingVilles = true;
  String? _villesError;

  late final TextEditingController _nomController;
  late final TextEditingController _latController;
  late final TextEditingController _longController;

  List<Ville> _villes = [];
  String? _selectedTypeZone;
  int? _selectedVilleId;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.zone?.nomZone ?? '');
    _latController = TextEditingController(text: widget.zone?.latitude ?? '');
    _longController = TextEditingController(text: widget.zone?.longitude ?? '');
    _selectedTypeZone = _normalizeTypeZone(widget.zone?.typeZone);
    _selectedVilleId = widget.zone?.idVille ?? widget.zone?.ville?.id;
    _loadVilles();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> _loadVilles() async {
    try {
      final data = await _villeService.getAll();
      final villes = data.map((json) => Ville.fromJson(json)).toList();

      final currentVille = widget.zone?.ville;
      if (currentVille != null &&
          villes.every((ville) => ville.id != currentVille.id)) {
        villes.insert(0, currentVille);
      }

      if (mounted) {
        setState(() {
          _villes = villes;
          if (_selectedVilleId != null &&
              _villes.every((ville) => ville.id != _selectedVilleId)) {
            _selectedVilleId = currentVille?.id;
          }
          _loadingVilles = false;
          _villesError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingVilles = false;
          _villesError = e.toString();
        });
      }
    }
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

  String _normalizeCoordinateInput(String input) {
    return input.trim().replaceAll(',', '.');
  }

  LatLng? _parseLatLngFromInputs() {
    final lat = double.tryParse(_normalizeCoordinateInput(_latController.text));
    final lng = double.tryParse(
      _normalizeCoordinateInput(_longController.text),
    );
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  void _applyPickedPoint(LatLng point) {
    _latController.text = point.latitude.toStringAsFixed(6);
    _longController.text = point.longitude.toStringAsFixed(6);
  }

  Future<void> _openMapPicker() async {
    final initialPoint =
        _parseLatLngFromInputs() ?? const LatLng(33.573110, -7.589843);
    final pickedPoint = await showDialog<LatLng>(
      context: context,
      builder: (context) {
        var selectedPoint = initialPoint;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Choisir la position sur la carte'),
              content: SizedBox(
                width: 420,
                height: 360,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: selectedPoint,
                      initialZoom: 13,
                      onTap: (_, point) {
                        setStateDialog(() => selectedPoint = point);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'clean_way_frontend',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: selectedPoint,
                            child: const Icon(
                              Icons.location_pin,
                              size: 36,
                              color: Colors.red,
                            ),
                          ),
                        ],
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
                  onPressed: () => Navigator.of(context).pop(selectedPoint),
                  child: const Text('Utiliser cette position'),
                ),
              ],
            );
          },
        );
      },
    );

    if (pickedPoint != null && mounted) {
      setState(() => _applyPickedPoint(pickedPoint));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final nomText = _nomController.text.trim();
    final typeText = (_selectedTypeZone ?? '').trim();
    final latText = _normalizeCoordinateInput(_latController.text);
    final longText = _normalizeCoordinateInput(_longController.text);

    if (nomText.isEmpty ||
        typeText.isEmpty ||
        latText.isEmpty ||
        longText.isEmpty ||
        _selectedVilleId == null) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'Tous les champs sont obligatoires',
        type: NadiSnackbarType.error,
      );
      return;
    }

    final lat = double.tryParse(latText);
    final lng = double.tryParse(longText);
    if (lat == null || lng == null) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'Latitude et Longitude doivent etre des nombres valides',
        type: NadiSnackbarType.error,
      );
      return;
    }

    setState(() => _saving = true);
    final controller = Get.find<ZoneController>();
    try {
      final payload = Zone(
        id: widget.zone?.id ?? 0,
        nomZone: nomText,
        typeZone: typeText,
        latitude: latText,
        longitude: longText,
        idVille: _selectedVilleId,
        ville: _villes.where((ville) => ville.id == _selectedVilleId).isNotEmpty
            ? _villes.firstWhere((ville) => ville.id == _selectedVilleId)
            : widget.zone?.ville,
      );

      if (widget.zone == null) {
        await controller.addZone(payload);
      } else {
        await controller.updateZone(payload);
      }

      if (mounted) Navigator.of(context).pop(payload);
    } catch (e) {
      showNadiSnackbar(
        title: 'Erreur',
        message: e.toString(),
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
    return widget.zone?.ville?.id == _selectedVilleId ? _selectedVilleId : null;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.zone != null;
    final selectedVilleId = _selectedVilleValue();

    return AlertDialog(
      title: Text(isEdit ? 'Modifier la zone' : 'Ajouter une zone'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loadingVilles)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
              if (_villesError != null && _villes.isEmpty) ...[
                Text(
                  'Impossible de charger les villes',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom zone'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedTypeZone,
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
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedVilleId,
                decoration: const InputDecoration(labelText: 'Ville'),
                items: _villes
                    .map(
                      (ville) => DropdownMenuItem<int>(
                        value: ville.id,
                        child: Text(
                          '${ville.nomVille}${ville.createdAt != null ? ' - ${ville.createdAt}' : ''}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedVilleId = value),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Requis';
                  }
                  if (double.tryParse(_normalizeCoordinateInput(v)) == null) {
                    return 'Doit etre un nombre';
                  }
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
                  if (v == null || v.trim().isEmpty) {
                    return 'Requis';
                  }
                  if (double.tryParse(_normalizeCoordinateInput(v)) == null) {
                    return 'Doit etre un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openMapPicker,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Choisir la position avec la carte'),
                ),
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
