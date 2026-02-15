class Chauffeur {
  final int id; 
  final int userId;
  final String numTelephone;
  final String cni;
  final String permis;
  final int? idCamion; 

  Chauffeur({
    required this.id,
    required this.userId,
    required this.numTelephone,
    required this.cni,
    required this.permis,
    this.idCamion,
  });

  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    return Chauffeur(
      id: json['id_chauffeur'] as int,
      userId: json['user_id'] as int,
      numTelephone: json['num_telephone'] as String,
      cni: json['cni'] as String,
      permis: json['permis'] as String,
      idCamion: json['id_camion'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_chauffeur': id,
      'user_id': userId,
      'num_telephone': numTelephone,
      'cni': cni,
      'permis': permis,
      'id_camion': idCamion,
    };
  }
}