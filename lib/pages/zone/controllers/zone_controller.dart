import 'package:clean_way_frontend/models/zone_model.dart';
import 'package:get/get.dart';
import '../../../services/zone_service.dart';

class ZoneController extends GetxController {
  var zones = <Zone>[].obs;
  var isLoading = false.obs; 

  @override
  void onInit() {
    super.onInit();
    fetchZones();
  }

  void fetchZones() async {
    try {
      isLoading(true);
      final data = await ZoneService.getAll();
      zones.value = data.map((json) => Zone.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load zones');
    } finally {
      isLoading(false);
    }
  }
  void addZone(Zone zone) async {
    try {
      final data = await ZoneService.create(zone.toJson());
      zones.add(Zone.fromJson(data));
      Get.snackbar('Success', 'Zone added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add zone');
    }
  }
  void updateZone(int id, Zone zone) async {
    try {
      final data = await ZoneService.update(id, zone.toJson());
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
      await ZoneService.delete(id);
      zones.removeWhere((z) => z.id == id);
      Get.snackbar('Success', 'Zone deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete zone');
    }
  }
  void getZoneById(int id) async {
    try {
      final data = await ZoneService.getById(id);
      Zone zone = Zone.fromJson(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load zone details');
    }
  }
}