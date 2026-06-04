import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:flutter/material.dart';
import '../../../core/services/chauffeur_service.dart';
import '../models/tournee_model.dart';
import '../widgets/tournee_card.dart';
import '../../../core/theme/app_theme.dart';

class TourneeChauffeurHistoryPage extends StatefulWidget {
  const TourneeChauffeurHistoryPage({super.key});

  @override
  State<TourneeChauffeurHistoryPage> createState() =>
      _TourneeChauffeurHistoryPageState();
}

class _TourneeChauffeurHistoryPageState
    extends State<TourneeChauffeurHistoryPage> {
  final ChauffeurService _service = ChauffeurService();
  late Future<List<Tournee>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = _loadHistory();
  }

  Future<List<Tournee>> _loadHistory() async {
    final data = await _service.getMyTournees();
    final tournees = data.map((json) => Tournee.fromJson(json)).toList();
    final completed = tournees.where(_isCompleted).toList();
    completed.sort((a, b) => b.dateTournee.compareTo(a.dateTournee));
    return completed;
  }

  bool _isCompleted(Tournee tournee) {
    final normalized = tournee.status
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');
    return normalized.contains('term') ||
        normalized.contains('fin') ||
        normalized.contains('done') ||
        normalized.contains('complete');
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: 'Historique',
      child: FutureBuilder<List<Tournee>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Erreur',
                subtitle:
                    'Impossible de charger l\'historique.\n${snapshot.error}',
                action: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _futureHistory = _loadHistory();
                    });
                  },
                  child: const Icon(Icons.refresh),
                ),
              ),
            );
          }

          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: EmptyState(
                icon: Icons.history,
                title: 'Aucune tournée terminée',
                subtitle:
                    'Quand vous terminez une tournée, elle apparaitra ici.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final tournee = history[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: TourneeCard(tournee: tournee, enableNavigation: false),
              );
            },
          );
        },
      ),
    );
  }
}
