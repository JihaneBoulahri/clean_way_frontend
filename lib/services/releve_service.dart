import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class ReleveService {

  //get all releves
  static Future<List<dynamic>> getAll() async {
    final res = await http.get(
      Uri.parse(ReleveEndpoints.base),
    );
    return jsonDecode(res.body);
  }

  //create releve
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse(ReleveEndpoints.base),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //update releve
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(ReleveEndpoints.detail(id)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //delete releve
  static Future delete(int id) async {
    await http.delete(Uri.parse(ReleveEndpoints.detail(id)));
  }

  //get releve by id
  static Future getById(int id) async { 
    final res = await http.get(Uri.parse(ReleveEndpoints.detail(id)));
    return jsonDecode(res.body);
  }
}
