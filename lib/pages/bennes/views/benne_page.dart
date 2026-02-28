import 'package:clean_way_frontend/pages/bennes/widgets/benne_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/benne_model.dart';
import '../../../services/benne_service.dart';
import '../../../routes/app_routes.dart';
import '../controllers/benne_controller.dart';
import '../widgets/benne_card.dart';

class BennesPage extends GetView<BennesController>{
  const BennesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx((){
          if(controller.isLoading.value){
            return const CircularProgressIndicator();
          }
          if(controller.bennes.isEmpty){
            return const Text("No Data");
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: controller.bennes.map((benne) {
                    return BenneCard(benne: benne, onDelete: () {
                      controller.deleteBenne(benne.id);
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