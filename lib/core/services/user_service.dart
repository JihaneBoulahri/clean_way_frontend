import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';

class UserService {
  static Map<String, String> _headers() {
    final box = GetStorage();
    final token = box.read('token')?.toString();
    final headers = <String, String>{"Content-Type": "application/json"};
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  static dynamic _handleResponse(http.Response res) {
    final body = res.body.trim();
    final decoded = body.isEmpty ? <String, dynamic>{} : jsonDecode(body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }

    throw Exception(
      "Server error (${res.statusCode}): "
      "${body.isNotEmpty ? body.substring(0, body.length > 200 ? 200 : body.length) : 'No response'}",
    );
  }

  //get all users
  static Future<dynamic> getUsers() async {
    final res = await http.get(
      Uri.parse(UserEndpoints.base),
      headers: _headers(),
    );

    return _handleResponse(res);
  }

  //create user
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse(UserEndpoints.base),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  //update user
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(UserEndpoints.detail(id)),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  //delete user
  static Future delete(int id) async {
    final res = await http.delete(
      Uri.parse(UserEndpoints.detail(id)),
      headers: _headers(),
    );
    _handleResponse(res);
  }

  //get user by id
  static Future getById(int id) async {
    final res = await http.get(
      Uri.parse(UserEndpoints.detail(id)),
      headers: _headers(),
    );
    return _handleResponse(res);
  }
}
