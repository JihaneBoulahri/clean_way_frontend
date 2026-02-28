import 'package:flutter/material.dart';
import '../../../services/tournee_service.dart';
import '../../../models/tournee_model.dart';
import '../controllers/tournee_controller.dart';

class TourneeCard extends StatelessWidget {
  final Tournee tournee;
  final VoidCallback onDelete;

  const TourneeCard({super.key, required this.tournee, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affiche le nom de la tournée comme titre
            Text(
              'Tournée ${tournee.id}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            //affiche la date de la tournée
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
              Text('  Capacité: ${tournee.camion!.capaciteCamion} kg'),
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