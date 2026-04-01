import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../chauffeur/controllers/chauffeur_controller.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/tournee_service.dart';
import '../../../widgets/snackbar_helper.dart';
import '../models/tournee_model.dart';

class TourneeLiveMapPage extends StatefulWidget {
  const TourneeLiveMapPage({super.key});

  @override
  State<TourneeLiveMapPage> createState() => _TourneeLiveMapPageState();
}

class _TourneeLiveMapPageState extends State<TourneeLiveMapPage> {
  final TourneeService _tourneeService = TourneeService();
  final ChauffeurController _chauffeurController = Get.put(
    ChauffeurController(),
  );
  final MapController _mapController = MapController();
  final List<LatLng> _routeStops = [];
  final List<String> _routeStopLabels = [];
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
      final startPoint = _parseCoordinates(
        tournee.zone?.latitude,
        tournee.zone?.longitude,
      );
      if (startPoint != null) {
        _prepareRouteStops(startPoint);
      } else {
        _clearRouteStops();
      }
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

  void _prepareRouteStops(LatLng origin) {
    _routeStops.clear();
    _routeStopLabels.clear();
    _currentSegment = 0;

    _routeStops.add(origin);
    _routeStopLabels.add('Zone');

    const offsets = [
      LatLng(0.0012, -0.0010),
      LatLng(0.0008, 0.0014),
      LatLng(-0.0010, 0.0010),
    ];

    for (var i = 0; i < offsets.length; i++) {
      final offset = offsets[i];
      _routeStops.add(LatLng(
        origin.latitude + offset.latitude,
        origin.longitude + offset.longitude,
      ));
      _routeStopLabels.add('Benne ${i + 1}');
    }
  }

  void _clearRouteStops() {
    _routeStops.clear();
    _routeStopLabels.clear();
    _currentSegment = 0;
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
      pageName: 'Live Map',
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
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _futureTournee = _loadCurrentTournee();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reessayer'),
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

          final normalizedStatus = tournee.status
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]'), '');
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
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            visualDensity: VisualDensity.compact,
          );
          final compactOutlined = OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            visualDensity: VisualDensity.compact,
          );

          final leftPanel = _OverlayPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: compactFilled,
                    onPressed: _hasRouteStops ? _passToNextBenne : null,
                    icon: const Icon(Icons.skip_next, size: 16),
                    label: const Text('Passer a la suivante'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(label: 'Etape courante', value: _currentStopLabel),
                _InfoRow(label: 'Suivant', value: _nextStopLabel),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Infos tournee',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _InfoRow(label: 'ID', value: '${tournee.id}'),
                _InfoRow(label: 'Zone', value: tournee.zone?.nomZone ?? '-'),
                _InfoRow(
                  label: 'Date',
                  value: tournee.dateTournee.toString().split(' ').first,
                ),
                _InfoRow(label: 'Statut', value: tournee.status),
              ],
            ),
          );
          final rightPanel = _OverlayPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _RouteSelectButton(
                  value: _routeMode,
                  onSelected: _selectRouteMode,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: compactOutlined,
                    onPressed: point == null ? null : () => _recenterMap(point),
                    icon: const Icon(Icons.center_focus_strong, size: 16),
                    label: const Text('Centrer'),
                  ),
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
          final rightPanelWide = SizedBox(width: 190, child: rightPanel);
          final isNarrow = MediaQuery.of(context).size.width < 720;

          return Stack(
            children: [
              Positioned.fill(
                child: _LiveMapPanel(
                  point: point,
                  mapController: _mapController,
                  routeMode: _routeMode,
                  routeStops: _routeStops,
                  routeStopLabels: _routeStopLabels,
                  currentSegment: _currentSegment,
                  onRecenter: point == null
                      ? null
                      : () => _recenterMap(
                            _hasRouteStops
                                ? _routeStops[_currentSegment]
                                : point,
                          ),
                  fullBleed: true,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isNarrow)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            leftPanel,
                            const SizedBox(height: AppSpacing.sm),
                            rightPanel,
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: leftPanel),
                            const SizedBox(width: AppSpacing.sm),
                            rightPanelWide,
                          ],
                        ),
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

  const _InfoRow({
    required this.label,
    required this.value,
  });

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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
              ),
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
  final int currentSegment;
  final VoidCallback? onRecenter;
  final bool fullBleed;

  const _LiveMapPanel({
    required this.point,
    required this.mapController,
    required this.routeMode,
    required this.routeStops,
    required this.routeStopLabels,
    required this.currentSegment,
    required this.onRecenter,
    this.fullBleed = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius =
        fullBleed ? BorderRadius.zero : BorderRadius.circular(AppRadius.md);
    final routePoints = _routePoints();
    final markers = _routeMarkers(scheme);

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
        child: point == null
            ? const Center(child: Text('Coordonnees non disponibles.'))
            : Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: point!,
                      initialZoom: 14,
                    ),
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
                              strokeWidth: 4,
                              color: scheme.primary.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Badge(
                      label: 'LIVE',
                      color: AppTheme.accentColor,
                    ),
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
    if (routeStops.length < 2) {
      return point == null ? [] : [point!];
    }
    if (routeMode == 'all') {
      return routeStops;
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
          visibleEntries.add(MapEntry(currentSegment, routeStops[currentSegment]));
        }
        final nextIndex = currentSegment + 1;
        if (nextIndex < routeStops.length) {
          visibleEntries.add(MapEntry(nextIndex, routeStops[nextIndex]));
        }
      }
      for (final entry in visibleEntries) {
        final label = entry.key < routeStopLabels.length
            ? routeStopLabels[entry.key]
            : 'Stop ${entry.key + 1}';
        markers.add(_buildMarker(entry.value, label, scheme));
      }
    } else if (point != null) {
      markers.add(_buildMarker(point!, 'Zone', scheme));
    }
    return markers;
  }

  Marker _buildMarker(LatLng position, String label, ColorScheme scheme) {
    return Marker(
      width: 80,
      height: 80,
      point: position,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_pin,
            size: 36,
            color: scheme.primary,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
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
        child: FilledButton.icon(
          style: filledStyle,
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow, size: 16),
          label: const Text('Demarrer'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: filledStyle,
            onPressed: isFinished ? null : onFinish,
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('Terminer'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            style: outlinedStyle,
            onPressed: isFinished ? null : onCancel,
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text('Annuler'),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

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
