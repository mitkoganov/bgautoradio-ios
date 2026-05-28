import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../data/models/radio_station.dart';

class RadioAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  RadioStation? _currentStation;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  RadioAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.idle &&
          _currentStation != null &&
          playbackState.value.playing) {
        _scheduleReconnect();
      }
    });
    _player.icyMetadataStream.listen((meta) {
      if (meta?.info?.title != null) {
        _updateMetadataTitle(meta!.info!.title!);
      }
    });
  }

  Future<void> playStation(RadioStation station) async {
    _cancelReconnect();
    _reconnectAttempts = 0;
    _currentStation = station;

    mediaItem.add(MediaItem(
      id: station.streamUrl,
      title: station.name,
      artist: station.city ?? station.country,
      album: station.category.displayName,
      artUri: station.logoUrl != null ? Uri.tryParse(station.logoUrl!) : null,
      extras: {'stationId': station.id},
      isLive: true,
    ));

    try {
      await _player.stop();
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(station.streamUrl),
            headers: {'Icy-MetaData': '1'}),
      );
      await _player.play();
    } catch (e) {
      _broadcastError(e.toString());
      _scheduleReconnect();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    _cancelReconnect();
    _currentStation = null;
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    // Handled externally by PlaybackManager using favorites list
  }

  @override
  Future<void> skipToPrevious() async {
    // Handled externally by PlaybackManager using favorites list
  }

  void _scheduleReconnect() {
    if (_currentStation == null) return;
    _reconnectAttempts++;
    final delay = _reconnectAttempts <= 3
        ? const Duration(seconds: 3)
        : const Duration(seconds: 10);
    _reconnectTimer = Timer(delay, () => playStation(_currentStation!));
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _updateMetadataTitle(String title) {
    final current = mediaItem.value;
    if (current == null) return;
    mediaItem.add(current.copyWith(title: title));
  }

  void _broadcastState(PlaybackEvent event) {
    final isPlaying = _player.playing;
    final processing = _player.processingState;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        isPlaying ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.stop,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[processing]!,
      playing: isPlaying,
      bufferedPosition: _player.bufferedPosition,
    ));
  }

  void _broadcastError(String message) {
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.error,
      errorMessage: message,
    ));
  }

  RadioStation? get currentStation => _currentStation;
}
