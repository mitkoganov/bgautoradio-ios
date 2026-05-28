import 'radio_station.dart';

class StationCatalog {
  final int version;
  final String? updatedAt;
  final List<RadioStation> stations;

  StationCatalog({required this.version, this.updatedAt, required this.stations});

  factory StationCatalog.fromJson(Map<String, dynamic> json, {Set<String> favoriteIds = const {}}) {
    final stationList = (json['stations'] as List<dynamic>)
        .map((s) => RadioStation.fromJson(s as Map<String, dynamic>,
            isFavorite: favoriteIds.contains(s['id'])))
        .toList();
    return StationCatalog(
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] as String?,
      stations: stationList,
    );
  }
}
