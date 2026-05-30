import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class VilleService {
  final _box = GetStorage();

  Map<String, String> get _headers {
    final token = _box.read('token')?.toString().trim();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

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

    throw Exception(
      'Server error (${res.statusCode}): ${res.body.isNotEmpty ? res.body.substring(0, res.body.length > 200 ? 200 : res.body.length) : 'No response'}',
    );
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

  Future<List<dynamic>> getAll() async {
    final res = await http.get(
      Uri.parse(VilleEndpoints.base),
      headers: _headers,
    );
    final decoded = _handleResponse(res);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['data'] is List) return decoded['data'];
    return const [];
  }

  Future<dynamic> getById(int id) async {
    final res = await http.get(
      Uri.parse(VilleEndpoints.detail(id)),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  Future<dynamic> create(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(VilleEndpoints.base),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  Future<dynamic> update(int id, Map<String, dynamic> data) async {
    final res = await _putOrPatch(
      Uri.parse(VilleEndpoints.detail(id)),
      data,
    );
    return _handleResponse(res);
  }

  Future<dynamic> delete(int id) async {
    final res = await http.delete(
      Uri.parse(VilleEndpoints.detail(id)),
      headers: _headers,
    );
    return _handleResponse(res);
  }
}
