import 'radio_station.dart';

enum PlaybackStatus { idle, loading, playing, paused, error, reconnecting }

class PlaybackState {
  final RadioStation? station;
  final PlaybackStatus status;
  final String? streamTitle;
  final String? errorMessage;
  final double bufferedFraction;

  const PlaybackState({
    this.station,
    this.status = PlaybackStatus.idle,
    this.streamTitle,
    this.errorMessage,
    this.bufferedFraction = 0.0,
  });

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isLoading => status == PlaybackStatus.loading || status == PlaybackStatus.reconnecting;
  bool get hasError => status == PlaybackStatus.error;

  PlaybackState copyWith({
    RadioStation? station,
    PlaybackStatus? status,
    String? streamTitle,
    String? errorMessage,
    double? bufferedFraction,
  }) {
    return PlaybackState(
      station: station ?? this.station,
      status: status ?? this.status,
      streamTitle: streamTitle ?? this.streamTitle,
      errorMessage: errorMessage ?? this.errorMessage,
      bufferedFraction: bufferedFraction ?? this.bufferedFraction,
    );
  }
}
