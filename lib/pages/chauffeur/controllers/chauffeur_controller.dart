import 'package:get/get.dart';
import '../../../services/chauffeur_service.dart';
import '../../../models/chauffeur_model.dart';
import '../../../models/user_model.dart';

class ChauffeurController extends GetxController {
  final ChauffeurService _service = ChauffeurService();
  var chauffeurs = <Chauffeur>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var searchQuery = ''.obs;

  List<Chauffeur> get filteredChauffeurs {
    if (searchQuery.value.trim().isEmpty) return chauffeurs;
    final q = searchQuery.value.trim().toLowerCase();
    return chauffeurs.where((c) {
      final phone = c.numTelephone.toLowerCase();
      final cni = c.cni.toLowerCase();
      final permis = c.permis.toLowerCase();
      final camionId = c.camion?.id.toString() ?? '';
      final userId = c.user?.id.toString() ?? '';
      final userName = c.user?.fullName.toLowerCase() ?? '';
      return phone.contains(q) ||
          cni.contains(q) ||
          permis.contains(q) ||
          camionId.contains(q) ||
          userId.contains(q) ||
          userName.contains(q);
    }).toList();
  }

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
      // ignore: avoid_print
      print('Error loading chauffeurs: $e');
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load chauffeurs: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addChauffeur(Chauffeur chauffeur) async {
    try {
      final data = await _service.create(chauffeur.toJson());
      chauffeurs.add(Chauffeur.fromJson(data));
      Get.snackbar('Success', 'Chauffeur added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> updateChauffeur(int id, Chauffeur chauffeur) async {
    try {
      final data = await _service.update(id, chauffeur.toJson());
      final index = chauffeurs.indexWhere((c) => c.id == id);
      if (index != -1) {
        chauffeurs[index] = Chauffeur.fromJson(data);
        Get.snackbar('Success', 'Chauffeur updated successfully');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update chauffeur: ${e.toString()}',
      );
    }
  }

  Future<void> deleteChauffeur(int id) async {
    try {
      await _service.delete(id);
      chauffeurs.removeWhere((c) => c.id == id);
      Get.snackbar('Success', 'Chauffeur deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete chauffeur: ${e.toString()}');
    }
  }

  void getChauffeurById(int id) async {
    try {
      await _service.getById(id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get chauffeur details');
    }
  }
}