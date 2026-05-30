class Ville {
  final int id;
  final String nomVille;
  final String? createdAt;
  final String? updatedAt;

  Ville({
    required this.id,
    required this.nomVille,
    this.createdAt,
    this.updatedAt,
  });

  factory Ville.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    String? parseFormattedDate(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        final formatted = value['formatted']?.toString().trim();
        if (formatted != null && formatted.isNotEmpty) return formatted;
        final raw = value['raw']?.toString().trim();
        if (raw != null && raw.isNotEmpty) return raw;
      }
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return Ville(
      id: parseInt(json['id_ville'] ?? json['id']),
      nomVille: parseString(json['nom_ville'] ?? json['nom'] ?? json['name']),
      createdAt: parseFormattedDate(json['created_at']),
      updatedAt: parseFormattedDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nom_ville': nomVille,
    };
    if (id > 0) {
      data['id_ville'] = id;
    }
    return data;
  }
}
