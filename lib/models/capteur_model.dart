class Capteur {
  final int id; 
  final String typeCapteur;
  final DateTime? dateInstallation;
  final String statut;
  final int? idPoint; 

  Capteur({
    required this.id,
    required this.typeCapteur,
    this.dateInstallation,
    required this.statut,
    this.idPoint,
  });

  factory Capteur.fromJson(Map<String, dynamic> json) {
    return Capteur(
      id: json['id_capteur'] as int,
      typeCapteur: json['type_capteur'] as String,
      dateInstallation: json['date_installation'] != null
          ? DateTime.parse(json['date_installation'] as String)
          : null,
      statut: json['statut'] as String,
      idPoint: json['id_point'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_capteur': id,
      'type_capteur': typeCapteur,
      'date_installation': dateInstallation?.toIso8601String(),
      'statut': statut,
      'id_point': idPoint,
    };
  }
}