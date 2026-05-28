import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const _lastStationId = 'lastStationId';
  static const _autoPlayOnStart = 'autoPlayOnStart';
  static const _themeMode = 'themeMode';
  static const _catalogVersion = 'catalogVersion';
  static const _catalogUpdatedAt = 'catalogUpdatedAt';
  static const _startScreen = 'startScreen';
  static const _recentlyPlayed = 'recentlyPlayed';

  final SharedPreferences _prefs;

  AppPreferences._(this._prefs);

  static Future<AppPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences._(prefs);
  }

  String? get lastStationId => _prefs.getString(_lastStationId);
  set lastStationId(String? v) => v != null ? _prefs.setString(_lastStationId, v) : _prefs.remove(_lastStationId);

  bool get autoPlayOnStart => _prefs.getBool(_autoPlayOnStart) ?? true;
  set autoPlayOnStart(bool v) => _prefs.setBool(_autoPlayOnStart, v);

  String get themeMode => _prefs.getString(_themeMode) ?? 'auto';
  set themeMode(String v) => _prefs.setString(_themeMode, v);

  int get catalogVersion => _prefs.getInt(_catalogVersion) ?? 0;
  set catalogVersion(int v) => _prefs.setInt(_catalogVersion, v);

  String? get catalogUpdatedAt => _prefs.getString(_catalogUpdatedAt);
  set catalogUpdatedAt(String? v) => v != null ? _prefs.setString(_catalogUpdatedAt, v) : _prefs.remove(_catalogUpdatedAt);

  String get startScreen => _prefs.getString(_startScreen) ?? 'now_playing';
  set startScreen(String v) => _prefs.setString(_startScreen, v);

  List<String> get recentlyPlayedIds => _prefs.getStringList(_recentlyPlayed) ?? [];

  void addRecentlyPlayed(String stationId) {
    final list = recentlyPlayedIds.where((id) => id != stationId).toList();
    list.insert(0, stationId);
    if (list.length > 20) list.removeLast();
    _prefs.setStringList(_recentlyPlayed, list);
  }
}
