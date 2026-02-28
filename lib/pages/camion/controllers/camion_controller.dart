import 'package:get/get.dart';
import '../../../services/camion_service.dart';
import '../../../models/camion_model.dart';
class CamionController extends GetxController {

  final CamionService _service = CamionService();
  var camions = <Camion>[].obs;
  var isLoading = false.obs;
  var error = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchCamions();
  }

  Future<void> fetchCamions() async {
    try {
      isLoading(true);
      error.value = null;
      final data = await _service.getAll();
      camions.value = data.map((json) => Camion.fromJson(json)).toList();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load camions: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
  void addCamion(Camion camion) async {
    try {
      final data = await _service.create(camion.toJson());
      camions.add(Camion.fromJson(data));
      Get.snackbar('Success', 'Camion added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
  void updateCamion(int id, Camion camion) async {
    try {
      final data = await _service.update(id, camion.toJson());
      int index = camions.indexWhere((c) => c.id == id);
      if (index != -1) {
        camions[index] = Camion.fromJson(data);
        Get.snackbar('Success', 'Camion updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update camion: ${e.toString()} amina');
    }
  }
  void deleteCamion(int id) async {
    try {
      await _service.delete(id);
      camions.removeWhere((c) => c.id == id);
      Get.snackbar('Success', 'Camion deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete camion');
    }
  }
  void getCamionById(int id) async {
    try {
      final data = await _service.getById(id);
      Camion camion = Camion.fromJson(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load camion details');
    }
  }
}