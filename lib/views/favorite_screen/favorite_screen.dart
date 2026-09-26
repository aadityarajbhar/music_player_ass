import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/player_controller.dart';
import '../widgets/mini_player.dart';
import '../widgets/state_widgets.dart';
import '../widgets/track_tile.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();
    final playerController = Get.find<PlayerController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final count = favoriteController.favoriteTracks.length;
          return Text(
            count > 0 ? 'Favorites ($count)' : 'Favorites',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }),
      ),
      body: Stack(
        children: [
          Obx(() {
            final favoriteTracks = favoriteController.favoriteTracks;

            if (favoriteTracks.isEmpty) {
              return const EmptyStateWidget(
                title: 'No Favorite Songs',
                description:
                    'Tap the heart icon on any song to save it to your favorites list.',
                icon: Icons.favorite_border_rounded,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: favoriteTracks.length,
              itemBuilder: (context, index) {
                final track = favoriteTracks[index];

                return Obx(() {
                  final currentTrack = playerController.currentTrack.value;
                  final isCurrentlyPlaying = currentTrack?.id == track.id;
                  final isFav = favoriteController.isFavorite(track.id);

                  return TrackTile(
                    track: track,
                    isCurrentlyPlaying: isCurrentlyPlaying,
                    isFavorite: isFav,
                    onFavoriteToggle: () {
                      favoriteController.toggleFavorite(track);
                    },
                    onTap: () {
                      playerController.playTrack(
                        track,
                        newPlaylist: favoriteTracks,
                      );
                    },
                  );
                });
              },
            );
          }),

          // Floating mini player at bottom
          const Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }
}
