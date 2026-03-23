import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';

class CamionService {
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
      final decoded = jsonDecode(res.body);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        if (decoded['data'] is List) return decoded['data'];
        if (decoded['data'] is Map) return decoded['data'];
        // If API returns wrapped object under 'data' key, return it; otherwise return whole map
        if (decoded.containsKey('data')) return decoded['data'];
      }
      return decoded;
    }

    // Show error but don't auto-redirect; let controller handle it
    throw Exception("Server error (${res.statusCode}): ${res.body.isNotEmpty ? res.body.substring(0, 200) : 'No response'}");
  }

  /// Get all camions
  Future<List<dynamic>> getAll() async {
    final res = await http.get(
      Uri.parse(CamionEndpoints.base),
      headers: _headers,
    );

    return _handleResponse(res);
  }

  /// Get camion by id
  Future<dynamic> getById(int id) async {
    final res = await http.get(
      Uri.parse(CamionEndpoints.detail(id)),
      headers: _headers,
    );

    return _handleResponse(res);
  }

  /// Get camion with full relations
  Future<dynamic> getWithRelations(int id) async {
    final res = await http.get(
      Uri.parse('${CamionEndpoints.detail(id)}?include=chauffeur'),
      headers: _headers,
    );

    return _handleResponse(res);
  }

  /// Create camion
  Future<dynamic> create(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(CamionEndpoints.base),
      headers: _headers,
      body: jsonEncode(data),
    );

    return _handleResponse(res);
  }

  /// Update camion
  Future<dynamic> update(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse(CamionEndpoints.detail(id)),
      headers: _headers,
      body: jsonEncode(data),
    );

    return _handleResponse(res);
  }

  /// Delete camion
  Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse(CamionEndpoints.detail(id)),
      headers: _headers,
    );

    _handleResponse(res);
  }
}