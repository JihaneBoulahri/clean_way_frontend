import 'package:get/get.dart';
import '../services/optimization_service.dart';
import '../services/stats_service.dart';
import '../widgets/snackbar_helper.dart'; 

class DashboardController extends GetxController {
  final StatsService _statsService = StatsService();
  final OptimizationService _optimizationService = OptimizationService();

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

  Future<void> fetchStats() async {
    try {
      stats_loading.value = true;
      stats_error.value = null;

      final data = await _statsService.fetchStats();
      stats.value = data;

    } catch (e) {
      stats_error.value = e.toString();
    } finally {
      stats_loading.value = false;
    }
  }

  Future<void> optimiser() async {
    try {
      optimisation_loading.value = true;
      optimisation_error.value = null;

      final data = await _optimizationService.optimiser();

      routes.value = _extractRoutesList(data); // store optimized routes

      // MODIFIÉ : snackbar de succès
      showNadiSnackbar(
        title: "Succès",
        message: "Tournée optimisée avec succès",
        type: NadiSnackbarType.success,
      );

    } catch (e) {
      optimisation_error.value = e.toString();

      // MODIFIÉ : snackbar d'erreur
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