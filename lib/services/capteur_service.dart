import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class CapteurService {
  static Future<List<dynamic>> getCapteurs() async {
    final res = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/capteurs"),
      headers: {"Accept": "application/json"},
    );

    return jsonDecode(res.body);
  }
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/capteurs"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/capteurs/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }
  static Future delete(int id) async {
    await http.delete(Uri.parse("${ApiConstants.baseUrl}/capteurs/$id"));
  }

  static Future getCapteursByBenne(int benneId) async {
    final res = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/bennes/$benneId/capteurs"),
    );

    return jsonDecode(res.body);
  }
}
