import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme/app_theme.dart';
import 'modern_widgets.dart';

class LocationMapCard extends StatelessWidget {
  final String title;
  final String latitude;
  final String longitude;
  final String markerTitle;
  final String? markerSubtitle;
  final double height;

  const LocationMapCard({
    super.key,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.markerTitle,
    this.markerSubtitle,
    this.height = 300,
  });

  LatLng? _parseCoordinates() {
    final lat = double.tryParse(latitude.trim());
    final lng = double.tryParse(longitude.trim());
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final point = _parseCoordinates();

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
              child: point == null
                  ? _MapUnavailableState(
                      message: 'Coordonnées non disponibles ou invalides',
                    )
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: point,
                        initialZoom: 14,
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
                              width: 44,
                              height: 44,
                              point: point,
                              child: Tooltip(
                                message: markerSubtitle == null
                                    ? markerTitle
                                    : '$markerTitle\n$markerSubtitle',
                                child: Icon(
                                  Icons.location_pin,
                                  size: 40,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ],
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

class _MapUnavailableState extends StatelessWidget {
  final String message;

  const _MapUnavailableState({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
