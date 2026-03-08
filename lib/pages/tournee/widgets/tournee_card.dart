import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/tournee_model.dart';
import '../../../routes/app_routes.dart';

class TourneeCard extends StatelessWidget {
  final Tournee tournee;

  const TourneeCard({
    super.key,
    required this.tournee,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(tournee.status);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      color: statusColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.tourneeDetail, arguments: tournee),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A1F14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      color: Color(0xFFFF7A00),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tournee #${tournee.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _StatusChip(status: tournee.status, color: statusColor),
              const SizedBox(height: 8),
              Text(
                tournee.dateTournee.toString().split(' ').first,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Debut: ${tournee.heureDebut}',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase().replaceAll('_', '').replaceAll('-', '').replaceAll(' ', '');
    if (lower.contains('term')) return const Color(0xFF16A34A);
    if (lower.contains('cours')) return const Color(0xFFF59E0B);
    if (lower.contains('annul')) return const Color(0xFFDC2626);
    return const Color(0xFFF59E0B);
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
