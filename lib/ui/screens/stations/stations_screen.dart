import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/radio_station.dart';
import '../../../data/models/radio_category.dart';
import '../../../data/repository/radio_repository.dart';
import '../../../playback/playback_manager.dart';
import '../../components/station_list_item.dart';
import '../../theme/app_theme.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  List<RadioStation> _stations = [];
  List<RadioStation> _filtered = [];
  RadioCategory? _selectedCategory;
  String _query = '';
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<RadioRepository>();
    final stations = await repo.getAllStations();
    if (!mounted) return;
    setState(() {
      _stations = stations;
      _loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    var result = _stations;
    if (_selectedCategory != null) {
      result = result.where((s) => s.category == _selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      result = result.where((s) =>
          s.name.toLowerCase().contains(q) ||
          (s.city?.toLowerCase().contains(q) ?? false) ||
          s.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }
    setState(() => _filtered = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Станции'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    _query = v;
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: 'Търсене на станция...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _query = '';
                              _applyFilters();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              // Category chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryChip(
                      label: 'Всички',
                      selected: _selectedCategory == null,
                      onTap: () => setState(() {
                        _selectedCategory = null;
                        _applyFilters();
                      }),
                    ),
                    ...RadioCategory.values
                        .where((c) => c != RadioCategory.other)
                        .map((c) => _CategoryChip(
                              label: '${c.emoji} ${c.displayName}',
                              selected: _selectedCategory == c,
                              onTap: () => setState(() {
                                _selectedCategory = _selectedCategory == c ? null : c;
                                _applyFilters();
                              }),
                            )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandTeal))
          : _filtered.isEmpty
              ? Center(
                  child: Text(
                    'Няма намерени станции',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: Consumer<PlaybackManager>(
                    builder: (context, pm, _) {
                      final repo = context.read<RadioRepository>();
                      return ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final station = _filtered[index];
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.black : AppColors.textPrimary)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.brandTeal,
        backgroundColor: AppColors.surfaceCard,
        checkmarkColor: Colors.black,
        side: BorderSide.none,
      ),
    );
  }
}
