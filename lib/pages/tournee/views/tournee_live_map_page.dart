import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/routes/app_routes.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../chauffeur/controllers/chauffeur_controller.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/tournee_service.dart';
import '../../../core/services/benne_service.dart';
import '../../../widgets/snackbar_helper.dart';
import '../models/tournee_model.dart';
import '../../bennes/models/benne_model.dart';

class TourneeLiveMapPage extends StatefulWidget {
  const TourneeLiveMapPage({super.key});

  @override
  State<TourneeLiveMapPage> createState() => _TourneeLiveMapPageState();
}

class _TourneeLiveMapPageState extends State<TourneeLiveMapPage> {
  final TourneeService _tourneeService = TourneeService();
  final BenneService _benneService = BenneService();
  final ChauffeurController _chauffeurController = Get.put(
    ChauffeurController(),
  );
  final MapController _mapController = MapController();
  final List<LatLng> _routeStops = [];
  final List<String> _routeStopLabels = [];
  final List<LatLng> _routeGeometry = [];
  int _currentSegment = 0;
  late Future<Tournee?> _futureTournee;
  String _routeMode = 'all';

  @override
  void initState() {
    super.initState();
    _futureTournee = _loadCurrentTournee();
  }

  Future<Tournee?> _loadCurrentTournee() async {
    try {
      final tournees = await _chauffeurController.fetchMyTournees(
        showSnackbar: false,
      );
      if (tournees.isEmpty) return null;
      final tournee = tournees.first;
      await _prepareRouteStops(tournee);
      return tournee;
    } catch (e) {
      final message = e.toString();
      if (!message.contains('404')) {
        showNadiSnackbar(
          title: 'Erreur',
          message: 'Impossible de charger la tournee actuelle.',
          type: NadiSnackbarType.error,
        );
      }
      return null;
    }
  }

  bool get _hasRouteStops => _routeStops.length > 1;

  Future<void> _prepareRouteStops(Tournee tournee) async {
    _routeStops.clear();
    _routeStopLabels.clear();
    _routeGeometry.clear();
    _currentSegment = 0;

    final startPoint = _parseCoordinates(
      tournee.zone?.latitude,
      tournee.zone?.longitude,
    );
    if (startPoint != null) {
      _routeStops.add(startPoint);
      _routeStopLabels.add('Zone');
    }

    if (tournee.benneIds.isNotEmpty) {
      try {
        final bennesData = await _benneService.getBennesByIds(tournee.benneIds);
        for (final benneJson in bennesData) {
          final benne = Benne.fromJson(benneJson);
          final point = _parseCoordinates(benne.latitude, benne.longitude);
          if (point != null) {
            _routeStops.add(point);
            _routeStopLabels.add('Benne ${benne.id}');
          }
        }
      } catch (e) {
        _addFallbackStops(startPoint);
      }
    } else {
      _addFallbackStops(startPoint);
    }

    if (_routeStops.length >= 2) {
      try {
        final geometryPayload = await _tourneeService.getGeometry(tournee.id);
        final extracted = _extractRouteGeometry(geometryPayload);
        if (extracted.length >= 2) {
          _routeGeometry.addAll(extracted);
        } else {
          _routeGeometry.addAll(_routeStops);
        }
      } catch (_) {
        _routeGeometry.addAll(_routeStops);
      }
    }
  }

  void _addFallbackStops(LatLng? startPoint) {
    if (startPoint == null) return;
    const offsets = [
      LatLng(0.0012, -0.0010),
      LatLng(0.0008, 0.0014),
      LatLng(-0.0010, 0.0010),
    ];
    for (var i = 0; i < offsets.length; i++) {
      final offset = offsets[i];
      _routeStops.add(
        LatLng(
          startPoint.latitude + offset.latitude,
          startPoint.longitude + offset.longitude,
        ),
      );
      _routeStopLabels.add('Benne ${i + 1}');
    }
  }

  List<LatLng> _extractRouteGeometry(dynamic payload) {
    final points = _extractGeometryPoints(payload);
    if (points.length >= 2) return points;
    if (_routeStops.length >= 2) {
      return List<LatLng>.from(_routeStops);
    }
    return const [];
  }

  List<LatLng> _extractGeometryPoints(dynamic payload) {
    if (payload is Map) {
      final direct = payload['geometry'] ?? payload['geometrie'] ?? payload['coordinates'];
      final parsedDirect = _parseRouteGeometry(direct);
      if (parsedDirect.length >= 2) return parsedDirect;

      const nestedKeys = [
        'data',
        'route',
        'trajet',
        'result',
        'results',
        'current',
        'tournee',
      ];
      for (final key in nestedKeys) {
        final nested = payload[key];
        final points = _extractGeometryPoints(nested);
        if (points.length >= 2) return points;
      }

      if (payload['features'] is List) {
        for (final item in payload['features']) {
          final points = _extractGeometryPoints(item);
          if (points.length >= 2) return points;
        }
      }
      return const [];
    }

    if (payload is List) {
      for (final item in payload) {
        final points = _extractGeometryPoints(item);
        if (points.length >= 2) return points;
      }
      return const [];
    }

    return const [];
  }

