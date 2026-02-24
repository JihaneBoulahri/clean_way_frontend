import 'package:flutter/material.dart';
import 'activity_tile.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ActivityTile(
          id: "BIN-A-2341",
          percent: "95%",
          status: "Collected",
          color: Colors.green,
        ),
        ActivityTile(
          id: "BIN-B-1823",
          percent: "100%",
          status: "Full",
          color: Colors.red,
        ),
        ActivityTile(
          id: "BIN-C-4521",
          percent: "85%",
          status: "Warning",
          color: Colors.orange,
        ),
      ],
    );
  }
}