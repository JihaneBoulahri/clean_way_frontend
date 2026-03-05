import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class TourneeService {
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
    throw Exception(
      "Server error (${res.statusCode}):\n${res.body.isNotEmpty ? (res.body.length > 200 ? res.body.substring(0, 200) + '...' : res.body) : 'No response'}"
    );
  }

  //get all tournees
  Future<List<dynamic>> getAll() async {
    final res = await http.get(
      Uri.parse(TourneeEndpoints.base),
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
    final res = await http.put(
      Uri.parse(TourneeEndpoints.detail(id)),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  //delete tournee
  Future delete(int id) async {
    await http.delete(
      Uri.parse(TourneeEndpoints.detail(id)), 
      headers: _headers
    );
  }

  //get tournee by id
  Future getById(int id) async {
    final res = await http.get(
      Uri.parse(TourneeEndpoints.detail(id)),
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
      Uri.parse(TourneeEndpoints.history),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  //search tournees
  Future<List<dynamic>> search(String query) async {
    final res = await http.get(
      Uri.parse("${TourneeEndpoints.search}?q=$query"),
      headers: _headers,
    );
    return _handleResponse(res);
  }
}