  List<LatLng> _parseRouteGeometry(dynamic raw) {
    if (raw == null) return const [];
    if (raw is String) return _decodePolyline(raw);
    if (raw is List) return _parseCoordinateCollection(raw);
    if (raw is Map) {
      final coordinates = raw['coordinates'];
      final parsedCoordinates = _parseRouteGeometry(coordinates);
      if (parsedCoordinates.length >= 2) return parsedCoordinates;
      final geometry = raw['geometry'];
      return _parseRouteGeometry(geometry);
    }
    return const [];
  }

  List<LatLng> _parseCoordinateCollection(List raw) {
    final points = <LatLng>[];
    for (final item in raw) {
      if (item is List && item.length >= 2) {
        final lng = _toDouble(item[0]);
        final lat = _toDouble(item[1]);
        if (lat != null && lng != null) {
          points.add(LatLng(lat, lng));
        }
        continue;
      }
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final lat = _toDouble(map['lat'] ?? map['latitude'] ?? map['y']);
        final lng = _toDouble(map['lng'] ?? map['lon'] ?? map['longitude'] ?? map['x']);
        if (lat != null && lng != null) {
          points.add(LatLng(lat, lng));
        }
      }
    }
    return points;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  List<LatLng> _decodePolyline(String encoded) {
    if (encoded.trim().isEmpty) return const [];
    final precision5 = _decodePolylineWithScale(encoded, 1e5);
    final precision6 = _decodePolylineWithScale(encoded, 1e6);
    return precision6.length > precision5.length ? precision6 : precision5;
  }

