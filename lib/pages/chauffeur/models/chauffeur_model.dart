import 'package:clean_way_frontend/pages/camion/models/camion_model.dart';
import 'package:clean_way_frontend/pages/auth/models/user_model.dart';

class Chauffeur {
  final int id;
  final User? user;          // nouveau champ utilisateur
  final String numTelephone;
  final String cni;
  final String permis;
  final Camion? camion;      // lien vers camion

  Chauffeur({
    required this.id,
    this.user,
    required this.numTelephone,
    required this.cni,
    required this.permis,
    this.camion,
  });

  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    String parseString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    Camion? parseCamion(dynamic v) {
      if (v == null) return null;
      if (v is Map<String, dynamic>) return Camion.fromJson(v);
      return null;
    }

    User? parseUser(dynamic v) {
      if (v == null) return null;
      if (v is Map<String, dynamic>) {
        try {
          return User.fromJson(v);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Essayer de récupérer l'utilisateur de différentes façons
    User? user;
    
    // D'abord essayer la clé 'user'
    if (json['user'] != null) {
      user = parseUser(json['user']);
    }
    // Ensuite essayer 'user_id' avec les autres champs
    else if (json['user_id'] != null || json['user'] != null) {
      user = parseUser(json['user']);
    }

    return Chauffeur(
      id: parseInt(json['id_chauffeur']),
      user: user,
      numTelephone: parseString(json['num_telephone']),
      cni: parseString(json['cni']),
      permis: parseString(json['permis']),
      camion: parseCamion(json['camion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_chauffeur': id,
      'user_id': user?.id,
      'num_telephone': numTelephone,
      'cni': cni,
      'permis': permis,
      'id_camion': camion?.id,
    };
  }
}