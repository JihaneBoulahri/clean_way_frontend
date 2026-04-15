import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static bool _isGenericValidationMessage(String value) {
    final normalized = value.trim().toLowerCase();
    const genericFragments = [
      'validation failed',
      'the given data was invalid',
      'validation error',
      'invalid data',
      'unprocessable entity',
      'erreur de validation',
    ];
    return genericFragments.any(normalized.contains);
  }

  static bool _isBackendNoiseMessage(String value) {
    final normalized = value.trim().toLowerCase();
    const noisyFragments = [
      'sqlstate',
      'integrity constraint violation',
      'pdoexception',
      'queryexception',
      'mysql',
      'postgres',
      'sqlite',
      'syntax error',
      'stack trace',
      'connection:',
      'internal server error',
      'server error',
      'call to undefined',
      'undefined variable',
      'failed to open stream',
      'duplicate entry',
      'cannot be null',
      'not null constraint',
      'data too long',
      'foreign key constraint fails',
    ];
    return noisyFragments.any(normalized.contains);
  }

  static String? _firstStringFrom(dynamic value, {bool allowGeneric = true}) {
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return null;
      if (!allowGeneric && _isGenericValidationMessage(text)) return null;
      if (_isBackendNoiseMessage(text)) return null;
      return text;
    }

    if (value is List) {
      for (final item in value) {
        final candidate = _firstStringFrom(item, allowGeneric: allowGeneric);
        if (candidate != null) return candidate;
      }
      return null;
    }

    if (value is Map) {
      for (final entry in value.entries) {
        final candidate = _firstStringFrom(
          entry.value,
          allowGeneric: allowGeneric,
        );
        if (candidate != null) return candidate;
      }
    }

    return null;
  }

  static String _extractErrorMessage(
    String responseBody, {
    required String fallback,
  }) {
    if (responseBody.trim().isEmpty) return fallback;

    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        // Prefer field-level validation details over generic root messages.
        final detailedError = _firstStringFrom(
          decoded['errors'] ??
              decoded['validation_errors'] ??
              decoded['details'] ??
              decoded['detail'],
          allowGeneric: false,
        );
        if (detailedError != null) {
          return detailedError;
        }

        final message = _firstStringFrom(
          decoded['message'],
          allowGeneric: false,
        );
        if (message != null) {
          return message;
        }

        final error = _firstStringFrom(decoded['error'], allowGeneric: false);
        if (error != null) {
          return error;
        }

        final anySpecificText = _firstStringFrom(decoded, allowGeneric: false);
        if (anySpecificText != null) {
          return anySpecificText;
        }

        // Last chance inside decoded body, even if the message is generic.
        final anyText = _firstStringFrom(decoded, allowGeneric: true);
        if (anyText != null) {
          return anyText;
        }
      }
    } catch (_) {}

    final plainText = responseBody.trim();
    if (plainText.isNotEmpty && !_isGenericValidationMessage(plainText)) {
      final normalized = plainText.toLowerCase();
      final looksTechnical =
          plainText.startsWith('<') ||
          normalized.contains('exception') ||
          normalized.contains('stack trace') ||
          normalized.contains('sqlstate') ||
          normalized.contains('internal server error') ||
          normalized.contains('bad gateway') ||
          normalized.contains('service unavailable');
      if (looksTechnical) return fallback;
      return plainText;
    }

    return fallback;
  }

  //login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse(AuthEndpoints.login),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {"success": true, "data": data};
      }

      return {
        "success": false,
        "message": _extractErrorMessage(
          res.body,
          fallback: "Connexion impossible. Verifiez vos informations.",
        ),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Connexion impossible. Verifiez votre connexion.",
      };
    }
  }

  //register
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String confirmPassword,
    required String numTelephone,
    required String cni,
    required String permis,
    required String camionId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(AuthEndpoints.register),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "nom": nom,
          "prenom": prenom,
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
          "role": "chauffeur",
          "num_telephone": numTelephone,
          "cni": cni,
          "permis": permis,
          "id_camion": int.tryParse(camionId) ?? camionId,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return {"success": true, "data": data};
      }

      return {
        "success": false,
        "message": _extractErrorMessage(
          res.body,
          fallback: "Inscription impossible. Verifiez vos informations.",
        ),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Inscription impossible. Verifiez votre connexion.",
      };
    }
  }

  //logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: "token");

      final res = await http.post(
        Uri.parse(AuthEndpoints.logout),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (res.statusCode == 200) {
        // supprimer le token du téléphone
        await storage.delete(key: "token");

        return {"success": true, "message": "Logout successful"};
      }

      if (res.body.isNotEmpty) {
        return {
          "success": false,
          "message": _extractErrorMessage(res.body, fallback: "Logout failed"),
        };
      }

      return {"success": false, "message": "Logout failed"};
    } catch (_) {
      return {"success": false, "message": "Logout failed"};
    }
  }

  /* static Future<Map<String, dynamic>> logout() async {
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
  } */
}
