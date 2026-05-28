import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repository/radio_repository.dart';
import '../../../data/models/radio_station.dart';
import '../../../playback/playback_manager.dart';
import '../../components/station_list_item.dart';
import '../../theme/app_theme.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<RadioStation> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<RadioRepository>();
    final favs = await repo.getFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = favs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Любими')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandTeal))
          : _favorites.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('Нямате любими станции',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Натиснете ❤ до дадена станция',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: Consumer<PlaybackManager>(
                    builder: (context, pm, _) {
                      final repo = context.read<RadioRepository>();
                      return ListView.builder(
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          final station = _favorites[index];
                          return StationListItem(
                            station: station,
                            playbackState: pm.state,
                            onTap: () => pm.play(station),
                            onFavoriteToggle: () async {
                              await repo.toggleFavorite(station);
                              await _load();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
