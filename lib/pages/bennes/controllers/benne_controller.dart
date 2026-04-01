import 'package:clean_way_frontend/core/constants/filter_constants.dart';
import 'package:clean_way_frontend/pages/bennes/models/benne_model.dart';
import 'package:get/get.dart';
import '../../../core/services/benne_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/snackbar_helper.dart'; 

class BennesController extends GetxController {
  final BenneService _service = BenneService();
  var bennes = <Benne>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var filterType = FilterDefaults.all.obs;
  var filterCapteur = FilterDefaults.all.obs;
  var filterCapteurStatus = FilterDefaults.all.obs;

  List<Benne> get filteredBennes {
    final q = searchQuery.value.trim().toLowerCase();
    return bennes.where((b) {
      final matchesSearch = q.isEmpty ||
          b.typeBenne.toLowerCase().contains(q) ||
          b.capacite.toString().contains(q) ||
          b.latitude.toLowerCase().contains(q) ||
          b.longitude.toLowerCase().contains(q);
      final matchesType = filterType.value == FilterDefaults.all ||
          b.typeBenne.toLowerCase() == filterType.value.toLowerCase();
      final matchesCapteur = filterCapteur.value == FilterDefaults.all ||
          (filterCapteur.value == FilterDefaults.withCapteur && b.capteur != null) ||
          (filterCapteur.value == FilterDefaults.withoutCapteur && b.capteur == null);
      final capteurStatus = b.capteur?.status.toLowerCase() ?? '';
      final matchesStatus = filterCapteurStatus.value == FilterDefaults.all ||
          capteurStatus == filterCapteurStatus.value.toLowerCase();
      return matchesSearch && matchesType && matchesCapteur && matchesStatus;
    }).toList();
  }

  bool get hasActiveFilters =>
      filterType.value != FilterDefaults.all ||
      filterCapteur.value != FilterDefaults.all ||
      filterCapteurStatus.value != FilterDefaults.all;

  List<String> get typeOptions =>
      _distinctStrings(bennes.map((b) => b.typeBenne));

  List<String> get capteurStatusOptions =>
      _distinctStrings(bennes.map((b) => b.capteur?.status ?? ''));

  void applyFilters({
    required String type,
    required String capteur,
    required String status,
  }) {
    filterType.value = type;
    filterCapteur.value = capteur;
    filterCapteurStatus.value = status;
  }

  void resetFilters() {
    filterType.value = FilterDefaults.all;
    filterCapteur.value = FilterDefaults.all;
    filterCapteurStatus.value = FilterDefaults.all;
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
    fetchBennes();
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
      
      showNadiSnackbar(
        title: "Succès",
        message: "Benne ajoutée avec succès",
        type: NadiSnackbarType.success,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateBenne(Benne benne) async {
    try {
      final data = await _service.updateBenne(benne.id, benne.toJson());
      int index = bennes.indexWhere((b) => b.id == benne.id);
      if (index != -1) {
        bennes[index] = Benne.fromJson(data);
       
        showNadiSnackbar(
          title: "Succès",
          message: "Benne modifiée avec succès",
          type: NadiSnackbarType.success,
        );
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteBenne(int id) async {
    try {
      await _service.deleteBenne(id);
      bennes.removeWhere((b) => b.id == id);
      
      showNadiSnackbar(
        title: "Succès",
        message: "Benne supprimée avec succès",
        type: NadiSnackbarType.success,
      );
    } catch (e) {
      _handleError(e);
    }
  }

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

  Future<Benne?> getBenneDetails(int id) async {
    try {
      final data = await _service.getBenneById(id);
      return Benne.fromJson(data is List ? data.first : data);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
}
