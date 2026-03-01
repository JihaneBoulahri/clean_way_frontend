import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';


class ChauffeurService {
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
      if (decoded is Map && decoded['data'] is List) return decoded['data'];
      return decoded;
    }

    // Show error but don't auto-redirect; let controller handle it
    throw Exception("Server error (${res.statusCode}): ${res.body.isNotEmpty ? res.body.substring(0, 200) : 'No response'}");
  }
  //get all chauffeurs
  Future<List<dynamic>> getAll() async {
    final res =await http.get(
      Uri.parse(ChauffeurEndpoints.base),
      headers: _headers,
      );
    return _handleResponse(res);
  }

  //create chauffeur
  Future create(Map data) async {
    final res = await http.post(
      Uri.parse(ChauffeurEndpoints.base),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  //update chauffeur
  Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(ChauffeurEndpoints.detail(id)),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  //delete chauffeur
  Future delete(int id) async {
    final res = await http.delete(
        Uri.parse(ChauffeurEndpoints.detail(id)),
        headers: _headers
    );
    return _handleResponse(res);
  }

  //get chauffeur by id
  Future getById(int id) async {
    final res = await http.get(
      Uri.parse(ChauffeurEndpoints.detail(id)),
      headers: _headers,
    );
    return _handleResponse(res);
  }
}
