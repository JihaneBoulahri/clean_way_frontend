import 'package:clean_way_frontend/models/benne_model.dart';
import 'package:get/get.dart';
import '../../../services/benne_service.dart';
import '../../../routes/app_routes.dart';

class BennesController extends GetxController {
  final BenneService _service = BenneService();
  var bennes = <Benne>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  List<Benne> get filteredBennes {
    if (searchQuery.value.trim().isEmpty) return bennes;
    final q = searchQuery.value.trim().toLowerCase();
    return bennes.where((b) {
      return b.typeBenne.toLowerCase().contains(q) ||
          b.capacite.toString().contains(q) ||
          b.latitude.toLowerCase().contains(q) ||
          b.longitude.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchBennes();
  }

  void _handleError(dynamic e) {
    if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.snackbar('Erreur', e.toString());
    }
  }

  void fetchBennes() async {
    try {
      isLoading(true);
      final data = await _service.getAllBennes();
      bennes.value = data.map((json) => Benne.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addBenne(Benne benne) async {
    try {
      final data = await _service.createBenne(benne.toJson());
      bennes.add(Benne.fromJson(data));
      Get.snackbar('Succès', 'Benne ajoutée avec succès');
    } catch (e) {
      _handleError(e);
    }
  }

  // Modification : on passe directement l'objet Benne (qui contient son id)
  Future<void> updateBenne(Benne benne) async {
    try {
      final data = await _service.updateBenne(benne.id, benne.toJson());
      int index = bennes.indexWhere((b) => b.id == benne.id);
      if (index != -1) {
        bennes[index] = Benne.fromJson(data);
        Get.snackbar('Succès', 'Benne modifiée avec succès');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteBenne(int id) async {
    try {
      await _service.deleteBenne(id);
      bennes.removeWhere((b) => b.id == id);
      Get.snackbar('Succès', 'Benne supprimée avec succès');
    } catch (e) {
      _handleError(e);
    }
  }

  // Méthode inutilisée supprimée (getBenneById)
  // Méthode getBennesWithSensors conservée
  void getBennesWithSensors() async {
    try {
      isLoading(true);
      final data = await _service.getBennesWithSensors();
      bennes.value = data.map((json) => Benne.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }
}