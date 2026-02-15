import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class TourneeService {

  //get all tournees
  static Future<List<dynamic>> getAll() async {
    final res = await http.get(Uri.parse(TourneeEndpoints.base));
    return jsonDecode(res.body);
  }

  //create tournee
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse(TourneeEndpoints.base),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //update tournee
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(TourneeEndpoints.detail(id)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //delete tournee
  static Future delete(int id) async {
    await http.delete(Uri.parse(TourneeEndpoints.detail(id)));
  }

  //get tournee by id
  static Future getById(int id) async {
    final res = await http.get(Uri.parse(TourneeEndpoints.detail(id)));
    return jsonDecode(res.body);
  }

  //get history
  static Future<List<dynamic>> getHistory() async {
    final res = await http.get(Uri.parse(TourneeEndpoints.history));
    return jsonDecode(res.body);
  }

  //search tournees
  static Future<List<dynamic>> search(String query) async {
    final res = await http.get(Uri.parse("${TourneeEndpoints.search}?q=$query"));
    return jsonDecode(res.body);
  }
}
