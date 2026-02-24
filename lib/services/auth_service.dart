import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class AuthService {
  //login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse(AuthEndpoints.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          "success": true,
          "data": data, // مثلا token, user info...
        };
      } else {
        final data = jsonDecode(res.body);
        return {
          "success": false,
          "message": data['message'] ?? "Login failed",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
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