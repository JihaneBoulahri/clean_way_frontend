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

  void _handleError(dynamic e) {
    if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.snackbar('Erreur', e.toString());
    }
  }

  void fetchZones() async {
    try {
      isLoading(true);
      final data = await _service.getAll();
      zones.value = data.map((json) => Zone.fromJson(json)).toList();
    } catch (e) {
      error.value = e.toString();
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addZone(Zone zone) async {
    try {
      final data = await _service.create(zone.toJson());
      zones.add(Zone.fromJson(data));
      Get.snackbar('Succès', 'Zone ajoutée avec succès');
    } catch (e) {
      _handleError(e);
    }
  }

  // Modification : on passe directement l'objet Zone (qui contient son id)
  Future<void> updateZone(Zone zone) async {
    try {
      final data = await _service.update(zone.id, zone.toJson());
      int index = zones.indexWhere((z) => z.id == zone.id);
      if (index != -1) {
        zones[index] = Zone.fromJson(data);
        Get.snackbar('Succès', 'Zone modifiée avec succès');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteZone(int id) async {
    try {
      await _service.delete(id);
      zones.removeWhere((z) => z.id == id);
      Get.snackbar('Succès', 'Zone supprimée avec succès');
    } catch (e) {
      _handleError(e);
    }
  }

  // Méthode inutilisée supprimée (getZoneById)
}