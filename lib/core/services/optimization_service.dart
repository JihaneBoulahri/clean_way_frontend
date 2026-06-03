import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';

class OptimizationService {
  final _box = GetStorage();

  /// Base headers with token
  Map<String, String> get _headers {
    final token = _box.read('token');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// Handle common response logic
  dynamic _handleResponse(http.Response res) {
    if (res.statusCode == 200 || res.statusCode == 201) {
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

    final preview = _extractErrorMessage(res.body);
    throw Exception('Server error (${res.statusCode}): $preview');
  }

  String _extractErrorMessage(String body) {
    if (body.trim().isEmpty) return 'No response';
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        if (decoded['message'] != null) return decoded['message'].toString();
        if (decoded['error'] != null) return decoded['error'].toString();
        if (decoded['data'] is Map && decoded['data']['message'] != null) {
          return decoded['data']['message'].toString();
        }
      }
      return body.length > 300 ? '${body.substring(0, 300)}...' : body;
    } catch (_) {
      return body.length > 300 ? '${body.substring(0, 300)}...' : body;
    }
  }

  /// Fetch optimized routes
  Future<dynamic> optimiser({
    int? villeId,
    int? zoneId,
    bool persist = true,
  }) async {
    final params = <String, String>{
      if (villeId != null) 'ville_id': villeId.toString(),
      if (zoneId != null) 'zone_id': zoneId.toString(),
      if (!persist) 'persist': 'false',
    };

    final uri = Uri.parse(
      OptimisationEndpoints.base,
    ).replace(queryParameters: params.isEmpty ? null : params);

    final res = await http.get(uri, headers: _headers);
    return _handleResponse(res);
  }
}
