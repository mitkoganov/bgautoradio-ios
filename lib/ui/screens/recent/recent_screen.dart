import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repository/radio_repository.dart';
import '../../../data/models/radio_station.dart';
import '../../../playback/playback_manager.dart';
import '../../components/station_list_item.dart';
import '../../theme/app_theme.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<RadioStation> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<RadioRepository>();
    final stations = await repo.getRecentlyPlayed();
    if (!mounted) return;
    setState(() {
      _recent = stations;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Скорошно')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandTeal))
          : _recent.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('Все още нямате история',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                )
              : Consumer<PlaybackManager>(
                  builder: (context, pm, _) {
                    final repo = context.read<RadioRepository>();
                    return ListView.builder(
                      itemCount: _recent.length,
                      itemBuilder: (context, i) {
                        final station = _recent[i];
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
    );
  }
}
