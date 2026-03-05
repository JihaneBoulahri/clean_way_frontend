import 'package:flutter/material.dart';
import '../../../models/tournee_model.dart';

class TourneeCard extends StatelessWidget {
  final Tournee tournee;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TourneeCard({
    super.key,
    required this.tournee,
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
              'Tournée ${tournee.id}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Date: ${tournee.dateTournee.toString().split(' ').first}'),
            Text('Heure de début: ${tournee.heureDebut}'),
            Text('Heure de fin: ${tournee.heureFin ?? "—"}'),
            Text('Statut: ${tournee.status}'),
            if (tournee.camion != null) ...[
              const SizedBox(height: 8),
              Text(
                'Camion: ${tournee.camion!.immatriculation}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('  Type: ${tournee.camion!.typeCamion}'),
              Text('  Capacité: ${tournee.camion!.capaciteCamion} m³'),
              Text('  Statut: ${tournee.camion!.status}'),
            ],
            if (tournee.zone != null) ...[
              const SizedBox(height: 8),
              Text(
                'Zone: ${tournee.zone!.nomZone}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('  Type: ${tournee.zone!.typeZone}'),
              Text('  Coordonnées: ${tournee.zone!.latitude}, ${tournee.zone!.longitude}'),
            ],
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}