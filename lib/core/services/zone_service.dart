import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';

class ZoneService {
  final _box = GetStorage();

  /// Base headers with token
  Map<String, String> get _headers {
    final token = _box.read('token');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  String _normalizeCoordinate(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return '';
    return raw.replaceAll(',', '.');
  }

  String _firstString(Map data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  Map<String, dynamic> _buildZonePayload(Map data) {
    final map = Map<String, dynamic>.from(data);

    final nom = _firstString(map, const ['nom_zone', 'nomZone', 'nom', 'name']);
    final type = _firstString(map, const ['type_zone', 'typeZone', 'type']);
    final lat = _normalizeCoordinate(
      _firstString(map, const [
        'latitude',
        'lat',
        'latitude_zone',
        'coord_lat',
      ]),
    );
    final lng = _normalizeCoordinate(
      _firstString(map, const [
        'longitude',
        'lng',
        'long',
        'longitude_zone',
        'coord_lng',
      ]),
    );

    final payload = <String, dynamic>{
      if (nom.isNotEmpty) 'nom_zone': nom,
      if (type.isNotEmpty) 'type_zone': type,
      if (lat.isNotEmpty) 'latitude': lat,
      if (lng.isNotEmpty) 'longitude': lng,
      // Aliases to tolerate backend field variations.
      if (nom.isNotEmpty) 'nom': nom,
      if (type.isNotEmpty) 'type': type,
      if (lat.isNotEmpty) 'lat': lat,
      if (lng.isNotEmpty) 'lng': lng,
      if (lng.isNotEmpty) 'long': lng,
    };

    final id = map['id_zone'] ?? map['id'];
    final parsedId = int.tryParse(id?.toString() ?? '');
    if (parsedId != null && parsedId > 0) {
      payload['id_zone'] = parsedId;
    }

    return payload;
  }

  String _extractErrorMessage(String body) {
    if (body.trim().isEmpty) return 'No response';
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString().trim();
        if (message != null && message.isNotEmpty) return message;
        final errors = decoded['errors'];
        if (errors is Map) {
          for (final entry in errors.entries) {
            final value = entry.value;
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
            final txt = value?.toString().trim() ?? '';
            if (txt.isNotEmpty) return txt;
          }
        }
      }
    } catch (_) {}
    return body.length > 800 ? '${body.substring(0, 800)}...' : body;
  }

  /// Handle common response logic
  dynamic _handleResponse(http.Response res) {
    if (res.statusCode == 200 || res.statusCode == 201) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        if (decoded['data'] is List) return decoded['data'];
        if (decoded['data'] is Map) return decoded['data'];
        if (decoded.containsKey('data')) return decoded['data'];
      }
      return decoded;
    }

    final message = _extractErrorMessage(res.body);
    throw Exception("Server error (${res.statusCode}): $message");
  }

  //get all zones
  Future<List<dynamic>> getAll() async {
    final res = await http.get(
      Uri.parse(ZoneEndpoints.base),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  //create zone
  Future create(Map data) async {
    final payload = _buildZonePayload(data);
    final res = await http.post(
      Uri.parse(ZoneEndpoints.base),
      headers: _headers,
      body: jsonEncode(payload),
    );
    try {
      return _handleResponse(res);
    } catch (e) {
      final errorText = e.toString().toLowerCase();
      final canRetry =
          res.statusCode >= 500 &&
          errorText.contains('zones.latitude') &&
          (payload['latitude']?.toString().trim().isNotEmpty ?? false);

      if (!canRetry) rethrow;

      final retryPayload = Map<String, dynamic>.from(payload)
        ..['latitude_zone'] = payload['latitude']
        ..['longitude_zone'] = payload['longitude']
        ..['coord_lat'] = payload['latitude']
        ..['coord_lng'] = payload['longitude'];

      final retryRes = await http.post(
        Uri.parse(ZoneEndpoints.base),
        headers: _headers,
        body: jsonEncode(retryPayload),
      );
      return _handleResponse(retryRes);
    }
  }

  //update zone
  Future update(int id, Map data) async {
    final payload = _buildZonePayload(data);
    final res = await http.put(
      Uri.parse(ZoneEndpoints.detail(id)),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return _handleResponse(res);
  }

  //delete zone
  Future delete(int id) async {
    final res = await http.delete(
      Uri.parse(ZoneEndpoints.detail(id)),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  //get zone by id
  Future getById(int id) async {
    final res = await http.get(
      Uri.parse(ZoneEndpoints.detail(id)),
      headers: _headers,
    );
    return _handleResponse(res);
  }
}
