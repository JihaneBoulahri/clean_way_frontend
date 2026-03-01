import 'package:flutter/material.dart';
import '../../../models/camion_model.dart';

class CamionCard extends StatelessWidget {
  final Camion camion;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CamionCard({
    super.key,
    required this.camion,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              camion.immatriculation,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Type: ${camion.typeCamion}'),
            Text('Capacité: ${camion.capaciteCamion} m³'),
            if (camion.dateMiseEnService != null)
              Text(
                'Mise en service: ${_formatDate(camion.dateMiseEnService!)}',
              ),
            Text('Statut: ${camion.status}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('Modifier'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 20),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}