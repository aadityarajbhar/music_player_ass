import 'package:get/get.dart';
import '../core/services/storage_service.dart';
import '../data/models/track_model.dart';

class FavoriteController extends GetxController {
  late final StorageService _storageService;

  /// Observable list of favorite tracks
  final RxList<Track> favoriteTracks = <Track>[].obs;

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<StorageService>();
    loadFavoritesFromStorage();
  }

  /// Load favorite tracks saved in GetStorage
  void loadFavoritesFromStorage() {
    try {
      final List<Map<String, dynamic>> rawList = _storageService.getFavorites();
      if (rawList.isNotEmpty) {
        final loadedTracks =
            rawList.map((json) => Track.fromJson(json)).toList();
        favoriteTracks.assignAll(loadedTracks);
      }
    } catch (e) {
      Get.log('Error loading favorites: $e');
    }
  }

  /// Check if a track is in favorites list
  bool isFavorite(String trackId) {
    return favoriteTracks.any((t) => t.id == trackId);
  }

  /// Toggle favorite status of a track silently without toast/snackbar
  Future<void> toggleFavorite(Track track) async {
    final bool currentlyFav = isFavorite(track.id);

    if (currentlyFav) {
      favoriteTracks.removeWhere((t) => t.id == track.id);
    } else {
      favoriteTracks.add(track);
    }

    // Persist updated favorite list to local storage
    await _storageService.saveFavorites(
      favoriteTracks.map((t) => t.toJson()).toList(),
    );
  }
}
