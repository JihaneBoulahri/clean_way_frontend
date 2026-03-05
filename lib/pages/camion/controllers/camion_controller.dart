import 'package:get/get.dart';
import '../../../services/camion_service.dart';
import '../../../models/camion_model.dart';
import '../../../routes/app_routes.dart';

class CamionController extends GetxController {
  final CamionService _service = CamionService();
  var camions = <Camion>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var searchQuery = ''.obs;

  List<Camion> get filteredCamions {
    if (searchQuery.value.trim().isEmpty) return camions;
    final q = searchQuery.value.trim().toLowerCase();
    return camions.where((c) {
      return c.immatriculation.toLowerCase().contains(q) ||
          c.typeCamion.toLowerCase().contains(q) ||
          c.status.toLowerCase().contains(q) ||
          c.capaciteCamion.toString().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCamions();
  }

  void _handleError(dynamic e) {
    if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> fetchCamions() async {
    try {
      isLoading(true);
      error.value = null;
      final data = await _service.getAll();
      camions.value = data.map((json) => Camion.fromJson(json)).toList();
    } catch (e) {
      error.value = e.toString();
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addCamion(Camion camion) async {
    try {
      final data = await _service.create(camion.toJson());
      camions.add(Camion.fromJson(data));
      Get.snackbar('Succès', 'Camion ajouté avec succès');
    } catch (e) {
      print('Erreur lors de l\'ajout: $e'); // Pour déboguer
      _handleError(e);
    }
  }

  Future<void> updateCamion(Camion camion) async {
    try {
      final data = await _service.update(camion.id, camion.toJson());
      int index = camions.indexWhere((c) => c.id == camion.id);
      if (index != -1) {
        camions[index] = Camion.fromJson(data);
        Get.snackbar('Succès', 'Camion modifié avec succès');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteCamion(int id) async {
    try {
      await _service.delete(id);
      camions.removeWhere((c) => c.id == id);
      Get.snackbar('Succès', 'Camion supprimé avec succès');
    } catch (e) {
      _handleError(e);
    }
  }

  /// Fetch detailed camion with all relations
  Future<Camion?> getCamionDetails(int id) async {
    try {
      final data = await _service.getWithRelations(id);
      return Camion.fromJson(data is List ? data.first : data);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
}