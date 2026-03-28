class Zone {
  final int id;
  final String nomZone;
  final String typeZone;
  final String latitude;
  final String longitude;

  Zone({
    required this.id,
    required this.nomZone,
    required this.typeZone,
    required this.latitude,
    required this.longitude,
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

    return Zone(
      id: parseInt(json['id_zone'] ?? json['id']),
      nomZone: parseString(json['nom_zone'] ?? json['nom']),
      typeZone: parseString(json['type_zone'] ?? json['type']),
      latitude: parseString(json['latitude'] ?? json['lat']),
      longitude: parseString(json['longitude'] ?? json['lng'] ?? json['long']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nom_zone': nomZone,
      'type_zone': typeZone,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (id > 0) {
      data['id_zone'] = id;
    }
    return data;
  }
}
