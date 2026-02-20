import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height; 

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value != null) {
          return Center(child: Text(controller.error.value!));
        }

        if (controller.stats.value == null) {
          return const Center(child: Text('No data'));
        }

        final stats = controller.stats.value!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statistics',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    double width = constraints.maxWidth;
                    int columns;
                    double spacing;
                    double runSpacing;

                    if (width < 600) {
                      columns = 1;
                      spacing = 8;
                      runSpacing = 12;
                    } else if (width < 900) {
                      columns = 2;
                      spacing = 16;
                      runSpacing = 16;
                    } else {
                      columns = 4;
                      spacing = 24;
                      runSpacing = 24;
                    }

                    return Wrap(
                      spacing: spacing,
                      runSpacing: runSpacing,
                      children: [
                        _statCard('Zones', stats['total_zones']),
                        _statCard('Bennes', stats['total_bennes']),
                        _statCard('Bennes Pleines', stats['bennes_pleines']),
                        _statCard('Bennes Vides', stats['bennes_vides']),
                        _statCard('Chauffeurs', stats['total_chauffeurs']),
                        _statCard('Camions', stats['total_camions']),
                        _statCard('Tournees', stats['total_tournees']),
                        _statCard('Tournees Aujourd’hui', stats['tournees_aujourdhui']),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                Text('Bennes Chart',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                _bennesPieChart(stats),

                const SizedBox(height: 32),

                Text('Tournees Chart',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                _tourneesBarChart(stats),
              ],
            ),
          );
      }),
    );
  }

  Widget _statCard(String title, dynamic value) {
    return Card(
      elevation: 3,
      child: Container(
        width: 150,
        height: 90,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value?.toString() ?? '-',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _bennesPieChart(Map<String, dynamic> stats) {
    final pleines = (stats['bennes_pleines'] ?? 0).toDouble();
    final vides = (stats['bennes_vides'] ?? 0).toDouble();
    final total = (stats['total_bennes'] ?? 0).toDouble();
    final autres = (total - pleines - vides).clamp(0, total);

    if (total == 0) {
      return const Center(child: Text("Aucune donnée"));
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: pleines,
              color: Colors.green,
              title: 'Pleines',
            ),
            PieChartSectionData(
              value: vides,
              color: Colors.blue,
              title: 'Vides',
            ),
            PieChartSectionData(
              value: autres.toDouble(),
              color: Colors.grey,
              title: 'Autres',
            ),
          ],
        ),
      ),
    );
  }

  Widget _tourneesBarChart(Map<String, dynamic> stats) {
    final total =
        (stats['total_tournees'] ?? 0).toDouble();
    final today =
        (stats['tournees_aujourdhui'] ?? 0).toDouble();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: total,
                  color: Colors.orange,
                  width: 25,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: today,
                  color: Colors.purple,
                  width: 25,
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Total');
                    case 1:
                      return const Text('Aujourd’hui');
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
