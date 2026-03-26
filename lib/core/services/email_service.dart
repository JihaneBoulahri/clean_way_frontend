import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';

class EmailService {
  final _box = GetStorage();

  Map<String, String> get _headers {
    final token = _box.read('token');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<void> sendEmail({
    required String name,
    required String email,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse(EmailEndpoints.send),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'message': message,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Server error (${response.statusCode}): '
        '${response.body.isNotEmpty ? response.body : 'No response'}',
      );
    }
  }
}
