import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../pages/auth/models/user_model.dart';
import '../routes/app_routes.dart';

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
    if (storedUser is Map) {
      try {
        return User.fromJsonSafe(storedUser);
      } catch (_) {}
    }
    return User(
      id: 0,
      nom: 'Utilisateur',
      prenom: '',
      email: '',
      role: 'chauffeur',
    );
  }

  bool get _isChauffeur =>
      user.role.toLowerCase() == 'chauffeur';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currentRoute = Get.currentRoute;
    return Container(
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Image.asset(
                        'images/logo_truck.png',
                        width: 160,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
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
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                            Text(user.role,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurface.withValues(alpha: 0.72),
                                ),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.onSurface.withValues(alpha: 0.12)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (_isChauffeur) ...[
                    _SidebarItem(icon: Icons.dashboard_outlined, label: 'Dashboard', primaryColor: primaryColor, active: currentRoute == AppRoutes.dashboard, onTap: () => onItemSelected(AppRoutes.dashboard)),
                    _SidebarItem(icon: Icons.map_outlined, label: 'Zones', primaryColor: primaryColor, active: currentRoute == AppRoutes.zones, onTap: () => onItemSelected(AppRoutes.zones)),
                    _SidebarItem(
                      icon: Icons.today_outlined,
                      label: 'Ma tournée',
                      primaryColor: primaryColor,
                      active: currentRoute == AppRoutes.tourneeChauffeur,
                      onTap: () => onItemSelected(AppRoutes.tourneeChauffeur),
                    ),
                    _SidebarItem(
                      icon: Icons.my_location,
                      label: 'Live Map',
                      primaryColor: primaryColor,
                      active: currentRoute == AppRoutes.liveMap,
                      onTap: () => onItemSelected(AppRoutes.liveMap),
                    ),
                    _SidebarItem(
                      icon: Icons.history,
                      label: 'Historique',
                      primaryColor: primaryColor,
                      active: currentRoute == AppRoutes.tourneeChauffeurHistory,
                      onTap: () =>
                          onItemSelected(AppRoutes.tourneeChauffeurHistory),
                    ),
                    _SidebarItem(icon: Icons.notifications_outlined, label: 'Notifications', primaryColor: primaryColor, active: currentRoute == AppRoutes.notifications, onTap: () => onItemSelected(AppRoutes.notifications)),
                    _SidebarItem(icon: Icons.settings_outlined, label: 'Paramètres', primaryColor: primaryColor, active: currentRoute == AppRoutes.settings, onTap: () => onItemSelected(AppRoutes.settings)),                    
                    _SidebarItem(icon: Icons.help_outline, label: 'Help & Support', primaryColor: primaryColor, active: currentRoute == AppRoutes.help, onTap: () => onItemSelected(AppRoutes.help)),

                  ] else ...[
                    _SidebarItem(icon: Icons.dashboard_outlined, label: 'Dashboard', primaryColor: primaryColor, active: currentRoute == AppRoutes.dashboard, onTap: () => onItemSelected(AppRoutes.dashboard)),
                    _SidebarItem(icon: Icons.person_outline, label: 'Chauffeurs', primaryColor: primaryColor, active: currentRoute == AppRoutes.chauffeurs, onTap: () => onItemSelected(AppRoutes.chauffeurs)),
                    _SidebarItem(icon: Icons.local_shipping_outlined, label: 'Camions', primaryColor: primaryColor, active: currentRoute == AppRoutes.camions, onTap: () => onItemSelected(AppRoutes.camions)),
                    _SidebarItem(icon: Icons.delete_outline, label: 'Bennes', primaryColor: primaryColor, active: currentRoute == AppRoutes.bennes, onTap: () => onItemSelected(AppRoutes.bennes)),
                    _SidebarItem(icon: Icons.today_outlined, label: 'Tournées', primaryColor: primaryColor, active: currentRoute == AppRoutes.tournees, onTap: () => onItemSelected(AppRoutes.tournees)),
                    _SidebarItem(icon: Icons.map_outlined, label: 'Zones', primaryColor: primaryColor, active: currentRoute == AppRoutes.zones, onTap: () => onItemSelected(AppRoutes.zones)),
                    _SidebarItem(icon: Icons.location_city_outlined, label: 'Villes', primaryColor: primaryColor, active: currentRoute == AppRoutes.villes, onTap: () => onItemSelected(AppRoutes.villes)),
                    _SidebarItem(icon: Icons.notifications_outlined, label: 'Notifications', primaryColor: primaryColor, active: currentRoute == AppRoutes.notifications, onTap: () => onItemSelected(AppRoutes.notifications)),
                    _SidebarItem(icon: Icons.settings_outlined, label: 'Paramètres', primaryColor: primaryColor, active: currentRoute == AppRoutes.settings, onTap: () => onItemSelected(AppRoutes.settings)),
                    _SidebarItem(icon: Icons.help_outline, label: 'Help & Support', primaryColor: primaryColor, active: currentRoute == AppRoutes.help, onTap: () => onItemSelected(AppRoutes.help)),
                  ],
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
                    border: Border.all(color: Colors.red.shade300.withValues(alpha: 0.5)),
                    color: Colors.red.withValues(alpha: 0.08),
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
  final bool active;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.primaryColor,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final itemColor = active ? primaryColor : scheme.onSurface.withValues(alpha: 0.82);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: active ? primaryColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: itemColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: active ? primaryColor : scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




