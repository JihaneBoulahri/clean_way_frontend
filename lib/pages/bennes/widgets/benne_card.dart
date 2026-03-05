import 'package:flutter/material.dart';
import '../../../models/benne_model.dart';

class BenneCard extends StatelessWidget {
  final Benne benne;
  final double fillLevel; // from capteur (0 - 100)
  final String locationName; // example: Downtown, 5th Avenue
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BenneCard({
    super.key,
    required this.benne,
    required this.fillLevel,
    required this.locationName,
    required this.onDelete,
    required this.onEdit,
  });

  Color getStatusColor() {
    if (fillLevel >= 70) return Colors.red;
    if (fillLevel >= 50) return Colors.orange;
    return Colors.green;
  }

  String getStatusText() {
    if (fillLevel >= 90) return "Critical";
    if (fillLevel >= 70) return "Warning";
    return "Normal";
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benne ${benne.typeBenne}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Capacité: ${benne.capacite} m³'),
            Text(
              'Position: (${benne.latitude}, ${benne.longitude})',
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Modifier',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outlined),
                  tooltip: 'Supprimer',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
                Text(
                  getStatusText(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                  ),
                ),
                ],
              ),
            ],
          )

          const SizedBox(height: 16),

          /// PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: fillLevel / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),

          const SizedBox(height: 12),

          /// ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.white70),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            ],
          ),
      ),
    );
  }
}