import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/benne_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/tournee_service.dart';
import '../../../pages/bennes/models/benne_model.dart';
import '../../../pages/tournee/models/tournee_model.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  final GetStorage _storage = GetStorage();
  final NotificationService _notificationService = NotificationService.instance;
  final BenneService _benneService = BenneService();
  final TourneeService _tourneeService = TourneeService();

  static const _historyKey = 'notifications_history';
  static const _shownToastsKey = 'shown_notification_ids';

  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var notificationsEnabled = false.obs;
  late Set<int> _shownToastIds;
  late String userRole;

  bool get isChauffeur => userRole.toLowerCase() == 'chauffeur';

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    _loadShownToastIds();
    updateStatus();
    loadHistory();
  }

  void _loadUserRole() {
    final storedUser = _storage.read('user');
    if (storedUser is Map) {
      userRole = storedUser['role']?.toString().toLowerCase() ?? '';
    } else {
      userRole = '';
    }
  }

  void _loadShownToastIds() {
    final stored = _storage.read(_shownToastsKey) as List<dynamic>?;
    _shownToastIds = (stored ?? []).cast<int>().toSet();
  }

  void _saveShownToastIds() {
    _storage.write(_shownToastsKey, _shownToastIds.toList());
  }

  void updateStatus() {
    notificationsEnabled.value = _notificationService.notificationsEnabled;
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      error.value = null;

      // Load persisted history from storage
      final stored = _storage.read(_historyKey);
      if (stored is List && stored.isNotEmpty) {
        notifications.value = stored
            .cast<Map<dynamic, dynamic>>()
            .map((item) => NotificationModel.fromJson(
                  item.cast<String, dynamic>(),
                ))
            .toList();
      }

      if (isChauffeur) {
        notifications.assignAll(_filterNotificationsForRole(notifications));
      }


      final liveNotifications = await _fetchLiveNotifications();
      
      if (liveNotifications.isNotEmpty) {
     
        for (final notif in liveNotifications) {
          if (!_shownToastIds.contains(notif.id)) {
            await _notificationService.showNotification(
              notif.title,
              notif.message,
              id: notif.id,
            );
            _shownToastIds.add(notif.id);
          }
        }
        _saveShownToastIds();

        // Update history
        notifications.value = liveNotifications;
        await _saveHistory();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHistory() async {
    updateStatus();
    try {
      isLoading.value = true;
      final liveNotifications = await _fetchLiveNotifications();
      
      if (liveNotifications.isNotEmpty) {
        for (final notif in liveNotifications) {
          if (!_shownToastIds.contains(notif.id)) {
            await _notificationService.showNotification(
              notif.title,
              notif.message,
              id: notif.id,
            );
            _shownToastIds.add(notif.id);
          }
        }
        _saveShownToastIds();

        final existingIds = notifications.map((n) => n.id).toSet();
        final newNotifications = liveNotifications
            .where((notif) => !existingIds.contains(notif.id))
            .toList();

        notifications.addAll(newNotifications);
        if (isChauffeur) {
          notifications.assignAll(_filterNotificationsForRole(notifications));
        }
        await _saveHistory();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(read: true);
      await _saveHistory();
    }
  }

  Future<void> markAllAsRead() async {
    notifications.value = notifications
        .map((notification) => notification.copyWith(read: true))
        .toList();
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    notifications.clear();
    await _storage.remove(_historyKey);
  }

  Future<void> _saveHistory() async {
    await _storage.write(
      _historyKey,
      notifications.map((notification) => notification.toJson()).toList(),
    );
  }

  Future<List<NotificationModel>> _fetchLiveNotifications() async {
    final notifications = <NotificationModel>[];

    if (!isChauffeur) {
      try {
        final bennesResponse = await _benneService.getBennesWithSensors();
        final bennes = _extractBennes(bennesResponse);
        notifications.addAll(_mapBennesToNotifications(bennes));
      } catch (_) {
        // ignore; preserve existing notifications if backend fails
      }
    }

    try {
      final tournees = await _fetchTourneeNotifications();
      notifications.addAll(_mapTourneesToNotifications(
        tournees,
        onlyForChauffeur: isChauffeur,
      ));
    } catch (_) {
      // ignore; preserve existing notifications if backend fails
    }

    return notifications;
  }

  List<Benne> _extractBennes(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) => Benne.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map<String, dynamic>) {
      if (response['data'] is List) {
        return _extractBennes(response['data']);
      }
      if (response['bennes'] is List) {
        return _extractBennes(response['bennes']);
      }
      return [Benne.fromJson(response)];
    }

    return [];
  }

  List<Tournee> _extractTournees(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) => Tournee.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map<String, dynamic>) {
      if (response['data'] is List) {
        return _extractTournees(response['data']);
      }
      if (response['tournees'] is List) {
        return _extractTournees(response['tournees']);
      }
      return [Tournee.fromJson(response)];
    }

    return [];
  }

  Future<List<Tournee>> _fetchTourneeNotifications() async {
    final tourneeNotifications = <Tournee>[];

    if (isChauffeur) {
      try {
        final currentResponse = await _tourneeService.getCurrentForChauffeur();
        tourneeNotifications.addAll(_extractTournees(currentResponse));
      } catch (_) {
        
      }
    }

    final historyResponse = await _tourneeService.getHistory();
    tourneeNotifications.addAll(_extractTournees(historyResponse));

    final uniqueById = <int, Tournee>{};
    for (final tournee in tourneeNotifications) {
      uniqueById[tournee.id] = tournee;
    }

    return uniqueById.values.toList();
  }

  List<NotificationModel> _filterNotificationsForRole(
    List<NotificationModel> notifications,
  ) {
    if (!isChauffeur) return notifications;

    return notifications.where((notification) {
      return notification.type == 'assignment' ||
          notification.type == 'alert';
    }).toList();
  }

  List<NotificationModel> _mapBennesToNotifications(List<Benne> bennes) {
    final fullBennes = bennes.where(_isFullBenne).toList();
    return fullBennes.map((benne) {
      final fillInfo = benne.capteur?.niveauRemplissage != null
          ? '${benne.capteur!.niveauRemplissage.toStringAsFixed(0)}%'
          : benne.status;
      final label = benne.typeBenne.isNotEmpty ? benne.typeBenne : 'Benne';
      return NotificationModel(
        id: 1000000 + benne.id,
        title: 'Benne pleine détectée',
        message: 'La $label ${benne.id} est à $fillInfo de remplissage.',
        timestamp: DateTime.now(),
        type: 'alert',
        read: false,
      );
    }).toList();
  }

  List<NotificationModel> _mapTourneesToNotifications(
    List<Tournee> tournees, {
    bool onlyForChauffeur = false,
  }) {
    final relevant = tournees.where((tournee) {
      return _isRelevantTournee(
        tournee,
        onlyForChauffeur: onlyForChauffeur,
      );
    }).toList();

    return relevant.map((tournee) {
      final status = tournee.status.toLowerCase();
      final isFinished = status.contains('termine') || status.contains('terminée');
      final isCancelled = status.contains('annul') || status.contains('cancel');
      final isStarted = status.contains('démarr') ||
          status.contains('demarr') ||
          status.contains('départ') ||
          status.contains('depart') ||
          status.contains('en cours') ||
          status.contains('encours');
      final isPlanned = status.contains('plan') ||
          status.contains('programm') ||
          status.contains('planifi');

      final title = isFinished
          ? 'Collecte terminée'
          : isCancelled
              ? 'Tournée annulée'
              : isStarted
                  ? 'Tournée démarrée'
                  : isPlanned
                      ? 'Tournée planifiée'
                      : 'Mise à jour de tournée';

      final message = isFinished
          ? 'La tournée ${tournee.id} a été terminée.'
          : isCancelled
              ? 'La tournée ${tournee.id} a été annulée.'
              : isStarted
                  ? 'La tournée ${tournee.id} a démarré.'
                  : isPlanned
                      ? 'La tournée ${tournee.id} est planifiée.'
                      : 'La tournée ${tournee.id} a le statut ${tournee.status}.';

      final timestamp = tournee.dateTournee;
      return NotificationModel(
        id: 2000000 + tournee.id,
        title: title,
        message: message,
        timestamp: timestamp,
        type: isFinished
            ? 'info'
            : isCancelled
                ? 'alert'
                : 'assignment',
        read: false,
      );
    }).toList();
  }

  bool _isRelevantTournee(Tournee tournee, {bool onlyForChauffeur = false}) {
    if (!onlyForChauffeur) {
      return true;
    }

    final status = tournee.status.toLowerCase();
    return status.contains('plan') ||
        status.contains('programm') ||
        status.contains('planifi') ||
        status.contains('démarr') ||
        status.contains('demarr') ||
        status.contains('termi') ||
        status.contains('en cours') ||
        status.contains('encours') ||
        status.contains('annul') ;
  }

  bool _isFullBenne(Benne benne) {
    final fillRate = benne.capteur?.niveauRemplissage;
    if (fillRate != null) {
      return fillRate >= 90;
    }
    final status = benne.status.toLowerCase();
    return status.contains('plein') || status.contains('full');
  }
}

