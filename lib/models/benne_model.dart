class Benne {
  final int id;
  final String typeBenne;
  final double capacite;
  final String latitude;
  final String longitude;


  Benne({
    required this.id,
    required this.typeBenne,
    required this.capacite,
    required this.latitude,
    required this.longitude,
  });

  factory Benne.fromJson(Map<String, dynamic> json) {
    return Benne(
      id: json['id_benne'] as int,
      typeBenne: json['type_benne'] as String,
      capacite: (json['capacite'] as num).toDouble(),
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_benne': id,
      'type_benne': typeBenne,
      'capacite': capacite,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}