import 'package:clean_way_frontend/models/benne_model.dart';
import 'package:get/get.dart';
import '../../../services/benne_service.dart'; 

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

  void fetchBennes() async {
    try {
      isLoading(true);
      final data = await _service.getAllBennes();
      bennes.value = data.map((json) => Benne.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bennes');
    } finally {
      isLoading(false);
    }
  }
  Future<void> addBenne(Benne benne) async {
    try {
      final data = await _service.createBenne(benne.toJson());
      bennes.add(Benne.fromJson(data));
      Get.snackbar('Success', 'Benne added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add benne: ${e.toString()}');
    }
  }
  Future<void> updateBenne(int id, Benne benne) async {
    try {
      final data = await _service.updateBenne(id, benne.toJson());
      int index = bennes.indexWhere((b) => b.id == id);
      if (index != -1) {
        bennes[index] = Benne.fromJson(data);
        Get.snackbar('Success', 'Benne updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update benne: ${e.toString()}');
    }
  }
  Future<void> deleteBenne(int id) async {
    try {
      await _service.deleteBenne(id);
      bennes.removeWhere((b) => b.id == id);
      Get.snackbar('Success', 'Benne deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete benne: ${e.toString()}');
    }
  }
  void getBenneById(int id) async {
    try {
      final data = await _service.getBenneById(id);
      Benne benne = Benne.fromJson(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get benne details');
    }
  }
  void getBennesWithSensors() async {
    try {
      isLoading(true);
      final data = await _service.getBennesWithSensors();
      bennes.value = data.map((json) => Benne.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bennes with sensors');
    } finally {
      isLoading(false);
    }
  }
 //tanzido viderbenne
  
}