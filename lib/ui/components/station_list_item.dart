import 'package:flutter/material.dart';
import '../../data/models/radio_station.dart';
import '../../data/models/playback_state.dart';
import '../theme/app_theme.dart';
import 'station_logo.dart';

class StationListItem extends StatelessWidget {
  final RadioStation station;
  final PlaybackState playbackState;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const StationListItem({
    super.key,
    required this.station,
    required this.playbackState,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  bool get _isCurrentStation => playbackState.station?.id == station.id;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: StationLogo(logoUrl: station.logoUrl, size: 48),
      title: Text(
        station.name,
        style: TextStyle(
          color: _isCurrentStation ? AppColors.brandTeal : AppColors.textPrimary,
          fontWeight: _isCurrentStation ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        [
          if (station.city != null) station.city!,
          station.category.displayName,
          if (station.bitrate != null) '${station.bitrate}kbps',
        ].join(' • '),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isCurrentStation && playbackState.isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandTeal),
            )
          else if (_isCurrentStation && playbackState.isPlaying)
            const Icon(Icons.equalizer, color: AppColors.playingGreen, size: 20),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              station.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: station.isFavorite ? AppColors.favoriteRed : AppColors.textSecondary,
              size: 22,
            ),
            onPressed: onFavoriteToggle,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
