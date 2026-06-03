import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class TourneeService {
  final _box = GetStorage();

  /// Base headers with token
  Map<String, String> get _headers {
    final token = _box.read('token')?.toString().trim();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// Handle common response logic
  dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.trim().isEmpty) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        if (decoded['data'] is List) return decoded['data'];
        if (decoded['data'] is Map) return decoded['data'];
        if (decoded.containsKey('data')) return decoded['data'];
      }
      return decoded;
    }

    // Show error but don't auto-redirect; let controller handle it
    // Try to surface a concise server message when available
    try {
      final decodedBody = res.body.trim().isEmpty ? null : jsonDecode(res.body);
      String serverMessage;
      if (decodedBody is Map) {
        if (decodedBody['message'] != null) {
          serverMessage = decodedBody['message'].toString();
        } else if (decodedBody['error'] != null) {
          serverMessage = decodedBody['error'].toString();
        } else if (decodedBody['data'] != null && decodedBody['data'] is Map && decodedBody['data']['message'] != null) {
          serverMessage = decodedBody['data']['message'].toString();
        } else {
          serverMessage = res.body.length > 300 ? '${res.body.substring(0, 300)}...' : res.body;
        }
      } else if (decodedBody is List) {
        serverMessage = decodedBody.toString();
      } else {
        serverMessage = res.body.isNotEmpty ? res.body : 'No response';
      }

      throw Exception('Server error (${res.statusCode}): $serverMessage');
    } catch (_) {
      throw Exception(
        "Server error (${res.statusCode}):\n${res.body.isNotEmpty ? (res.body.length > 200 ? '${res.body.substring(0, 200)}...' : res.body) : 'No response'}",
      );
    }
  }

  Future<http.Response> _putOrPatch(Uri uri, Map<String, dynamic> data) async {
    final putRes = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(data),
    );
    if (putRes.statusCode != 404 && putRes.statusCode != 405) {
      return putRes;
    }

    return http.patch(
      uri,
      headers: _headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> _getWithFallback(
    List<String> urls, {
    Set<int> retryStatusCodes = const {404},
  }) async {
    http.Response? last;
    for (final url in urls) {
      final res = await http.get(Uri.parse(url), headers: _headers);
      if (!retryStatusCodes.contains(res.statusCode)) {
        return res;
      }
      last = res;
    }
    return last ?? http.Response('Route not found', 404);
  }

  Future<http.Response> _actionWithFallback({
    required List<String> urls,
    required List<String> methods,
  }) async {
    http.Response? last;
    for (final url in urls) {
      for (final method in methods) {
        late final http.Response res;
        if (method == 'POST') {
          res = await http.post(Uri.parse(url), headers: _headers);
        } else if (method == 'PATCH') {
          res = await http.patch(Uri.parse(url), headers: _headers);
        } else {
          res = await http.put(Uri.parse(url), headers: _headers);
        }

        if (res.statusCode == 404) {
          last = res;
          continue;
        }

        return res;
      }
    }
    return last ?? http.Response('Route not found', 404);
  }

  bool _looksLikeGeometryPayload(Map<String, dynamic> map) {
    final geometry = map['geometry'];
    final coordinates = map['coordinates'];
    return (geometry is String && geometry.trim().isNotEmpty) ||
        coordinates is List;
  }

  Map<String, dynamic>? _extractGeometryPayload(dynamic payload) {
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      if (_looksLikeGeometryPayload(map)) return map;

      const nestedKeys = [
        'data',
        'route',
        'trajet',
        'result',
        'results',
        'current',
        'tournee',
      ];
      for (final key in nestedKeys) {
        final value = map[key];
        if (value is Map) {
          final nested = Map<String, dynamic>.from(value);
          if (_looksLikeGeometryPayload(nested)) return nested;
        }
        if (value is List) {
          for (final item in value) {
            if (item is Map) {
              final nested = Map<String, dynamic>.from(item);
              if (_looksLikeGeometryPayload(nested)) return nested;
            }
          }
        }
      }
      return null;
    }

    if (payload is List) {
      for (final item in payload) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          if (_looksLikeGeometryPayload(map)) return map;
        }
      }
    }

    return null;
  }

  int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Map<String, dynamic>? _extractGeometryByTourneeId(
    dynamic payload,
    int tourneeId,
  ) {
    if (payload is Map) {
      final root = _extractGeometryPayload(payload);
      if (root != null) {
        final id = _parseNullableInt(
          root['id_tournee'] ?? root['tournee_id'] ?? root['id'],
        );
        if (id == null || id == tourneeId) return root;
      }

      for (final value in payload.values) {
        final fromValue = _extractGeometryByTourneeId(value, tourneeId);
        if (fromValue != null) return fromValue;
      }
      return null;
    }

    if (payload is List) {
      for (final item in payload) {
        final fromItem = _extractGeometryByTourneeId(item, tourneeId);
        if (fromItem != null) return fromItem;
      }
    }

    return null;
  }

  Map<String, dynamic> _extractGeometryOrThrow(dynamic payload, int tourneeId) {
    final extracted =
        _extractGeometryByTourneeId(payload, tourneeId) ??
        _extractGeometryPayload(payload);
    if (extracted != null) {
      return extracted;
    }

    throw Exception(
      'Format de géométrie inattendu pour la tournée #$tourneeId',
    );
  }

  String _buildGeometryUrl(
    int tourneeId, {
    required String profile,
    required bool returnToDepot,
  }) {
    final uri = Uri.parse('${TourneeEndpoints.detail(tourneeId)}/geometry');
    return uri
        .replace(
          queryParameters: {
            'profile': profile,
            'return_to_depot': returnToDepot.toString(),
          },
        )
        .toString();
  }

  //get all tournees
  Future<List<dynamic>> getAll() async {
    final res = await http.get(
      Uri.parse('${TourneeEndpoints.base}?include=camion,zone'),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  //create tournee
  Future create(Map data) async {
    final res = await http.post(
      Uri.parse(TourneeEndpoints.base),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  //update tournee
  Future update(int id, Map data) async {
    final res = await _putOrPatch(
      Uri.parse(TourneeEndpoints.detail(id)),
      Map<String, dynamic>.from(data),
    );
    return _handleResponse(res);
  }

  //delete tournee
  Future delete(int id) async {
    final res = await http.delete(
      Uri.parse(TourneeEndpoints.detail(id)),
      headers: _headers,
    );
    _handleResponse(res);
  }

  //get tournee by id
  Future getById(int id) async {
    final res = await http.get(
      Uri.parse('${TourneeEndpoints.detail(id)}?include=camion,zone'),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  //get tournee with full relations (camion, zone)
  Future getWithRelations(int id) async {
    final res = await http.get(
      Uri.parse('${TourneeEndpoints.detail(id)}?include=camion,zone'),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  //get history
  Future<List<dynamic>> getHistory() async {
    final res = await http.get(
      Uri.parse('${TourneeEndpoints.history}?include=camion,zone'),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  //search tournees
  Future<List<dynamic>> search(String query) async {
    final res = await http.get(
      Uri.parse("${TourneeEndpoints.search}?q=$query&include=camion,zone"),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  /// Get the current optimized tournee assigned to the authenticated chauffeur
  Future getCurrentForChauffeur() async {
    final res = await _getWithFallback([
      TourneeEndpoints.currentForChauffeur,
      TourneeEndpoints.currentForChauffeurAlt1,
      TourneeEndpoints.currentForChauffeurAlt2,
    ]);
    return _handleResponse(res);
  }

  /// Get route geometry for a specific tournee.
  /// Returns payload like:
  /// {
  ///   "id_tournee": 1,
  ///   "profile": "driving-car",
  ///   "return_to_depot": false,
  ///   "coordinates": [[lng, lat], ...],
  ///   "geometry": "encoded_polyline"
  /// }
  Future<Map<String, dynamic>> getGeometry(
    int tourneeId, {
    String profile = 'driving-car',
    bool returnToDepot = false,
  }) async {
    final canonicalRes = await http.get(
      Uri.parse(
        _buildGeometryUrl(
          tourneeId,
          profile: profile,
          returnToDepot: returnToDepot,
        ),
      ),
      headers: _headers,
    );

    if (canonicalRes.statusCode != 404 && canonicalRes.statusCode != 405) {
      final decoded = _handleResponse(canonicalRes);
      return _extractGeometryOrThrow(decoded, tourneeId);
    }

    final base = TourneeEndpoints.base;
    final detail = TourneeEndpoints.detail(tourneeId);
    final optimisationBase = OptimisationEndpoints.base;
    final res = await _getWithFallback(
      [
        _buildGeometryUrl(
          tourneeId,
          profile: profile,
          returnToDepot: returnToDepot,
        ),
        '$detail/geometry?profile=$profile&return_to_depot=$returnToDepot',
        '$base/$tourneeId/geometry?profile=$profile&return_to_depot=$returnToDepot',
        '$base/geometry/$tourneeId?profile=$profile&return_to_depot=$returnToDepot',
        '$optimisationBase/geometry/$tourneeId?profile=$profile&return_to_depot=$returnToDepot',
        '$optimisationBase/$tourneeId/geometry?profile=$profile&return_to_depot=$returnToDepot',
        '$optimisationBase/geometry?id_tournee=$tourneeId&profile=$profile&return_to_depot=$returnToDepot',
        '$detail/geometry',
        '$detail/geometrie',
        '$detail/trajet',
        '$detail/route',
        '$detail/itineraire',
        '$base/$tourneeId/geometry',
        '$base/$tourneeId/geometrie',
        '$base/$tourneeId/trajet',
        '$base/$tourneeId/route',
        '$base/$tourneeId/itineraire',
        '$base/geometry/$tourneeId',
        '$base/geometrie/$tourneeId',
        '$base/trajet/$tourneeId',
        '$base/route/$tourneeId',
        '$base/itineraire/$tourneeId',
        '$base/geometry?id_tournee=$tourneeId',
        '$base/geometrie?id_tournee=$tourneeId',
        '$base/trajet?id_tournee=$tourneeId',
        '$base/route?id_tournee=$tourneeId',
        '$base/itineraire?id_tournee=$tourneeId',
        '$optimisationBase/geometry/$tourneeId',
        '$optimisationBase/geometrie/$tourneeId',
        '$optimisationBase/trajet/$tourneeId',
        '$optimisationBase/route/$tourneeId',
        '$optimisationBase/$tourneeId/geometry',
        '$optimisationBase/$tourneeId/geometrie',
        '$optimisationBase/$tourneeId/trajet',
        '$optimisationBase/$tourneeId/route',
        '$optimisationBase/geometry?id_tournee=$tourneeId',
        '$optimisationBase/geometrie?id_tournee=$tourneeId',
        '$optimisationBase/trajet?id_tournee=$tourneeId',
        '$optimisationBase/route?id_tournee=$tourneeId',
      ],
      retryStatusCodes: const {404, 405},
    );

    final decoded = _handleResponse(res);
    final extracted = _extractGeometryByTourneeId(decoded, tourneeId);
    if (extracted != null) return extracted;

    // Last fallback: some backends expose geometry only through /optimiser.
    final optimiseRes = await http.get(
      Uri.parse(optimisationBase),
      headers: _headers,
    );
    final optimiseDecoded = _handleResponse(optimiseRes);
    return _extractGeometryOrThrow(optimiseDecoded, tourneeId);
  }

  // Dans TourneeService

  Future<void> start(int tourneeId) async {
    final res = await _actionWithFallback(
      urls: [
        TourneeEndpoints.start(tourneeId),
        "${TourneeEndpoints.base}/start/$tourneeId",
        "${TourneeEndpoints.base}/$tourneeId/start",
      ],
      methods: const ['POST', 'PATCH', 'PUT'],
    );

    _handleResponse(res);
  }

  Future<void> annuler(int id) async {
    final res = await _actionWithFallback(
      urls: [
        TourneeEndpoints.annuler(id),
        "${TourneeEndpoints.base}/annuler/$id",
        "${TourneeEndpoints.base}/$id/annuler",
      ],
      methods: const ['POST', 'PATCH', 'PUT'],
    );

    _handleResponse(res);
  }

  Future<void> terminer(int id) async {
    final res = await _actionWithFallback(
      urls: [
        TourneeEndpoints.terminer(id),
        "${TourneeEndpoints.base}/terminer/$id",
        "${TourneeEndpoints.base}/$id/terminer",
      ],
      methods: const ['POST', 'PATCH', 'PUT'],
    );

    _handleResponse(res);
  }
  /* Future start(int id) async {
    final res = await _actionWithFallback(
      urls: [
        TourneeEndpoints.start(id),
        "${TourneeEndpoints.base}/start/$id",
      ],
      methods: const ['POST', 'PATCH', 'PUT'],
    );
    return _handleResponse(res);
  } */

  /* Future<void> start(int tourneeId) async {
    final res = await http.post(
      Uri.parse(TourneeEndpoints.start(tourneeId)),
      headers: _headers,
    );
    _handleResponse(res);
  } */

  /* Future annuler(int id) async {
    final res = await _actionWithFallback(
      urls: [
        TourneeEndpoints.annuler(id),
        "${TourneeEndpoints.base}/annuler/$id",
      ],
      methods: const ['POST', 'PATCH', 'PUT'],
    );
    return _handleResponse(res);
  } */

  /*  Future terminer(int id) async {
    final res = await _actionWithFallback(
      urls: [
        TourneeEndpoints.terminer(id),
        "${TourneeEndpoints.base}/terminer/$id",
      ],
      methods: const ['POST', 'PATCH', 'PUT'],
    );
    return _handleResponse(res);
  } */
}
