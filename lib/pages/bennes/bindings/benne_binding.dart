import 'package:get/get.dart';
import '../controllers/benne_controller.dart';

class BennesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BennesController>(() => BennesController());
  }
}
