import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/chauffeur_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class ChauffeurCard extends StatelessWidget {
  final Chauffeur chauffeur;

  const ChauffeurCard({
    super.key,
    required this.chauffeur,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.chauffeurDetail, arguments: chauffeur),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: scheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person,
                color: scheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    chauffeur.user != null
                        ? chauffeur.user!.fullName
                        : 'Chauffeur #${chauffeur.id}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (chauffeur.user != null)
                    Text(
                      'User: ${chauffeur.user!.nom} ${chauffeur.user!.prenom}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Text(
                      'Utilisateur non assigné',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'CNI: ${chauffeur.cni}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}