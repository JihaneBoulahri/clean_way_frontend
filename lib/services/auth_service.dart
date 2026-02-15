import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class AuthService {
  //login
  static Future login(String email, String password) async {
    final res = await http.post(
      Uri.parse(AuthEndpoints.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(res.body);
  }

  //register
  static Future register(Map data) async {
    final res = await http.post(
      Uri.parse(AuthEndpoints.register),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  //logout
  static Future logout() async {
    await http.post(Uri.parse(AuthEndpoints.logout));
  }
}