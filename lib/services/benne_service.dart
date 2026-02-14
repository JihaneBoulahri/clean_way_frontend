import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class BenneService {
  static Future<List<dynamic>> getBennes() async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/bennes"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur chargement bennes");
    }
  }

  static Future createBenne(Map data) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/bennes"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }
  static Future updateBenne(int id, Map data) async {
    final response = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/bennes/$id"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  static Future deleteBenne(int id) async {
    await http.delete(
      Uri.parse("${ApiConstants.baseUrl}/bennes/$id"),
    );
  }
}
