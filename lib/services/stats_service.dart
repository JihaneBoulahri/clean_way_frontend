import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class StatsService  {

Future<Map<String, dynamic>> fetchStats() async {
  final response = await http.get(
    Uri.parse(StatsEndpoint.statistiques),
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data'] ?? data;
  } else {
    throw Exception('Failed to load stats');
  }
}


}
