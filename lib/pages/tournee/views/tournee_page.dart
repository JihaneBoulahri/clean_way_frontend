import 'package:clean_way_frontend/widgets/search_bar_field.dart';
import 'package:clean_way_frontend/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tournee_controller.dart';
import '../widgets/tournee_card.dart';
import '../widgets/tournee_form_dialog.dart';

class TourneePage extends GetView<TourneeController> {
  const TourneePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: "Tournées",
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(const TourneeFormDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      child: Column(
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
    );
  }
}