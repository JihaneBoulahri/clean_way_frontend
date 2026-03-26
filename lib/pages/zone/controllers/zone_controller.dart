import 'package:clean_way_frontend/core/constants/filter_constants.dart';
import 'package:clean_way_frontend/pages/zone/models/zone_model.dart';
import 'package:get/get.dart';
import '../../../core/services/zone_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/snackbar_helper.dart'; 

class ZoneController extends GetxController {
  final ZoneService _service = ZoneService();
  var zones = <Zone>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var searchQuery = ''.obs;
  var filterType = FilterDefaults.all.obs;

  List<Zone> get filteredZones {
    final q = searchQuery.value.trim().toLowerCase();
    return zones.where((z) {
      final matchesSearch = q.isEmpty ||
          z.nomZone.toLowerCase().contains(q) ||
          z.typeZone.toLowerCase().contains(q) ||
          z.latitude.toLowerCase().contains(q) ||
          z.longitude.toLowerCase().contains(q);
      final matchesType = filterType.value == FilterDefaults.all ||
          z.typeZone.toLowerCase() == filterType.value.toLowerCase();
      return matchesSearch && matchesType;
    }).toList();
  }

  bool get hasActiveFilters => filterType.value != FilterDefaults.all;

  List<String> get typeOptions =>
      _distinctStrings(zones.map((z) => z.typeZone));

  void applyFilters({required String type}) {
    filterType.value = type;
  }

  void resetFilters() {
    filterType.value = FilterDefaults.all;
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
    fetchZones();
  }

  void _handleError(dynamic e, {bool showSnackbar = true}) {
    final errorMsg = e.toString();
    if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      if (showSnackbar) {
        
        showNadiSnackbar(
          title: "Erreur",
          message: errorMsg,
          type: NadiSnackbarType.error,
        );
      }
    }
  }

  Future<void> fetchZones() async {
    try {
      isLoading(true);
      error.value = null;
      final data = await _service.getAll();
      zones.value = data.map((json) => Zone.fromJson(json)).toList();
    } catch (e) {
      error.value = e.toString();
      _handleError(e, showSnackbar: false);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addZone(Zone zone) async {
    try {
      final data = await _service.create(zone.toJson());
      zones.add(Zone.fromJson(data));
    
      showNadiSnackbar(
        title: "Succès",
        message: "Zone ajoutée avec succès",
        type: NadiSnackbarType.success,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateZone(Zone zone) async {
    try {
      final data = await _service.update(zone.id, zone.toJson());
      int index = zones.indexWhere((z) => z.id == zone.id);
      if (index != -1) {
        final updatedZone = Zone.fromJson(data);
        zones[index] = updatedZone;
        zones.refresh();
      
        showNadiSnackbar(
          title: "Succès",
          message: "Zone modifiée avec succès",
          type: NadiSnackbarType.success,
        );
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteZone(int id) async {
    try {
      await _service.delete(id);
      zones.removeWhere((z) => z.id == id);
      
      showNadiSnackbar(
        title: "Succès",
        message: "Zone supprimée avec succès",
        type: NadiSnackbarType.success,
      );
    } catch (e) {
      _handleError(e);
    }
  }
}
