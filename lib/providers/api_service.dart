import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/benne_model.dart';
import '../models/camion_model.dart';
import '../models/capteur_model.dart';
import '../models/chauffeur_model.dart';
import '../models/releve_model.dart';
import '../models/tournee_model.dart';
import '../models/user_model.dart';
import '../models/zone_model.dart';

class ApiService {
  
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ───────────────────────────── BENNE ─────────────────────────────
  static Future<List<Benne>> fetchBennes() async {
    final response = await http.get(Uri.parse('$baseUrl/bennes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Benne.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bennes');
    }
  }

  static Future<Benne> createBenne(Benne benne) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bennes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(benne.toJson()),
    );
    if (response.statusCode == 201) {
      return Benne.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create benne');
    }
  }

  static Future<Benne> updateBenne(Benne benne) async {
    final response = await http.put(
      Uri.parse('$baseUrl/bennes/${benne.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(benne.toJson()),
    );
    if (response.statusCode == 200) {
      return Benne.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update benne');
    }
  }

  static Future<void> deleteBenne(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/bennes/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete benne');
    }
  }

  // ───────────────────────────── CAMION ─────────────────────────────
  static Future<List<camion>> fetchCamions() async {
    final response = await http.get(Uri.parse('$baseUrl/camions'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => camion.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load camions');
    }
  }

  static Future<camion> createCamion(camion camion) async {
    final response = await http.post(
      Uri.parse('$baseUrl/camions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(camion.toJson()),
    );
    if (response.statusCode == 201) {
      return camion.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create camion');
    }
  }

  static Future<camion> updateCamion(camion camion) async {
    final response = await http.put(
      Uri.parse('$baseUrl/camions/${camion.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(camion.toJson()),
    );
    if (response.statusCode == 200) {
      return camion.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update camion');
    }
  }

  static Future<void> deleteCamion(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/camions/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete camion');
    }
  }

  // ───────────────────────────── CAPTEUR ─────────────────────────────
  static Future<List<Capteur>> fetchCapteurs() async {
    final response = await http.get(Uri.parse('$baseUrl/capteurs'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Capteur.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load capteurs');
    }
  }

  static Future<Capteur> createCapteur(Capteur capteur) async {
    final response = await http.post(
      Uri.parse('$baseUrl/capteurs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(capteur.toJson()),
    );
    if (response.statusCode == 201) {
      return Capteur.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create capteur');
    }
  }

  static Future<Capteur> updateCapteur(Capteur capteur) async {
    final response = await http.put(
      Uri.parse('$baseUrl/capteurs/${capteur.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(capteur.toJson()),
    );
    if (response.statusCode == 200) {
      return Capteur.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update capteur');
    }
  }

  static Future<void> deleteCapteur(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/capteurs/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete capteur');
    }
  }

  // ───────────────────────────── CHAUFFEUR ─────────────────────────────
  static Future<List<Chauffeur>> fetchChauffeurs() async {
    final response = await http.get(Uri.parse('$baseUrl/chauffeurs'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Chauffeur.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chauffeurs');
    }
  }

  static Future<Chauffeur> createChauffeur(Chauffeur chauffeur) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chauffeurs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chauffeur.toJson()),
    );
    if (response.statusCode == 201) {
      return Chauffeur.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create chauffeur');
    }
  }

  static Future<Chauffeur> updateChauffeur(Chauffeur chauffeur) async {
    final response = await http.put(
      Uri.parse('$baseUrl/chauffeurs/${chauffeur.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chauffeur.toJson()),
    );
    if (response.statusCode == 200) {
      return Chauffeur.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update chauffeur');
    }
  }

  static Future<void> deleteChauffeur(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/chauffeurs/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete chauffeur');
    }
  }

  // ───────────────────────────── RELEVE ─────────────────────────────
  static Future<List<Releve>> fetchReleves() async {
    final response = await http.get(Uri.parse('$baseUrl/releves'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Releve.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load releves');
    }
  }

  static Future<Releve> createReleve(Releve releve) async {
    final response = await http.post(
      Uri.parse('$baseUrl/releves'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(releve.toJson()),
    );
    if (response.statusCode == 201) {
      return Releve.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create releve');
    }
  }

  static Future<Releve> updateReleve(Releve releve) async {
    final response = await http.put(
      Uri.parse('$baseUrl/releves/${releve.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(releve.toJson()),
    );
    if (response.statusCode == 200) {
      return Releve.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update releve');
    }
  }

  static Future<void> deleteReleve(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/releves/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete releve');
    }
  }

  // ───────────────────────────── TOURNEE ─────────────────────────────
  static Future<List<Tournee>> fetchTournees() async {
    final response = await http.get(Uri.parse('$baseUrl/tournees'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Tournee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tournees');
    }
  }

  static Future<Tournee> createTournee(Tournee tournee) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tournees'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tournee.toJson()),
    );
    if (response.statusCode == 201) {
      return Tournee.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create tournee');
    }
  }

  static Future<Tournee> updateTournee(Tournee tournee) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tournees/${tournee.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tournee.toJson()),
    );
    if (response.statusCode == 200) {
      return Tournee.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update tournee');
    }
  }

  static Future<void> deleteTournee(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tournees/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete tournee');
    }
  }

  // ───────────────────────────── USER ─────────────────────────────
  static Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<User> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user');
    }
  }

  static Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  // ───────────────────────────── ZONE ─────────────────────────────
  static Future<List<Zone>> fetchZones() async {
    final response = await http.get(Uri.parse('$baseUrl/zones'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Zone.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load zones');
    }
  }

  static Future<Zone> createZone(Zone zone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/zones'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(zone.toJson()),
    );
    if (response.statusCode == 201) {
      return Zone.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create zone');
    }
  }

  static Future<Zone> updateZone(Zone zone) async {
    final response = await http.put(
      Uri.parse('$baseUrl/zones/${zone.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(zone.toJson()),
    );
    if (response.statusCode == 200) {
      return Zone.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update zone');
    }
  }

  static Future<void> deleteZone(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/zones/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete zone');
    }
  }
}