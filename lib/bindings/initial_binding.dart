import 'package:get/get.dart';
import 'package:music_player/controllers/favorite_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/track_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put controllers into Get dependency injection container
    Get.put<PlayerController>(PlayerController(), permanent: true);
    Get.put<TrackController>(TrackController(), permanent: true);
    Get.put<FavoriteController>(FavoriteController(), permanent: true);
  }
}
