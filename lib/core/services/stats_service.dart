import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class StatsService {
  final GetStorage _box = GetStorage();

  Map<String, String> get _headers {
    final token = _box.read('token')?.toString();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> fetchStats() async {
    final response = await http.get(
      Uri.parse(StatsEndpoint.statistiques),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? data;
    }

    throw Exception('Failed to load stats (${response.statusCode})');
  }

  Future<Map<String, dynamic>> fetchChauffeurStats() async {
    final response = await http.get(
      Uri.parse(StatsEndpoint.chauffeur),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? data;
    }

    throw Exception('Failed to load chauffeur stats (${response.statusCode})');
  }
}
