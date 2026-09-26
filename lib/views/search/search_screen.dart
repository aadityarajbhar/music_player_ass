import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controllers/favorite_controller.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/track_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/mini_player.dart';
import '../widgets/state_widgets.dart';
import '../widgets/track_tile.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trackController = Get.find<TrackController>();
    final playerController = Get.find<PlayerController>();
    final favoriteController = Get.find<FavoriteController>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: trackController.searchBarController,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search songs, artists...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              suffixIcon: Obx(() {
                if (trackController.searchQuery.value.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => trackController.clearSearch(),
                  );
                }
                return const SizedBox.shrink();
              }),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            onChanged: (query) => trackController.onSearchQueryChanged(query),
          ),
        ),
      ),
      body: Stack(
        children: [
          Obx(() {
            if (trackController.searchQuery.value.isEmpty) {
              return const EmptyStateWidget(
                title: 'Search Jamendo Tracks',
                description:
                    'Type a song title or artist name above to begin searching.',
                icon: Icons.search_rounded,
              );
            }

            if (trackController.isLoading.value &&
                trackController.tracks.isEmpty) {
              return const LoadingWidget(message: 'Searching music library...');
            }

            if (trackController.errorMessage.value.isNotEmpty &&
                trackController.tracks.isEmpty) {
              return ErrorStateWidget(
                message: trackController.errorMessage.value,
                onRetry: () => trackController.fetchTracks(isRefresh: true),
              );
            }

            if (trackController.tracks.isEmpty) {
              return EmptyStateWidget(
                title: 'No results found',
                description:
                    'No tracks matching "${trackController.searchQuery.value}"',
                icon: Icons.search_off_rounded,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: trackController.tracks.length + 1,
              itemBuilder: (context, index) {
                if (index == trackController.tracks.length) {
                  return Obx(() {
                    if (trackController.isFetchingMore.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  });
                }

                final track = trackController.tracks[index];

                return Obx(() {
                  final currentTrack = playerController.currentTrack.value;
                  final isCurrentlyPlaying = currentTrack?.id == track.id;

                  return TrackTile(
                    track: track,
                    isCurrentlyPlaying: isCurrentlyPlaying,
                    isFavorite: favoriteController.isFavorite(track.id),
                    onFavoriteToggle: () {
                      favoriteController.toggleFavorite(track);
                    },
                    onTap: () {
                      playerController.playTrack(
                        track,
                        newPlaylist: trackController.tracks,
                      );
                    },
                  );
                });
              },
            );
          }),

          // Mini player at bottom
          const Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),
        ],
      ),
    );
  }
}
