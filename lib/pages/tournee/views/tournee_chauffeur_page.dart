import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/location_map_card.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/tournee_model.dart';
import '../../chauffeur/controllers/chauffeur_controller.dart';
import '../../../core/services/tournee_service.dart';
import '../../../widgets/snackbar_helper.dart';

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
  late Future<Tournee?> _futureTournee;

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
      return tournees.first;
    } catch (e) {
      final message = e.toString();
      if (!message.contains('404')) {
        // MODIFIÉ
        showNadiSnackbar(
          title: "Erreur",
          message: "Impossible de charger la tournée actuelle.",
          type: NadiSnackbarType.error,
        );
      }
      return null;
    }
  }

  Future<void> _startTour(Tournee tournee) async {
    try {
      await _tourneeService.start(tournee.id);

      showNadiSnackbar(
        title: "Succès",
        message: "Tournée démarrée",
        type: NadiSnackbarType.success,
      );
      setState(() {
        _futureTournee = _loadCurrentTournee();
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
      setState(() {
        _futureTournee = _loadCurrentTournee();
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
      setState(() {
        _futureTournee = _loadCurrentTournee();
      });
    } catch (e) {
      showNadiSnackbar(
        title: "Erreur",
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    }
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
          final statusLower = tournee.status.toLowerCase();
          final isStarted =
              statusLower == 'en cours' ||
              statusLower == 'en_cours' ||
              statusLower == 'terminee' ||
              statusLower == 'terminée';
          final isFinished =
              statusLower == 'terminee' || statusLower == 'terminée';

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
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isFinished
                            ? null
                            : () => _finishTour(tournee),
                        icon: const Icon(Icons.stop),
                        label: const Text('Terminer'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: isFinished
                            ? null
                            : () => _cancelTour(tournee),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Annuler'),
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

                LocationMapCard(
                  title: 'Carte de la tournée',
                  latitude: tournee.zone?.latitude ?? '',
                  longitude: tournee.zone?.longitude ?? '',
                  markerTitle: tournee.zone?.nomZone ?? 'Zone',
                  markerSubtitle:
                      '${tournee.zone?.latitude ?? '-'}, ${tournee.zone?.longitude ?? '-'}',
                  height: 350,
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
