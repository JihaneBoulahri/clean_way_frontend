import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class CamionService {
  //get all camions
  static Future<List<dynamic>> getAll() async {
    final res = await http.get(Uri.parse(CamionEndpoints.base));
    return jsonDecode(res.body);
  }

  //create camion
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse(CamionEndpoints.base),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //update camion
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(CamionEndpoints.detail(id)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //delete camion
  static Future delete(int id) async {
    await http.delete(Uri.parse(CamionEndpoints.detail(id)));
  }

  //get camion by id 
  static Future getById(int id) async {
    final res = await http.get(Uri.parse(CamionEndpoints.detail(id)));
    return jsonDecode(res.body);
  }
}
