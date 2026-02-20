import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/api_service.dart';
import '../../models/tournee_model.dart';
import '../../models/benne_model.dart';
import '../../models/releve_model.dart';
import '../../models/capteur_model.dart';
import 'dashboard_navbar.dart';
import 'dashboard_sidebar.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color background = Color(0xFFF9F2F7);

  bool _isSidebarVisible = false;

  // Exemple de données utilisateur – remplacez par vos vraies données.
  final String _firstName = 'Amina';
  final String _lastName = 'Driver';
  final String _email = 'amina.driver@example.com';
  final String _phone = '+212 6 00 00 00 00';

  List<Tournee> _tournees = [];
  List<Benne> _bennes = [];
  List<Releve> _releves = [];
  List<Capteur> _capteurs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tournees = await ApiService.fetchTournees();
      final bennes = await ApiService.fetchBennes();
      final releves = await ApiService.fetchReleves();
      final capteurs = await ApiService.fetchCapteurs();
      setState(() {
        _tournees = tournees;
        _bennes = bennes;
        _releves = releves;
        _capteurs = capteurs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _tournees = [];
        _bennes = [];
        _releves = [];
        _capteurs = [];
        _loading = false;
        final errorMsg = e.toString();
        if (errorMsg.contains('Connection refused') ||
            errorMsg.contains('SocketException') ||
            errorMsg.contains('ClientException') ||
            errorMsg.contains('Failed host lookup') ||
            errorMsg.contains('TimeoutException') ||
            errorMsg.contains('Serveur inaccessible')) {
          _error = 'Serveur inaccessible. Vérifiez que le backend est démarré sur http://127.0.0.1:8000';
        } else {
          _error = errorMsg;
        }
      });
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  List<Tournee> get _todayTournees {
    final now = DateTime.now();
    return _tournees
        .where((t) =>
            t.dateTournee.year == now.year &&
            t.dateTournee.month == now.month &&
            t.dateTournee.day == now.day)
        .toList();
  }

  bool _isTourneeDone(String statut) {
    final s = statut.toLowerCase().trim();
    return s.contains('term') || s.contains('done') || s.contains('finish') || s == 'completed';
  }

  List<_DailyPoint> get _dailyFillSeries {
    // Moyenne journalière des relevés (valeur), sur les 7 derniers jours.
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final byDay = <DateTime, List<double>>{};
    for (final r in _releves) {
      final d = DateTime(r.date.year, r.date.month, r.date.day);
      if (d.isBefore(start)) continue;
      (byDay[d] ??= []).add(r.valeur);
    }

    final points = <_DailyPoint>[];
    for (int i = 0; i < 7; i++) {
      final d = start.add(Duration(days: i));
      final vals = byDay[d];
      final avg = (vals == null || vals.isEmpty)
          ? null
          : (vals.reduce((a, b) => a + b) / vals.length);
      points.add(_DailyPoint(date: d, value: avg));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: const DashboardBottomBar(
        primaryColor: primaryGreen,
        appName: 'Clean Way',
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Contenu principal avec navbar + dashboard
                Column(
                  children: [
                    DashboardNavbar(
                      primaryColor: primaryGreen,
                      firstName: _firstName,
                      lastName: _lastName,
                      email: _email,
                      phone: _phone,
                      onRefresh: _loading ? null : _loadData,
                      onToggleSidebar: _toggleSidebar,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(),
                              if (_error != null) _buildErrorBanner(),
                              const SizedBox(height: 20),
                              _buildSectionTitle('Ma distribution du jour', Icons.today),
                              _buildDailyDistributionCard(),
                              const SizedBox(height: 16),
                              _buildSectionTitle('Le parcours', Icons.route),
                              _buildRouteCard(),
                              const SizedBox(height: 16),
                              _buildSectionTitle('Les conteneurs', Icons.delete_outline),
                              _buildContainersCard(),
                              const SizedBox(height: 16),
                              _buildSectionTitle('Statut', Icons.info_outline),
                              _buildStatusCard(),
                              const SizedBox(height: 16),
                              _buildSectionTitle('Total', Icons.donut_large),
                              _buildTotalCard(),
                              const SizedBox(height: 16),
                              _buildSectionTitle(
                                'Niveau de remplissage par jour',
                                Icons.show_chart,
                              ),
                              _buildFillLevelCard(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Sidebar qui glisse par-dessus, comme un drawer
                if (_isSidebarVisible)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _toggleSidebar,
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 260,
                          child: Material(
                            elevation: 8,
                            child: DashboardSidebar(
                              primaryColor: primaryGreen,
                              onItemSelected: (String route) {
                                // Ferme le menu, puis gère la navigation si besoin.
                                _toggleSidebar();
                                // TODO: navigation selon "route".
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.dashboard, color: primaryGreen, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Chauffeur',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: primaryGreen,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Vue d\'ensemble',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryGreen),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDailyDistributionCard() {
    final list = _todayTournees;
    return _buildCard(
      child: list.isEmpty
          ? _placeholder(
              'Aucune tournée prévue aujourd\'hui.',
              Icons.event_busy,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: primaryGreen, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${t.heureDebut} – ${t.heureFin} • ${t.statut}',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildRouteCard() {
    return _buildCard(
      child: _placeholder(
        'Votre itinéraire du jour s\'affichera ici.',
        Icons.map_outlined,
      ),
    );
  }

  Widget _buildContainersCard() {
    return _buildCard(
      child: _bennes.isEmpty
          ? _placeholder(
              'Aucune benne / conteneur assignée.',
              Icons.inbox_outlined,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _bennes.take(5).map((b) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: primaryGreen, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${b.typeBenne} • ${b.position} (${b.niveauRemplissage.toStringAsFixed(0)}%)',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildStatusCard() {
    final list = _todayTournees;
    final status = list.isEmpty
        ? 'Aucune tournée'
        : list.first.statut;
    return _buildCard(
      child: Row(
        children: [
          Icon(
            list.isEmpty ? Icons.pending : Icons.local_shipping,
            color: primaryGreen,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'État actuel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    final today = _todayTournees;
    final doneCount = today.where((t) => _isTourneeDone(t.statut)).length;
    final totalCount = today.length;
    final remaining = (totalCount - doneCount).clamp(0, totalCount).toDouble();
    final done = doneCount.toDouble();

    return _buildCard(
      child: SizedBox(
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    value: done == 0 && remaining == 0 ? 1 : done,
                    color: primaryGreen,
                    radius: 26,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: done == 0 && remaining == 0 ? 0 : remaining,
                    color: Colors.grey.shade200,
                    radius: 26,
                    title: '',
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  totalCount.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    color: Colors.grey[900],
                  ),
                ),
                Text(
                  'tournées',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  totalCount == 0 ? 'Aucune tournée' : '$doneCount terminée(s)',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillLevelCard() {
    final series = _dailyFillSeries;
    final yValues = series.where((p) => p.value != null).map((p) => p.value!).toList();
    final minY = yValues.isEmpty ? 0.0 : yValues.reduce((a, b) => a < b ? a : b);
    final maxY = yValues.isEmpty ? 100.0 : yValues.reduce((a, b) => a > b ? a : b);
    final paddedMinY = (minY - 5).clamp(0.0, double.infinity);
    final paddedMaxY = (maxY + 5).clamp(1.0, double.infinity);

    return _buildCard(
      child: SizedBox(
        height: 240,
        child: yValues.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.show_chart, color: Colors.grey.shade400, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune donnée',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              )
            : LineChart(
                LineChartData(
                  minY: paddedMinY,
                  maxY: paddedMaxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= series.length) return const SizedBox();
                          final d = series[i].date;
                          final label = '${d.day}/${d.month}';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: TextStyle(color: Colors.grey[600], fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: primaryGreen,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: primaryGreen.withOpacity(0.12),
                      ),
                      spots: [
                        for (int i = 0; i < series.length; i++)
                          if (series[i].value != null) FlSpot(i.toDouble(), series[i].value!.toDouble()),
                      ],
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 250),
              ),
      ),
    );
  }

  // _benneFillSeries removed — section disabled by user request

  // _buildBennesFillLevelCard removed — section disabled by user request

  Widget _placeholder(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// _BenneSeries removed

class _DailyPoint {
  final DateTime date;
  final double? value;
  const _DailyPoint({required this.date, required this.value});
}
