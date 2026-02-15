import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class UserService {

  //get all users
  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(
      Uri.parse(UserEndpoints.base),
    );

    return jsonDecode(res.body);
  }

  //create user
  static Future create(Map data) async {
    final res = await http.post(
      Uri.parse(UserEndpoints.base),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //update user
  static Future update(int id, Map data) async {
    final res = await http.put(
      Uri.parse(UserEndpoints.detail(id)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //delete user
  static Future delete(int id) async {
    await http.delete(Uri.parse(UserEndpoints.detail(id)));
  }

  //get user by id
  static Future getById(int id) async {
    final res = await http.get(Uri.parse(UserEndpoints.detail(id)));
    return jsonDecode(res.body);
  }

}
