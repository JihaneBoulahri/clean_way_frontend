class Capteur {
  final int id;
  final String typeCapteur;
  final DateTime? dateInstallation;
  final String status;
  final int? idBenne;
  final double niveauRemplissage;

  Capteur({
    required this.id,
    required this.typeCapteur,
    required this.niveauRemplissage,
    this.dateInstallation,
    required this.status,
    this.idBenne,
  });

  factory Capteur.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? fallback;
    }

    double toDouble(dynamic value, {double fallback = 0}) {
      if (value == null) return fallback;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? fallback;
    }

    DateTime? toDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    final niveauRaw = json['niveau_remplissage'] ??
        json['niveau remplissage'] ??
        json['niveauRemplissage'];

    return Capteur(
      id: toInt(json['id_capteur'] ?? json['id']),
      typeCapteur: (json['type_capteur'] ?? json['typeCapteur'] ?? '').toString(),
      niveauRemplissage: toDouble(niveauRaw),
      dateInstallation: toDate(json['date_installation'] ?? json['dateInstallation']),
      status: (json['status'] ?? '').toString(),
      idBenne: (json['id_benne'] ?? json['idBenne']) == null
          ? null
          : toInt(json['id_benne'] ?? json['idBenne']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_capteur': id,
      'type_capteur': typeCapteur,
      'niveau_remplissage': niveauRemplissage,
      'date_installation': dateInstallation?.toIso8601String(),
      'status': status,
      'id_benne': idBenne,
    };
  }
}
