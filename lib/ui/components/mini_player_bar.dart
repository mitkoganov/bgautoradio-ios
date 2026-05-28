import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../playback/playback_manager.dart';
import '../theme/app_theme.dart';
import 'station_logo.dart';

class MiniPlayerBar extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayerBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaybackManager>(
      builder: (context, pm, _) {
        final state = pm.state;
        if (state.station == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 64,
            color: AppColors.surfaceCard,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                StationLogo(logoUrl: state.station!.logoUrl, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.station!.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (state.streamTitle != null)
                        Text(
                          state.streamTitle!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (state.isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.brandTeal,
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.brandTeal,
                      size: 28,
                    ),
                    onPressed: pm.playPause,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
