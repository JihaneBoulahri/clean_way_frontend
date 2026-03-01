import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tournee_controller.dart';
import '../widgets/tournee_card.dart';
import '../widgets/tournee_form_dialog.dart';

class TourneePage extends GetView<TourneeController> {
  const TourneePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournées'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SearchBarField(
            hint: 'Rechercher...',
            onChanged: (v) => controller.searchOrFetch(v),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.tournees.isEmpty) {
                return const Center(child: Text('Aucune tournée'));
              }
              final list = controller.tournees;
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  // Vérification stricte pour éviter tout accès hors limites
                  if (i < 0 || i >= list.length) return const SizedBox.shrink();
                  final tournee = list[i];
                  return TourneeCard(
                    tournee: tournee,
                    onDelete: () => controller.deleteTournee(tournee.id),
                    onEdit: () => Get.dialog(TourneeFormDialog(tournee: tournee)),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(TourneeFormDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }
}