import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/zone_controller.dart';
import '../widgets/zone_card.dart';
import '../../../routes/app_routes.dart';

class ZonePage extends GetView<ZoneController> {
  const ZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          }

          if (controller.zones.isEmpty) {
            return const Text("No Data");
          }
          
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: controller.zones.map((zone) {
                    return ZoneCard(zone: zone, onDelete: () {
                      controller.deleteZone(zone.id);
                    });
                  }).toList(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}