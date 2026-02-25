
class Camion {
  final int id;
  final String immatriculation;
  final String typeCamion;
  final double capaciteCamion;
  final DateTime? dateMiseEnService;
  final String status;

  Camion({
    required this.id,
    required this.immatriculation,
    required this.typeCamion,
    required this.capaciteCamion,
    this.dateMiseEnService,
    required this.status,
  });

  factory Camion.fromJson(Map<String, dynamic> json) {
    return Camion(
      id: json['id_camion'] as int,
      immatriculation: json['immatriculation'] as String,
      typeCamion: json['type_camion'] as String,
      capaciteCamion: (json['capacite_camion'] as num).toDouble(),
      dateMiseEnService: json['date_mise_en_service'] != null
          ? DateTime.parse(json['date_mise_en_service'] as String)
          : null,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_camion': id,
      'immatriculation': immatriculation,
      'type_camion': typeCamion,
      'capacite_camion': capaciteCamion,
      'date_mise_en_service': dateMiseEnService?.toIso8601String(),
      'status': status,
    };
  }
}