import 'package:flutter/material.dart';
import '../../../models/chauffeur_model.dart';

class ChauffeurCard extends StatelessWidget {
  final Chauffeur chauffeur;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ChauffeurCard({
    super.key,
    required this.chauffeur,
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
              chauffeur.user != null
                  ? chauffeur.user!.fullName
                  : 'Chauffeur #${chauffeur.id}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('CNI: ${chauffeur.cni}'),
            Text('Permis: ${chauffeur.permis}'),
            Text('Téléphone: ${chauffeur.numTelephone}'),
            Text('Camion: ${chauffeur.camion?.immatriculation ?? 'Aucun'}'),
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
}