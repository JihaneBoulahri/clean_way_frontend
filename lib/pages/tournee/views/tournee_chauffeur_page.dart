import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

import '../../../models/tournee_model.dart';
import '../../../models/zone_model.dart';
import '../../../services/tournee_service.dart';

class TourneeChauffeurPage extends StatefulWidget {
  const TourneeChauffeurPage({super.key});

  @override
  State<TourneeChauffeurPage> createState() => _TourneeChauffeurPageState();
}

class _TourneeChauffeurPageState extends State<TourneeChauffeurPage> {
  final TourneeService _service = TourneeService();
  late Future<Tournee?> _futureTournee;

  @override
  void initState() {
    super.initState();
    _futureTournee = _loadCurrentTournee();
  }

  Future<Tournee?> _loadCurrentTournee() async {
    try {
      final data = await _service.getCurrentForChauffeur();
      if (data == null) return null;
      if (data is List && data.isNotEmpty) {
        return Tournee.fromJson(data.first);
      }
      if (data is Map<String, dynamic>) {
        return Tournee.fromJson(data);
      }
      if (data is Map) {
        return Tournee.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
      return null;
    }
  }

  Future<void> _startTour(Tournee tournee) async {
    try {
      final now = TimeOfDay.now();
      final formattedTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final updated = Tournee(
        id: tournee.id,
        dateTournee: tournee.dateTournee,
        heureDebut: tournee.heureDebut.isNotEmpty ? tournee.heureDebut : formattedTime,
        heureFin: tournee.heureFin,
        status: 'en_cours',
        camion: tournee.camion,
        zone: tournee.zone,
      );

      await _service.update(tournee.id, updated.toJson());

      Get.snackbar('Succès', 'Tournée démarrée');
      setState(() {
        _futureTournee = _loadCurrentTournee();
      });
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> _finishTour(Tournee tournee) async {
    try {
      final now = TimeOfDay.now();
      final formattedTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final updated = Tournee(
        id: tournee.id,
        dateTournee: tournee.dateTournee,
        heureDebut: tournee.heureDebut.isNotEmpty ? tournee.heureDebut : formattedTime,
        heureFin: formattedTime,
        status: 'terminee',
        camion: tournee.camion,
        zone: tournee.zone,
      );

      await _service.update(tournee.id, updated.toJson());

      Get.snackbar('Succès', 'Tournée terminée');
      setState(() {
        _futureTournee = _loadCurrentTournee();
      });
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }

  LatLng? _parseLatLng(Zone? zone) {
    if (zone == null) return null;
    final lat = double.tryParse(zone.latitude);
    final lng = double.tryParse(zone.longitude);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: 'Ma tournée',
      child: FutureBuilder<Tournee?>(
        future: _futureTournee,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Erreur',
                  subtitle: 'Impossible de charger votre tournée.\n${snapshot.error}',
                  action: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _futureTournee = _loadCurrentTournee();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ),
              ),
            );
          }

          final tournee = snapshot.data;

          if (tournee == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: EmptyState(
                  icon: Icons.directions_bus_outlined,
                  title: 'Aucune tournée assignée',
                  subtitle:
                      'Aucune tournée optimisée ne vous est actuellement assignée.\nVeuillez contacter l\'administration si le problème persiste.',
                ),
              ),
            );
          }

          final scheme = Theme.of(context).colorScheme;
          final position = _parseLatLng(tournee.zone);
          final statusLower = tournee.status.toLowerCase();
          final isStarted =
              statusLower == 'en_cours' || statusLower == 'terminee' || statusLower == 'terminée';
          final isFinished = statusLower == 'terminee' || statusLower == 'terminée';

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

                // Infos principales
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
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isStarted ? null : () => _startTour(tournee),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Démarrer'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isFinished ? null : () => _finishTour(tournee),
                        icon: const Icon(Icons.stop),
                        label: const Text('Terminer'),
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

                // Carte Google Maps
                Text(
                  'Carte de la tournée',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: scheme.outline.withOpacity(0.3)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: position == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_outlined,
                                    size: 48, color: scheme.onSurfaceVariant),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Coordonnées non disponibles ou invalides',
                                  style:
                                      TextStyle(color: scheme.onSurfaceVariant),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: position,
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('tournee_zone'),
                              position: position,
                              infoWindow: InfoWindow(
                                title: tournee.zone?.nomZone ?? 'Zone',
                                snippet:
                                    '${tournee.zone?.latitude}, ${tournee.zone?.longitude}',
                              ),
                            ),
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: true,
                        ),
                ),
              ],
            ),
          );
        },
      ),
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
                    color: scheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

