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
    final scheme = ColorScheme.fromSeed(seedColor: Color(_accentColor), brightness: brightness);
    final theme = ThemeData.from(colorScheme: scheme).copyWith(useMaterial3: true);
    Get.changeTheme(theme);
    Get.changeThemeMode(_darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final applied = await NotificationService.instance.setNotificationsEnabled(enabled);
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
        message: enabled ? "Notifications activées" : "Notifications désactivées",
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
    final userName = nom.isNotEmpty ? nom : (prenom.isNotEmpty ? prenom : 'Utilisateur');
    
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

                return Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark ? 0.42 : 0.12,
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
                  child: Column(
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
                      const SizedBox(height: AppSpacing.md),
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
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Couleur d\'accent',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.md,
                        children: [0xFFFFFFFF, 0xFF0F172A, 0xFFDC2626, 0xFF065F46, 0xFF1E3A8A]
                            .map(
                              (colorValue) => _ColorOption(
                                colorValue: colorValue,
                                selected: _accentColor == colorValue,
                                onTap: () {
                                  setState(() {
                                    _accentColor = colorValue;
                                    box.write('settings:accentColor', _accentColor);
                                    _applyTheme();
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Notifications Section
                _SectionHeader(title: 'Notifications'),
                ModernCard(
                  child: ModernListTile(
                    leading: Icon(
                      _notifications ? Icons.notifications_active : Icons.notifications_off,
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
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final int colorValue;
  final bool selected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.colorValue,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Color(colorValue),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? onSurface : Colors.grey[300]!,
            width: selected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(colorValue).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
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
    _nameController = TextEditingController(text: userMap['nom']?.toString() ?? '');
    _prenomController = TextEditingController(text: userMap['prenom']?.toString() ?? '');
    _emailController = TextEditingController(text: userMap['email']?.toString() ?? '');
    _phoneController = TextEditingController(text: userMap['telephone']?.toString() ?? '');
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
                  labelText: 'Email',
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
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
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
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Enregistrement...' : 'Enregistrer'),
        ),
      ],
    );
  }
}
