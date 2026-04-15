import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/location_map_card.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';

import '../models/tournee_model.dart';
import '../../chauffeur/controllers/chauffeur_controller.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/tournee_service.dart';
import '../../../widgets/snackbar_helper.dart';
import '../controllers/tournee_controller.dart';

class TourneeChauffeurPage extends StatefulWidget {
  const TourneeChauffeurPage({super.key});

  @override
  State<TourneeChauffeurPage> createState() => _TourneeChauffeurPageState();
}

class _TourneeChauffeurPageState extends State<TourneeChauffeurPage> {
  final TourneeService _tourneeService = TourneeService();
  final ChauffeurController _chauffeurController = Get.put(
    ChauffeurController(),
  );
  late Future<_TourneePageData?> _futureTourneeData;

  @override
  void initState() {
    super.initState();
    _futureTourneeData = _loadCurrentTourneeData();
  }

  bool _isNotFoundError(Object error) {
    final message = error.toString();
    return message.contains('404') ||
        message.toLowerCase().contains('not found');
  }

  Tournee? _mapToTournee(Map<String, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    map['id_tournee'] ??= map['id'] ?? map['tournee_id'];
    map['date_tournee'] ??= map['date'] ?? map['dateTournee'];
    map['heure_debut'] ??= map['start_time'] ?? map['heureDebut'] ?? '';
    map['heure_fin'] ??= map['end_time'] ?? map['heureFin'];
    map['status'] ??= map['etat'] ?? map['state'] ?? 'en cours';

    final nestedTournee = map['tournee'];
    if (nestedTournee is Map) {
      final nested = Map<String, dynamic>.from(nestedTournee);
      nested['id_tournee'] ??= nested['id'] ?? map['id_tournee'];
      nested['status'] ??= map['status'];
      nested['date_tournee'] ??= map['date_tournee'];
      nested['heure_debut'] ??= map['heure_debut'];
      nested['heure_fin'] ??= map['heure_fin'];
      if (nested['zone'] == null && map['zone'] is Map) {
        nested['zone'] = map['zone'];
      }
      if (nested['camion'] == null && map['camion'] is Map) {
        nested['camion'] = map['camion'];
      }
      map
        ..clear()
        ..addAll(nested);
    }

    final tournee = Tournee.fromJson(map);
    return tournee.id > 0 ? tournee : null;
  }

  Tournee? _extractCurrentTournee(dynamic payload) {
    if (payload is Map) {
      final root = _mapToTournee(Map<String, dynamic>.from(payload));
      if (root != null) return root;

      const candidates = [
        'tournee',
        'current',
        'current_tournee',
        'result',
        'item',
      ];
      for (final key in candidates) {
        final value = payload[key];
        if (value is Map) {
          final parsed = _mapToTournee(Map<String, dynamic>.from(value));
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    if (payload is List) {
      for (final item in payload) {
        if (item is Map) {
          final parsed = _mapToTournee(Map<String, dynamic>.from(item));
          if (parsed != null) return parsed;
        }
      }
    }

    return null;
  }

  bool _looksLikeGeometryPayload(Map<String, dynamic> map) {
    final geometry = map['geometry'];
    final coordinates = map['coordinates'];
    return (geometry is String && geometry.trim().isNotEmpty) ||
        coordinates is List;
  }

  Map<String, dynamic>? _extractGeometryPayload(dynamic payload) {
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      if (_looksLikeGeometryPayload(map)) return map;

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
        final value = map[key];
        if (value is Map) {
          final nested = Map<String, dynamic>.from(value);
          if (_looksLikeGeometryPayload(nested)) return nested;
        }
      }
      return null;
    }

    if (payload is List) {
      for (final item in payload) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          if (_looksLikeGeometryPayload(map)) return map;
        }
      }
    }

