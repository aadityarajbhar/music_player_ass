import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/player_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/seek_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 36),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'NOW PLAYING',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: Obx(() {
        final track = playerController.currentTrack.value;

        if (track == null) {
          return const Center(
            child: Text(
              'No track selected',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Large Artwork Card
                Center(
                  child: Hero(
                    tag: 'track_art_${track.id}',
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.78,
                      height: MediaQuery.of(context).size.width * 0.78,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: track.image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: track.image,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.surfaceLight,
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.surfaceLight,
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.surfaceLight,
                                child: const Icon(
                                  Icons.music_note,
                                  size: 80,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Track Info (Title & Artist)
                Column(
                  children: [
                    Text(
                      track.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${track.artistName} • ${track.albumName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // Progress Bar & Duration Timestamps
                Obx(() {
                  return SeekBar(
                    position: playerController.position.value,
                    duration: playerController.duration.value,
                    onChangeEnd: (newPosition) {
                      playerController.seek(newPosition);
                    },
                  );
                }),

                const Spacer(flex: 1),

                // Audio Playback Control Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle mode button
                    Obx(() {
                      final isShuffle = playerController.isShuffleMode.value;
                      return IconButton(
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: isShuffle ? AppColors.secondary : AppColors.textMuted,
                          size: 24,
                        ),
                        onPressed: () => playerController.toggleShuffle(),
                      );
                    }),

                    // Previous Track Button
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: AppColors.textPrimary,
                        size: 42,
                      ),
                      onPressed: () => playerController.playPrevious(),
                    ),

                    // Play / Pause Button
                    Obx(() {
                      if (playerController.isLoadingAudio.value) {
                        return Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        );
                      }

                      final isPlaying = playerController.isPlaying.value;
                      return GestureDetector(
                        onTap: () => playerController.togglePlayPause(),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      );
                    }),

                    // Next Track Button
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textPrimary,
                        size: 42,
                      ),
                      onPressed: () => playerController.playNext(),
                    ),

                    // Repeat mode button
                    Obx(() {
                      final isRepeat = playerController.isRepeatMode.value;
                      return IconButton(
                        icon: Icon(
                          Icons.repeat_rounded,
                          color: isRepeat ? AppColors.secondary : AppColors.textMuted,
                          size: 24,
                        ),
                        onPressed: () => playerController.toggleRepeat(),
                      );
                    }),
                  ],
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        );
      }),
    );
  }
}
