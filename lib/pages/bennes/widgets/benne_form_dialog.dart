import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
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
                  child: const Icon(Icons.close),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(selectedPoint),
                  child: const Icon(Icons.check),
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
      final latitude = _normalizeCoordinateInput(_latController.text);
      final longitude = _normalizeCoordinateInput(_longController.text);

      final payload = Benne(
        id: widget.benne?.id ?? 0,
        typeBenne: _selectedType!,
        status: _selectedStatus!,
        capacite: cap,
        latitude: latitude,
        longitude: longitude,
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
                  if (v == null || v.trim().isEmpty) {
                    return 'Requis';
                  }
                  if (double.tryParse(_normalizeCoordinateInput(v)) == null) {
                    return 'Doit être un nombre';
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
                    return 'Doit être un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _openMapPicker,
                  child: const Icon(Icons.map_outlined),
                ),
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
