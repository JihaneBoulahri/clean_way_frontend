import '../../../capteur_model.dart';

class Benne {
  final int id;
  final String typeBenne;
  final double capacite;
  final String latitude;
  final String longitude;
  final Capteur? capteur;


  Benne({
    required this.id,
    required this.typeBenne,
    required this.capacite,
    required this.latitude,
    required this.longitude,
    this.capteur,
  });

  factory Benne.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? fallback;
    }

    double toDouble(dynamic value, {double fallback = 0}) {
      if (value == null) return fallback;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? fallback;
    }

    Capteur? parseCapteur(dynamic raw) {
      if (raw == null) return null;
      if (raw is List && raw.isNotEmpty) {
        final first = raw.first;
        if (first is Map<String, dynamic>) return Capteur.fromJson(first);
        if (first is Map) return Capteur.fromJson(Map<String, dynamic>.from(first));
        return null;
      }
      if (raw is Map<String, dynamic>) return Capteur.fromJson(raw);
      if (raw is Map) return Capteur.fromJson(Map<String, dynamic>.from(raw));
      return null;
    }

    return Benne(
      id: toInt(json['id_benne'] ?? json['id']),
      typeBenne: (json['type_benne'] ?? json['typeBenne'] ?? '').toString(),
      capacite: toDouble(json['capacite']),
      latitude: (json['latitude'] ?? '').toString(),
      longitude: (json['longitude'] ?? '').toString(),
      capteur: parseCapteur(json['capteur'] ?? json['capteurs']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_benne': id,
      'type_benne': typeBenne,
      'capacite': capacite,
      'latitude': latitude,
      'longitude': longitude,
      'capteur': capteur?.toJson(),
    };
  }
}
