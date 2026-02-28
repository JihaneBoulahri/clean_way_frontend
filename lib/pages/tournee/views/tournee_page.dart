import 'package:clean_way_frontend/pages/tournee/controllers/tournee_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tournee_controller.dart';
import '../widgets/tournee_card.dart';
import '../../../routes/app_routes.dart';

class TourneePage extends GetView<TourneeController> {
  const TourneePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          }

          if (controller.tournees.isEmpty) {
            return const Text("No Data");
          }
          
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: controller.tournees.map((tournee) {
                    return TourneeCard(tournee: tournee, onDelete: () {
                      controller.deleteTournee(tournee.id);
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