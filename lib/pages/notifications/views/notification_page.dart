import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:clean_way_frontend/widgets/modern_widgets.dart';
import 'package:clean_way_frontend/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: 'Notifications',
      floatingActionButton: FloatingActionButton(
        onPressed: controller.markAllAsRead,
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.done_all),
      ),
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
                  color: AppTheme.errorColor,
                  size: 64,
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
                  onPressed: controller.refreshHistory,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_none,
            title: 'Aucun historique',
            subtitle: 'Aucune notification n\'a encore été reçue.',
          );
        }

        final unreadCount = controller.notifications
            .where((notification) => !notification.read)
            .length;

        return RefreshIndicator(
          onRefresh: controller.refreshHistory,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _NotificationStatus(
                  enabled: controller.notificationsEnabled.value,
                );
              }

              if (index == 1) {
                return _HistorySummary(
                  total: controller.notifications.length,
                  unread: unreadCount,
                  onClear: controller.clearHistory,
                );
              }

              final notification = controller.notifications[index - 2];
              return _NotificationCard(
                notification: notification,
                onMarkAsRead: () => controller.markAsRead(notification.id),
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationStatus extends StatelessWidget {
  final bool enabled;

  const _NotificationStatus({
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppTheme.successColor : AppTheme.warningColor;
    final icon = enabled ? Icons.notifications_active : Icons.notifications_off;
    final title = enabled ? 'Notifications activées' : 'Notifications désactivées';
    final subtitle = enabled
        ? 'Vous recevrez les dernières alertes et mises à jour.'
        : 'Les notifications sont désactivées dans les paramètres.';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.75),
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

class _HistorySummary extends StatelessWidget {
  final int total;
  final int unread;
  final VoidCallback onClear;

  const _HistorySummary({
    required this.total,
    required this.unread,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historique des notifications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Total: $total • Non lus: $unread'),
                ],
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: const Text('Effacer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;

  const _NotificationCard({
    required this.notification,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.read;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: isRead ? null : onMarkAsRead,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(type: notification.type, isRead: isRead),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.75),
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inDays > 0) {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    }
    if (diff.inHours > 0) {
      return 'il y a ${diff.inHours}h';
    }
    if (diff.inMinutes > 0) {
      return 'il y a ${diff.inMinutes}min';
    }
    return 'À l\'instant';
  }
}

class _NotificationIcon extends StatelessWidget {
  final String type;
  final bool isRead;

  const _NotificationIcon({
    required this.type,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case 'alert':
        icon = Icons.warning_amber_rounded;
        color = AppTheme.warningColor;
        break;
      case 'assignment':
        icon = Icons.assignment_ind;
        color = AppTheme.primaryColor;
        break;
      case 'info':
      default:
        icon = Icons.notifications;
        color = AppTheme.accentColor;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(isRead ? 0.15 : 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }
}
