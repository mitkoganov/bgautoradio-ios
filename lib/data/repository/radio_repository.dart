import 'dart:convert';
import 'package:flutter/services.dart';
import '../local/radio_database.dart';
import '../models/radio_station.dart';
import '../models/radio_category.dart';
import '../models/station_catalog.dart';
import '../preferences/app_preferences.dart';
import '../remote/station_api_service.dart';

class RadioRepository {
  final RadioDatabase _db;
  final StationApiService _api;
  final AppPreferences _prefs;

  RadioRepository({
    required this._db,
    required this._api,
    required this._prefs,
  });

  Future<void> initializeCatalog() async {
    await _seedFromAssetIfNeeded();
    _refreshFromRemote(); // fire-and-forget
  }

  Future<void> _seedFromAssetIfNeeded() async {
    final count = await _db.count();
    if (count > 0) return;

    try {
      final raw = await rootBundle.loadString('assets/data/bulgarian_radio_stations.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final catalog = StationCatalog.fromJson(json);
      await _db.upsertAll(catalog.stations);
      _prefs.catalogVersion = catalog.version;
    } catch (e) {
      // asset missing — proceed without seeding
    }
  }

  Future<void> _refreshFromRemote() async {
    try {
      final favoriteIds = await _db.getFavoriteIds();
      final catalog = await _api.fetchCatalog(favoriteIds: favoriteIds);

      if (catalog.version <= _prefs.catalogVersion) return;

      final mergedStations = catalog.stations.map((s) {
        return s.copyWith(isFavorite: favoriteIds.contains(s.id));
      }).toList();

      await _db.upsertAll(mergedStations);
      await _db.pruneNonFavorites({for (final s in mergedStations) s.id});

      _prefs.catalogVersion = catalog.version;
      if (catalog.updatedAt != null) _prefs.catalogUpdatedAt = catalog.updatedAt;
    } catch (_) {
      // remote unavailable — silently use cached data
    }
  }

  Future<List<RadioStation>> getAllStations() => _db.getAll();

  Future<List<RadioStation>> getFavorites() => _db.getFavorites();

  Future<List<RadioStation>> getByCategory(RadioCategory category) =>
      _db.getByCategory(category);

  Future<List<RadioStation>> search(String query) {
    if (query.trim().isEmpty) return getAllStations();
    return _db.search(query.trim());
  }

  Future<RadioStation?> getById(String id) => _db.getById(id);

  Future<List<RadioStation>> getRecentlyPlayed() async {
    final ids = _prefs.recentlyPlayedIds;
    final stations = <RadioStation>[];
    for (final id in ids) {
      final s = await _db.getById(id);
      if (s != null) stations.add(s);
    }
    return stations;
  }

  Future<void> toggleFavorite(RadioStation station) async {
    await _db.setFavorite(station.id, !station.isFavorite);
  }

  Future<void> setFavorite(String id, bool isFavorite) =>
      _db.setFavorite(id, isFavorite);

  void trackRecentlyPlayed(String stationId) {
    _prefs.addRecentlyPlayed(stationId);
  }

  Future<List<RadioStation>> getNavList() async {
    final favs = await getFavorites();
    if (favs.isNotEmpty) return favs;
    return getAllStations();
  }
}
