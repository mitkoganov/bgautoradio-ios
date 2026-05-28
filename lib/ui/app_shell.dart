import 'package:flutter/material.dart';
import 'components/mini_player_bar.dart';
import 'screens/now_playing/now_playing_screen.dart';
import 'screens/stations/stations_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/recent/recent_screen.dart';
import 'screens/settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _screens = [
    NowPlayingScreen(),
    StationsScreen(),
    FavoritesScreen(),
    RecentScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _screens[_currentIndex]),
          MiniPlayerBar(
            onTap: () => setState(() => _currentIndex = 0),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            label: 'В ефир',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Станции',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Любими',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Скорошно',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
