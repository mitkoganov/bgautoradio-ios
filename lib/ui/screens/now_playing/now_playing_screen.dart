import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../playback/playback_manager.dart';
import '../../../data/models/playback_state.dart';
import '../../components/station_logo.dart';
import '../../theme/app_theme.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaybackManager>(
      builder: (context, pm, _) {
        final state = pm.state;
        return Scaffold(
          backgroundColor: AppColors.brandDark,
          appBar: AppBar(
            title: const Text('В ефир'),
            backgroundColor: AppColors.brandDark,
          ),
          body: state.station == null
              ? const _EmptyNowPlaying()
              : _NowPlayingContent(state: state, pm: pm),
        );
      },
    );
  }
}

class _EmptyNowPlaying extends StatelessWidget {
  const _EmptyNowPlaying();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radio, size: 80, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'Изберете станция',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Отидете в "Станции" или "Любими"',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingContent extends StatelessWidget {
  final PlaybackState state;
  final PlaybackManager pm;

  const _NowPlayingContent({required this.state, required this.pm});

  @override
  Widget build(BuildContext context) {
    final station = state.station!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Station logo — large
          StationLogo(logoUrl: station.logoUrl, size: 200, borderRadius: 24),
          const SizedBox(height: 32),

          // Station name
          Text(
            station.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Stream title / ICY metadata
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              state.streamTitle ?? (station.city ?? station.category.displayName),
              key: ValueKey(state.streamTitle),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 48),

          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 40),
                color: AppColors.textSecondary,
                onPressed: pm.playPrevious,
                tooltip: 'Предишна (любими)',
              ),
              const SizedBox(width: 24),
              _PlayPauseButton(state: state, pm: pm),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 40),
                color: AppColors.textSecondary,
                onPressed: pm.playNext,
                tooltip: 'Следваща (любими)',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Station info chips
          Wrap(
            spacing: 8,
            children: [
              if (station.city != null)
                _InfoChip(label: station.city!, color: AppColors.textSecondary),
              _InfoChip(label: station.category.displayName, color: AppColors.brandTeal),
              if (station.bitrate != null)
                _InfoChip(label: '${station.bitrate}kbps', color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final PlaybackState state;
  final PlaybackManager pm;

  const _PlayPauseButton({required this.state, required this.pm});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: AppColors.brandTeal,
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
        ),
      );
    }

    return GestureDetector(
      onTap: pm.playPause,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: AppColors.brandTeal,
          shape: BoxShape.circle,
        ),
        child: Icon(
          state.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.black,
          size: 40,
        ),
      ),
    );
  }
}
