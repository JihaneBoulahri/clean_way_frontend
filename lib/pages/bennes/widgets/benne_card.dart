import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/benne_model.dart';
import '../../../routes/app_routes.dart';

class BenneCard extends StatelessWidget {
  final Benne benne;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onAddCapteur;
  final bool showActions;

  const BenneCard({
    super.key,
    required this.benne,
    required this.onDelete,
    required this.onEdit,
    this.onAddCapteur,
    this.showActions = true,
  });

  Color _getStatusColor(double fillLevel) {
    if (fillLevel >= 70) return Colors.red;
    if (fillLevel >= 50) return Colors.orange;
    return Colors.green;
  }

  String _getStatusText(double fillLevel) {
    if (fillLevel >= 90) return 'Critical';
    if (fillLevel >= 70) return 'Warning';
    return 'Normal';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fillLevel = (benne.capteur?.niveauRemplissage ?? 0)
        .clamp(0, 100)
        .toDouble();
    final statusColor = _getStatusColor(fillLevel);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.benneDetail, arguments: benne),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Benne ${benne.id}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (showActions)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') onEdit();
                              if (value == 'delete') onDelete();
                              if (value == 'add_capteur') onAddCapteur?.call();
                            },
                            itemBuilder: (context) => [
                              if (onAddCapteur != null)
                                const PopupMenuItem(
                                  value: 'add_capteur',
                                  child: Text('Ajouter capteur'),
                                ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Modifier'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Supprimer'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert, size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(
                              alpha: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            benne.typeBenne,
                            style: TextStyle(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${benne.capacite.toStringAsFixed(0)} m3',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: fillLevel / 100,
                              minHeight: 8,
                              backgroundColor: scheme.outlineVariant.withValues(
                                alpha: 0.35,
                              ),
                              valueColor: AlwaysStoppedAnimation(statusColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${fillLevel.toInt()}%',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getStatusText(fillLevel),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
