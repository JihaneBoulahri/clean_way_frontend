import 'package:clean_way_frontend/models/zone_model.dart';
import 'package:get/get.dart';
import '../../../services/zone_service.dart';

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

  void fetchZones() async {
    try {
      isLoading(true);
      final data = await _service.getAll();
      zones.value = data.map((json) => Zone.fromJson(json)).toList();
    } catch (e) {
      error.value = e.toString();
      print('Error loading zones: $e');
      Get.snackbar('Error', 'Failed to load zones');
    } finally {
      isLoading(false);
    }
  }
  void addZone(Zone zone) async {
    try {
      final data = await _service.create(zone.toJson());
      zones.add(Zone.fromJson(data));
      Get.snackbar('Success', 'Zone added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add zone');
    }
  }
  void updateZone(int id, Zone zone) async {
    try {
      final data = await _service.update(id, zone.toJson());
      int index = zones.indexWhere((z) => z.id == id);
      if (index != -1) {
        zones[index] = Zone.fromJson(data);
        Get.snackbar('Success', 'Zone updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update zone');
    }
  }
  void deleteZone(int id) async {
    try {
      await _service.delete(id);
      zones.removeWhere((z) => z.id == id);
      Get.snackbar('Success', 'Zone deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete zone');
    }
  }
  void getZoneById(int id) async {
    try {
      final data = await _service.getById(id);
      Zone zone = Zone.fromJson(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load zone details');
    }
  }
}