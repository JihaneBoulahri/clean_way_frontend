import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/zone_model.dart';
import '../../../routes/app_routes.dart';

class ZoneCard extends StatelessWidget {
  final Zone zone;

  const ZoneCard({
    super.key,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.zoneDetail, arguments: zone),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A1F14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFFF7A00),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      zone.nomZone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  zone.typeZone,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lat: ${_shortCoord(zone.latitude)}',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lng: ${_shortCoord(zone.longitude)}',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortCoord(String value) {
    if (value.length <= 10) return value;
    return '${value.substring(0, 10)}...';
  }
}
