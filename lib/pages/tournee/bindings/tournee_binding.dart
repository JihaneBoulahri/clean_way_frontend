import 'package:get/get.dart';
import '../controllers/tournee_controller.dart';

class TourneeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TourneeController>(() => TourneeController());
  }
}