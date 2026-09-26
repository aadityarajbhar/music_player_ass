import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/track_model.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final bool isCurrentlyPlaying;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const TrackTile({
    super.key,
    required this.track,
    required this.isCurrentlyPlaying,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color:
            isCurrentlyPlaying
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isCurrentlyPlaying
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child:
              track.image.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: track.image,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          width: 54,
                          height: 54,
                          color: AppColors.surfaceLight,
                          child: const Icon(
                            Icons.music_note,
                            color: AppColors.textMuted,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          width: 54,
                          height: 54,
                          color: AppColors.surfaceLight,
                          child: const Icon(
                            Icons.music_note,
                            color: AppColors.primary,
                          ),
                        ),
                  )
                  : Container(
                    width: 54,
                    height: 54,
                    color: AppColors.surfaceLight,
                    child: const Icon(
                      Icons.music_note,
                      color: AppColors.primary,
                    ),
                  ),
        ),
        title: Text(
          track.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color:
                isCurrentlyPlaying
                    ? AppColors.primaryAccent
                    : AppColors.textPrimary,
            fontWeight: isCurrentlyPlaying ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${track.artistName} • ${track.albumName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 22,
                color: isFavorite ? Colors.redAccent : AppColors.textMuted,
              ),
              onPressed: onFavoriteToggle,
            ),
            Text(
              track.formattedDuration,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(width: 10),
            if (isCurrentlyPlaying)
              const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.secondary,
                size: 22,
              )
            else
              const Icon(
                Icons.play_circle_fill_rounded,
                color: AppColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
