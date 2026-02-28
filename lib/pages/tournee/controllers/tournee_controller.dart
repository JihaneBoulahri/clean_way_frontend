import 'package:clean_way_frontend/models/tournee_model.dart';
import 'package:get/get.dart';
import '../../../services/tournee_service.dart';

class TourneeController extends GetxController {
  var tournees = <Tournee>[].obs;
  var isLoading = false.obs; 

  @override
  void onInit() {
    super.onInit();
    fetchTournees();
  }

  void fetchTournees() async {
    try {
      isLoading(true);
      final data = await TourneeService.getAll();
      tournees.value = data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tournees');
    } finally {
      isLoading(false);
    }
  }
  void addTournee(Tournee tournee) async {
    try {
      final data = await TourneeService.create(tournee.toJson());
      tournees.add(Tournee.fromJson(data));
      Get.snackbar('Success', 'Tournee added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add tournee');
    }
  }
  void updateTournee(int id, Tournee tournee) async {
    try {
      final data = await TourneeService.update(id, tournee.toJson());
      int index = tournees.indexWhere((t) => t.id == id);
      if (index != -1) {
        tournees[index] = Tournee.fromJson(data);
        Get.snackbar('Success', 'Tournee updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update tournee');
    }
  }
  void deleteTournee(int id) async {
    try {
      await TourneeService.delete(id);
      tournees.removeWhere((t) => t.id == id);
      Get.snackbar('Success', 'Tournee deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete tournee');
    }
  }
  void getTourneeById(int id) async {
    try {
      final data = await TourneeService.getById(id);
      Tournee tournee = Tournee.fromJson(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tournee details');
    }
  }
  void searchTournees(String query) async {
    try {
      isLoading(true);
      final data = await TourneeService.search(query);
      tournees.value = data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to search tournees');
    } finally {
      isLoading(false);
    }
  }
  
}