
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
    int _parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    double _parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    String _parseString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return Camion(
      id: _parseInt(json['id_camion']),
      immatriculation: _parseString(json['immatriculation']),
      typeCamion: _parseString(json['type_camion']),
      capaciteCamion: _parseDouble(json['capacite_camion']),
      dateMiseEnService: _parseDate(json['date_mise_en_service']),
      status: _parseString(json['status']),
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