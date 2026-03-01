import 'package:flutter/material.dart';
import '../../../services/benne_service.dart';
import '../../../models/benne_model.dart';
import '../controllers/benne_controller.dart';

class BenneCard extends StatelessWidget {
  final Benne benne;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BenneCard({
    super.key,
    required this.benne,
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
            // Affiche le type comme titre (ou id si disponible)
            Text(
              'Benne ${benne.typeBenne}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Capacité
            Text('Capacité: ${benne.capacite} m³'),

            // Coordonnées (latitude / longitude)
            Text(
              benne.latitude != null && benne.longitude != null
                  ? 'Position: (${benne.latitude}, '
                    '${benne.longitude})'
                  : 'Position: Non renseignée',
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                        const SizedBox(width: 4),
                        Text('Modifier', style: TextStyle(color: Colors.blue.shade700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                        const SizedBox(width: 4),
                        Text('Supprimer', style: TextStyle(color: Colors.red.shade700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}