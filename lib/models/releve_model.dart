class Releve {
  final int id; 
  final double valeur;
  final String unite;
  final DateTime date;
  final int idCapteur; 

  Releve({
    required this.id,
    required this.valeur,
    required this.unite,
    required this.date,
    required this.idCapteur,
  });

  factory Releve.fromJson(Map<String, dynamic> json) {
    return Releve(
      id: json['id_releve'] as int,
      valeur: (json['valeur'] as num).toDouble(),
      unite: json['unite'] as String,
      date: DateTime.parse(json['date'] as String),
      idCapteur: json['id_capteur'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_releve': id,
      'valeur': valeur,
      'unite': unite,
      'date': date.toIso8601String(),
      'id_capteur': idCapteur,
    };
  }
}