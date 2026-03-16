import 'package:get/get.dart';
import '../../../services/chauffeur_service.dart';
import '../../../models/chauffeur_model.dart';
import '../../../models/tournee_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/filter_constants.dart';

class ChauffeurController extends GetxController {
  final bool autoFetch;
  final ChauffeurService _service = ChauffeurService();
  var chauffeurs = <Chauffeur>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var searchQuery = ''.obs;
  var filterAffectation = FilterDefaults.all.obs;
  var filterPermis = FilterDefaults.all.obs;

  ChauffeurController({this.autoFetch = true});

  List<Chauffeur> get filteredChauffeurs {
    final q = searchQuery.value.trim().toLowerCase();
    return chauffeurs.where((c) {
      final phone = c.numTelephone.toLowerCase();
      final cni = c.cni.toLowerCase();
      final permis = c.permis.toLowerCase();
      final camionId = c.camion?.id.toString() ?? '';
      final userId = c.user?.id.toString() ?? '';
      final userName = c.user?.fullName.toLowerCase() ?? '';
      final matchesSearch = q.isEmpty ||
          phone.contains(q) ||
          cni.contains(q) ||
          permis.contains(q) ||
          camionId.contains(q) ||
          userId.contains(q) ||
          userName.contains(q);
      final matchesAffectation = filterAffectation.value == FilterDefaults.all ||
          (filterAffectation.value == FilterDefaults.withCamion && c.camion != null) ||
          (filterAffectation.value == FilterDefaults.withoutCamion && c.camion == null);
      final matchesPermis = filterPermis.value == FilterDefaults.all ||
          c.permis.toLowerCase() == filterPermis.value.toLowerCase();
      return matchesSearch && matchesAffectation && matchesPermis;
    }).toList();
  }

  bool get hasActiveFilters =>
      filterAffectation.value != FilterDefaults.all ||
      filterPermis.value != FilterDefaults.all;

  List<String> get permisOptions =>
      _distinctStrings(chauffeurs.map((c) => c.permis));

  void applyFilters({
    required String affectation,
    required String permis,
  }) {
    filterAffectation.value = affectation;
    filterPermis.value = permis;
  }

  void resetFilters() {
    filterAffectation.value = FilterDefaults.all;
    filterPermis.value = FilterDefaults.all;
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
    if (autoFetch) {
      fetchChauffeurs();
    }
  }

  void _handleError(
    dynamic e, {
    bool showSnackbar = true,
    bool refreshOnNotFound = true,
  }) {
    final errorMsg = e.toString();
    if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
      Get.offAllNamed(AppRoutes.login);
    } else if (errorMsg.contains('404') || errorMsg.contains('Not Found')) {
      // L'element n'existe plus, on rafraichit la liste
      if (refreshOnNotFound) {
        fetchChauffeurs();
      }
      if (showSnackbar) {
        Get.snackbar('Info', "L'element a ete supprime ailleurs");
      }
    } else {
      if (showSnackbar) Get.snackbar('Erreur', errorMsg);
    }
  }

  Future<void> fetchChauffeurs() async {
    try {
      isLoading(true);
      error.value = null;
      final data = await _service.getAll();
      chauffeurs.value = data.map((json) => Chauffeur.fromJson(json)).toList();
    } catch (e) {
      error.value = e.toString();
      _handleError(e, showSnackbar: false);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addChauffeur(Chauffeur chauffeur) async {
    try {
      final data = await _service.create(chauffeur.toJson());
      chauffeurs.add(Chauffeur.fromJson(data));
      Get.snackbar('Succès', 'Chauffeur ajouté avec succès');
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateChauffeur(Chauffeur chauffeur) async {
    try {
      final data = await _service.update(chauffeur.id, chauffeur.toJson());
      final index = chauffeurs.indexWhere((c) => c.id == chauffeur.id);
      if (index != -1) {
        chauffeurs[index] = Chauffeur.fromJson(data);
        Get.snackbar('Succès', 'Chauffeur modifié avec succès');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteChauffeur(int id) async {
    try {
      await _service.delete(id);
      chauffeurs.removeWhere((c) => c.id == id);
      Get.snackbar('Succès', 'Chauffeur supprimé avec succès');
    } catch (e) {
      _handleError(e);
    }
  }

  /// Fetch detailed chauffeur with all relations (user, camion)
  Future<Chauffeur?> getChauffeurDetails(int id) async {
    try {
      final data = await _service.getWithRelations(id);
      return Chauffeur.fromJson(data is List ? data.first : data);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  /// Fetch tournees for the authenticated chauffeur
  Future<List<Tournee>> fetchMyTournees({bool showSnackbar = true}) async {
    try {
      final data = await _service.getMyTournees();
      return data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      _handleError(
        e,
        showSnackbar: showSnackbar,
        refreshOnNotFound: false,
      );
      rethrow;
    }
  }
}
