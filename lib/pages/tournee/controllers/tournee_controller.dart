import 'package:clean_way_frontend/models/tournee_model.dart';
import 'package:get/get.dart';
import '../../../services/tournee_service.dart';
import '../../../routes/app_routes.dart';

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

  void _handleError(dynamic e, {bool showSnackbar = true}) {
    final errorMsg = e.toString();
    if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
      Get.offAllNamed(AppRoutes.login);
    } else if (errorMsg.contains('404') || errorMsg.contains('Not Found')) {
      fetchTournees();
      if (showSnackbar) Get.snackbar('Info', 'L\'élément a été supprimé ailleurs');
    } else {
      if (showSnackbar) Get.snackbar('Erreur', errorMsg);
    }
  }

  void fetchTournees() async {
    try {
      isLoading(true);
      final data = await _service.getAll();
      tournees.value = data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, showSnackbar: false);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addTournee(Tournee tournee) async {
    try {
      final data = await _service.create(tournee.toJson());
      tournees.add(Tournee.fromJson(data));
      Get.snackbar('Succès', 'Tournée ajoutée avec succès');
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateTournee(Tournee tournee) async {
    try {
      final data = await _service.update(tournee.id, tournee.toJson());
      int index = tournees.indexWhere((t) => t.id == tournee.id);
      if (index != -1) {
        tournees[index] = Tournee.fromJson(data);
        Get.snackbar('Succès', 'Tournée modifiée avec succès');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteTournee(int id) async {
    try {
      await _service.delete(id);
      tournees.removeWhere((t) => t.id == id);
      Get.snackbar('Succès', 'Tournée supprimée avec succès');
    } catch (e) {
      _handleError(e);
    }
  }

  void searchTournees(String query) async {
    try {
      isLoading(true);
      final data = await _service.search(query);
      tournees.value = data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  /// Fetch detailed tournee with all relations (camion, zone)
  Future<Tournee?> getTourneeDetails(int id) async {
    try {
      final data = await _service.getWithRelations(id);
      return Tournee.fromJson(data is List ? data.first : data);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
}