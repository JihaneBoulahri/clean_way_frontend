import 'package:clean_way_frontend/core/constants/filter_constants.dart';
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
  var filterAffectation = FilterDefaults.all.obs;
  var filterPermis = FilterDefaults.all.obs;

  ChauffeurController({this.autoFetch = true});

  List<Chauffeur> get filteredChauffeurs {
    final q = searchQuery.value.trim().toLowerCase();
    return chauffeurs.where((c) {
      final phone = c.numTelephone.toLowerCase();
      final cni = c.cni.toLowerCase();
      final permis = c.permis.toLowerCase();
      final email = c.user?.email.toLowerCase() ?? '';
      final camionId = (c.camionId ?? c.camion?.id)?.toString() ?? '';
      final userId = (c.userId ?? c.user?.id)?.toString() ?? '';
      final userName = c.user?.fullName.toLowerCase() ?? '';
      final matchesSearch = q.isEmpty ||
          phone.contains(q) ||
          cni.contains(q) ||
          permis.contains(q) ||
          email.contains(q) ||
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
      final hasChauffeurRows = chauffeurByUserId.isNotEmpty;
      final mergedUsers = users
          .map(
            (userJson) => _mergeUserWithChauffeur(userJson, chauffeurByUserId),
          )
          .where((json) {
            if (!hasChauffeurRows) return true;
            final id = _parseNullableInt(json['id']);
            return _hasChauffeurPayload(json) ||
                (id != null && chauffeurByUserId.containsKey(id));
          })
          .toList();
      final mapped = mergedUsers.map(Chauffeur.fromJson).toList();
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
      if (_isCniConstraintError(e)) {
        try {
          await _fallbackCreateChauffeur(payload);
          await fetchChauffeurs();
          showNadiSnackbar(
            title: "Succès",
            message: "Chauffeur ajouté avec succès",
            type: NadiSnackbarType.success,
          );
          return;
        } catch (fallbackError) {
          _handleError(fallbackError);
          return;
        }
      }
      _handleError(e);
    }
  }

  Future<void> updateChauffeur(int userId, Map<String, dynamic> payload) async {
    try {
      final current = _findLocalChauffeurByUserId(userId);

      await _upsertChauffeurForUser(
        userId: userId,
        payload: payload,
        preferredChauffeurId: current?.chauffeurId,
      );

      final userPayload = _buildUserPayload(payload, forceRoleChauffeur: true);
      await UserService.update(userId, userPayload);

      await fetchChauffeurs();
      showNadiSnackbar(
        title: "Succès",
        message: "Chauffeur modifié avec succès",
        type: NadiSnackbarType.success,
      );
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
      final hasChauffeurRows = chauffeurByUserId.isNotEmpty;
      if (hasChauffeurRows && !_hasChauffeurPayload(merged)) return null;
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
    return chauffeur.chauffeurId != null ||
        chauffeur.cni.isNotEmpty ||
        chauffeur.permis.isNotEmpty ||
        chauffeur.numTelephone.isNotEmpty ||
        chauffeur.camionId != null;
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

  bool _hasChauffeurPayload(Map<String, dynamic> json) {
    final nested = json['chauffeur'];
    if (nested is Map) {
      final map = Map<String, dynamic>.from(nested);
      return _hasValue(map['id_chauffeur']) ||
          _hasValue(map['cni']) ||
          _hasValue(map['permis']) ||
          _hasValue(map['num_telephone']) ||
          _hasValue(map['id_camion']) ||
          _hasValue(map['camion_id']) ||
          _hasValue(map['user_id']);
    }

    return _hasValue(json['id_chauffeur']) ||
        _hasValue(json['cni']) ||
        _hasValue(json['permis']) ||
        _hasValue(json['num_telephone']) ||
        _hasValue(json['id_camion']) ||
        _hasValue(json['camion_id']) ||
        _hasValue(json['user_id']);
  }

  bool _hasValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    return true;
  }

  Chauffeur? _findLocalChauffeurByUserId(int userId) {
    for (final c in chauffeurs) {
      if (c.id == userId || c.userId == userId || c.user?.id == userId) {
        return c;
      }
    }
    return null;
  }

  Future<void> _upsertChauffeurForUser({
    required int userId,
    required Map<String, dynamic> payload,
    int? preferredChauffeurId,
  }) async {
    final chauffeurPayload = _buildChauffeurPayload(payload, userId: userId);
    int? chauffeurId = preferredChauffeurId;
    if (chauffeurId == null) {
      final mapByUser = await _fetchChauffeurDetailsByUserId();
      final existing = mapByUser[userId];
      chauffeurId = _parseNullableInt(
        existing?['id_chauffeur'] ?? existing?['id'],
      );
    }

    if (chauffeurId != null) {
      await _chauffeurService.update(chauffeurId, chauffeurPayload);
    } else {
      await _chauffeurService.create(chauffeurPayload);
    }
  }

  Map<String, dynamic> _buildChauffeurPayload(
    Map<String, dynamic> source, {
    required int userId,
  }) {
    return <String, dynamic>{
      'user_id': userId,
      'num_telephone': source['num_telephone'],
      'cni': source['cni'],
      'permis': source['permis'],
      'id_camion': source['id_camion'],
    };
  }

  Map<String, dynamic> _buildUserPayload(
    Map<String, dynamic> source, {
    required bool forceRoleChauffeur,
  }) {
    final payload = <String, dynamic>{
      'nom': source['nom'],
      'prenom': source['prenom'],
      'email': source['email'],
    };
    if (forceRoleChauffeur) {
      payload['role'] = 'chauffeur';
    }
    final password = source['password']?.toString().trim() ?? '';
    if (password.isNotEmpty) {
      payload['password'] = password;
    }
    return payload;
  }

  Future<void> _fallbackCreateChauffeur(Map<String, dynamic> payload) async {
    final email = payload['email']?.toString().trim().toLowerCase();
    int? userId = await _findUserIdByEmail(email);

    if (userId == null) {
      final userPayload = _buildUserPayload(payload, forceRoleChauffeur: false)
        ..['role'] = 'admin';
      final createdUser = await UserService.create(userPayload);
      userId = _parseNullableInt(_extractMap(createdUser)?['id']);
    }

    if (userId == null) {
      throw Exception("Impossible de créer l'utilisateur chauffeur");
    }

    await _upsertChauffeurForUser(userId: userId, payload: payload);
    await UserService.update(userId, {'role': 'chauffeur'});
  }

  Future<int?> _findUserIdByEmail(String? email) async {
    final normalized = email?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) return null;

    final response = await UserService.getUsers();
    final rows = _extractList(response);
    for (final row in rows) {
      if (row is! Map) continue;
      final map = Map<String, dynamic>.from(row);
      final rowEmail = map['email']?.toString().trim().toLowerCase() ?? '';
      if (rowEmail == normalized) {
        return _parseNullableInt(map['id']);
      }
    }
    return null;
  }

  bool _isCniConstraintError(dynamic e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('chauffeurs.cni') &&
        msg.contains('not null constraint failed');
  }
}
