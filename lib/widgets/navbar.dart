import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class Navbar extends StatelessWidget {
  final Color primaryColor;
  final String pageName;
  final VoidCallback? onMenuPressed;

  const Navbar({super.key, required this.primaryColor, required this.pageName, this.onMenuPressed});

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

  void _showUserInfo(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: scheme.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Text(user.initials, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      user.role,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: scheme.onSurface.withValues(alpha: 0.12)),
            const SizedBox(height: 8),
            _infoRow(context, Icons.email_outlined, 'Email', user.email),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.onSurface.withValues(alpha: 0.72)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(onPressed: onMenuPressed, icon: Icon(Icons.menu, color: primaryColor)),
            Flexible(
              child: Center(
                child: Text(
                  pageName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showUserInfo(context),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.12),
                child: Text(user.initials, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
