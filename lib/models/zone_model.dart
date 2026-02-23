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
    return Zone(
      id: json['id_zone'] as int,
      nomZone: json['nom_zone'] as String,
      typeZone: json['type_zone'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
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