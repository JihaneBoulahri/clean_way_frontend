import 'package:clean_way_frontend/core/constants/filter_constants.dart';
import 'package:get/get.dart';
import '../../../core/services/camion_service.dart';
import '../models/camion_model.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/snackbar_helper.dart'; 

class CamionController extends GetxController {
  final CamionService _service = CamionService();
  var camions = <Camion>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var searchQuery = ''.obs;
  var filterType = FilterDefaults.all.obs;
  var filterStatus = FilterDefaults.all.obs;

  List<Camion> get filteredCamions {
    final q = searchQuery.value.trim().toLowerCase();
    return camions.where((c) {
      final matchesSearch = q.isEmpty ||
          c.immatriculation.toLowerCase().contains(q) ||
          c.typeCamion.toLowerCase().contains(q) ||
          c.status.toLowerCase().contains(q) ||
          c.capaciteCamion.toString().contains(q);
      final matchesType = filterType.value == FilterDefaults.all ||
          c.typeCamion.toLowerCase() == filterType.value.toLowerCase();
      final matchesStatus = filterStatus.value == FilterDefaults.all ||
          c.status.toLowerCase() == filterStatus.value.toLowerCase();
      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  bool get hasActiveFilters =>
      filterType.value != FilterDefaults.all ||
      filterStatus.value != FilterDefaults.all;

  List<String> get typeOptions =>
      _distinctStrings(camions.map((c) => c.typeCamion));

  List<String> get statusOptions =>
      _distinctStrings(camions.map((c) => c.status));

  void applyFilters({
    required String type,
    required String status,
  }) {
    filterType.value = type;
    filterStatus.value = status;
  }

  void resetFilters() {
    filterType.value = FilterDefaults.all;
    filterStatus.value = FilterDefaults.all;
  }

  List<String> _distinctStrings(Iterable<String> values) {
    final set = <String>{};
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        set.add(trimmed);
      }
    }
    final list = set.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
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
      
      showNadiSnackbar(
        title: "Erreur",
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
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
      // MODIFIÉ
      showNadiSnackbar(
        title: "Succès",
        message: "Camion ajouté avec succès",
        type: NadiSnackbarType.success,
      );
    } catch (e) {
      print('Erreur lors de l\'ajout: $e');
      _handleError(e);
    }
  }

  Future<void> updateCamion(Camion camion) async {
    try {
      final data = await _service.update(camion.id, camion.toJson());
      int index = camions.indexWhere((c) => c.id == camion.id);
      if (index != -1) {
        camions[index] = Camion.fromJson(data);
        // MODIFIÉ
        showNadiSnackbar(
          title: "Succès",
          message: "Camion modifié avec succès",
          type: NadiSnackbarType.success,
        );
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteCamion(int id) async {
    try {
      await _service.delete(id);
      camions.removeWhere((c) => c.id == id);
      
      showNadiSnackbar(
        title: "Succès",
        message: "Camion supprimé avec succès",
        type: NadiSnackbarType.success,
      );
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
