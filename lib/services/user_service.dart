import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../core/constants/api_constants.dart';

class UserService {
  static Map<String, String> _headers() {
    final box = GetStorage();
    final token = box.read('token')?.toString();
    final headers = <String, String>{
      "Content-Type": "application/json",
    };
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  //get all users
  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(
      Uri.parse(UserEndpoints.base),
      headers: _headers(),
    );

    return jsonDecode(res.body);
  }

  //create user
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse(UserEndpoints.base),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //update user
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(UserEndpoints.detail(id)),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //delete user
  static Future delete(int id) async {
    await http.delete(Uri.parse(UserEndpoints.detail(id)), headers: _headers());
  }

  //get user by id
  static Future getById(int id) async {
    final res = await http.get(Uri.parse(UserEndpoints.detail(id)), headers: _headers());
    return jsonDecode(res.body);
  }

}
