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
      id: parseInt(json['id_zone']),
      nomZone: parseString(json['nom_zone']),
      typeZone: parseString(json['type_zone']),
      latitude: parseString(json['latitude']),
      longitude: parseString(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_zone': id,
      'nom_zone': nomZone,
      'type_zone': typeZone,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}