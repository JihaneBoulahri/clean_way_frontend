import 'package:clean_way_frontend/models/tournee_model.dart';
import 'package:get/get.dart';
import '../../../services/tournee_service.dart';

class TourneeController extends GetxController {
  final TourneeService _service = TourneeService();
  var tournees = <Tournee>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  void searchOrFetch(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      fetchTournees();
    } else {
      searchTournees(query.trim());
    }
  } 

  @override
  void onInit() {
    super.onInit();
    fetchTournees();
  }

  void fetchTournees() async {
    try {
      isLoading(true);
      final data = await _service.getAll();
      tournees.value = data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      print('Error loading tournees: $e');
      Get.snackbar('Error', 'Failed to load tournees');
    } finally {
      isLoading(false);
    }
  }
  Future<void> addTournee(Tournee tournee) async {
    try {
      final data = await _service.create(tournee.toJson());
      tournees.add(Tournee.fromJson(data));
      Get.snackbar('Success', 'Tournee added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add tournee: ${e.toString()}');
    }
  }
  Future<void> updateTournee(int id, Tournee tournee) async {
    try {
      final data = await _service.update(id, tournee.toJson());
      int index = tournees.indexWhere((t) => t.id == id);
      if (index != -1) {
        tournees[index] = Tournee.fromJson(data);
        Get.snackbar('Success', 'Tournee updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update tournee: ${e.toString()}');
    }
  }
  Future<void> deleteTournee(int id) async {
    try {
      await _service.delete(id);
      tournees.removeWhere((t) => t.id == id);
      Get.snackbar('Success', 'Tournee deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete tournee: ${e.toString()}');
    }
  }
  void getTourneeById(int id) async {
    try {
      final data = await _service.getById(id);
      Tournee tournee = Tournee.fromJson(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tournee details');
    }
  }
  void searchTournees(String query) async {
    try {
      isLoading(true);
      final data = await _service.search(query);
      tournees.value = data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to search tournees');
    } finally {
      isLoading(false);
    }
  }
  
}