import '../../ville/models/ville_model.dart';

class Zone {
  final int id;
  final String nomZone;
  final String typeZone;
  final String latitude;
  final String longitude;
  final int? idVille;
  final Ville? ville;

  Zone({
    required this.id,
    required this.nomZone,
    required this.typeZone,
    required this.latitude,
    required this.longitude,
    this.idVille,
    this.ville,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
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

    int? parseNullableInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    Ville? parseVille(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return Ville.fromJson(value);
      if (value is Map) return Ville.fromJson(Map<String, dynamic>.from(value));
      return null;
    }

    return Zone(
      id: parseInt(json['id_zone'] ?? json['id']),
      nomZone: parseString(json['nom_zone'] ?? json['nom']),
      typeZone: parseString(json['type_zone'] ?? json['type']),
      latitude: parseString(json['latitude'] ?? json['lat']),
      longitude: parseString(json['longitude'] ?? json['lng'] ?? json['long']),
      idVille: parseNullableInt(json['id_ville'] ?? json['ville_id']),
      ville: parseVille(json['ville']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nom_zone': nomZone,
      'type_zone': typeZone,
      'latitude': latitude,
      'longitude': longitude,
    };
    final villeId = idVille ?? ville?.id;
    if (villeId != null) {
      data['id_ville'] = villeId;
    }
    if (id > 0) {
      data['id_zone'] = id;
    }
    return data;
  }

  String? get villeNom => ville?.nomVille;
}
