import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/language_provider.dart';
import 'providers/user_provider.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';

/// Global route observer so screens can auto-refresh when they become visible
/// again (e.g. returning to the Lessons page after playing a game).
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

// ========== MODULE BACKGROUND MUSIC MAP ==========
class ModuleMusic {
  static const matematika = 'audio/modules_bg/mathematics_module.mp3';
  static const pamilya = 'audio/modules_bg/about_bg.mp3';
  static const kulay = 'audio/modules_bg/color-fun_module.mp3';
  static const traceIt = 'audio/modules_bg/trace-it_bg.mp3';
  static const magbasa = 'audio/modules_bg/lets-read_module.mp3';
  static const tandaan = 'audio/modules_bg/remember-it_module.mp3';
  static const mainBg = 'audio/modules_bg/main_bg.mp3';
  static const aboutBg = 'audio/modules_bg/about_bg.mp3';
}

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
  // Remembers each track's last playback position so switching tracks and
  // returning resumes instead of restarting from the top.
  final Map<String, Duration> _positions = {};

  Future<void> initialize() async {
    if (_isInitialized) return;

    _player = AudioPlayer();

    // Listen for unexpected completion and restart if needed
    _player.onPlayerComplete.listen((_) {
      if (_isMusicEnabled && _currentAssetPath != null && _isPlaying) {
        _restartMusic();
      }
    });

    // Continuously remember the current track's position so we can resume it.
    _player.onPositionChanged.listen((pos) {
      final path = _currentAssetPath;
      if (path != null) _positions[path] = pos;
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

  // ── Module music helpers ───────────────────────────────────────────────
  // The main/home track. Modules switch to their own track on entry and
  // this resumes when returning home. Because startBackgroundMusic ignores
  // a request for the track that's already playing, navigating within the
  // same module (or re-entering it) never restarts the music.
  static const String homeMusicAsset = 'audio/modules_bg/main_bg.mp3';

  Future<void> playModuleMusic(String assetPath) =>
      startBackgroundMusic(assetPath);

  Future<void> resumeHomeMusic() => startBackgroundMusic(homeMusicAsset);

  Future<void> _playWithRetry(String assetPath) async {
    try {
      final resumeAt = _positions[assetPath] ?? Duration.zero;
      _currentAssetPath = assetPath;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.3);
      await _player.play(AssetSource(assetPath), position: resumeAt);
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

    // ── Smart network caching (offline-first) ──
    // Cache all Firestore data locally so the app works fully offline:
    // reads are served from cache when there's no network, writes are
    // queued locally and automatically synced once the network returns.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Give every app instance a stable Firebase identity (anonymous).
    // This is additive — students are still identified by their Firestore
    // record — but it lets us secure Firestore behind authentication later.
    // Fails gracefully (e.g. offline first-run, or provider disabled).
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      debugPrint('Anonymous auth skipped: $e');
    }
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
    // Use the platform default font for all text (no custom font family).
    // Only the top header/app-bar text is emphasized in bold — handled where
    // headers are built (see CustomHeaderAppBar and screen headers).
    final baseText = ThemeData(useMaterial3: true).textTheme;
    final appTextTheme = baseText.apply(
      bodyColor: AppColors.textDark,
      displayColor: AppColors.textDark,
    );

    return MaterialApp(
      title: 'E-Tarabay',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
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
        scaffoldBackgroundColor: AppColors.background,
        textTheme: appTextTheme,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
          background: AppColors.background,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
