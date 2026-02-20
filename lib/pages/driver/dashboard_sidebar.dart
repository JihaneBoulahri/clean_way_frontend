import 'package:flutter/material.dart';

class DashboardSidebar extends StatelessWidget {
  final Color primaryColor;
  final void Function(String route) onItemSelected;

  const DashboardSidebar({
    super.key,
    required this.primaryColor,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Chauffeur',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _SidebarItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    primaryColor: primaryColor,
                    onTap: () => onItemSelected('dashboard'),
                  ),
                  _SidebarItem(
                    icon: Icons.today_outlined,
                    label: 'Tournées du jour',
                    primaryColor: primaryColor,
                    onTap: () => onItemSelected('today'),
                  ),
                  _SidebarItem(
                    icon: Icons.route,
                    label: 'Parcours',
                    primaryColor: primaryColor,
                    onTap: () => onItemSelected('route'),
                  ),
                  _SidebarItem(
                    icon: Icons.delete_outline,
                    label: 'Conteneurs',
                    primaryColor: primaryColor,
                    onTap: () => onItemSelected('containers'),
                  ),
                  _SidebarItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    primaryColor: primaryColor,
                    onTap: () => onItemSelected('profile'),
                  ),
                  _SidebarItem(
                    icon: Icons.settings_outlined,
                    label: 'Paramètres',
                    primaryColor: primaryColor,
                    onTap: () => onItemSelected('settings'),
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

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primaryColor;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
