import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station_catalog.dart';

const _catalogUrl =
    'https://raw.githubusercontent.com/mitkoganov/bgautoradio-android/main/app/src/main/assets/bulgarian_radio_stations.json';

class StationApiService {
  final http.Client _client;

  StationApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<StationCatalog> fetchCatalog({Set<String> favoriteIds = const {}}) async {
    final response = await _client.get(
      Uri.parse(_catalogUrl),
      headers: {'Cache-Control': 'no-cache'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch catalog: ${response.statusCode}');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return StationCatalog.fromJson(json, favoriteIds: favoriteIds);
  }
}
