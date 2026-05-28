import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import '../data/models/radio_station.dart';
import '../data/models/playback_state.dart' as app;
import '../data/repository/radio_repository.dart';
import 'radio_audio_handler.dart';

class PlaybackManager extends ChangeNotifier {
  final RadioAudioHandler _handler;
  final RadioRepository _repository;

  app.PlaybackState _state = const app.PlaybackState();
  app.PlaybackState get state => _state;

  StreamSubscription? _playbackSub;
  StreamSubscription? _mediaSub;

  PlaybackManager({
    required this._handler,
    required this._repository,
  }) {
    _playbackSub = _handler.playbackState.listen(_onPlaybackState);
    _mediaSub = _handler.mediaItem.listen(_onMediaItem);
  }

  Future<void> play(RadioStation station) async {
    _repository.trackRecentlyPlayed(station.id);
    _updateState(_state.copyWith(
      station: station,
      status: app.PlaybackStatus.loading,
      streamTitle: null,
    ));
    await _handler.playStation(station);
  }

  Future<void> playPause() async {
    if (_state.isPlaying) {
      await _handler.pause();
    } else if (_state.station != null) {
      await _handler.play();
    }
  }

  Future<void> stop() async {
    await _handler.stop();
    _updateState(const app.PlaybackState());
  }

  Future<void> playNext() async {
    final list = await _repository.getNavList();
    if (list.isEmpty) return;
    final current = _state.station;
    if (current == null) {
      await play(list.first);
      return;
    }
    final idx = list.indexWhere((s) => s.id == current.id);
    final next = list[(idx + 1) % list.length];
    await play(next);
  }

  Future<void> playPrevious() async {
    final list = await _repository.getNavList();
    if (list.isEmpty) return;
    final current = _state.station;
    if (current == null) {
      await play(list.last);
      return;
    }
    final idx = list.indexWhere((s) => s.id == current.id);
    final prev = list[(idx - 1 + list.length) % list.length];
    await play(prev);
  }

  void _onPlaybackState(PlaybackState ps) {
    final status = _mapStatus(ps);
    _updateState(_state.copyWith(status: status));
  }

  void _onMediaItem(MediaItem? item) {
    if (item == null) return;
    final title = item.title;
    final stationName = _state.station?.name;
    if (title != stationName && title.isNotEmpty) {
      _updateState(_state.copyWith(streamTitle: title));
    }
  }

  app.PlaybackStatus _mapStatus(PlaybackState ps) {
    if (ps.processingState == AudioProcessingState.error) {
      return app.PlaybackStatus.error;
    }
    if (ps.processingState == AudioProcessingState.loading ||
        ps.processingState == AudioProcessingState.buffering) {
      return app.PlaybackStatus.loading;
    }
    if (ps.playing) return app.PlaybackStatus.playing;
    if (ps.processingState == AudioProcessingState.idle) {
      return app.PlaybackStatus.idle;
    }
    return app.PlaybackStatus.paused;
  }

  void _updateState(app.PlaybackState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _playbackSub?.cancel();
    _mediaSub?.cancel();
    super.dispose();
  }
}
