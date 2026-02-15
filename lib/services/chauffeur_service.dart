import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class ChauffeurService {
  //get all chauffeurs
  static Future<List<dynamic>> getAll() async {
    final res =await http.get(Uri.parse(ChauffeurEndpoints.base));
    return jsonDecode(res.body);
  }

  //create chauffeur
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse(ChauffeurEndpoints.base),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //update chauffeur
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(ChauffeurEndpoints.detail(id)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //delete chauffeur
  static Future delete(int id) async {
    await http.delete(
        Uri.parse(ChauffeurEndpoints.detail(id)));
  }

  //get chauffeur by id
  static Future getById(int id) async {
    final res = await http.get(Uri.parse(ChauffeurEndpoints.detail(id)));
    return jsonDecode(res.body);
  }
}
