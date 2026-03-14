import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../controllers/dashboard_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppLayout(
      pageName: 'Dashboard',
      child: SafeArea(
        child: Obx(() {
          if (controller.stats_loading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.stats_error.value != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  controller.stats_error.value!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error),
                ),
              ),
            );
          }

          final stats = controller.stats.value;
          if (stats == null) {
            return Center(
              child: Text(
                'Aucune statistique disponible.',
                style: TextStyle(color: scheme.onSurface),
              ),
            );
          }

          final canOptimise = _isAdmin();

          return RefreshIndicator(
            onRefresh: controller.fetchStats,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _HeroBanner(
                  stats: stats,
                  canOptimise: canOptimise,
                  isOptimising: controller.optimisation_loading.value,
                  onOptimiser: controller.optimiser,
                ),
                const SizedBox(height: 14),
                _PerformancePanel(stats: stats),
                const SizedBox(height: 14),
                _StatsWrap(stats: stats),
                const SizedBox(height: 14),
                _OperationsInsights(stats: stats),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool canOptimise;
  final bool isOptimising;
  final VoidCallback onOptimiser;

  const _HeroBanner({
    required this.stats,
    required this.canOptimise,
    required this.isOptimising,
    required this.onOptimiser,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = _readUserName();
    final totalAssets = _toInt(stats['total_zones']) +
        _toInt(stats['total_bennes']) +
        _toInt(stats['total_camions']) +
        _toInt(stats['total_chauffeurs']);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.95),
            const Color(0xFF0EA5E9).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.waving_hand_rounded, color: scheme.onPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bonjour, $user',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Bonne journee de travail! ',
            style: TextStyle(
              color: scheme.onPrimary.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          if (canOptimise) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: isOptimising ? null : onOptimiser,
                icon: isOptimising
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                    : const Icon(Icons.auto_graph_rounded, size: 18),
                label: Text(isOptimising ? 'Optimisation...' : 'Optimiser les tournees'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.onPrimary,
                  foregroundColor: scheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PerformancePanel extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _PerformancePanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fullRate = _toInt(stats['taux_de_bennes_pleines']).clamp(0, 100);
    final fillAverage = _toInt(stats['niveau_remplissage_moyen']).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance du jour',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _RingMetric(
                  label: 'Bennes pleines',
                  value: fullRate,
                  color: fullRate >= 70
                      ? const Color(0xFFDC2626)
                      : fullRate >= 40
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RingMetric(
                  label: 'Remplissage moyen',
                  value: fillAverage,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingMetric extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _RingMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 8,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.2),
                ),
                Text(
                  '$value%',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsWrap extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsWrap({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = <_Kpi>[
      _Kpi(Icons.map_outlined, 'Zones', _toInt(stats['total_zones']), const Color(0xFF0EA5E9)),
      _Kpi(Icons.delete_outline, 'Bennes', _toInt(stats['total_bennes']), const Color(0xFF16A34A)),
      _Kpi(Icons.local_shipping_outlined, 'Camions', _toInt(stats['total_camions']), const Color(0xFFF97316)),
      _Kpi(Icons.person_outline, 'Chauffeurs', _toInt(stats['total_chauffeurs']), const Color(0xFF7C3AED)),
      _Kpi(Icons.route_outlined, 'Tournees', _toInt(stats['total_tournees']), const Color(0xFFDC2626)),
      _Kpi(Icons.today_outlined, 'Aujourdhui', _toInt(stats['tournees_aujourdhui']), const Color(0xFF2563EB)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cards
              .map((e) => SizedBox(width: width, child: _MiniStatCard(item: e)))
              .toList(),
        );
      },
    );
  }
}

class _Kpi {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _Kpi(this.icon, this.label, this.value, this.color);
}

class _MiniStatCard extends StatelessWidget {
  final _Kpi item;

  const _MiniStatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value.toString(),
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationsInsights extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _OperationsInsights({required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sensorsActive = _toInt(stats['capteurs_actifs']);
    final sensorsInactive = _toInt(stats['capteurs_inactifs']);
    final totalSensors = _toInt(stats['total_capteurs']);
    final camionsDisponibles = _toInt(stats['camions_disponibles']);
    final camionsCollecte = _toInt(stats['camions_en_collecte']);
    final camionsHs = _toInt(stats['camions_hors_service']);
    final criticalBins = _toInt(stats['bennes_critique']);

    final rawWeek = stats['tournees_7_derniers_jours'];
    final weekly = (rawWeek is List ? rawWeek : const [])
        .map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Etat operationnel',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InsightTile(
                  icon: Icons.sensors_rounded,
                  title: 'Capteurs',
                  value: '$sensorsActive / $totalSensors actifs',
                  subtitle: '$sensorsInactive inactif(s)',
                  tone: sensorsInactive == 0
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Camions',
                  value: '$camionsDisponibles disponibles',
                  subtitle: '$camionsCollecte en collecte | $camionsHs HS',
                  tone: camionsHs > 0
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _WeeklyToursBars(data: weekly),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color tone;

  const _InsightTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: tone),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyToursBars extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _WeeklyToursBars({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final parsed = data
        .map((e) => _DayTours(
              date: e['date']?.toString() ?? '',
              total: _toInt(e['total']),
            ))
        .toList();

    final max = parsed.isEmpty
        ? 1
        : parsed.map((e) => e.total).fold<int>(1, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tournees - 7 derniers jours',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ${parsed.fold<int>(0, (sum, d) => sum + d.total)}',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (parsed.isEmpty)
            Text(
              'Pas de donnees hebdomadaires.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            )
          else
            SizedBox(
              height: 148,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: parsed
                    .map(
                      (e) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                e.total.toString(),
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 92,
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                  height: ((e.total / max) * 92).clamp(6, 92).toDouble(),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color(0xFF2563EB),
                                        Color(0xFF60A5FA),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _shortDate(e.date),
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayTours {
  final String date;
  final int total;

  const _DayTours({required this.date, required this.total});
}

String _shortDate(String raw) {
  if (raw.length < 10) return raw;
  final d = raw.substring(8, 10);
  final m = raw.substring(5, 7);
  return '$d/$m';
}

String _readUserName() {
  final raw = GetStorage().read('user');
  if (raw is Map) {
    final nom = raw['nom']?.toString().trim() ?? '';
    final prenom = raw['prenom']?.toString().trim() ?? '';
    final full = '$prenom $nom'.trim();
    if (full.isNotEmpty) return full;
  }
  return 'Utilisateur';
}

bool _isAdmin() {
  final raw = GetStorage().read('user');
  if (raw is Map) {
    final role = raw['role'] ?? raw['roles'];
    if (role is String) {
      return role.toLowerCase().contains('admin');
    }
    if (role is List) {
      return role.any((e) => e.toString().toLowerCase().contains('admin'));
    }
  }
  return false;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
