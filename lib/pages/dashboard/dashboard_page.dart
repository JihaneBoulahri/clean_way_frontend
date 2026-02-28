import 'package:clean_way_frontend/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import 'widgets/stats_grid.dart';
import 'widgets/recent_activity.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.error.value != null) {
            return Center(
              child: Text(
                controller.error.value!,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final stats = controller.stats.value;

          if (stats == null) {
            return const Center(
              child: Text(
                "No data",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                const Text(
                  "Hello Jihane 👋",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Ready to start working",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                StatsGrid(stats: stats),

                const SizedBox(height: 30),

                const Text(
                  "Recent Activity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const RecentActivity(),

                const SizedBox(height: 30),

                TextButton(
                  onPressed: (){
                    Get.toNamed(AppRoutes.camions);
                  }, 
                  child: Text(
                    'Voir camions',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 30),

                TextButton(
                  onPressed: (){
                    Get.toNamed(AppRoutes.bennes);
                  }, 
                  child: Text(
                    'Voir bennes',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}