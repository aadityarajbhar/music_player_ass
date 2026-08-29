import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/track_controller.dart';
import '../../core/constants/app_colors.dart';
import '../search/search_screen.dart';
import '../widgets/mini_player.dart';
import '../widgets/state_widgets.dart';
import '../widgets/track_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trackController = Get.find<TrackController>();
    final playerController = Get.find<PlayerController>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.headphones_rounded,
                color: AppColors.primaryAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Jamendo Beats',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 26),
            onPressed: () {
              Get.to(() => const SearchScreen());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Offline Cached Banner indicator if offline
              Obx(() {
                if (trackController.isOfflineMode.value) {
                  return Container(
                    width: double.infinity,
                    color: Colors.amber.shade900.withValues(alpha: 0.8),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'You are offline. Showing cached tracks.',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Main Song List
              Expanded(
                child: Obx(() {
                  if (trackController.isLoading.value && trackController.tracks.isEmpty) {
                    return const LoadingWidget(message: 'Discovering music...');
                  }

                  if (trackController.errorMessage.value.isNotEmpty && trackController.tracks.isEmpty) {
                    return ErrorStateWidget(
                      message: trackController.errorMessage.value,
                      onRetry: () => trackController.fetchTracks(isRefresh: true),
                    );
                  }

                  if (trackController.tracks.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No Tracks Found',
                      description: 'Check back later or pull down to refresh.',
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => trackController.fetchTracks(isRefresh: true),
                    child: ListView.builder(
                      controller: trackController.scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: 90),
                      itemCount: trackController.tracks.length + 1,
                      itemBuilder: (context, index) {
                        // Footer element for scroll pagination loader
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

                            if (!trackController.hasMore.value && trackController.tracks.isNotEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    'You\'ve reached the end of the list',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
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
                            onTap: () {
                              playerController.playTrack(
                                track,
                                newPlaylist: trackController.tracks,
                              );
                            },
                          );
                        });
                      },
                    ),
                  );
                }),
              ),
            ],
          ),

          // Mini Player Widget at bottom
          const Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }
}
