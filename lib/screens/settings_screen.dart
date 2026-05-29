import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _musicEnabled = prefs.getBool('music_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleMusic(bool value) async {
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    setState(() {
      _musicEnabled = value;
    });

    await audioManager.setMusicEnabled(value);

    if (value) {
      await audioManager.startBackgroundMusic('audio/tunog.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final audioManager = Provider.of<AudioManager>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          loc.settingsTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _sectionHeader(loc.language),
          Card.filled(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _LanguageTile(
                  flag: '🇺🇸',
                  label: 'English',
                  code: 'en',
                  isSelected: languageProvider.currentLanguageCode == 'en',
                  onTap: () => _setLanguage('en'),
                ),
                const Divider(height: 0, indent: 72),
                _LanguageTile(
                  flag: '🇵🇭',
                  label: 'Filipino',
                  code: 'fil',
                  isSelected: languageProvider.currentLanguageCode == 'fil',
                  onTap: () => _setLanguage('fil'),
                ),
                const Divider(height: 0, indent: 72),
                _LanguageTile(
                  flag: '🇵🇭',
                  label: 'Ilokano',
                  code: 'ilo',
                  isSelected: languageProvider.currentLanguageCode == 'ilo',
                  onTap: () => _setLanguage('ilo'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Audio ────────────────────────────────────────────────────────────
          _sectionHeader('Audio'),
          Card.filled(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: _IconBadge(icon: Icons.volume_up_rounded),
                  title: Text(loc.sound),
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() => _soundEnabled = value);
                    SharedPreferences.getInstance().then(
                      (prefs) => prefs.setBool('sound_enabled', value),
                    );
                  },
                ),
                const Divider(height: 0, indent: 72),
                SwitchListTile(
                  secondary: _IconBadge(icon: Icons.music_note_rounded),
                  title: Text(loc.music),
                  value: _musicEnabled,
                  onChanged: _toggleMusic,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Notifications ──────────────────────────────────────────────────
          _sectionHeader(loc.notifications),
          Card.filled(
            clipBehavior: Clip.antiAlias,
            child: SwitchListTile(
              secondary: _IconBadge(icon: Icons.notifications_rounded),
              title: Text(loc.notifications),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                SharedPreferences.getInstance().then(
                  (prefs) => prefs.setBool('notifications_enabled', value),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ── App Info ─────────────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'E-Tarabay',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${loc.version} 1.0.4',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (audioManager.isPlaying) ...[
                  const SizedBox(height: 10),
                  _MusicPill(text: loc.backgroundMusicPlaying),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _setLanguage(String code) async {
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    await provider.setLanguage(code);
    setState(() {});
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LANGUAGE TILE
// ─────────────────────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final String flag;
  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(flag, style: const TextStyle(fontSize: 20))),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isSelected
            ? Icon(Icons.check_circle_rounded,
                key: const ValueKey('selected'), color: colorScheme.primary)
            : const SizedBox(key: ValueKey('empty'), width: 24),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ICON BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: colorScheme.primary, size: 20),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MUSIC PILL
// ─────────────────────────────────────────────────────────────────────────────
class _MusicPill extends StatelessWidget {
  final String text;

  const _MusicPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note_rounded, size: 14, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
