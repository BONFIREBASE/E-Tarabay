import 'package:e_tarabay/l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../main.dart';
import '../widgets/custom_header_app_bar.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import '../widgets/staggered_entrance.dart';
import '../utils/page_transitions.dart';
import 'lessons_screen.dart';
import 'awards_screen.dart';

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
      extendBody: true,
      appBar: CustomHeaderAppBar(
        title: loc.settingsTitle,
        baseColor: colorScheme.primary,
        showBackButton: false,
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        selectedIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          switch (index) {
            case 0:
              Navigator.pop(context);
              break;
            case 1:
              context.pushReplacementPremium(const LessonsScreen());
              break;
            case 2:
              context.pushReplacementPremium(const AwardsScreen());
              break;
          }
        },
        items: const [
          NavItemData(icon: LucideIcons.house, label: 'Home'),
          NavItemData(icon: LucideIcons.book_open, label: 'Lessons'),
          NavItemData(icon: LucideIcons.trophy, label: 'Awards'),
          NavItemData(icon: LucideIcons.settings, label: 'Settings'),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_settings.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          StaggeredEntrance(
            index: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(loc.language),
                Card.filled(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _LanguageTile(
                        label: 'English',
                        code: 'en',
                        isSelected:
                            languageProvider.currentLanguageCode == 'en',
                        onTap: () => _setLanguage('en'),
                      ),
                      const Divider(height: 0, indent: 72),
                      _LanguageTile(
                        label: 'Filipino',
                        code: 'fil',
                        isSelected:
                            languageProvider.currentLanguageCode == 'fil',
                        onTap: () => _setLanguage('fil'),
                      ),
                      const Divider(height: 0, indent: 72),
                      _LanguageTile(
                        label: 'Ilokano',
                        code: 'ilo',
                        isSelected:
                            languageProvider.currentLanguageCode == 'ilo',
                        onTap: () => _setLanguage('ilo'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StaggeredEntrance(
            index: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Audio'),
                Card.filled(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: _IconBadge(icon: LucideIcons.volume_2),
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
                        secondary: _IconBadge(icon: LucideIcons.music),
                        title: Text(loc.music),
                        value: _musicEnabled,
                        onChanged: _toggleMusic,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StaggeredEntrance(
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(loc.notifications),
                Card.filled(
                  clipBehavior: Clip.antiAlias,
                  child: SwitchListTile(
                    secondary: _IconBadge(icon: LucideIcons.bell),
                    title: Text(loc.notifications),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                      SharedPreferences.getInstance().then(
                        (prefs) =>
                            prefs.setBool('notifications_enabled', value),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          StaggeredEntrance(
            index: 3,
            child: Center(
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
                    '1.0.4++',
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
          ),
          const SizedBox(height: 24),
        ],
      ),
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
  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  ({String short, Color color}) get _meta {
    switch (code) {
      case 'fil':
        return (short: 'FIL', color: const Color(0xFFFF6584));
      case 'ilo':
        return (short: 'ILO', color: const Color(0xFFFFB347));
      default:
        return (short: 'EN', color: const Color(0xFF4A90D9));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final meta = _meta;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              meta.color,
              meta.color.withOpacity(0.75),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: meta.color.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            meta.short,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
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
            ? Icon(LucideIcons.circle_check,
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
          Icon(LucideIcons.music, size: 14, color: colorScheme.primary),
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
