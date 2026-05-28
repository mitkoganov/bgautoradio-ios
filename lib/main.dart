import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/local/radio_database.dart';
import 'data/preferences/app_preferences.dart';
import 'data/remote/station_api_service.dart';
import 'data/repository/radio_repository.dart';
import 'playback/playback_manager.dart';
import 'playback/radio_audio_handler.dart';
import 'carplay/carplay_manager.dart';
import 'ui/app_shell.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await AppPreferences.create();
  final db = RadioDatabase.instance;
  final api = StationApiService();
  final repository = RadioRepository(db: db, api: api, prefs: prefs);

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
    avAudioSessionRouteSharingPolicy:
        AVAudioSessionRouteSharingPolicy.defaultPolicy,
    avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.music,
      usage: AndroidAudioUsage.media,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    androidWillPauseWhenDucked: false,
  ));

  final audioHandler = await AudioService.init<RadioAudioHandler>(
    builder: () => RadioAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.bgautoradio.channel.audio',
      androidNotificationChannelName: 'BG Auto Radio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
    ),
  );

  final playbackManager = PlaybackManager(
    handler: audioHandler,
    repository: repository,
  );

  final carplayManager = CarPlayManager(
    repository: repository,
    playback: playbackManager,
  );
  carplayManager.initialize();

  await repository.initializeCatalog();

  if (prefs.autoPlayOnStart && prefs.lastStationId != null) {
    final station = await repository.getById(prefs.lastStationId!);
    if (station != null) {
      await playbackManager.play(station);
    }
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AppPreferences>.value(value: prefs),
        Provider<RadioRepository>.value(value: repository),
        ChangeNotifierProvider<PlaybackManager>.value(value: playbackManager),
        Provider<CarPlayManager>.value(value: carplayManager),
      ],
      child: BulgarianAutoRadioApp(prefs: prefs),
    ),
  );
}

class BulgarianAutoRadioApp extends StatelessWidget {
  final AppPreferences prefs;

  const BulgarianAutoRadioApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final themeMode = switch (prefs.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      title: 'BG Auto Radio',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}
