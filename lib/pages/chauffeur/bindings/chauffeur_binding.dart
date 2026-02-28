import 'package:get/get.dart';
import '../controllers/chauffeur_controller.dart';

class ChauffeurBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChauffeurController>(() => ChauffeurController());
  }
}