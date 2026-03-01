import 'package:get/get.dart';
import '../../../services/chauffeur_service.dart';
import '../../../models/chauffeur_model.dart';

class ChauffeurController extends GetxController {

  final ChauffeurService _service = ChauffeurService();
  var chauffeurs = <Chauffeur>[].obs;
  var isLoading = false.obs;
  var error = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchChauffeurs();
  }

  Future<void> fetchChauffeurs() async {
    try {
      isLoading(true);
      error.value = null;
      final data = await _service.getAll();
      chauffeurs.value = data.map((json) => Chauffeur.fromJson(json)).toList();
    } catch (e) {
      print('Error loading chauffeurs: $e');
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load chauffeurs: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
  void addChauffeur(Chauffeur chauffeur) async {
    try {
      final data = await _service.create(chauffeur.toJson());
      chauffeurs.add(Chauffeur.fromJson(data));
      Get.snackbar('Success', 'Chauffeur added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
  void updateChauffeur(int id, Chauffeur chauffeur) async {
    try {
      final data = await _service.update(id, chauffeur.toJson());
      int index = chauffeurs.indexWhere((c) => c.id == id);
      if (index != -1) {
        chauffeurs[index] = Chauffeur.fromJson(data);
        Get.snackbar('Success', 'Chauffeur updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update chauffeur: ${e.toString()} amina');
    }
  }
  void deleteChauffeur(int id) async {
    try {
      await _service.delete(id);
      chauffeurs.removeWhere((c) => c.id == id);
      Get.snackbar('Success', 'Chauffeur deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete chauffeur');
    }
  }
  void getChauffeurById(int id) async {
    try {
      final data = await _service.getById(id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get chauffeur details');
    }
  }
}