import 'package:flutter/material.dart';
import '../../../services/zone_service.dart';
import '../../../models/zone_model.dart';
import '../controllers/zone_controller.dart';

class ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback onDelete;

  const ZoneCard({super.key, required this.zone, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affiche le nom de la zone comme titre
            Text(
              'Zone ${zone.nomZone}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            //affiche le type de la zone
            Text('Type: ${zone.typeZone}'),

            // Affiche les coordonnées de la zone
            Text('Coordonnées: (${zone.latitude}, ${zone.longitude})'),

            const SizedBox(height: 12),

            // Bouton de suppression
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
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
            ),
          ],
        ),
      ),
    );
  }
}