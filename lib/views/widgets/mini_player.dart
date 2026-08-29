import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/player_controller.dart';
import '../../core/constants/app_colors.dart';
import '../player/now_playing_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();

    return Obx(() {
      final track = playerController.currentTrack.value;

      if (track == null) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onTap: () {
          Get.to(
            () => const NowPlayingScreen(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 300),
          );
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.miniPlayerBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top linear progress indicator
              Obx(() {
                final durationSecs = playerController.duration.value.inSeconds;
                final positionSecs = playerController.position.value.inSeconds;
                final progress = durationSecs > 0 ? (positionSecs / durationSecs).clamp(0.0, 1.0) : 0.0;

                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    minHeight: 2.5,
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Artwork
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: track.image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: track.image,
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 46,
                                height: 46,
                                color: AppColors.surfaceLight,
                                child: const Icon(Icons.music_note, color: AppColors.primary),
                              ),
                            )
                          : Container(
                              width: 46,
                              height: 46,
                              color: AppColors.surfaceLight,
                              child: const Icon(Icons.music_note, color: AppColors.primary),
                            ),
                    ),
                    const SizedBox(width: 12),

                    // Track title & artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            track.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Playback Controls
                    Obx(() {
                      if (playerController.isLoadingAudio.value) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }

                      return IconButton(
                        onPressed: () => playerController.togglePlayPause(),
                        icon: Icon(
                          playerController.isPlaying.value
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: AppColors.primaryAccent,
                          size: 38,
                        ),
                      );
                    }),
                    IconButton(
                      onPressed: () => playerController.playNext(),
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textPrimary,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
