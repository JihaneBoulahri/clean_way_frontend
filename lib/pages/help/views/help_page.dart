import 'package:flutter/material.dart';
import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import '../../../widgets/app_layout.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: 'Aide & Support',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Links Section
            Text(
              'Accès rapide',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ModernCard(
                    onTap: () {},
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Icon(
                          Icons.help_center_outlined,
                          size: 32,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'FAQ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: ModernCard(
                    onTap: () {},
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: 32,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Contact',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Help Categories
            Text(
              'Guides d\'utilisation',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildHelpCategory(
              context,
              icon: Icons.delete_outline,
              title: 'Gestion des Bennes',
              description: 'Apprenez à ajouter, modifier et supprimer des bennes',
              items: [
                'Ajouter une nouvelle benne',
                'Modifier les informations d\'une benne',
                'Localiser une benne sur la carte',
                'Exporter les données des bennes',
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildHelpCategory(
              context,
              icon: Icons.directions_bus,
              title: 'Gestion des Tournées',
              description: 'Optimisez vos itinéraires de collecte',
              items: [
                'Créer une nouvelle tournée',
                'Assigner des bennes à une tournée',
                'Suivre la progression en temps réel',
                'Générer des rapports',
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildHelpCategory(
              context,
              icon: Icons.local_shipping,
              title: 'Gestion des Camions',
              description: 'Administrez votre flotte de véhicules',
              items: [
                'Ajouter un camion à la flotte',
                'Vérifier l\'état d\'un camion',
                'Planifier la maintenance',
                'Consulter l\'historique',
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildHelpCategory(
              context,
              icon: Icons.person_outline,
              title: 'Gestion des Chauffeurs',
              description: 'Gérez votre équipe de chauffeurs',
              items: [
                'Ajouter un chauffeur',
                'Consulter les permis',
                'Attribuer des tournées',
                'Voir les statistiques',
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildHelpCategory(
              context,
              icon: Icons.location_on_outlined,
              title: 'Gestion des Zones',
              description: 'Organisez vos secteurs de collecte',
              items: [
                'Créer une nouvelle zone',
                'Définir les limites',
                'Assigner des bennes',
                'Consulter la couverture',
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Support Section
            ModernCard(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.darkCardBackground],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        color: AppTheme.textLight,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Besoin d\'aide ?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Notre équipe support est disponible pour vous aider',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.email_outlined),
                          label: const Text('Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone_outlined),
                          label: const Text('Appel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCategory(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<String> items,
  }) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentColor, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
