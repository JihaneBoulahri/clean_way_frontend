
class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final DateTime? emailVerifiedAt; // optional, rarely used in frontend

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
    );
  }
    // Getter pratiques
      String get fullName => '$prenom $nom';
      String get initials => (prenom.isNotEmpty ? prenom[0] : '') +
          (nom.isNotEmpty ? nom[0] : '');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
    };
  }
}