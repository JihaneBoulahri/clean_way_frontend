import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../core/constants/api_constants.dart';

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
    throw Exception("Server error (${res.statusCode}): ${res.body.isNotEmpty ? res.body.substring(0, 200) : 'No response'}");
  }

  /// Fetch optimized routes
  Future<dynamic> optimiser() async {
    final res = await http.get(
      Uri.parse(OptimisationEndpoints.base),
      headers: _headers,
    );

    return _handleResponse(res);
  }
}
