import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/language_provider.dart';
import 'providers/user_provider.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';

// ========== AUDIO MANAGER (FOR BACKGROUND MUSIC) ==========
class AudioManager extends ChangeNotifier with WidgetsBindingObserver {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  static AudioManager get instance => _instance;

  late AudioPlayer _player;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMusicEnabled = true;
  String? _currentAssetPath;
  bool _wasPlayingBeforePause = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _player = AudioPlayer();

    // Load saved preference
    final prefs = await SharedPreferences.getInstance();
    _isMusicEnabled = prefs.getBool('music_enabled') ?? true;

    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isPlaying) {
        _wasPlayingBeforePause = true;
        _player.pause();
        // We don't set _isPlaying = false because we want to remember it was playing
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_wasPlayingBeforePause && _isMusicEnabled) {
        _player.resume();
        _wasPlayingBeforePause = false;
      }
    }
  }

  Future<void> startBackgroundMusic(String assetPath) async {
    if (!_isInitialized) await initialize();
    if (!_isMusicEnabled) return;

    // Smart Check: Don't restart if already playing the same song
    if (_isPlaying && _currentAssetPath == assetPath) return;

    try {
      _currentAssetPath = assetPath;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.3);
      await _player.play(AssetSource(assetPath));
      _isPlaying = true;
      _wasPlayingBeforePause = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }

  Future<void> pauseMusic() async {
    await _player.pause();
    _isPlaying = false;
    _wasPlayingBeforePause = false;
    notifyListeners();
  }

  Future<void> resumeMusic() async {
    if (!_isMusicEnabled) return;
    await _player.resume();
    _isPlaying = true;
    _wasPlayingBeforePause = false;
    notifyListeners();
  }

  Future<void> stopMusic() async {
    await _player.stop();
    _isPlaying = false;
    _wasPlayingBeforePause = false;
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    if (_isPlaying) {
      await pauseMusic();
    } else {
      await resumeMusic();
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', enabled);

    if (!enabled && _isPlaying) {
      await stopMusic();
    }

    notifyListeners();
  }

  bool get isPlaying => _isPlaying;
  bool get isMusicEnabled => _isMusicEnabled;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('userProfile');
  await Hive.openBox('userProgress');
  await Hive.openBox('settings');

  // Initialize SharedPreferences early
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('language') ?? 'en';

  // Initialize UserProvider and wait for its internal async setup
  final userProvider = UserProvider();

  // Initialize AudioManager
  final audioManager = AudioManager.instance;
  await audioManager.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => LanguageProvider(savedLanguage)),
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider(create: (context) => audioManager),
      ],
      child: const ETarabayApp(),
    ),
  );
}

class ETarabayApp extends StatelessWidget {
  const ETarabayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Tarabay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
