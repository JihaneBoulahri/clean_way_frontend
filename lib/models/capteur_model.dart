class Capteur {
  final int id; 
  final String typeCapteur;
  final DateTime? dateInstallation;
  final String status;
  final int? idPoint; 
  final double niveauRemplissage;

  Capteur({
    required this.id,
    required this.typeCapteur,
    required this.niveauRemplissage,
    this.dateInstallation,
    required this.status,
    this.idPoint,
  });

  factory Capteur.fromJson(Map<String, dynamic> json) {
    return Capteur(
      id: json['id_capteur'] as int,
      typeCapteur: json['type_capteur'] as String,
      niveauRemplissage: (json['niveau_remplissage'] as num).toDouble(),
      dateInstallation: json['date_installation'] != null
          ? DateTime.parse(json['date_installation'] as String)
          : null,
      status: json['status'] as String,
      idPoint: json['id_benne'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_capteur': id,
      'type_capteur': typeCapteur,
      'niveau_remplissage': niveauRemplissage,
      'date_installation': dateInstallation?.toIso8601String(),
      'status': status,
      'id_benne': idPoint,
    };
  }
}