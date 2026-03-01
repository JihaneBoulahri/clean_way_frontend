import 'package:clean_way_frontend/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class Sidebar extends StatelessWidget {
  final Color primaryColor;
  final void Function(String route) onItemSelected;

  const Sidebar({
    super.key,
    required this.primaryColor,
    required this.onItemSelected,
  });

  User get user {
    final box = GetStorage();
    final storedUser = box.read('user');
    return User.fromJson(storedUser);
  }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.recycling, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Clean Way',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.grey[900]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Text(
                          user.initials,
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.fullName,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                            Text(user.role,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _SidebarItem(icon: Icons.dashboard_outlined, label: 'Dashboard', primaryColor: primaryColor, onTap: () => onItemSelected(AppRoutes.dashboard)),
                  _SidebarItem(icon: Icons.local_shipping_outlined, label: 'Camions', primaryColor: primaryColor, onTap: () => onItemSelected(AppRoutes.camions)),
                  _SidebarItem(icon: Icons.map_outlined, label: 'Zones', primaryColor: primaryColor, onTap: () => onItemSelected(AppRoutes.zones)),
                  _SidebarItem(icon: Icons.delete_outline, label: 'Bennes', primaryColor: primaryColor, onTap: () => onItemSelected(AppRoutes.bennes)),
                  _SidebarItem(icon: Icons.today_outlined, label: 'Tournées', primaryColor: primaryColor, onTap: () => onItemSelected(AppRoutes.tournees)),
                  _SidebarItem(icon: Icons.settings_outlined, label: 'Paramètres', primaryColor: primaryColor, onTap: () => onItemSelected('settings')),
                  _SidebarItem(icon: Icons.help_outline, label: 'Help & Support', primaryColor: primaryColor, onTap: () => onItemSelected('help')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: InkWell(
                onTap: () => onItemSelected('logout'),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade100),
                    color: Colors.red.shade50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 18, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600, fontSize: 14)),
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
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }
}