class Capteur {
  final int id; 
  final String typeCapteur;
  final DateTime? dateInstallation;
  final String statut;
  final int? idPoint; 
  final double niveauRemplissage;

  Capteur({
    required this.id,
    required this.typeCapteur,
    required this.niveauRemplissage,
    this.dateInstallation,
    required this.statut,
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
      statut: json['statut'] as String,
      idPoint: json['id_benne'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_capteur': id,
      'type_capteur': typeCapteur,
      'niveau_remplissage': niveauRemplissage,
      'date_installation': dateInstallation?.toIso8601String(),
      'statut': statut,
      'id_benne': idPoint,
    };
  }
}