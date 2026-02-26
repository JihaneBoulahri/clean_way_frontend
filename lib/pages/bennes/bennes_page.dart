import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/benne_model.dart';
import '../../services/benne_service.dart';
import '../driver/dashboard_navbar.dart';
import '../driver/dashboard_sidebar.dart';
import '../../routes/app_routes.dart';

class BennesController extends GetxController {
  var bennes = <Benne>[].obs;
  var selectedBenne = Rxn<Benne>();
  var loading = false.obs;
  var error = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchBennes();
  }

  Future<void> fetchBennes() async {
    try {
      loading.value = true;
      error.value = null;

      final data = await BenneService.getBennesWithSensors();
      bennes.value = data
          .map<Benne>((json) => Benne.fromJson(json as Map<String, dynamic>))
          .toList();

      if (bennes.isNotEmpty) {
        selectedBenne.value = bennes.first;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void selectBenne(Benne benne) {
    selectedBenne.value = benne;
  }
}

class BennesPage extends GetView<BennesController> {
  const BennesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF22C55E);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            DashboardNavbar(
              primaryColor: primaryColor,
              firstName: 'Jihane',
              lastName: 'Ben',
              email: 'jihane@example.com',
              phone: '+212000000000',
              // Nom de la page affiché dans la navbar
              pageName: 'Bennes',
              // Rôle de l'utilisateur affiché dans la fiche profil
              userRole: 'Chauffeur',
              onToggleSidebar: () => _openSidebar(context, primaryColor),
              onRefresh: controller.fetchBennes,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;

                  return Row(
                    children: [
                      if (isWide)
                        SizedBox(
                          width: 260,
                          child: DashboardSidebar(
                            primaryColor: primaryColor,
                            userName: 'Jihane Ben',
                            userRole: 'Chauffeur',
                            onItemSelected: (route) =>
                                _handleSidebarNavigation(context, route),
                          ),
                        ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: Obx(() {
                          if (controller.loading.value) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (controller.error.value != null) {
                            return Center(
                              child: Text(
                                controller.error.value!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (controller.bennes.isEmpty) {
                            return const Center(
                              child: Text('Aucune benne trouvée'),
                            );
                          }

                          final list = _BennesList(
                            bennes: controller.bennes,
                            selected: controller.selectedBenne.value,
                            onSelect: controller.selectBenne,
                          );

                          final detail = _BenneDetail(
                            benne: controller.selectedBenne.value,
                          );

                          if (isWide) {
                            return Row(
                              children: [
                                Expanded(flex: 2, child: list),
                                const VerticalDivider(width: 1),
                                Expanded(flex: 3, child: detail),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              Expanded(child: list),
                              const Divider(height: 1),
                              SizedBox(
                                height: 260,
                                child: detail,
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _handleSidebarNavigation(BuildContext context, String route) {
  switch (route) {
    case 'dashboard':
      Get.toNamed(AppRoutes.dashboard);
      break;
    case 'bennes':
      // déjà sur la page bennes
      break;
    default:
      // autres routes à connecter plus tard
      break;
  }
}

void _openSidebar(BuildContext context, Color primaryColor) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final width = MediaQuery.of(ctx).size.width * 0.65; // 65% width
      return SafeArea(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: width,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DashboardSidebar(
                primaryColor: primaryColor,
                userName: 'Jihane Ben',
                userRole: 'Chauffeur',
                onItemSelected: (route) {
                  Navigator.of(ctx).pop();
                  _handleSidebarNavigation(context, route);
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _BennesList extends StatelessWidget {
  final List<Benne> bennes;
  final Benne? selected;
  final void Function(Benne) onSelect;

  const _BennesList({
    required this.bennes,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bennes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final b = bennes[index];
        final isSelected = selected?.id == b.id;

        // Pourcentage fictif basé sur la capacité
        final fillPercent = (b.capacite.clamp(0, 100)).toDouble();

        return InkWell(
          onTap: () => onSelect(b),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.1)
                            : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color:
                            isSelected ? Colors.white : const Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Benne #${b.id} - ${b.typeBenne}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${fillPercent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: fillPercent / 100,
                    minHeight: 8,
                    backgroundColor: isSelected
                        ? Colors.white.withOpacity(0.15)
                        : const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      fillPercent >= 80
                          ? Colors.redAccent
                          : (fillPercent >= 50
                              ? Colors.amber
                              : const Color(0xFF22C55E)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BenneDetail extends StatelessWidget {
  final Benne? benne;

  const _BenneDetail({this.benne});

  @override
  Widget build(BuildContext context) {
    if (benne == null) {
      return const Center(
        child: Text('Sélectionnez une benne pour voir les détails'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benne #${benne!.id}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            benne!.typeBenne,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 18),
          _infoRow(
            icon: Icons.scale,
            label: 'Capacité',
            value: '${benne!.capacite.toStringAsFixed(1)} %',
          ),
          const SizedBox(height: 10),
          _infoRow(
            icon: Icons.location_on_outlined,
            label: 'Position',
            value: '${benne!.latitude}, ${benne!.longitude}',
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // ici tu pourras ouvrir ta carte ou la page MAP
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.map_outlined),
              label: const Text(
                'Voir sur la carte',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

