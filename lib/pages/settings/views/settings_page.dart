import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:clean_way_frontend/core/services/notification_service.dart';
import 'package:clean_way_frontend/core/services/user_service.dart';
import '../../../widgets/app_layout.dart';
import '../../../widgets/snackbar_helper.dart';

Map<String, dynamic> _readUserMap(GetStorage box) {
  final raw = box.read('user');
  if (raw == null || raw is! Map) return <String, dynamic>{};
  return Map<String, dynamic>.from(raw);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final box = GetStorage();
  bool _darkMode = false;
  bool _notifications = true;
  int _accentColor = 0xFFFFFFFF;

  @override
  void initState() {
    super.initState();
    _loadStoredSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyTheme();
    });
  }

  void _loadStoredSettings() {
    _darkMode = box.read('settings:darkMode') ?? false;
    _notifications = box.read('settings:notifications') ?? true;
    _accentColor = box.read('settings:accentColor') ?? _accentColor;
  }

  void _applyTheme() {
    final brightness = _darkMode ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: Color(_accentColor),
      brightness: brightness,
    );
    final theme = ThemeData.from(
      colorScheme: scheme,
    ).copyWith(useMaterial3: true);
    Get.changeTheme(theme);
    Get.changeThemeMode(_darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final applied = await NotificationService.instance.setNotificationsEnabled(
      enabled,
    );
    if (!mounted) return;

    setState(() {
      _notifications = applied;
    });

    if (applied) {
      if (enabled) {
        await NotificationService.instance.showLocalTestNotification();
      }
      showNadiSnackbar(
        title: "Succès",
        message: enabled
            ? "Notifications activées"
            : "Notifications désactivées",
        type: NadiSnackbarType.success,
      );
    } else {
      showNadiSnackbar(
        title: "Permission refusée",
        message: "Autorisez les notifications dans les paramètres système.",
        type: NadiSnackbarType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final userMap = _readUserMap(box);
    final nom = userMap['nom']?.toString().trim() ?? '';
    final prenom = userMap['prenom']?.toString().trim() ?? '';
    final role = userMap['role']?.toString().trim() ?? 'Utilisateur';
    final telephone = userMap['telephone']?.toString().trim() ?? 'Non renseigné';
    final userId = userMap['id']?.toString() ?? '—';
    final userName = prenom.isNotEmpty || nom.isNotEmpty
        ? '$prenom $nom'.trim()
        : 'Utilisateur';
    final emailVerifiedAt = userMap['email_verified_at']?.toString();
    final emailVerified = emailVerifiedAt != null && emailVerifiedAt.isNotEmpty ? 'Vérifié' : 'Non vérifié';

    // Afficher 1 lettre du prénom + 1 lettre du nom
    String initials = '';
    if (prenom.isNotEmpty && nom.isNotEmpty) {
      initials = (prenom.substring(0, 1) + nom.substring(0, 1)).toUpperCase();
    } else if (prenom.isNotEmpty) {
      initials = prenom.substring(0, 1).toUpperCase();
    } else if (nom.isNotEmpty) {
      initials = nom.substring(0, 1).toUpperCase();
    } else {
      initials = 'U';
    }

    return AppLayout(
      pageName: 'Paramètres',
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                String imagePath;
                if (constraints.maxWidth < 600) {
                  // écran mobile
                  imagePath = 'images/moroccan_tile_bg1.jpeg';
                } else {
                  // écran plus large (PC)
                  imagePath = 'images/moroccan_tile_bg_pc.jpeg';
                }

                return Image.asset(imagePath, fit: BoxFit.cover);
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.42
                    : 0.12,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _SectionHeader(title: 'Profil'),
                ModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: scheme.primary,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: _roleBadgeColor(role).withOpacity(0.16),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Text(
                              _capitalize(role),
                              style: TextStyle(
                                color: _roleBadgeColor(role),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _ProfileInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Courriel',
                          value: userMap['email']?.toString() ?? 'Non renseigné',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ProfileInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Téléphone',
                          value: telephone,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ProfileInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'ID utilisateur',
                          value: userId,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ProfileInfoRow(
                          icon: Icons.verified_user_outlined,
                          label: 'Email vérifié',
                          value: emailVerified,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final res = await Get.dialog<bool>(_EditProfileDialog(box: box));
                              if (res == true) setState(() {});
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Modifier le profil'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Appearance Section
                _SectionHeader(title: 'Apparence'),
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ModernListTile(
                        leading: Icon(
                          _darkMode ? Icons.dark_mode : Icons.light_mode,
                          color: scheme.primary,
                        ),
                        title: 'Mode sombre',
                        subtitle: _darkMode ? 'Activé' : 'Désactivé',
                        trailing: Switch(
                          value: _darkMode,
                          onChanged: (v) {
                            setState(() {
                              _darkMode = v;
                              box.write('settings:darkMode', _darkMode);
                              _applyTheme();
                            });
                          },
                          activeColor: scheme.primary,
                        ),
                        showDivider: false,
                        backgroundColor: Colors.transparent,
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      if (!_darkMode) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Couleur d\'accent',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final colors = <int>[
                              0xFFFFFFFF,
                              0xFF0F172A,
                              0xFFDC2626,
                              0xFF065F46,
                              0xFF1E3A8A,
                            ];
                            final count = colors.length;
                            const minSize = 24.0;
                            const maxSize = 48.0;
                            var spacing = AppSpacing.md;
                            var size =
                                (constraints.maxWidth - spacing * (count - 1)) /
                                count;
                            if (size < minSize) {
                              spacing =
                                  ((constraints.maxWidth - minSize * count) /
                                          (count - 1))
                                      .clamp(4.0, AppSpacing.md);
                              size =
                                  (constraints.maxWidth -
                                      spacing * (count - 1)) /
                                  count;
                            }
                            size = size.clamp(minSize, maxSize);

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: colors
                                  .map(
                                    (colorValue) => SizedBox(
                                      width: size,
                                      height: size,
                                      child: _ColorOption(
                                        colorValue: colorValue,
                                        size: size,
                                        selected: _accentColor == colorValue,
                                        onTap: () {
                                          setState(() {
                                            _accentColor = colorValue;
                                            box.write(
                                              'settings:accentColor',
                                              _accentColor,
                                            );
                                            _applyTheme();
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Notifications Section
                _SectionHeader(title: 'Notifications'),
                ModernCard(
                  child: ModernListTile(
                    leading: Icon(
                      _notifications
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: scheme.primary,
                    ),
                    title: 'Notifications',
                    subtitle: _notifications ? 'Activées' : 'Désactivées',
                    trailing: Switch(
                      value: _notifications,
                      onChanged: _toggleNotifications,
                      activeColor: scheme.primary,
                    ),
                    showDivider: false,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.72),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

Color _roleBadgeColor(String role) {
  final lower = role.toLowerCase();
  if (lower.contains('admin')) return const Color(0xFF4F46E5);
  if (lower.contains('chauffeur')) return const Color(0xFF0E9F6E);
  return const Color(0xFF2563EB);
}

class _ColorOption extends StatelessWidget {
  final int colorValue;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  const _ColorOption({
    required this.colorValue,
    required this.selected,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final effectiveSize = size;
    final iconSize = (effectiveSize * 0.5).clamp(14.0, 22.0);
    final borderWidth = selected ? (effectiveSize >= 38 ? 2.0 : 1.5) : 1.0;
    final shadowBlur = (effectiveSize * 0.15).clamp(4.0, 8.0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: effectiveSize,
        height: effectiveSize,
        decoration: BoxDecoration(
          color: Color(colorValue),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? onSurface : Colors.grey[300]!,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(colorValue).withOpacity(0.3),
              blurRadius: shadowBlur,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: selected
            ? Icon(Icons.check, color: Colors.white, size: iconSize)
            : null,
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final GetStorage box;

  const _EditProfileDialog({required this.box});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _prenomController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _isSaving = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    final userMap = _readUserMap(widget.box);
    _nameController = TextEditingController(
      text: userMap['nom']?.toString() ?? '',
    );
    _prenomController = TextEditingController(
      text: userMap['prenom']?.toString() ?? '',
    );
    _emailController = TextEditingController(
      text: userMap['email']?.toString() ?? '',
    );
    _phoneController = TextEditingController(
      text: userMap['telephone']?.toString() ?? '',
    );
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userMap = _readUserMap(widget.box);
    final idRaw = userMap['id'];
    final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');

    final updated = <String, dynamic>{
      ...userMap,
      'nom': _nameController.text.trim(),
      'prenom': _prenomController.text.trim(),
      'email': _emailController.text.trim(),
      'telephone': _phoneController.text.trim(),
    };

    final payload = <String, dynamic>{
      'nom': updated['nom'],
      'prenom': updated['prenom'],
      'email': updated['email'],
      'telephone': updated['telephone'],
    };
    final password = _passwordController.text.trim();
    if (password.isNotEmpty) {
      payload['password'] = password;
    }

    setState(() => _isSaving = true);
    try {
      if (id != null) {
        await UserService.update(id, payload);
      }
      widget.box.write('user', updated);

      showNadiSnackbar(
        title: "Succès",
        message: "Profil mis à jour",
        type: NadiSnackbarType.success,
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      showNadiSnackbar(
        title: "Erreur",
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: AppTheme.accentColor),
          const SizedBox(width: AppSpacing.md),
          const Text('Modifier le profil'),
        ],
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _prenomController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Courriel',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _passwordController,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Icon(Icons.close),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
        ),
      ],
    );
  }
}
