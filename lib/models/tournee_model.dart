class Tournee {
  final int id; 
  final DateTime dateTournee;
  final String heureDebut; 
  final String heureFin;
  final String statut;
  final int? idCamion;
  final int? id_zone; 

  Tournee({
    required this.id,
    required this.dateTournee,
    required this.heureDebut,
    required this.heureFin,
    required this.statut,
    this.idCamion,
    this.id_zone,
  });

  factory Tournee.fromJson(Map<String, dynamic> json) {
    return Tournee(
      id: json['id_tournee'] as int,
      dateTournee: DateTime.parse(json['date_tournee'] as String),
      heureDebut: json['heure_debut'] as String,
      heureFin: json['heure_fin'] as String,
      statut: json['statut'] as String,
      idCamion: json['id_camion'] as int?,
      id_zone: json['id_zone'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tournee': id,
      'date_tournee': dateTournee.toIso8601String(),
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'statut': statut,
      'id_camion': idCamion,
      'id_zone': id_zone,
    };
  }
}