    return null;
  }

  Future<_AssignedTournee?> _loadAssignedTournee() async {
    Object? lastNon404Error;

    try {
      final currentPayload = await _tourneeService.getCurrentForChauffeur();
      final current = _extractCurrentTournee(currentPayload);
      if (current != null) {
        return _AssignedTournee(
          tournee: current,
          geometryPayload: _extractGeometryPayload(currentPayload),
        );
      }
    } catch (e) {
      if (!_isNotFoundError(e)) {
        lastNon404Error = e;
      }
    }

    try {
      final tournees = await _chauffeurController.fetchMyTournees(
        showSnackbar: false,
      );
      if (tournees.isNotEmpty) {
        return _AssignedTournee(tournee: tournees.first);
      }
    } catch (e) {
      if (!_isNotFoundError(e)) {
        lastNon404Error = e;
      }
    }

    if (lastNon404Error != null) {
      throw Exception(lastNon404Error.toString());
    }
    return null;
  }

  Future<_TourneePageData?> _loadCurrentTourneeData() async {
    try {
      final assigned = await _loadAssignedTournee();
      if (assigned == null) return null;
      final tournee = assigned.tournee;

      _TourneeGeometry? geometry;
      String? geometryError;

      final inlinePayload = assigned.geometryPayload;
      if (inlinePayload != null) {
        final inlineGeometry = _TourneeGeometry.fromJson(inlinePayload);
        if (inlineGeometry.routePoints.isNotEmpty) {
          geometry = inlineGeometry;
        }
      }

      try {
        if (geometry == null || geometry.routePoints.isEmpty) {
          final payload = await _tourneeService.getGeometry(
            tournee.id,
            profile: 'driving-car',
            returnToDepot: false,
          );
          geometry = _TourneeGeometry.fromJson(payload);
        }
      } catch (e) {
        geometryError = _buildGeometryErrorMessage(e);
      }
      if (geometry != null && geometry.routePoints.isEmpty) {
        geometryError =
            "Le backend a répondu sans points exploitables pour afficher le trajet.";
      }

      return _TourneePageData(
        tournee: tournee,
        geometry: geometry,
        geometryError: geometryError,
      );
    } catch (e) {
      final message = e.toString();
      if (!message.contains('404')) {
        showNadiSnackbar(
          title: "Erreur",
          message: "Impossible de charger la tournée actuelle.",
          type: NadiSnackbarType.error,
        );
      }
      return null;
    }
  }

  String? _buildGeometryErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('404')) return null;
    final short = message.length > 80
        ? '${message.substring(0, 80)}...'
        : message;
    return 'Trajet indisponible pour le moment ($short).';
  }

  Future<void> _startTour(Tournee tournee) async {
    try {
      await _tourneeService.start(tournee.id);

      showNadiSnackbar(
        title: "Succès",
        message: "Tournée démarrée",
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Tournée démarrée',
        'Votre tournée ${tournee.id} est maintenant en cours.',
      );
      setState(() {
        _futureTourneeData = _loadCurrentTourneeData();
      });
    } catch (e) {
      showNadiSnackbar(
        title: "Erreur",
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    }
  }

  Future<void> _finishTour(Tournee tournee) async {
    try {
      await _tourneeService.terminer(tournee.id);

      showNadiSnackbar(
        title: "Succès",
        message: "Tournée terminée",
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Tournée terminée',
        'La tournée ${tournee.id} a été terminée avec succès.',
      );
      setState(() {
        _futureTourneeData = _loadCurrentTourneeData();
      });
    } catch (e) {
      showNadiSnackbar(
        title: "Erreur",
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    }
  }

  Future<void> _cancelTour(Tournee tournee) async {
    try {
      await _tourneeService.annuler(tournee.id);

      showNadiSnackbar(
        title: "Succès",
        message: "Tournée annulée",
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Tournée annulée',
        'La tournée ${tournee.id} a été annulée.',
      );
      setState(() {
        _futureTourneeData = _loadCurrentTourneeData();
      });
    } catch (e) {
      showNadiSnackbar(
        title: "Erreur",
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    }
  }

  Future<void> _startNewTournee() async {
    try {
      // Get current chauffeur
      final storedUser = GetStorage().read('user');
      if (storedUser is! Map || storedUser['id'] == null) {
        showNadiSnackbar(
          title: 'Erreur',
          message: 'Utilisateur non connecté.',
          type: NadiSnackbarType.error,
        );
        return;
      }
      final userId = storedUser['id'] as int;
      final chauffeur = await _chauffeurController.getChauffeurDetails(userId);
      if (chauffeur == null || chauffeur.camion == null) {
        showNadiSnackbar(
          title: 'Erreur',
          message: 'Aucun camion assigné. Contactez l\'administration.',
          type: NadiSnackbarType.error,
        );
        return;
      }

      // Create new tournee
      final now = DateTime.now();
      final tourneeController = Get.find<TourneeController>();
      await tourneeController.addTournee(
        Tournee(
          id: 0,
          dateTournee: now,
          heureDebut: '',
          heureFin: null,
          status: 'planifiee',
          camion: chauffeur.camion,
          zone: null, // Will be assigned by backend or admin
        ),
      );

      // Refresh and get the newly created tournee
      final tournees = await _chauffeurController.fetchMyTournees(
        showSnackbar: false,
      );
      if (tournees.isNotEmpty) {
        final newTournee =
            tournees.last; // Assuming the last one is the new one
        await _startTour(newTournee);
      }
    } catch (e) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'Échec de création de tournée: ${e.toString()}',
        type: NadiSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: 'Ma tournée',
      child: FutureBuilder<_TourneePageData?>(
        future: _futureTourneeData,
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
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Erreur',
                  subtitle:
                      'Impossible de charger votre tournée.\n${snapshot.error}',
                  action: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureTourneeData = _loadCurrentTourneeData();
                      });
                    },
                    child: const Icon(Icons.refresh),
                  ),
                ),
              ),
            );
          }

          final pageData = snapshot.data;
          final tournee = pageData?.tournee;

          if (tournee == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: EmptyState(
                  icon: Icons.directions_bus_outlined,
                  title: 'Aucune tournée assignée',
                  subtitle:
                      'Commencez une nouvelle tournée ou contactez l\'administration.',
                  action: ElevatedButton(
                    onPressed: _startNewTournee,
                    child: const Icon(Icons.play_arrow),
                  ),
                ),
              ),
            );
          }

          final scheme = Theme.of(context).colorScheme;
          final statusLower = tournee.status.toLowerCase();
          final isStarted =
              statusLower == 'en cours' ||
              statusLower == 'en_cours' ||
              statusLower == 'terminee' ||
              statusLower == 'terminée';
          final isFinished =
              statusLower == 'terminee' || statusLower == 'terminée';
          final geometry = pageData?.geometry;
          final hasRoute = geometry != null && geometry.routePoints.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tournée affectée',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.confirmation_number,
                        label: 'ID Tournée',
                        value: '${tournee.id}',
                        scheme: scheme,
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: tournee.dateTournee.toString().split(' ').first,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.schedule,
                        label: 'Heure début',
                        value: tournee.heureDebut,
                        scheme: scheme,
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.schedule_send,
                        label: 'Heure fin',
                        value: tournee.heureFin ?? 'Non définie',
                        scheme: scheme,
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.flag,
                        label: 'Statut',
                        value: tournee.status,
                        scheme: scheme,
                      ),
                      if (geometry?.profile != null) ...[
                        const Divider(),
                        _InfoRow(
                          icon: Icons.route,
                          label: 'Profil trajet',
                          value: geometry!.profile!,
                          scheme: scheme,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: isStarted ? null : () => _startTour(tournee),
                        child: const Icon(Icons.play_arrow),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isFinished
                            ? null
                            : () => _finishTour(tournee),
                        child: const Icon(Icons.stop),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextButton(
                        onPressed: isFinished
                            ? null
                            : () => _cancelTour(tournee),
                        child: const Icon(Icons.cancel_outlined),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                if (tournee.zone != null) ...[
                  Text(
                    'Zone de collecte',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          icon: Icons.location_on,
                          label: 'Zone',
                          value: tournee.zone!.nomZone,
                          scheme: scheme,
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.category,
                          label: 'Type',
                          value: tournee.zone!.typeZone,
                          scheme: scheme,
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.public,
                          label: 'Latitude',
                          value: tournee.zone!.latitude,
                          scheme: scheme,
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.public,
                          label: 'Longitude',
                          value: tournee.zone!.longitude,
                          scheme: scheme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                if (hasRoute)
                  _TourneeRouteMapCard(
                    title: 'Trajet de la tournée',
                    routePoints: geometry.routePoints,
                    stopPoints: geometry.stopPoints,
                    height: 350,
                  )
                else
                  LocationMapCard(
                    title: 'Carte de la tournée',
                    latitude: tournee.zone?.latitude ?? '',
                    longitude: tournee.zone?.longitude ?? '',
                    markerTitle: tournee.zone?.nomZone ?? 'Zone',
                    markerSubtitle:
                        '${tournee.zone?.latitude ?? '-'}, ${tournee.zone?.longitude ?? '-'}',
                    height: 350,
                  ),

                if ((pageData?.geometryError ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    pageData!.geometryError!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TourneePageData {
  final Tournee tournee;
  final _TourneeGeometry? geometry;
  final String? geometryError;

  const _TourneePageData({
    required this.tournee,
    required this.geometry,
    required this.geometryError,
  });
}

class _AssignedTournee {
  final Tournee tournee;
  final Map<String, dynamic>? geometryPayload;

  const _AssignedTournee({required this.tournee, this.geometryPayload});
}

class _TourneeGeometry {
  final int? idTournee;
  final String? profile;
  final bool returnToDepot;
  final List<LatLng> stopPoints;
  final String? encodedGeometry;
  final List<LatLng> routePoints;

  const _TourneeGeometry({
    required this.idTournee,
    required this.profile,
    required this.returnToDepot,
    required this.stopPoints,
    required this.encodedGeometry,
    required this.routePoints,
  });

  factory _TourneeGeometry.fromJson(Map<String, dynamic> json) {
    final returnToDepot = _toBool(
      json['return_to_depot'] ?? json['returnToDepot'],
    );
    final stops = _sanitizePoints(_parseCoordinates(json['coordinates']));
    final nearestRouteFromStops = _buildNearestNeighborRoute(
      stops,
      closeLoop: returnToDepot,
    );
    final geometryValue = json['geometry'];
    final routeFromGeometry = _sanitizePoints(_parseGeometry(geometryValue));
    final encodedGeometry = geometryValue is String
        ? _toOptionalString(geometryValue)
        : null;
    final decodedRoute = encodedGeometry == null
        ? const <LatLng>[]
        : _sanitizePoints(_decodePolyline(encodedGeometry));

    final mergedRoute = routeFromGeometry.length >= 2
        ? routeFromGeometry
        : (decodedRoute.length >= 2
              ? decodedRoute
              : (nearestRouteFromStops.length >= 2
                    ? nearestRouteFromStops
                    : (routeFromGeometry.isNotEmpty
                          ? routeFromGeometry
                          : (decodedRoute.isNotEmpty
                                ? decodedRoute
                                : nearestRouteFromStops))));

    return _TourneeGeometry(
      idTournee: _toInt(json['id_tournee'] ?? json['idTournee'] ?? json['id']),
      profile: _toOptionalString(json['profile']),
      returnToDepot: returnToDepot,
      stopPoints: stops,
      encodedGeometry: encodedGeometry,
      routePoints: mergedRoute,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    if (value is num) return value != 0;
    return false;
  }

  static String? _toOptionalString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static List<LatLng> _parseCoordinates(dynamic raw) {
    if (raw is! List) return const <LatLng>[];
    final result = <LatLng>[];
    for (final item in raw) {
      if (item is List && item.length >= 2) {
        final lng = _toDouble(item[0]);
        final lat = _toDouble(item[1]);
        if (lat != null && lng != null) {
          result.add(LatLng(lat, lng));
        }
        continue;
      }

      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final lat = _toDouble(map['lat'] ?? map['latitude'] ?? map['y']);
        final lng = _toDouble(
          map['lng'] ?? map['lon'] ?? map['longitude'] ?? map['x'],
        );
        if (lat != null && lng != null) {
          result.add(LatLng(lat, lng));
        }
      }
    }
    return result;
  }

  static bool _isValidPoint(LatLng point) {
    if (!point.latitude.isFinite || !point.longitude.isFinite) return false;
    return point.latitude.abs() <= 90 && point.longitude.abs() <= 180;
  }

  static List<LatLng> _sanitizePoints(List<LatLng> points) {
    final valid = <LatLng>[];
    for (final point in points) {
      if (_isValidPoint(point)) {
        valid.add(point);
      }
    }
    return valid;
  }

  static double _distanceSquared(LatLng a, LatLng b) {
    final dLat = a.latitude - b.latitude;
    final dLng = a.longitude - b.longitude;
    return dLat * dLat + dLng * dLng;
  }

  /// Fallback ordering when backend returns only stop coordinates.
  /// Starts from first point (depot) and greedily visits nearest next point.
  static List<LatLng> _buildNearestNeighborRoute(
    List<LatLng> points, {
    required bool closeLoop,
  }) {
    if (points.length <= 2) {
      if (closeLoop && points.length > 1) {
        return [...points, points.first];
      }
      return List<LatLng>.from(points);
    }

    final route = <LatLng>[points.first];
    final remaining = <LatLng>[...points.skip(1)];

    while (remaining.isNotEmpty) {
      final current = route.last;
      var nearestIndex = 0;
      var nearestDistance = _distanceSquared(current, remaining.first);

      for (var i = 1; i < remaining.length; i++) {
        final d = _distanceSquared(current, remaining[i]);
        if (d < nearestDistance) {
          nearestDistance = d;
          nearestIndex = i;
        }
      }

      route.add(remaining.removeAt(nearestIndex));
    }

    if (closeLoop) {
      route.add(route.first);
    }
    return route;
  }

  static List<LatLng> _parseGeometry(dynamic rawGeometry) {
    if (rawGeometry is String) {
      return _decodePolyline(rawGeometry);
    }

    if (rawGeometry is List) {
      return _parseCoordinates(rawGeometry);
    }

    if (rawGeometry is! Map) {
      return const <LatLng>[];
    }

    final map = Map<String, dynamic>.from(rawGeometry);
    final directCoordinates = _parseCoordinates(map['coordinates']);
    if (directCoordinates.isNotEmpty) {
      return directCoordinates;
    }

    final features = map['features'];
    if (features is List) {
      for (final feature in features) {
        if (feature is Map) {
          final geometry = (feature['geometry'] is Map)
              ? Map<String, dynamic>.from(feature['geometry'])
              : null;
          if (geometry == null) continue;
          final coords = _parseCoordinates(geometry['coordinates']);
          if (coords.isNotEmpty) {
            return coords;
          }
        }
      }
    }

    return const <LatLng>[];
  }

  static List<LatLng> _decodePolyline(String encoded) {
    if (encoded.trim().isEmpty) return const <LatLng>[];
    final precision5 = _decodePolylineWithScale(encoded, 1e5);
    final precision6 = _decodePolylineWithScale(encoded, 1e6);

    final valid5 = _sanitizePoints(precision5);
    final valid6 = _sanitizePoints(precision6);

    if (valid6.length > valid5.length) return valid6;
    return valid5;
  }

  static List<LatLng> _decodePolylineWithScale(String encoded, double scale) {
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
      return const <LatLng>[];
    }

    return points;
  }
}

class _TourneeRouteMapCard extends StatelessWidget {
  final String title;
  final List<LatLng> routePoints;
  final List<LatLng> stopPoints;
  final double height;

  const _TourneeRouteMapCard({
    required this.title,
    required this.routePoints,
    required this.stopPoints,
    this.height = 300,
  });

  LatLng _center(List<LatLng> points) {
    if (points.isEmpty) {
      return const LatLng(33.931269, -5.575555);
    }
    var lat = 0.0;
    var lng = 0.0;
    for (final point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    final count = points.length.toDouble();
    return LatLng(lat / count, lng / count);
  }

  List<LatLng> _markerPoints() {
    if (stopPoints.isNotEmpty) return stopPoints;
    if (routePoints.length <= 1) return routePoints;
    return [routePoints.first, routePoints.last];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final points = routePoints.isNotEmpty ? routePoints : stopPoints;
    final markerPoints = _markerPoints();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ModernCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              height: height,
              child: points.isEmpty
                  ? Container(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      child: Center(
                        child: Text(
                          'Trajet non disponible',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: _center(points),
                        initialZoom: 12.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'clean_way_frontend',
                        ),
                        if (points.length >= 2)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: points,
                                strokeWidth: 5,
                                color: scheme.primary,
                              ),
                            ],
                          ),
                        if (markerPoints.isNotEmpty)
                          MarkerLayer(
                            markers: List.generate(markerPoints.length, (
                              index,
                            ) {
                              final isStart = index == 0;
                              final isEnd = index == markerPoints.length - 1;
                              final color = isStart
                                  ? const Color(0xFF16A34A)
                                  : (isEnd
                                        ? const Color(0xFFDC2626)
                                        : scheme.primary);
                              final icon = isStart
                                  ? Icons.play_circle
                                  : (isEnd
                                        ? Icons.flag_circle
                                        : Icons.location_pin);
                              final label = isStart
                                  ? 'Départ'
                                  : (isEnd ? 'Arrivée' : 'Point ${index + 1}');

                              return Marker(
                                width: 36,
                                height: 36,
                                point: markerPoints[index],
                                child: Tooltip(
                                  message: label,
                                  child: Icon(icon, color: color, size: 34),
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
