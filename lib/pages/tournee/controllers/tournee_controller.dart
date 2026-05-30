import 'package:clean_way_frontend/pages/tournee/models/tournee_model.dart';
import 'package:clean_way_frontend/core/constants/filter_constants.dart';
import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/tournee_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/snackbar_helper.dart';

class TourneeController extends GetxController {
  final TourneeService _service = TourneeService();
  var tournees = <Tournee>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var filterStatus = FilterDefaults.all.obs;
  var filterPeriod = FilterDefaults.all.obs;

  void searchOrFetch(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      fetchTournees();
    } else {
      searchTournees(query.trim());
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTournees();
  }

  List<Tournee> get filteredTournees {
    final now = DateTime.now();
    return tournees.where((t) {
      final matchesStatus = filterStatus.value == FilterDefaults.all ||
          t.status.toLowerCase() == filterStatus.value.toLowerCase();
      final matchesPeriod = _matchesPeriod(t.dateTournee, now);
      return matchesStatus && matchesPeriod;
    }).toList();
  }

  bool get hasActiveFilters =>
      filterStatus.value != FilterDefaults.all ||
      filterPeriod.value != FilterDefaults.all;

  List<String> get statusOptions =>
      _distinctStrings(tournees.map((t) => t.status));

  List<String> get periodOptions => const [
        FilterDefaults.all,
        FilterDefaults.today,
        FilterDefaults.last7Days,
        FilterDefaults.last30Days,
      ];

  void applyFilters({
    required String status,
    required String period,
  }) {
    filterStatus.value = status;
    filterPeriod.value = period;
  }

  void resetFilters() {
    filterStatus.value = FilterDefaults.all;
    filterPeriod.value = FilterDefaults.all;
  }

  bool _matchesPeriod(DateTime date, DateTime now) {
    if (filterPeriod.value == FilterDefaults.all) return true;
    if (filterPeriod.value == FilterDefaults.today) {
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }
    if (filterPeriod.value == FilterDefaults.last7Days) {
      final start = now.subtract(const Duration(days: 7));
      return !date.isBefore(start) && !date.isAfter(now);
    }
    if (filterPeriod.value == FilterDefaults.last30Days) {
      final start = now.subtract(const Duration(days: 30));
      return !date.isBefore(start) && !date.isAfter(now);
    }
    return true;
  }

  List<String> _distinctStrings(Iterable<String> values) {
    final set = <String>{};
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        set.add(trimmed);
      }
    }
    final list = set.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  void _handleError(dynamic e, {bool showSnackbar = true}) {
    final errorMsg = e.toString();
    if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
      Get.offAllNamed(AppRoutes.login);
    } else if (errorMsg.contains('404') || errorMsg.contains('Not Found')) {
      fetchTournees();
      if (showSnackbar) {
        showNadiSnackbar(
          title: "Info",
          message: "L'élément a été supprimé ailleurs",
          type: NadiSnackbarType.info,
        );
      }
    } else {
      if (showSnackbar) {
        showNadiSnackbar(
          title: "Erreur",
          message: errorMsg,
          type: NadiSnackbarType.error,
        );
      }
    }
  }

  Future<void> fetchTournees() async {
    try {
      isLoading(true);
      final data = await _service.getAll();
      tournees.value = data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, showSnackbar: false);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addTournee(Tournee tournee) async {
    try {
      final data = await _service.create(tournee.toJson());
      if (data != null) {
        tournees.add(Tournee.fromJson(data));
      }
      await fetchTournees();

      showNadiSnackbar(
        title: "Succès",
        message: "Tournée ajoutée avec succès",
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Tournée ajoutée',
        'Votre tournée ${tournee.id} a été créée avec le statut ${tournee.status}.',
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateTournee(Tournee tournee) async {
    try {
      final data = await _service.update(tournee.id, tournee.toJson());
      final index = tournees.indexWhere((t) => t.id == tournee.id);
      if (data == null) {
        await fetchTournees();
      } else if (index != -1) {
        tournees[index] = Tournee.fromJson(data);
        await fetchTournees();
      }

      showNadiSnackbar(
        title: "Succès",
        message: "Tournée modifiée avec succès",
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Tournée modifiée',
        'La tournée ${tournee.id} a été mise à jour.',
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteTournee(int id) async {
    try {
      await _service.delete(id);
      tournees.removeWhere((t) => t.id == id);

      showNadiSnackbar(
        title: "Succès",
        message: "Tournée supprimée avec succès",
        type: NadiSnackbarType.success,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  void searchTournees(String query) async {
    try {
      isLoading(true);
      final data = await _service.search(query);
      tournees.value = data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  /// Fetch detailed tournee with all relations (camion, zone)
  Future<Tournee?> getTourneeDetails(int id) async {
    try {
      final data = await _service.getWithRelations(id);
      return Tournee.fromJson(data is List ? data.first : data);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
}
