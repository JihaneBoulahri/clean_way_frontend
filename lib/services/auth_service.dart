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
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(AuthEndpoints.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": nom,
          "prenom": prenom,
          "email": email,
          "password": password,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return {
          "success": true,
          "data": data,
        };
      } else {
        final data = jsonDecode(res.body);
        return {
          "success": false,
          "message": data['message'] ?? "Registration failed",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  //logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final res = await http.post(Uri.parse(AuthEndpoints.logout));
      if (res.statusCode == 200) {
        return {"success": true};
      }

      if (res.body.isNotEmpty) {
        final data = jsonDecode(res.body);
        return {
          "success": false,
          "message": data['message'] ?? "Logout failed",
        };
      }

      return {
        "success": false,
        "message": "Logout failed",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}
