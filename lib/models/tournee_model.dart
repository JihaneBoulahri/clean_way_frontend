import 'camion_model.dart';
import 'zone_model.dart';

class Tournee {
  final int id;
  final DateTime dateTournee;
  final String heureDebut;
  final String? heureFin;
  final String status;
  final Camion? camion;
  final Zone? zone;

  Tournee({
    required this.id,
    required this.dateTournee,
    required this.heureDebut,
    required this.heureFin,
    required this.status,
    this.camion,
    this.zone,
  });

  factory Tournee.fromJson(Map<String, dynamic> json) {
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

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return Tournee(
      id: parseInt(json['id_tournee']),
      dateTournee: parseDate(json['date_tournee']) ?? DateTime.now(),
      heureDebut: parseString(json['heure_debut']),
      heureFin: json['heure_fin'] != null ? parseString(json['heure_fin']) : null,
      status: parseString(json['status']),
      camion: json['camion'] != null
          ? Camion.fromJson((json['camion'] is Map) ? json['camion'] as Map<String, dynamic> : Map<String, dynamic>.from(json['camion']))
          : null,
      zone: json['zone'] != null
          ? Zone.fromJson((json['zone'] is Map) ? json['zone'] as Map<String, dynamic> : Map<String, dynamic>.from(json['zone']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tournee': id,
      'date_tournee': dateTournee.toIso8601String().split('T').first,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'status': status,
      'id_camion': camion?.id,
      'id_zone': zone?.id,
    };
  }
}