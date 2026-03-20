import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../main.dart'; // Import AudioManager
import '../utils/constants.dart';
import '../utils/translations.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          Translations.getSettings(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.textLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    Translations.getLanguage(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Divider(height: 1),

                // English Option
                _buildLanguageOption(
                  context,
                  language: 'English',
                  code: 'en',
                  isSelected: languageProvider.currentLanguageCode == 'en',
                  flag: '🇺🇸',
                ),

                // Ilocano Option
                _buildLanguageOption(
                  context,
                  language: 'Ilocano',
                  code: 'il',
                  isSelected: languageProvider.currentLanguageCode == 'il',
                  flag: '🇵🇭',
                ),

                // Filipino Option
                _buildLanguageOption(
                  context,
                  language: 'Filipino',
                  code: 'tl',
                  isSelected: languageProvider.currentLanguageCode == 'tl',
                  flag: '🇵🇭',
                ),
              ],
            ),
          ),

          // Sound & Music Settings
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.volume_up,
                  title: Translations.getSound(context),
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() => _soundEnabled = value);
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setBool('sound_enabled', value);
                    });
                  },
                ),
                const Divider(height: 1, indent: 60),
                _buildSwitchTile(
                  icon: Icons.music_note,
                  title: Translations.getMusic(context),
                  value: _musicEnabled,
                  onChanged: _toggleMusic,
                ),
              ],
            ),
          ),

          // Notifications
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildSwitchTile(
              icon: Icons.notifications,
              title: Translations.getNotifications(context),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setBool('notifications_enabled', value);
                });
              },
            ),
          ),

          // App Info with Music Status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_stories,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                const Text(
                  'E Tarabay',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.2',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (audioManager.isPlaying) ...[
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note,
                          size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Background music playing',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String language,
    required String code,
    required bool isSelected,
    required String flag,
  }) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return InkWell(
      onTap: () async {
        await languageProvider.setLanguage(code);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  flag.isNotEmpty ? flag : '🏳️',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language.isNotEmpty ? language : 'Unknown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textDark,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title.isNotEmpty ? title : '',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}
