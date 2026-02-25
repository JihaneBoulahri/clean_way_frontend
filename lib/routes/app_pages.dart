import 'package:get/get.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/auth/registre_page.dart';
import '../bindings/login_binding.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/bennes/bennes_page.dart';
import '../controllers/dashboard_controller.dart';
import 'app_routes.dart';

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
      name: '/bennes',
      page: () => const BennesPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BennesController());
      }),
    ),
  ];
}
