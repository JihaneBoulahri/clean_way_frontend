import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class BenneService {

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

  //get all bennes
  Future<List<dynamic>> getAllBennes() async {
    final response = await http.get(
      Uri.parse(BenneEndpoints.base),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  //create benne
  Future createBenne(Map data) async {
    final response = await http.post(
      Uri.parse(BenneEndpoints.base),
      headers: _headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  //update benne
  Future updateBenne(int id, Map data) async {
    final response = await http.put(
      Uri.parse(BenneEndpoints.detail(id)),
      headers: _headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  //delete benne
  Future deleteBenne(int id) async {
    final response = await http.delete(
      Uri.parse(BenneEndpoints.detail(id)),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  //get benne by id
  Future getBenneById(int id) async {
    final response = await http.get(
      Uri.parse(BenneEndpoints.detail(id)),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  //get bennes with sensors
  Future<List<dynamic>> getBennesWithSensors() async {
    final response = await http.get(
      Uri.parse(BenneEndpoints.withSensors),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  //vider benne
  Future viderBenne(int id) async {
    final response = await http.post(
      Uri.parse(BenneEndpoints.vider(id)),
      headers: _headers,
    );
    return _handleResponse(response);
  }
}
