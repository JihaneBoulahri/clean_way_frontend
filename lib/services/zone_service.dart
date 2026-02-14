import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class ZoneService {
  static Future<List<dynamic>> getAll() async {
    final res = await http.get(Uri.parse("${ApiConstants.baseUrl}/zones"));
    return jsonDecode(res.body);
  }

  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/zones"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/zones/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }
  static Future delete(int id) async {
    await http.delete(Uri.parse("${ApiConstants.baseUrl}/zones/$id"));
  }
}
