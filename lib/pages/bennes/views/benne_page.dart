import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/benne_controller.dart';
import '../widgets/benne_card.dart';
import '../widgets/benne_form_dialog.dart';

class BennesPage extends GetView<BennesController> {
  const BennesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: "Bennes",
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(const BenneFormDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      child: Column(
        children: [
          SearchBarField(
            hint: 'Rechercher par type, capacité, coordonnées...',
            onChanged: (v) => controller.searchQuery.value = v,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.bennes.isEmpty) {
                return const Center(child: Text('Aucune benne'));
              }
              final list = controller.filteredBennes;
              if (list.isEmpty) {
                return const Center(child: Text('Aucun résultat'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final benne = list[i];
                  return BenneCard(
                    benne: benne,
                    onDelete: () => controller.deleteBenne(benne.id),
                    onEdit: () => Get.dialog(
                      BenneFormDialog(benne: benne),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
