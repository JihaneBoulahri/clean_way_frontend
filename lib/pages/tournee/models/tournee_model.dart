import '../../camion/models/camion_model.dart';
import '../../zone/models/zone_model.dart';

class Tournee {
  final int id;
  final DateTime dateTournee;
  final String heureDebut;
  final String? heureFin;
  final String status;
  final int? idCamion;
  final int? idZone;
  final Camion? camion;
  final Zone? zone;
  final List<int> benneIds;

  Tournee({
    required this.id,
    required this.dateTournee,
    required this.heureDebut,
    required this.heureFin,
    required this.status,
    this.idCamion,
    this.idZone,
    this.camion,
    this.zone,
    this.benneIds = const [],
  });

  factory Tournee.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    int? parseNullableInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    String parseString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is Map) {
        final raw = v['raw'] ?? v['value'] ?? v['date'];
        if (raw != null) {
          return DateTime.tryParse(raw.toString());
        }
      }
      return DateTime.tryParse(v.toString());
    }

    String parseStatus(dynamic v) {
      final raw = parseString(v).trim();
      if (raw.isNotEmpty) return raw;
      return 'en cours';
    }

    List<int> parseBenneIds(dynamic v) {
      if (v == null) return [];
      if (v is List) {
        return v.map((e) => parseInt(e)).where((e) => e > 0).toList();
      }
      return [];
    }

    return Tournee(
      id: parseInt(json['id_tournee'] ?? json['id'] ?? json['tournee_id']),
      dateTournee:
          parseDate(
            json['date_tournee'] ?? json['date'] ?? json['dateTournee'],
          ) ??
          DateTime.now(),
      heureDebut: parseString(
        json['heure_debut'] ?? json['heureDebut'] ?? json['start_time'],
      ),
      heureFin: json['heure_fin'] != null
          ? parseString(json['heure_fin'])
          : (json['heureFin'] != null
                ? parseString(json['heureFin'])
                : (json['end_time'] != null
                      ? parseString(json['end_time'])
                      : null)),
      status: parseStatus(json['status'] ?? json['etat'] ?? json['state']),
      idCamion: parseNullableInt(
        json['id_camion'] ?? json['camion_id'] ?? json['idCamion'],
      ),
      idZone: parseNullableInt(
        json['id_zone'] ?? json['zone_id'] ?? json['idZone'],
      ),
      camion: (json['camion'] == null && json['truck'] is Map)
          ? Camion.fromJson(Map<String, dynamic>.from(json['truck']))
          : (json['camion'] != null
                ? Camion.fromJson(
                    (json['camion'] is Map)
                        ? json['camion'] as Map<String, dynamic>
                        : Map<String, dynamic>.from(json['camion']),
                  )
                : null),
      zone: (json['zone'] == null && json['area'] is Map)
          ? Zone.fromJson(Map<String, dynamic>.from(json['area']))
          : (json['zone'] != null
                ? Zone.fromJson(
                    (json['zone'] is Map)
                        ? json['zone'] as Map<String, dynamic>
                        : Map<String, dynamic>.from(json['zone']),
                  )
                : null),
      benneIds: parseBenneIds(json['benne_ids'] ?? json['bennes'] ?? json['ids_benne']),
    );
  }

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'date_tournee': dateTournee.toIso8601String().split('T').first,
      'heure_debut': heureDebut,
      'status': status,
    };

    if (id > 0) {
      payload['id_tournee'] = id;
      payload['id'] = id;
    }
    if ((heureFin ?? '').trim().isNotEmpty) {
      payload['heure_fin'] = heureFin;
    }

    final camionId = idCamion ?? camion?.id;
    final zoneId = idZone ?? zone?.id;
    if (camionId != null) {
      payload['id_camion'] = camionId;
    }
    if (zoneId != null) {
      payload['id_zone'] = zoneId;
    }

    return payload;
  }

  String? get villeNom => zone?.villeNom ?? camion?.villeNom;
}
