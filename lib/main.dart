import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:e_tarabay/l10n/app_localizations.dart';
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
  int _retryCount = 0;
  static const int _maxRetries = 3;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _player = AudioPlayer();

    // Listen for unexpected completion and restart if needed
    _player.onPlayerComplete.listen((_) {
      if (_isMusicEnabled && _currentAssetPath != null && _isPlaying) {
        _restartMusic();
      }
    });

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

    _retryCount = 0;
    await _playWithRetry(assetPath);
  }

  Future<void> _playWithRetry(String assetPath) async {
    try {
      _currentAssetPath = assetPath;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.3);
      await _player.play(AssetSource(assetPath));
      _isPlaying = true;
      _wasPlayingBeforePause = false;
      _retryCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing music: $e');
      if (_retryCount < _maxRetries) {
        _retryCount++;
        debugPrint('Retrying music playback ($_retryCount/$_maxRetries)...');
        await Future.delayed(const Duration(seconds: 1));
        await _playWithRetry(assetPath);
      } else {
        debugPrint('Music playback failed after $_maxRetries retries.');
        _isPlaying = false;
      }
    }
  }

  Future<void> _restartMusic() async {
    if (_currentAssetPath == null || !_isMusicEnabled) return;
    debugPrint('Music stopped unexpectedly, restarting...');
    _isPlaying = false;
    await _playWithRetry(_currentAssetPath!);
  }

  Future<void> pauseMusic() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
    _isPlaying = false;
    _wasPlayingBeforePause = false;
    notifyListeners();
  }

  Future<void> resumeMusic() async {
    if (!_isMusicEnabled || !_isInitialized) return;
    try {
      await _player.resume();
      _isPlaying = true;
      _wasPlayingBeforePause = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resuming music: $e');
      if (_currentAssetPath != null) {
        await _playWithRetry(_currentAssetPath!);
      }
    }
  }

  Future<void> stopMusic() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
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

// Fallback delegate that loads English MaterialLocalizations for unsupported locales
class _MaterialFallback extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialFallback();

  static const delegate = _MaterialFallback();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    final target = GlobalMaterialLocalizations.delegate.isSupported(locale)
        ? locale
        : const Locale('en');
    return GlobalMaterialLocalizations.delegate.load(target);
  }

  @override
  bool shouldReload(_MaterialFallback old) => false;
}

class ETarabayApp extends StatelessWidget {
  const ETarabayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Tarabay',
      debugShowCheckedModeBanner: false,
      locale:
          Locale(Provider.of<LanguageProvider>(context).currentLanguageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        _MaterialFallback.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fil'),
        Locale('ilo'),
      ],
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
