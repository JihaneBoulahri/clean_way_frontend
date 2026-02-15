class Benne {
  final int id;
  final String typeBenne;
  final double capacite;
  final double niveauRemplissage;
  final String position;

  Benne({
    required this.id,
    required this.typeBenne,
    required this.capacite,
    required this.niveauRemplissage,
    required this.position,
  });

  factory Benne.fromJson(Map<String, dynamic> json) {
    return Benne(
      id: json['id_point'] as int,
      typeBenne: json['type_benne'] as String,
      capacite: (json['capacite'] as num).toDouble(),
      niveauRemplissage: (json['niveau_remplissage'] as num).toDouble(),
      position: json['position'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_point': id,
      'type_benne': typeBenne,
      'capacite': capacite,
      'niveau_remplissage': niveauRemplissage,
      'position': position,
    };
  }
}