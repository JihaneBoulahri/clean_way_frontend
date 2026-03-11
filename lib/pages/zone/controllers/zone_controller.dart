import 'package:clean_way_frontend/models/zone_model.dart';
import 'package:get/get.dart';
import '../../../services/zone_service.dart';
import '../../../routes/app_routes.dart';

class ZoneController extends GetxController {
  final ZoneService _service = ZoneService();
  var zones = <Zone>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var searchQuery = ''.obs;

  List<Zone> get filteredZones {
    if (searchQuery.value.trim().isEmpty) return zones;
    final q = searchQuery.value.trim().toLowerCase();
    return zones.where((z) {
      return z.nomZone.toLowerCase().contains(q) ||
          z.typeZone.toLowerCase().contains(q) ||
          z.latitude.toLowerCase().contains(q) ||
          z.longitude.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchZones();
  }

  void _handleError(dynamic e, {bool showSnackbar = true}) {
    final errorMsg = e.toString();
    if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      if (showSnackbar) Get.snackbar('Erreur', errorMsg);
    }
  }

  Future<void> fetchZones() async {
    try {
      isLoading(true);
      error.value = null;
      final data = await _service.getAll();
      zones.value = data.map((json) => Zone.fromJson(json)).toList();
    } catch (e) {
      error.value = e.toString();
      _handleError(e, showSnackbar: false);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addZone(Zone zone) async {
    try {
      final data = await _service.create(zone.toJson());
      zones.add(Zone.fromJson(data));
      Get.snackbar('Succes', 'Zone ajoutee avec succes');
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateZone(Zone zone) async {
    try {
      final data = await _service.update(zone.id, zone.toJson());
      int index = zones.indexWhere((z) => z.id == zone.id);
      if (index != -1) {
        final updatedZone = Zone.fromJson(data);
        zones[index] = updatedZone;
        zones.refresh();
        Get.snackbar('Succes', 'Zone modifiee avec succes');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteZone(int id) async {
    try {
      await _service.delete(id);
      zones.removeWhere((z) => z.id == id);
      Get.snackbar('Succes', 'Zone supprimee avec succes');
    } catch (e) {
      _handleError(e);
    }
  }
}
