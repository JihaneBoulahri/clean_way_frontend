import 'package:flutter/material.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        StatCard(
          icon: Icons.delete_outline,
          title: "Total Bins",
          value: stats['total_bennes'].toString(),
          color: Colors.blue,
        ),
        StatCard(
          icon: Icons.local_shipping,
          title: "Active Trucks",
          value: stats['total_camions'].toString(),
          color: Colors.green,
        ),
        StatCard(
          icon: Icons.warning_amber_rounded,
          title: "Full Bins",
          value: stats['bennes_pleines'].toString(),
          color: Colors.red,
        ),
        StatCard(
          icon: Icons.check_circle_outline,
          title: "Collected Today",
          value: stats['tournees_aujourdhui'].toString(),
          color: Colors.teal,
        ),
      ],
    );
  }
}