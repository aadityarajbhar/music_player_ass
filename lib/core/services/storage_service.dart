import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  static const String _cachedTracksKey = 'cached_tracks_list';
  static const String _lastCacheTimeKey = 'last_cache_time';
  static const String _favoriteTracksKey = 'favorite_tracks_list';

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  /// Save fetched tracks list as raw JSON maps for offline playback & fallback
  Future<void> saveTracks(List<Map<String, dynamic>> tracksJson) async {
    try {
      await _box.write(_cachedTracksKey, tracksJson);
      await _box.write(_lastCacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      Get.log('Error saving tracks to cache: $e');
    }
  }

  /// Get cached tracks from local storage
  List<Map<String, dynamic>> getCachedTracks() {
    try {
      final List<dynamic>? rawList = _box.read<List<dynamic>>(_cachedTracksKey);
      if (rawList != null) {
        return rawList
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    } catch (e) {
      Get.log('Error reading cached tracks: $e');
    }
    return [];
  }

  /// Save favorite tracks JSON list to local storage
  Future<void> saveFavorites(List<Map<String, dynamic>> favoritesJson) async {
    try {
      await _box.write(_favoriteTracksKey, favoritesJson);
    } catch (e) {
      Get.log('Error saving favorite tracks: $e');
    }
  }

  /// Get stored favorite tracks JSON list
  List<Map<String, dynamic>> getFavorites() {
    try {
      final List<dynamic>? rawList = _box.read<List<dynamic>>(_favoriteTracksKey);
      if (rawList != null) {
        return rawList
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    } catch (e) {
      Get.log('Error reading favorite tracks: $e');
    }
    return [];
  }

  /// Returns true if cached tracks are available
  bool get hasCachedTracks => getCachedTracks().isNotEmpty;

  /// Get time of last cache
  String? get lastCacheTime => _box.read<String>(_lastCacheTimeKey);
}
