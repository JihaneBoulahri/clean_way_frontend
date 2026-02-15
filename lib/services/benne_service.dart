import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class BenneService {
  //get all bennes
  static Future<List<dynamic>> getAllBennes() async {
    final response = await http.get(
      Uri.parse(BenneEndpoints.base),
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load bennes");
    }
  }

  //create benne
  static Future createBenne(Map data) async {
    final response = await http.post(
      Uri.parse(BenneEndpoints.base),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  //update benne
  static Future updateBenne(int id, Map data) async {
    final response = await http.put(
      Uri.parse(BenneEndpoints.detail(id)),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  //delete benne
  static Future deleteBenne(int id) async {
    await http.delete(
      Uri.parse(BenneEndpoints.detail(id)),
    );
  }

  //get benne by id
  static Future getBenneById(int id) async {
    final response = await http.get(
      Uri.parse(BenneEndpoints.detail(id)),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load benne");
    }
  }

  //get bennes with sensors
  static Future<List<dynamic>> getBennesWithSensors() async {
    final response = await http.get(
      Uri.parse(BenneEndpoints.withSensors),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load bennes with sensors");
    }
  }

  //vider benne
  static Future viderBenne(int id) async {
    final response = await http.post(
      Uri.parse(BenneEndpoints.vider(id)),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to vider benne");
    }
  }
}
