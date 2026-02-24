import 'package:get/get.dart';
import '../services/stats_service.dart';

class DashboardController extends GetxController {
  final StatsService _statsService = StatsService();

  var stats = Rxn<Map<String, dynamic>>();
  var loading = true.obs;
  var error = RxnString();

  @override
  void onInit() {
    fetchStats();
    super.onInit();
  }

  Future<void> fetchStats() async {
    try {
      loading.value = true;
      error.value = null;

      final data = await _statsService.fetchStats();
      stats.value = data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
