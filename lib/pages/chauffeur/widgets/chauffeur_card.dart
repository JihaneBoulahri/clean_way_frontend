import 'package:flutter/material.dart';
import '../../../services/chauffeur_service.dart';
import '../../../models/chauffeur_model.dart';
import '../controllers/chauffeur_controller.dart';

class ChauffeurCard extends StatelessWidget {
  final Chauffeur chauffeur;
  final VoidCallback onDelete;

  const ChauffeurCard({super.key, required this.chauffeur, required this.onDelete});

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
              chauffeur.userId.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('CNI: ${chauffeur.cni}'),
            Text('permis: ${chauffeur.permis}'),
            Text('Téléphone: ${chauffeur.numTelephone}'),
            Text('Camion ID: ${chauffeur.idCamion ?? "Aucun"}'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Supprimer',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
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