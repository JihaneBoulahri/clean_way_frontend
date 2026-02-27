import 'package:get/get.dart';
import '../../../services/camion_service.dart';
import '../../../models/camion_model.dart';
class CamionController extends GetxController {

  var camions = <Camion>[].obs;
  var isLoading = false.obs; 

  @override
  void onInit() {
    super.onInit();
    fetchCamions();
  }

  void fetchCamions() async {
    try {
      isLoading(true);
      final data = await CamionService.getAll();
      camions.value = data.map((json) => Camion.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load camions');
    } finally {
      isLoading(false);
    }
  }
  void addCamion(Camion camion) async {
    try {
      final data = await CamionService.create(camion.toJson());
      camions.add(Camion.fromJson(data));
      Get.snackbar('Success', 'Camion added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add camion');
    }
  }
  void updateCamion(int id, Camion camion) async {
    try {
      final data = await CamionService.update(id, camion.toJson());
      int index = camions.indexWhere((c) => c.id == id);
      if (index != -1) {
        camions[index] = Camion.fromJson(data);
        Get.snackbar('Success', 'Camion updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update camion');
    }
  }
  void deleteCamion(int id) async {
    try {
      await CamionService.delete(id);
      camions.removeWhere((c) => c.id == id);
      Get.snackbar('Success', 'Camion deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete camion');
    }
  }
  void getCamionById(int id) async {
    try {
      final data = await CamionService.getById(id);
      Camion camion = Camion.fromJson(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load camion details');
    }
  }
}