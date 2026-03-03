import 'package:clean_way_frontend/pages/bennes/controllers/benne_controller.dart';
import 'package:clean_way_frontend/pages/bennes/views/benne_page.dart';
import 'package:get/get.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/auth/registre_page.dart';
import '../bindings/login_binding.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../controllers/dashboard_controller.dart';
import 'app_routes.dart';
import '../pages/camion/views/camion_page.dart';
import '../pages/camion/controllers/camion_controller.dart';
import '../pages/zone/views/zone_page.dart';
import '../pages/zone/controllers/zone_controller.dart';
import '../pages/tournee/views/tournee_page.dart';
import '../pages/tournee/controllers/tournee_controller.dart';
import '../pages/chauffeur/views/chauffeur_page.dart';
import '../pages/chauffeur/controllers/chauffeur_controller.dart';
import '../pages/settings/views/settings_page.dart';
import '../pages/help/views/help_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashPage(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signup, 
      page: () => RegisterPage()
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.camions,
      page: () => const CamionPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CamionController());
      }),
    ),
    GetPage(
      name: AppRoutes.bennes, 
      page: () => const BennesPage(),
      binding: BindingsBuilder((){
        Get.lazyPut(() => BennesController());
      }),
    ),
    GetPage(
      name: AppRoutes.zones, 
      page: () => const ZonePage(),
      binding: BindingsBuilder((){
        Get.lazyPut(() => ZoneController());
      }),
    ),
    GetPage(
      name: AppRoutes.tournees, 
      page: () => const TourneePage(),
      binding: BindingsBuilder((){
        Get.lazyPut(() => TourneeController());
      }),
    ),
    GetPage(
      name: AppRoutes.chauffeurs, 
      page: () => const ChauffeurPage(),
      binding: BindingsBuilder((){
        Get.lazyPut(() => ChauffeurController());
      }),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
    ),
    GetPage(
      name: AppRoutes.help,
      page: () => const HelpPage(),
    ),
  ];
}
