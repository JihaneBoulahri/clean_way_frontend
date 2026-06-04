import 'package:clean_way_frontend/pages/camion/models/camion_model.dart';
import 'package:clean_way_frontend/pages/auth/models/user_model.dart';

class Chauffeur {
  // In users-based flow this is the User ID.
  final int id;
  final int? chauffeurId;
  final int? userId;
  final User? user;
  final String numTelephone;
  final String cni;
  final String permis;
  final int? camionId;
  final Camion? camion;

  Chauffeur({
    required this.id,
    this.chauffeurId,
    this.userId,
    this.user,
    required this.numTelephone,
    required this.cni,
    required this.permis,
    this.camionId,
    this.camion,
  });

  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    int? parseOptionalInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    String parseString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    Camion? parseCamion(dynamic v) {
      if (v == null) return null;
      if (v is Map) return Camion.fromJson(Map<String, dynamic>.from(v));
      return null;
    }

    User? parseUser(dynamic v) {
      if (v == null) return null;
      if (v is Map) {
        try {
          return User.fromJson(Map<String, dynamic>.from(v));
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    Map<String, dynamic>? parseMap(dynamic v) {
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    }

    final nestedChauffeur = parseMap(json['chauffeur']);
    final looksLikeUserPayload =
        nestedChauffeur != null ||
        (json.containsKey('role') &&
            json.containsKey('email') &&
            json.containsKey('id'));

    if (looksLikeUserPayload) {
      final userMap = parseMap(json['user']) ?? Map<String, dynamic>.from(json);
      final chauffeurMap = nestedChauffeur ?? <String, dynamic>{};

      final user = parseUser(userMap);
      final camion = parseCamion(chauffeurMap['camion'] ?? json['camion']);
      final parsedUserId = parseOptionalInt(
        userMap['id'] ??
            chauffeurMap['user_id'] ??
            json['user_id'] ??
            json['id_user'],
      );
      final parsedCamionId = parseOptionalInt(
        chauffeurMap['id_camion'] ??
            chauffeurMap['camion_id'] ??
            json['id_camion'] ??
            json['camion_id'],
      );

      return Chauffeur(
        id: parseInt(userMap['id'] ?? json['id']),
        chauffeurId: parseOptionalInt(
          chauffeurMap['id_chauffeur'] ?? json['id_chauffeur'],
        ),
        userId: parsedUserId ?? user?.id,
        user: user,
        numTelephone: parseString(
          chauffeurMap['num_telephone'] ?? json['num_telephone'],
        ),
        cni: parseString(chauffeurMap['cni'] ?? json['cni']),
        permis: parseString(chauffeurMap['permis'] ?? json['permis']),
        camionId: parsedCamionId ?? camion?.id,
        camion: camion,
      );
    }

    final user = parseUser(json['user']);
    final camion = parseCamion(json['camion']);
    final parsedUserId = parseOptionalInt(
      json['user_id'] ?? json['id_user'] ?? user?.id,
    );
    final parsedCamionId = parseOptionalInt(
      json['id_camion'] ?? json['camion_id'] ?? camion?.id,
    );

    return Chauffeur(
      id: parseInt(json['id_chauffeur'] ?? json['id']),
      chauffeurId: parseOptionalInt(json['id_chauffeur']),
      userId: parsedUserId ?? user?.id,
      user: user,
      numTelephone: parseString(json['num_telephone']),
      cni: parseString(json['cni']),
      permis: parseString(json['permis']),
      camionId: parsedCamionId ?? camion?.id,
      camion: camion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_chauffeur': chauffeurId ?? id,
      'id': id,
      'user_id': userId ?? user?.id,
      'num_telephone': numTelephone,
      'cni': cni,
      'permis': permis,
      'id_camion': camionId ?? camion?.id,
    };
  }
}
