import 'package:get/get.dart';
import '../../../core/services/chauffeur_service.dart';
import '../../../core/services/user_service.dart';
import '../models/chauffeur_model.dart';
import '../../tournee/models/tournee_model.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/snackbar_helper.dart';

class ChauffeurController extends GetxController {
  final bool autoFetch;
  final ChauffeurService _chauffeurService = ChauffeurService();
  var chauffeurs = <Chauffeur>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var searchQuery = ''.obs;

  ChauffeurController({this.autoFetch = true});

  List<Chauffeur> get filteredChauffeurs {
    if (searchQuery.value.trim().isEmpty) return chauffeurs;
    final q = searchQuery.value.trim().toLowerCase();
    return chauffeurs.where((c) {
      final phone = c.numTelephone.toLowerCase();
      final cni = c.cni.toLowerCase();
      final permis = c.permis.toLowerCase();
      final email = c.user?.email.toLowerCase() ?? '';
      final camionId = (c.camionId ?? c.camion?.id)?.toString() ?? '';
      final userId = (c.userId ?? c.user?.id)?.toString() ?? '';
      final userName = c.user?.fullName.toLowerCase() ?? '';
      return phone.contains(q) ||
          cni.contains(q) ||
          permis.contains(q) ||
          email.contains(q) ||
          camionId.contains(q) ||
          userId.contains(q) ||
          userName.contains(q);
    }).toList();
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
      if (refreshOnNotFound) {
        fetchChauffeurs();
      }
      if (showSnackbar) {
        showNadiSnackbar(
          title: "Info",
          message: "L'élément a été supprimé ailleurs",
          type: NadiSnackbarType.info,
        );
      }
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

  Future<void> fetchChauffeurs() async {
    try {
      isLoading(true);
      error.value = null;
      final response = await UserService.getUsers();
      final rows = _extractList(response);
      final users = rows
          .whereType<Map>()
          .map((raw) => Map<String, dynamic>.from(raw))
          .where(_isChauffeurLike)
          .toList();

      final chauffeurByUserId = await _fetchChauffeurDetailsByUserId();
      final mapped = users
          .map(
            (userJson) => _mergeUserWithChauffeur(userJson, chauffeurByUserId),
          )
          .map(Chauffeur.fromJson)
          .toList();
      chauffeurs.value = mapped;
    } catch (e) {
      error.value = e.toString();
      _handleError(e, showSnackbar: false);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addChauffeur(Map<String, dynamic> payload) async {
    try {
      final response = await UserService.create(payload);
      final created = _extractMap(response);
      final chauffeur = created == null ? null : Chauffeur.fromJson(created);
      if (chauffeur != null && _isChauffeurModel(chauffeur)) {
        chauffeurs.add(chauffeur);
      } else {
        await fetchChauffeurs();
      }

      showNadiSnackbar(
        title: "Succès",
        message: "Chauffeur ajouté avec succès",
        type: NadiSnackbarType.success,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateChauffeur(int userId, Map<String, dynamic> payload) async {
    try {
      final response = await UserService.update(userId, payload);
      final updatedMap = _extractMap(response);
      final updated = updatedMap == null
          ? null
          : Chauffeur.fromJson(updatedMap);
      final index = chauffeurs.indexWhere((c) => c.id == userId);
      if (index != -1) {
        if (updated != null && _isChauffeurModel(updated)) {
          chauffeurs[index] = updated;
        } else {
          await fetchChauffeurs();
        }

        showNadiSnackbar(
          title: "Succès",
          message: "Chauffeur modifié avec succès",
          type: NadiSnackbarType.success,
        );
      } else {
        await fetchChauffeurs();
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteChauffeur(int userId) async {
    try {
      await UserService.delete(userId);
      chauffeurs.removeWhere((c) => c.id == userId);

      showNadiSnackbar(
        title: "Succès",
        message: "Chauffeur supprimé avec succès",
        type: NadiSnackbarType.success,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  /// Fetch detailed chauffeur through users API
  Future<Chauffeur?> getChauffeurDetails(int userId) async {
    try {
      final response = await UserService.getById(userId);
      final map = _extractMap(response);
      if (map == null || !_isChauffeurLike(map)) return null;

      final chauffeurByUserId = await _fetchChauffeurDetailsByUserId();
      final merged = _mergeUserWithChauffeur(map, chauffeurByUserId);
      return Chauffeur.fromJson(merged);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  /// Fetch tournees for the authenticated chauffeur
  Future<List<Tournee>> fetchMyTournees({bool showSnackbar = true}) async {
    try {
      final data = await _chauffeurService.getMyTournees();
      return data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, showSnackbar: showSnackbar, refreshOnNotFound: false);
      rethrow;
    }
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) {
      return response;
    }
    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final data = map['data'];
      if (data is List) {
        return data;
      }
    }
    return const [];
  }

  Map<String, dynamic>? _extractMap(dynamic response) {
    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final data = map['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return map;
    }
    return null;
  }

  bool _isChauffeurLike(Map<String, dynamic> json) {
    final role = json['role']?.toString().toLowerCase();
    return role == 'chauffeur' || (json['chauffeur'] is Map);
  }

  bool _isChauffeurModel(Chauffeur chauffeur) {
    return (chauffeur.user?.role.toLowerCase() == 'chauffeur') ||
        chauffeur.cni.isNotEmpty ||
        chauffeur.permis.isNotEmpty ||
        chauffeur.userId != null;
  }

  Future<Map<int, Map<String, dynamic>>>
  _fetchChauffeurDetailsByUserId() async {
    final result = <int, Map<String, dynamic>>{};
    try {
      final rows = await _chauffeurService.getAll();
      for (final raw in rows) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final userId = _parseNullableInt(
          map['user_id'] ??
              map['id_user'] ??
              (map['user'] is Map ? (map['user'] as Map)['id'] : null),
        );
        if (userId == null) continue;
        result[userId] = map;
      }
    } catch (_) {
      // Keep users-only payload if chauffeur endpoint fails.
    }
    return result;
  }

  Map<String, dynamic> _mergeUserWithChauffeur(
    Map<String, dynamic> userJson,
    Map<int, Map<String, dynamic>> chauffeurByUserId,
  ) {
    final merged = Map<String, dynamic>.from(userJson);
    final userId = _parseNullableInt(merged['id']);
    final fromUserPayload = merged['chauffeur'] is Map
        ? Map<String, dynamic>.from(merged['chauffeur'] as Map)
        : null;
    final fromChauffeurEndpoint = userId == null
        ? null
        : chauffeurByUserId[userId];

    Map<String, dynamic>? combined;
    if (fromUserPayload != null || fromChauffeurEndpoint != null) {
      combined = <String, dynamic>{
        ...?fromChauffeurEndpoint,
        ...?fromUserPayload,
      };
      if (fromUserPayload != null &&
          fromUserPayload['camion'] == null &&
          fromChauffeurEndpoint?['camion'] != null) {
        combined['camion'] = fromChauffeurEndpoint!['camion'];
      }
    }

    if (combined != null) {
      merged['chauffeur'] = combined;
    }
    return merged;
  }

  int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