  List<LatLng> _decodePolylineWithScale(String encoded, double scale) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;
    try {
      while (index < encoded.length) {
        var shift = 0;
        var result = 0;
        int byte;
        do {
          byte = encoded.codeUnitAt(index++) - 63;
          result |= (byte & 0x1f) << shift;
          shift += 5;
        } while (byte >= 0x20);
        final deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
        lat += deltaLat;

        shift = 0;
        result = 0;
        do {
          byte = encoded.codeUnitAt(index++) - 63;
          result |= (byte & 0x1f) << shift;
          shift += 5;
        } while (byte >= 0x20);
        final deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
        lng += deltaLng;

        points.add(LatLng(lat / scale, lng / scale));
      }
    } catch (_) {
      return const [];
    }
    return points;
  }

  void _passToNextBenne() {
    if (!_hasRouteStops) {
      showNadiSnackbar(
        title: 'Info',
        message: 'Aucune route de bennes disponible.',
        type: NadiSnackbarType.info,
      );
      return;
    }

    if (_currentSegment >= _routeStops.length - 2) {
      showNadiSnackbar(
        title: 'Info',
        message: 'Vous êtes déjà sur la dernière benne.',
        type: NadiSnackbarType.info,
      );
      return;
    }

    setState(() {
      _currentSegment += 1;
    });
    _recenterMap(_routeStops[_currentSegment]);
  }

  String get _currentStopLabel {
    if (_routeStopLabels.isEmpty) return '-';
    return _routeStopLabels[_currentSegment];
  }

  String get _nextStopLabel {
    final nextIndex = _currentSegment + 1;
    if (nextIndex >= _routeStopLabels.length) return '-';
    return _routeStopLabels[nextIndex];
  }

  Future<void> _startTour(Tournee tournee) async {
    try {
      await _tourneeService.start(tournee.id);
      showNadiSnackbar(
        title: 'Succes',
        message: 'Tournee demarree',
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Tournée démarrée',
        'Votre tournée ${tournee.id} a commencé.',
      );
      setState(() {
        _futureTournee = _loadCurrentTournee();
      });
    } catch (e) {
      showNadiSnackbar(
        title: 'Erreur',
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    }
  }

  Future<void> _finishTour(Tournee tournee) async {
    try {
      await _tourneeService.terminer(tournee.id);
      showNadiSnackbar(
        title: 'Succes',
        message: 'Tournee terminee',
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Tournée terminée',
        'La tournée ${tournee.id} est maintenant terminée.',
      );
      if (mounted) {
        Get.offNamed(AppRoutes.tourneeChauffeurHistory);
      }
    } catch (e) {
      showNadiSnackbar(
        title: 'Erreur',
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    }
  }

  Future<void> _cancelTour(Tournee tournee) async {
    try {
      await _tourneeService.annuler(tournee.id);
      showNadiSnackbar(
        title: 'Succes',
        message: 'Tournee annulee',
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Tournée annulée',
        'La tournée ${tournee.id} a été annulée.',
      );
      setState(() {
        _futureTournee = _loadCurrentTournee();
      });
    } catch (e) {
      showNadiSnackbar(
        title: 'Erreur',
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    }
  }

  void _selectRouteMode(String value) {
    setState(() => _routeMode = value);
  }

  void _recenterMap(LatLng point) {
    _mapController.move(point, 14);
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: 'Carte en direct',
      child: FutureBuilder<Tournee?>(
        future: _futureTournee,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Impossible de charger votre tournee.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _futureTournee = _loadCurrentTournee();
                        });
                      },
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            );
          }

          final tournee = snapshot.data;
          if (tournee == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.map_outlined, size: 48),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Aucune tournee optimisee ne vous est assignee.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final normalizedStatus = tournee.status.toLowerCase().replaceAll(
            RegExp(r'[^a-z0-9]'),
            '',
          );
          final isStarted =
              normalizedStatus == 'encours' || normalizedStatus == 'terminee';
          final isFinished = normalizedStatus == 'terminee';

          final point = _parseCoordinates(
            tournee.zone?.latitude,
            tournee.zone?.longitude,
          );

          final scheme = Theme.of(context).colorScheme;
          final compactFilled = FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            visualDensity: VisualDensity.compact,
          );
          final compactOutlined = OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            visualDensity: VisualDensity.compact,
          );

          final controlPanel = _OverlayPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TargetCard(
                  current: _currentStopLabel,
                  next: _nextStopLabel,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: FilledButton(
                        style: compactFilled,
                        onPressed: _hasRouteStops ? _passToNextBenne : null,
                        child: const Icon(Icons.skip_next, size: 18),
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: _RouteSelectButton(
                        value: _routeMode,
                        onSelected: _selectRouteMode,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: OutlinedButton(
                        style: compactOutlined,
                        onPressed: point == null ? null : () => _recenterMap(point),
                        child: const Icon(Icons.center_focus_strong, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Route: ${_routeMode == 'all' ? 'tout' : 'partiel'}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );

          return Stack(
            children: [
              Positioned.fill(
                child: _LiveMapPanel(
                  point: point,
                  mapController: _mapController,
                  routeMode: _routeMode,
                  routeStops: _routeStops,
                  routeStopLabels: _routeStopLabels,
                  routeGeometry: _routeGeometry,
                  currentSegment: _currentSegment,
                  onRecenter: (_routeGeometry.isNotEmpty || point != null)
                      ? () => _recenterMap(
                          _routeGeometry.isNotEmpty
                              ? _routeGeometry.first
                              : (_hasRouteStops ? _routeStops[_currentSegment] : point!),
                        )
                      : null,
                  fullBleed: true,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      controlPanel,
                      const Spacer(),
                      _OverlayPanel(
                        child: _BottomActions(
                          isStarted: isStarted,
                          isFinished: isFinished,
                          onStart: () => _startTour(tournee),
                          onFinish: () => _finishTour(tournee),
                          onCancel: () => _cancelTour(tournee),
                          filledStyle: compactFilled,
                          outlinedStyle: compactOutlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RouteSelectButton extends StatelessWidget {
  final String value;
  final ValueChanged<String> onSelected;
  final TextStyle? textStyle;

  const _RouteSelectButton({
    required this.value,
    required this.onSelected,
    this.textStyle,
  });

  String get _label => value == 'all' ? 'Route: Tout' : 'Route: Partiel';

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'all', child: Text("Tout l'itineraire")),
        PopupMenuItem(value: 'partial', child: Text('Partie de route')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune, size: 18),
            const SizedBox(width: 8),
            Text(_label, style: textStyle),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final String current;
  final String next;

  const _TargetCard({required this.current, required this.next});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cible',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Etape courante', value: current),
          _InfoRow(label: 'Suivant', value: next),
        ],
      ),
    );
  }
}

class _OverlayPanel extends StatelessWidget {
  final Widget child;

  const _OverlayPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveMapPanel extends StatelessWidget {
  final LatLng? point;
  final MapController mapController;
  final String routeMode;
  final List<LatLng> routeStops;
  final List<String> routeStopLabels;
  final List<LatLng> routeGeometry;
  final int currentSegment;
  final VoidCallback? onRecenter;
  final bool fullBleed;

  const _LiveMapPanel({
    required this.point,
    required this.mapController,
    required this.routeMode,
    required this.routeStops,
    required this.routeStopLabels,
    required this.routeGeometry,
    required this.currentSegment,
    required this.onRecenter,
    this.fullBleed = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = fullBleed
        ? BorderRadius.zero
        : BorderRadius.circular(AppRadius.md);
    final routePoints = _routePoints();
    final markers = _routeMarkers(scheme);
    final centerPoint = routeGeometry.isNotEmpty
        ? routeGeometry[routeGeometry.length ~/ 2]
        : point;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: radius,
        border: fullBleed
            ? null
            : Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: centerPoint == null
            ? const Center(child: Text('Coordonnees non disponibles.'))
            : Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(initialCenter: centerPoint, initialZoom: 14),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'clean_way_frontend',
                      ),
                      if (routePoints.length > 1)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              strokeWidth: 5,
                              color: scheme.primary,
                            ),
                          ],
                        ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Badge(label: 'LIVE', color: AppTheme.accentColor),
                  ),
                  if (onRecenter != null)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: FloatingActionButton.small(
                        onPressed: onRecenter,
                        backgroundColor: scheme.primary,
                        child: const Icon(Icons.center_focus_strong),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  List<LatLng> _routePoints() {
    if (routeMode == 'all') {
      if (routeGeometry.length >= 2) {
        return routeGeometry;
      }
      if (routeStops.length >= 2) {
        return routeStops;
      }
      return point == null ? [] : [point!];
    }

    if (routeStops.length < 2) {
      return point == null ? [] : [point!];
    }

    final nextIndex = currentSegment + 1;
    if (nextIndex < routeStops.length) {
      return [routeStops[currentSegment], routeStops[nextIndex]];
    }
    return [routeStops.last];
  }

  List<Marker> _routeMarkers(ColorScheme scheme) {
    final markers = <Marker>[];
    if (routeStops.isNotEmpty) {
      final visibleEntries = <MapEntry<int, LatLng>>[];
      if (routeMode == 'all') {
        visibleEntries.addAll(routeStops.asMap().entries);
      } else {
        if (currentSegment < routeStops.length) {
          visibleEntries.add(
            MapEntry(currentSegment, routeStops[currentSegment]),
          );
        }
        final nextIndex = currentSegment + 1;
        if (nextIndex < routeStops.length) {
          visibleEntries.add(MapEntry(nextIndex, routeStops[nextIndex]));
        }
      }
      for (final entry in visibleEntries) {
        final isStart = entry.key == 0;
        final isEnd = entry.key == routeStops.length - 1;
        final label = entry.key < routeStopLabels.length
            ? routeStopLabels[entry.key]
            : 'Stop ${entry.key + 1}';
        markers.add(
          _buildMarker(
            entry.value,
            label,
            scheme,
            isStart: isStart,
            isEnd: isEnd,
          ),
        );
      }
    } else if (point != null) {
      markers.add(_buildMarker(point!, 'Zone', scheme));
    }
    return markers;
  }

  Marker _buildMarker(
    LatLng position,
    String label,
    ColorScheme scheme, {
    bool isStart = false,
    bool isEnd = false,
  }) {
    final icon = isStart
        ? Icons.play_circle
        : isEnd
            ? Icons.flag_circle
            : Icons.location_pin;
    final color = isStart
        ? const Color(0xFF16A34A)
        : isEnd
            ? const Color(0xFFDC2626)
            : scheme.primary;

    return Marker(
      width: 36,
      height: 36,
      point: position,
      child: Tooltip(
        message: label,
        child: Icon(icon, color: color, size: 34),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool isStarted;
  final bool isFinished;
  final VoidCallback onStart;
  final VoidCallback onFinish;
  final VoidCallback onCancel;
  final ButtonStyle? filledStyle;
  final ButtonStyle? outlinedStyle;

  const _BottomActions({
    required this.isStarted,
    required this.isFinished,
    required this.onStart,
    required this.onFinish,
    required this.onCancel,
    this.filledStyle,
    this.outlinedStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (!isStarted) {
      return SizedBox(
        width: double.infinity,
        height: 42,
        child: FilledButton(
          style: filledStyle,
          onPressed: onStart,
          child: const Icon(Icons.play_arrow, size: 16),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: filledStyle,
            onPressed: isFinished ? null : onFinish,
            child: const Icon(Icons.stop, size: 16),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton(
            style: outlinedStyle,
            onPressed: isFinished ? null : onCancel,
            child: const Icon(Icons.cancel_outlined, size: 16),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

LatLng? _parseCoordinates(String? latitude, String? longitude) {
  final lat = double.tryParse(latitude?.trim() ?? '');
  final lng = double.tryParse(longitude?.trim() ?? '');
  if (lat == null || lng == null) return null;
  return LatLng(lat, lng);
}
