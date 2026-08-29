import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/storage_service.dart';
import '../data/models/track_model.dart';
import '../data/providers/jamendo_api_provider.dart';

class TrackController extends GetxController {
  final JamendoApiProvider _apiProvider = JamendoApiProvider();
  late final StorageService _storageService;

  // Track Lists & State
  final RxList<Track> tracks = <Track>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFetchingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOfflineMode = false.obs;

  // Pagination parameters
  int _offset = 0;
  final int _limit = 20;

  // Search parameters
  final RxString searchQuery = ''.obs;
  final RxBool isSearchMode = false.obs;
  final TextEditingController searchBarController = TextEditingController();

  // Scroll Controller for Infinite Pagination
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<StorageService>();
    _setupScrollListener();
    fetchTracks(isRefresh: true);
  }

  /// Attach scroll listener to detect bottom scroll threshold
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 300) {
        // Trigger load next page when scrolled near bottom
        loadNextPage();
      }
    });
  }

  /// Initial fetch or pull-to-refresh tracks
  Future<void> fetchTracks({bool isRefresh = false}) async {
    if (isRefresh) {
      _offset = 0;
      hasMore.value = true;
      errorMessage.value = '';
      isOfflineMode.value = false;
      isLoading.value = true;
    }

    try {
      List<Track> newTracks;

      if (isSearchMode.value && searchQuery.value.trim().isNotEmpty) {
        newTracks = await _apiProvider.searchTracks(
          query: searchQuery.value,
          limit: _limit,
          offset: _offset,
        );
      } else {
        newTracks = await _apiProvider.getTracks(
          limit: _limit,
          offset: _offset,
        );
      }

      if (isRefresh) {
        tracks.assignAll(newTracks);
        // Cache initial page of tracks offline
        if (!isSearchMode.value && newTracks.isNotEmpty) {
          _storageService.saveTracks(newTracks.map((t) => t.toJson()).toList());
        }
      } else {
        tracks.addAll(newTracks);
      }

      // Check if end of list reached
      if (newTracks.length < _limit) {
        hasMore.value = false;
      }

      _offset += newTracks.length;
    } catch (e) {
      if (isRefresh) {
        // Fallback to offline cached tracks if initial fetch fails
        _loadOfflineCache(e.toString());
      } else {
        Get.snackbar(
          'Error',
          'Failed to load more tracks: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Load next page for pagination (prevents duplicate calls while loading)
  Future<void> loadNextPage() async {
    if (isFetchingMore.value || !hasMore.value || isLoading.value || isOfflineMode.value) {
      return;
    }

    isFetchingMore.value = true;

    try {
      List<Track> newTracks;
      if (isSearchMode.value && searchQuery.value.trim().isNotEmpty) {
        newTracks = await _apiProvider.searchTracks(
          query: searchQuery.value,
          limit: _limit,
          offset: _offset,
        );
      } else {
        newTracks = await _apiProvider.getTracks(
          limit: _limit,
          offset: _offset,
        );
      }

      if (newTracks.isEmpty || newTracks.length < _limit) {
        hasMore.value = false;
      }

      tracks.addAll(newTracks);
      _offset += newTracks.length;
    } catch (e) {
      Get.log('Error loading next page: $e');
    } finally {
      isFetchingMore.value = false;
    }
  }

  /// Load cached tracks from GetStorage as fallback
  void _loadOfflineCache(String errorMsg) {
    final cachedData = _storageService.getCachedTracks();
    if (cachedData.isNotEmpty) {
      tracks.assignAll(cachedData.map((json) => Track.fromJson(json)).toList());
      isOfflineMode.value = true;
      hasMore.value = false;
      errorMessage.value = '';
    } else {
      errorMessage.value = errorMsg;
    }
  }

  /// Perform track search with query
  void onSearchQueryChanged(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      isSearchMode.value = false;
      fetchTracks(isRefresh: true);
    } else {
      isSearchMode.value = true;
      fetchTracks(isRefresh: true);
    }
  }

  /// Clear search input
  void clearSearch() {
    searchBarController.clear();
    searchQuery.value = '';
    isSearchMode.value = false;
    fetchTracks(isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchBarController.dispose();
    super.onClose();
  }
}
