import 'package:flutter/foundation.dart';
import 'package:flutter_carplay/flutter_carplay.dart';
import '../data/models/radio_station.dart';
import '../data/models/radio_category.dart';
import '../data/repository/radio_repository.dart';
import '../playback/playback_manager.dart';

class CarPlayManager {
  final RadioRepository _repository;
  final PlaybackManager _playback;
  late final FlutterCarplay _flutterCarplay;
  CPListTemplate? _stationsTemplate;
  CPListTemplate? _favoritesTemplate;

  CarPlayManager({
    required this._repository,
    required this._playback,
  });

  void initialize() {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    _flutterCarplay = FlutterCarplay();
    _flutterCarplay.addListenerOnConnectionChange(_onConnectionChange);
    _setInitialRoot();
  }

  void _onConnectionChange(ConnectionStatusTypes status) {
    if (status == ConnectionStatusTypes.connected) {
      _setInitialRoot();
    }
  }

  void _setInitialRoot() {
    FlutterCarplay.setRootTemplate(
      rootTemplate: CPTabBarTemplate(
        templates: [
          _buildNowPlayingTab(),
          _buildStationsTab(),
          _buildFavoritesTab(),
          _buildCategoriesTab(),
        ],
      ),
      animated: false,
    );
    // Async load stations into tabs
    _loadAllTabs();
  }

  CPListTemplate _buildNowPlayingTab() {
    final station = _playback.state.station;
    return CPListTemplate(
      title: 'В ефир',
      tabTitle: 'В ефир',
      systemIcon: 'play.circle',
      sections: [
        CPListSection(
          items: station != null
              ? [
                  CPListItem(
                    text: station.name,
                    detailText: _playback.state.streamTitle ?? station.city ?? '',
                    isPlaying: _playback.state.isPlaying,
                    onPress: (complete, self) => complete(),
                  )
                ]
              : [
                  CPListItem(
                    text: 'Няма активна станция',
                    detailText: 'Изберете от "Станции"',
                  )
                ],
        )
      ],
    );
  }

  CPListTemplate _buildStationsTab() {
    _stationsTemplate = CPListTemplate(
      title: 'Станции',
      tabTitle: 'Станции',
      systemIcon: 'list.bullet',
      sections: [
        CPListSection(items: [CPListItem(text: 'Зареждане...')])
      ],
    );
    return _stationsTemplate!;
  }

  CPListTemplate _buildFavoritesTab() {
    _favoritesTemplate = CPListTemplate(
      title: 'Любими',
      tabTitle: 'Любими',
      systemIcon: 'heart',
      sections: [
        CPListSection(items: [CPListItem(text: 'Зареждане...')])
      ],
    );
    return _favoritesTemplate!;
  }

  CPListTemplate _buildCategoriesTab() {
    final items = RadioCategory.values
        .where((c) => c != RadioCategory.other)
        .map((c) => CPListItem(
              text: '${c.emoji} ${c.displayName}',
              accessoryType: CPListItemAccessoryType.disclosureIndicator,
              onPress: (complete, self) async {
                complete();
                await _pushCategoryTemplate(c);
              },
            ))
        .toList();

    return CPListTemplate(
      title: 'Категории',
      tabTitle: 'Категории',
      systemIcon: 'tag',
      sections: [CPListSection(items: items)],
    );
  }

  Future<void> _loadAllTabs() async {
    final stations = await _repository.getAllStations();
    final favorites = await _repository.getFavorites();
    _updateStationsTab(stations);
    _updateFavoritesTab(favorites);
  }

  void _updateStationsTab(List<RadioStation> stations) {
    final t = _stationsTemplate;
    if (t == null) return;
    final sections = [CPListSection(items: _stationsToItems(stations))];
    _flutterCarplay.updateListTemplateSections(
      elementId: t.uniqueId,
      sections: sections,
    );
  }

  void _updateFavoritesTab(List<RadioStation> favorites) {
    final t = _favoritesTemplate;
    if (t == null) return;
    final items = favorites.isEmpty
        ? [CPListItem(text: 'Нямате любими', detailText: 'Добавете от приложението')]
        : _stationsToItems(favorites);
    _flutterCarplay.updateListTemplateSections(
      elementId: t.uniqueId,
      sections: [CPListSection(items: items)],
    );
  }

  Future<void> _pushCategoryTemplate(RadioCategory category) async {
    final stations = await _repository.getByCategory(category);
    final template = CPListTemplate(
      title: '${category.emoji} ${category.displayName}',
      sections: [CPListSection(items: _stationsToItems(stations))],
      emptyViewTitleVariants: ['Няма станции в тази категория'],
    );
    FlutterCarplay.push(template: template, animated: true);
  }

  List<CPListItem> _stationsToItems(List<RadioStation> stations) {
    return stations.map((s) {
      return CPListItem(
        text: s.name,
        detailText: s.city ?? s.category.displayName,
        isPlaying: _playback.state.station?.id == s.id && _playback.state.isPlaying,
        onPress: (complete, self) async {
          await _playback.play(s);
          self.setIsPlaying(true);
          complete();
          updateNowPlayingTab();
        },
      );
    }).toList();
  }

  void updateNowPlayingTab() {
    // Rebuild root to reflect currently playing station
    _setInitialRoot();
  }
}
