import 'package:get/get.dart';
import '../controllers/player_controller.dart';
import '../controllers/track_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put controllers into Get dependency injection container
    Get.put<PlayerController>(PlayerController(), permanent: true);
    Get.put<TrackController>(TrackController(), permanent: true);
  }
}
