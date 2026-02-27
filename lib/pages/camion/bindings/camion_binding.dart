import 'package:get/get.dart';
import '../controllers/camion_controller.dart';
class CamionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CamionController>(() => CamionController());
  }
}