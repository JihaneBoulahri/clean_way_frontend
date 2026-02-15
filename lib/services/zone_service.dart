import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class ZoneService {

  //get all zones
  static Future<List<dynamic>> getAll() async {
    final res = await http.get(Uri.parse(ZoneEndpoints.base));
    return jsonDecode(res.body);
  }

  //create zone
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse(ZoneEndpoints.base),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //update zone
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(ZoneEndpoints.detail(id)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //delete zone
  static Future delete(int id) async {
    await http.delete(Uri.parse(ZoneEndpoints.detail(id)));
  }

  //get zone by id
  static Future getById(int id) async {
    final res = await http.get(Uri.parse(ZoneEndpoints.detail(id)));
    return jsonDecode(res.body);
  }
}
