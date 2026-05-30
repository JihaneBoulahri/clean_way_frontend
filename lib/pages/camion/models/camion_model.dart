
import '../../zone/models/zone_model.dart';

class Camion {
  final int id;
  final String immatriculation;
  final String typeCamion;
  final double capaciteCamion;
  final DateTime? dateMiseEnService;
  final String status;
  final int? idZone;
  final Zone? zone;

  Camion({
    required this.id,
    required this.immatriculation,
    required this.typeCamion,
    required this.capaciteCamion,
    this.dateMiseEnService,
    required this.status,
    this.idZone,
    this.zone,
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
      if (v is Map) {
        final raw = v['raw'] ?? v['value'] ?? v['date'];
        if (raw != null) {
          return DateTime.tryParse(raw.toString());
        }
        final formatted = v['formatted'];
        if (formatted != null) {
          return DateTime.tryParse(formatted.toString());
        }
      }
      return DateTime.tryParse(v.toString());
    }

    int? _parseNullableInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    Zone? _parseZone(dynamic raw) {
      if (raw == null) return null;
      if (raw is Map<String, dynamic>) return Zone.fromJson(raw);
      if (raw is Map) return Zone.fromJson(Map<String, dynamic>.from(raw));
      return null;
    }

    return Camion(
      id: _parseInt(json['id_camion']),
      immatriculation: _parseString(json['immatriculation']),
      typeCamion: _parseString(json['type_camion']),
      capaciteCamion: _parseDouble(json['capacite_camion']),
      dateMiseEnService: _parseDate(json['date_mise_en_service']),
      status: _parseString(json['status']),
      idZone: _parseNullableInt(json['id_zone'] ?? json['zone_id']),
      zone: _parseZone(json['zone']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id_camion': id,
      'immatriculation': immatriculation,
      'type_camion': typeCamion,
      'capacite_camion': capaciteCamion,
      'date_mise_en_service': dateMiseEnService?.toIso8601String(),
      'status': status,
    };
    final zoneId = idZone ?? zone?.id;
    if (zoneId != null) {
      data['id_zone'] = zoneId;
    }
    return data;
  }

  String? get villeNom => zone?.ville?.nomVille;
}
