import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class CapteurService {
  //get all capteurs
  static Future<List<dynamic>> getCapteurs() async {
    final res = await http.get(
      Uri.parse(CapteurEndpoints.base),
      headers: {"Accept": "application/json"},
    );

    return jsonDecode(res.body);
  }

  //create capteur
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse(CapteurEndpoints.base),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //update capteur
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(CapteurEndpoints.detail(id)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //delete capteur
  static Future delete(int id) async {
    await http.delete(Uri.parse(CapteurEndpoints.detail(id)));
  }

  //get capteurs by benne
  static Future getCapteursByBenne(int benneId) async {
    final res = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/bennes/$benneId/capteurs"),
    );

    return jsonDecode(res.body);
  }

  //get capteur by id 
  static Future getById(int id) async {
    final res = await http.get(Uri.parse(CapteurEndpoints.detail(id)));
    return jsonDecode(res.body);
  }

  //get capteurs with benne 
  static Future getWithBenne(int benneId) async {
    final res = await http.get(Uri.parse(CapteurEndpoints.byBenne(benneId)));
    return jsonDecode(res.body);
  }
}
