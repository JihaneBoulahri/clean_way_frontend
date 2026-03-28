import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';

class CapteurService {
  static Map<String, String> _headers({bool json = true}) {
    final box = GetStorage();
    final token = box.read('token')?.toString();
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static dynamic _handleResponse(http.Response res) {
    final body = res.body.trim();
    final decoded = body.isEmpty ? <String, dynamic>{} : jsonDecode(body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }
    throw Exception(
      "Server error (${res.statusCode}): "
      "${body.isNotEmpty ? body.substring(0, body.length > 200 ? 200 : body.length) : 'No response'}",
    );
  }

  //get all capteurs
  static Future<List<dynamic>> getCapteurs() async {
    final res = await http.get(
      Uri.parse(CapteurEndpoints.base),
      headers: _headers(json: false),
    );
    final decoded = _handleResponse(res);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['data'] is List) return decoded['data'];
    return const [];
  }

  //create capteur
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse(CapteurEndpoints.base),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  //update capteur
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(CapteurEndpoints.detail(id)),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  //delete capteur
  static Future delete(int id) async {
    final res = await http.delete(
      Uri.parse(CapteurEndpoints.detail(id)),
      headers: _headers(json: false),
    );
    _handleResponse(res);
  }

  //get capteurs by benne
  static Future getCapteursByBenne(int benneId) async {
    final res = await http.get(
      Uri.parse(CapteurEndpoints.byBenne(benneId)),
      headers: _headers(json: false),
    );
    return _handleResponse(res);
  }

  //get capteur by id
  static Future getById(int id) async {
    final res = await http.get(
      Uri.parse(CapteurEndpoints.detail(id)),
      headers: _headers(json: false),
    );
    return _handleResponse(res);
  }

  //get capteurs with benne
  static Future getWithBenne(int benneId) async {
    final res = await http.get(
      Uri.parse(CapteurEndpoints.byBenne(benneId)),
      headers: _headers(json: false),
    );
    return _handleResponse(res);
  }
}
