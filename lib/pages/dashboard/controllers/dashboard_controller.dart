import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/optimization_service.dart';
import '../../../core/services/stats_service.dart';
import '../../../widgets/snackbar_helper.dart';

class DashboardController extends GetxController {
  final StatsService _statsService = StatsService();
  final OptimizationService _optimizationService = OptimizationService();
  final GetStorage _box = GetStorage();

  var stats = Rxn<Map<String, dynamic>>();
  var routes = RxList<dynamic>();

  var stats_loading = true.obs;
  var optimisation_loading = false.obs;

  var stats_error = RxnString();
  var optimisation_error = RxnString();

  @override
  void onInit() {
    fetchStats();
    super.onInit();
  }

  String _userRole() {
    final raw = _box.read('user');
    if (raw is Map) {
      final role = raw['role'] ?? raw['roles'];
      if (role is String) return role.toLowerCase();
      if (role is List && role.isNotEmpty) {
        return role.first.toString().toLowerCase();
      }
    }
    return '';
  }

  Future<void> fetchStats() async {
    try {
      stats_loading.value = true;
      stats_error.value = null;

      final isChauffeur = _userRole() == 'chauffeur';
      final data = isChauffeur
          ? await _statsService.fetchChauffeurStats()
          : await _statsService.fetchStats();
      stats.value = data;
    } catch (e) {
      stats_error.value = e.toString();
    } finally {
      stats_loading.value = false;
    }
  }

  Future<void> optimiser({
    int? villeId,
    int? zoneId,
    bool persist = true,
  }) async {
    try {
      optimisation_loading.value = true;
      optimisation_error.value = null;

      final data = await _optimizationService.optimiser(
        villeId: villeId,
        zoneId: zoneId,
        persist: persist,
      );

      routes.value = _extractRoutesList(data); // store optimized routes

      showNadiSnackbar(
        title: "Succès",
        message: "Tournée optimisée avec succès",
        type: NadiSnackbarType.success,
      );
    } catch (e) {
      optimisation_error.value = e.toString();

      showNadiSnackbar(
        title: "Erreur",
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    } finally {
      optimisation_loading.value = false;
    }
  }

  List<dynamic> _extractRoutesList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data.containsKey('par_zone')) {
        final parZone = data['par_zone'];
        if (parZone is Map) {
          final list = <dynamic>[];
          for (final value in parZone.values) {
            if (value is List) {
              list.addAll(value);
            } else if (value != null) {
              list.add(value);
            }
          }
          if (list.isNotEmpty) return list;
        }
        if (parZone is List) return parZone;
      }

      const keys = ['data', 'routes', 'tournees', 'result', 'results'];
      for (final key in keys) {
        final value = data[key];
        if (value is List) return value;
      }
      for (final value in data.values) {
        if (value is List) return value;
        if (value is Map) {
          for (final nested in value.values) {
            if (nested is List) return nested;
          }
        }
      }
      return [data];
    }
    return const [];
  }
}
