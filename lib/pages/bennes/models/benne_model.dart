import '../../../capteur_model.dart';

class Benne {
  final int id;
  final String typeBenne;
  final String status;
  final double capacite;
  final String latitude;
  final String longitude;
  final Capteur? capteur;
  final List<Capteur> capteurs;

  Benne({
    required this.id,
    required this.typeBenne,
    required this.status,
    required this.capacite,
    required this.latitude,
    required this.longitude,
    this.capteur,
    this.capteurs = const [],
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
        if (first is Map) {
          return Capteur.fromJson(Map<String, dynamic>.from(first));
        }
        return null;
      }
      if (raw is Map<String, dynamic>) return Capteur.fromJson(raw);
      if (raw is Map) return Capteur.fromJson(Map<String, dynamic>.from(raw));
      return null;
    }

    List<Capteur> parseCapteurs(dynamic raw) {
      if (raw == null) return const [];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((item) => Capteur.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      if (raw is Map<String, dynamic>) return [Capteur.fromJson(raw)];
      if (raw is Map) return [Capteur.fromJson(Map<String, dynamic>.from(raw))];
      return const [];
    }

    final parsedCapteurs = parseCapteurs(json['capteurs'] ?? json['capteur']);
    final parsedCapteur = parsedCapteurs.isNotEmpty
        ? parsedCapteurs.first
        : parseCapteur(json['capteur'] ?? json['capteurs']);

    return Benne(
      id: toInt(json['id_benne'] ?? json['id']),
      typeBenne: (json['type_benne'] ?? json['typeBenne'] ?? '').toString(),
      status: (json['status'] ?? json['etat'] ?? '').toString(),
      capacite: toDouble(json['capacite']),
      latitude: (json['latitude'] ?? '').toString(),
      longitude: (json['longitude'] ?? '').toString(),
      capteur: parsedCapteur,
      capteurs: parsedCapteurs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_benne': id,
      'type_benne': typeBenne,
      'status': status,
      'capacite': capacite,
      'latitude': latitude,
      'longitude': longitude,
      'capteur': capteur?.toJson(),
      'capteurs': capteurs.map((c) => c.toJson()).toList(),
    };
  }
}
