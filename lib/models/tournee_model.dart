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
    return Tournee(
      id: json['id_tournee'] as int,
      dateTournee: DateTime.parse(json['date_tournee'] as String),
      heureDebut: json['heure_debut'] as String,
      heureFin: json['heure_fin'] as String?,
      status: json['status'] as String,
      camion: json['camion'] != null
          ? Camion.fromJson(json['camion'] as Map<String, dynamic>)
          : null,
      zone: json['zone'] != null
          ? Zone.fromJson(json['zone'] as Map<String, dynamic>)
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