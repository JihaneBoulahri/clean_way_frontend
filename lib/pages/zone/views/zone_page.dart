import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/zone_controller.dart';
import '../widgets/zone_card.dart';
import '../widgets/zone_form_dialog.dart';

class ZonePage extends GetView<ZoneController> {
  const ZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zones'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SearchBarField(
            hint: 'Rechercher par nom, type, coordonnées...',
            onChanged: (v) => controller.searchQuery.value = v,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.zones.isEmpty) {
                return const Center(child: Text('Aucune zone'));
              }
              final list = controller.filteredZones;
              if (list.isEmpty) {
                return const Center(child: Text('Aucun résultat'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  // Sécurité contre les accès hors limites
                  if (i >= list.length) return const SizedBox.shrink();
                  final zone = list[i];
                  return ZoneCard(
                    zone: zone,
                    onDelete: () => controller.deleteZone(zone.id),
                    onEdit: () => Get.dialog(ZoneFormDialog(zone: zone)),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(ZoneFormDialog()), // plus de const
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }
}