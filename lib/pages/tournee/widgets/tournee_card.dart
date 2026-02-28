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
            Text('Date: ${tournee.dateTournee}'),
            Text('heure de début: ${tournee.heureDebut}'),
            Text('heure de fin: ${tournee.heureFin}'),
            Text('status: ${tournee.statut}'),

            // Affiche les zones associées à la tournée
            Text('Zones associées au camion: ${tournee.idCamion}'),
            Text('Zones associées à la tournée: ${tournee.id_zone}'),

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