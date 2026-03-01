import 'package:flutter/material.dart';
import '../../../services/camion_service.dart';
import '../../../models/camion_model.dart';
import '../controllers/camion_controller.dart';

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
            Text('Status: ${camion.status}'),
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

  // Méthode utilitaire pour formater la date (à adapter selon vos besoins)
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}