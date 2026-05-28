import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/preferences/app_preferences.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppPreferences _prefs;
  late bool _autoPlay;
  late String _theme;

  @override
  void initState() {
    super.initState();
    _prefs = context.read<AppPreferences>();
    _autoPlay = _prefs.autoPlayOnStart;
    _theme = _prefs.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          const _SectionHeader('Поведение'),
          SwitchListTile(
            title: const Text('Авто-пускане при старт',
                style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Пусни последната станция при отваряне',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            value: _autoPlay,
            activeThumbColor: AppColors.brandTeal,
            onChanged: (v) {
              setState(() => _autoPlay = v);
              _prefs.autoPlayOnStart = v;
            },
          ),
          const Divider(color: AppColors.surfaceElevated),
          const _SectionHeader('Тема'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'auto', label: Text('Авто')),
                ButtonSegment(value: 'dark', label: Text('Тъмна')),
                ButtonSegment(value: 'light', label: Text('Светла')),
              ],
              selected: {_theme},
              onSelectionChanged: (s) => _setTheme(s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? AppColors.brandTeal
                        : AppColors.surfaceCard),
                foregroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.black
                        : AppColors.textPrimary),
              ),
            ),
          ),
          const Divider(color: AppColors.surfaceElevated),
          const _SectionHeader('За приложението'),
          ListTile(
            title: const Text('Версия', style: TextStyle(color: AppColors.textPrimary)),
            trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ListTile(
            title: const Text('Каталог станции',
                style: TextStyle(color: AppColors.textPrimary)),
            trailing: Text(
              'v${_prefs.catalogVersion}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _setTheme(String value) {
    setState(() => _theme = value);
    _prefs.themeMode = value;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.brandTeal,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
