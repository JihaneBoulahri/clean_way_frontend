import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: "Profil",
      floatingActionButton: Obx(() {
        if (controller.isEditing.value) {
          return FloatingActionButton(
            onPressed: controller.updateProfile,
            child: const Icon(Icons.check),
            backgroundColor: AppTheme.accentColor,
            tooltip: 'Sauvegarder',
          );
        } else {
          return FloatingActionButton(
            onPressed: controller.startEditing,
            child: const Icon(Icons.edit),
            backgroundColor: AppTheme.accentColor,
            tooltip: 'Modifier',
          );
        }
      }),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentColor),
          );
        }

        if (controller.error.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.error.value!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadUserProfile,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final user = controller.user.value;
        if (user == null) {
          return const EmptyState(
            icon: Icons.person_off,
            title: 'Profil non trouvé',
            subtitle: 'Impossible de charger les informations du profil.',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _ProfileHeader(user: user),
              const SizedBox(height: 24),
              _ProfileForm(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.accentColor,
              child: Text(
                user.initials,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (user.telephone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                user.telephone,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Chip(
              label: Text(
                _getRoleDisplayName(user.role),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: AppTheme.accentColor,
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrateur';
      case 'chauffeur':
        return 'Chauffeur';
      case 'superviseur':
        return 'Superviseur';
      default:
        return role;
    }
  }
}

class _ProfileForm extends StatelessWidget {
  final ProfileController controller;

  const _ProfileForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isEditing.value) {
                return Column(
                  children: [
                    TextFormField(
                      initialValue: controller.nom.value,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => controller.nom.value = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: controller.prenom.value,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => controller.prenom.value = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: controller.email.value,
                      decoration: const InputDecoration(
                        labelText: 'Courriel',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => controller.email.value = value,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: controller.telephone.value,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => controller.telephone.value = value,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => ElevatedButton.icon(
                          onPressed: controller.isFetchingPhones.value
                              ? null
                              : () => _showPhoneNumbersDialog(context),
                          icon: controller.isFetchingPhones.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.phone),
                          label: const Text('Récupérer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                        )),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _ProfileField(
                      label: 'Nom',
                      value: controller.nom.value,
                    ),
                    const SizedBox(height: 12),
                    _ProfileField(
                      label: 'Prénom',
                      value: controller.prenom.value,
                    ),
                    const SizedBox(height: 12),
                    _ProfileField(
                      label: 'Courriel',
                      value: controller.email.value,
                    ),
                    const SizedBox(height: 12),
                    _ProfileField(
                      label: 'Téléphone',
                      value: controller.telephone.value.isNotEmpty ? controller.telephone.value : 'Non renseigné',
                    ),
                    const SizedBox(height: 12),
                    _ProfileField(
                      label: 'Rôle',
                      value: _getRoleDisplayName(controller.user.value?.role ?? ''),
                    ),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrateur';
      case 'chauffeur':
        return 'Chauffeur';
      case 'superviseur':
        return 'Superviseur';
      default:
        return role;
    }
  }

  /// Show dialog with fetched phone numbers
  void _showPhoneNumbersDialog(BuildContext context) {
    controller.fetchPhoneNumbersFromDatabase();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Sélectionner un numéro'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (controller.isFetchingPhones.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.phoneNumbers.isEmpty) {
              return const Center(
                child: Text('Aucun numéro disponible'),
              );
            }

            return ListView.builder(
              itemCount: controller.phoneNumbers.length,
              itemBuilder: (context, index) {
                final phone = controller.phoneNumbers[index];
                return ListTile(
                  title: Text(phone),
                  leading: const Icon(Icons.phone),
                  onTap: () => controller.setPhoneNumber(phone),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}