import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  Box? _pb;
  Box? _gb;
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  String? _currentStudentId;
  StreamSubscription<DocumentSnapshot>? _profileSubscription;
  bool _hasSyncedFromCloud = false;
  String? _currentRole; // 'student' or 'teacher'
  bool _isAccountDeleted = false; // Flag to track if account was deleted

  Box get _profileBox => _pb!;
  Box get _progressBox => _gb!;

  UserProfile? get userProfile => _userProfile;
  bool get hasUserProfile => _userProfile != null;
  bool get isInitialized => _isInitialized;
  String? get currentStudentId => _currentStudentId;
  String? get currentRole => _currentRole;
  bool get isAccountDeleted => _isAccountDeleted;

  /// Set the current student ID (from RTDB login result) for syncing.
  void setCurrentStudentId(String? id) {
    _currentStudentId = id;
    if (_currentStudentId != null) {
      _isAccountDeleted = false; // Reset when setting new user
      _prefs?.setString('session_student_id', id!);
      _hasSyncedFromCloud = false; // Reset for new user
      _startProfileListener();
    } else {
      _prefs?.remove('session_student_id');
      _hasSyncedFromCloud = false;
      _stopProfileListener();
    }
    notifyListeners();
  }

  void setCurrentRole(String? role) {
    _currentRole = role;
    if (role != null) {
      _prefs?.setString('session_role', role);
    } else {
      _prefs?.remove('session_role');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _currentStudentId = null;
    _currentRole = null;
    _userProfile = null;
    _hasSyncedFromCloud = false;
    _isAccountDeleted = false;
    _stopProfileListener();

    if (_prefs != null) {
      await _prefs!.remove('session_student_id');
      await _prefs!.remove('session_role');
    }

    await _profileBox.clear();
    // Note: We don't clear progressBox here because they might want to use it offline,
    // but the session is cleared.
    notifyListeners();
  }

  void _startProfileListener() {
    _stopProfileListener();
    if (_currentStudentId == null) return;

    _profileSubscription = FirebaseFirestore.instance
        .collection('students')
        .doc(_currentStudentId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('profile')) {
          final profileData = Map<String, dynamic>.from(data['profile'] as Map);
          if (profileData.isNotEmpty) {
            _userProfile = UserProfile.fromJson(profileData);
            _profileBox.put('currentUser', _userProfile!.toJson());
            notifyListeners();
          }
        }
      } else {
        // Document does not exist - student might have been deleted by teacher
        if (_currentStudentId != null) {
          debugPrint(
              'DEBUG: Account for $_currentStudentId does not exist on server.');
          _isAccountDeleted = true;
          notifyListeners();
        }
      }
    });
  }

  void _stopProfileListener() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
  }

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _ensureInitialized();
      await _initializeBoxes();
    } catch (e) {
      debugPrint('CRITICAL: UserProvider initialization failed: $e');
    }
  }

  /// Ensures that boxes are ready before usage in async methods.
  Future<void> _ensureInitialized() async {
    try {
      if (_pb == null) {
        if (Hive.isBoxOpen('userProfile')) {
          _pb = Hive.box('userProfile');
        } else {
          _pb = await Hive.openBox('userProfile');
        }
      }

      if (_gb == null) {
        if (Hive.isBoxOpen('userProgress')) {
          _gb = Hive.box('userProgress');
        } else {
          _gb = await Hive.openBox('userProgress');
        }
      }
    } catch (e) {
      debugPrint('Error ensuring boxes are initialized: $e');
    }
  }

  Future<void> _initializeBoxes() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load session
      _currentRole = _prefs!.getString('session_role');
      _currentStudentId = _prefs!.getString('session_student_id');

      if (_currentStudentId != null) {
        _startProfileListener();
        // Trigger background sync if they just opened the app
        syncFromFirebase();
      }

      _loadUserProfile();
      _initProgressBox();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing boxes: $e');
    }
  }

  void _initProgressBox() {
    // Matematika progress
    if (!_progressBox.containsKey('matematika_total')) {
      _progressBox.put('matematika_total', 0);
    }
    if (!_progressBox.containsKey('matematika_stars')) {
      _progressBox.put('matematika_stars', 0);
    }
    if (!_progressBox.containsKey('matematika_levels')) {
      _progressBox.put('matematika_levels',
          [false, false, false, false, false, false, false]);
    }
    if (!_progressBox.containsKey('matematika_games')) {
      _progressBox.put('matematika_games', {});
    }
    if (!_progressBox.containsKey('matematika_streak')) {
      _progressBox.put('matematika_streak', 0);
    }
    if (!_progressBox.containsKey('matematika_last_played')) {
      _progressBox.put(
          'matematika_last_played', DateTime.now().toIso8601String());
    }

    // Pamilya (Ang Aking Sarili) progress
    if (!_progressBox.containsKey('pamilya_total')) {
      _progressBox.put('pamilya_total', 0);
    }
    if (!_progressBox.containsKey('pamilya_stars')) {
      _progressBox.put('pamilya_stars', 0);
    }
    if (!_progressBox.containsKey('pamilya_levels')) {
      _progressBox.put('pamilya_levels', List.filled(9, false));
    }
    if (!_progressBox.containsKey('pamilya_games')) {
      _progressBox.put('pamilya_games', {});
    }
    if (!_progressBox.containsKey('pamilya_streak')) {
      _progressBox.put('pamilya_streak', 0);
    }
    if (!_progressBox.containsKey('pamilya_last_played')) {
      _progressBox.put('pamilya_last_played', DateTime.now().toIso8601String());
    }

    // Magbasa Tayo progress
    if (!_progressBox.containsKey('magbasa_total')) {
      _progressBox.put('magbasa_total', 0);
    }
    if (!_progressBox.containsKey('magbasa_tula')) {
      _progressBox.put('magbasa_tula', {});
    }
    if (!_progressBox.containsKey('magbasa_kwento')) {
      _progressBox.put('magbasa_kwento', {});
    }
    if (!_progressBox.containsKey('magbasa_kanta')) {
      _progressBox.put('magbasa_kanta', {});
    }

    // Kulay-Saya progress
    if (!_progressBox.containsKey('kulay_basic')) {
      _progressBox.put('kulay_basic', false);
    }
    if (!_progressBox.containsKey('kulay_mixing')) {
      _progressBox.put('kulay_mixing', false);
    }
    if (!_progressBox.containsKey('kulay_objects')) {
      _progressBox.put('kulay_objects', false);
    }
    if (!_progressBox.containsKey('kulay_coloring')) {
      _progressBox.put('kulay_coloring', false);
    }
    if (!_progressBox.containsKey('kulay_total')) {
      _progressBox.put('kulay_total', 0);
    }

    // Sundan Mo progress
    if (!_progressBox.containsKey('sundan_uppercase')) {
      _progressBox.put('sundan_uppercase', List.filled(26, false));
    }
    if (!_progressBox.containsKey('sundan_lowercase')) {
      _progressBox.put('sundan_lowercase', List.filled(26, false));
    }
    if (!_progressBox.containsKey('sundan_numbers')) {
      _progressBox.put('sundan_numbers', List.filled(10, false));
    }
    if (!_progressBox.containsKey('sundan_total')) {
      _progressBox.put('sundan_total', 0);
    }
  }

  void _loadUserProfile() {
    if (_pb == null) return;
    try {
      final data = _pb!.get('currentUser');
      if (data != null) {
        _userProfile = UserProfile.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> createUserProfile(
    String name,
    String gender, {
    DateTime? birthday,
    String? parentName,
    String? parentContact,
  }) async {
    await _ensureInitialized();
    _userProfile = UserProfile(
      name: name,
      gender: gender,
      birthday: birthday,
      parentName: parentName ?? '',
      parentContact: parentContact ?? '',
    );
    if (_pb != null) {
      await _pb!.put('currentUser', _userProfile!.toJson());
    }
    await _syncToFirebase();
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? name,
    String? gender,
    DateTime? birthday,
    String? parentName,
    String? parentContact,
  }) async {
    await _ensureInitialized();
    if (_userProfile == null) return;

    _userProfile = UserProfile(
      name: name ?? _userProfile!.name,
      gender: gender ?? _userProfile!.gender,
      birthday: birthday ?? _userProfile!.birthday,
      parentName: parentName ?? _userProfile!.parentName,
      parentContact: parentContact ?? _userProfile!.parentContact,
      stars: _userProfile!.stars,
      lessonsCompleted: _userProfile!.lessonsCompleted,
      achievements: Map<String, int>.from(_userProfile!.achievements),
    );

    await _profileBox.put('currentUser', _userProfile!.toJson());
    await _syncToFirebase();
    notifyListeners();
  }

  Future<void> syncFromFirebase() async {
    await _ensureInitialized();
    if (_currentStudentId == null) return;
    try {
      // Prioritize fast login: fetch from server with a short timeout, fallback to cache
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(_currentStudentId)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 4));

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data == null) {
          _hasSyncedFromCloud = true;
          return;
        }

        // Restore Profile
        if (data.containsKey('profile') && data['profile'] is Map) {
          final profileData = Map<String, dynamic>.from(data['profile'] as Map);
          if (profileData.isNotEmpty) {
            _userProfile = UserProfile.fromJson(profileData);
            await _profileBox.put('currentUser', _userProfile!.toJson());
          }
        }

        // Restore Raw Progress
        if (data.containsKey('rawProgress') && data['rawProgress'] is Map) {
          final rawProgress =
              Map<String, dynamic>.from(data['rawProgress'] as Map);
          final prefs = await SharedPreferences.getInstance();

          for (var entry in rawProgress.entries) {
            await _progressBox.put(entry.key, entry.value);

            final localVal = prefs.get(entry.key);
            if (localVal == true && entry.value == false) {
              // Local has progress that Firebase missed. Keep local!
            } else {
              if (entry.value is bool) {
                await prefs.setBool(entry.key, entry.value);
              } else if (entry.value is int) {
                await prefs.setInt(entry.key, entry.value);
              } else if (entry.value is String) {
                await prefs.setString(entry.key, entry.value);
              } else if (entry.value is double) {
                await prefs.setDouble(entry.key, entry.value);
              }
            }
          }
          _syncToFirebase();
        }

        // Restore Creations
        if (data.containsKey('creations') && data['creations'] is List) {
          await _progressBox.put('coloring_creations', data['creations']);
        }

        _hasSyncedFromCloud = true;
      } else {
        // Document does not exist, so they are a new student in terms of progress
        _hasSyncedFromCloud = true;
      }
    } catch (e) {
      debugPrint('Error syncing from Firebase: $e');
      // Do NOT set _hasSyncedFromCloud to true here, so we retry or block pushes
    }
    notifyListeners();
  }

  Future<void> clearLocalData() async {
    await _ensureInitialized();
    _userProfile = null;
    await _profileBox.clear();
    await _progressBox.clear();

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) =>
            k.startsWith('sundan_') ||
            k.startsWith('kulay_') ||
            k.startsWith('magbasa_') ||
            k.startsWith('mat_') ||
            k.startsWith('pamilya_'))
        .toList();
    for (String key in keys) {
      await prefs.remove(key);
    }

    _initProgressBox();
    notifyListeners();
  }

  // MATEMATIKA PROGRESS
  Future<void> updateMatematikaProgress(
      int level, int stars, int score, int streak) async {
    await _ensureInitialized();
    List<dynamic> completedLevels = _progressBox.get('matematika_levels') ??
        [false, false, false, false, false, false, false];

    // Only add stars if this level wasn't previously completed
    bool isNewCompletion = false;
    if (level < completedLevels.length) {
      if (completedLevels[level] == false) {
        isNewCompletion = true;
      }
      completedLevels[level] = true;
      await _progressBox.put('matematika_levels', completedLevels);
    }

    if (isNewCompletion) {
      int currentStars = _progressBox.get('matematika_stars') ?? 0;
      await _progressBox.put('matematika_stars', currentStars + stars);

      int currentScore = _progressBox.get('matematika_total') ?? 0;
      await _progressBox.put('matematika_total', currentScore + score);

      if (_prefs != null) {
        await _prefs!.setInt('matematika_total', (currentScore + score));
        await _prefs!.setInt('matematika_stars', (currentStars + stars));
      }

      // AWARD TO MAIN USER PROFILE
      await addStars(stars);
    }

    await _progressBox.put('matematika_streak', streak);
    await _progressBox.put(
        'matematika_last_played', DateTime.now().toIso8601String());

    if (_prefs != null) {
      await _prefs!.setInt('matematika_streak', streak);
    }

    await _syncToFirebase();
    notifyListeners();
  }

  Future<void> updateMatematikaGameProgress(
      int level, int gameIndex, bool completed) async {
    await _ensureInitialized();
    Map<String, dynamic> games =
        Map<String, dynamic>.from(_progressBox.get('matematika_games') ?? {});

    final gameKey = 'level${level}_game$gameIndex';
    bool isNewGameCompletion = games[gameKey] != true && completed == true;

    games[gameKey] = completed;
    await _progressBox.put('matematika_games', games);

    // If new game completion, we could award stars here if needed,
    // but usually Matematika awards per level in updateMatematikaProgress.
    // Ensure consistency:
    if (isNewGameCompletion) {
      // Logic to ensure level is marked as started/touched
    }

    // Update level completion in Hive (if all games in level are done)
    List<dynamic> completedLevels = List.from(
        _progressBox.get('matematika_levels') ??
            [false, false, false, false, false, false, false]);
    if (level < completedLevels.length) {
      completedLevels[level] = true;
      await _progressBox.put('matematika_levels', completedLevels);
    }

    // Update SharedPreferences
    if (_prefs != null) {
      await _prefs!.setBool('matematika_game_${level}_$gameIndex', completed);
      await _prefs!.setBool('mat_level_${level}_game_$gameIndex',
          completed); // Legacy key for consistency
    }

    await _syncToFirebase();
    notifyListeners();
  }

  Map<String, dynamic> getMatematikaProgress() {
    if (!_isInitialized) {
      return {
        'completedLevels': 0,
        'totalLevels': 7,
        'totalStars': 0,
        'totalScore': 0,
        'streak': 0,
        'gamesCompleted': 0,
        'totalGames': 31,
      };
    }
    int totalStars = _progressBox.get('matematika_stars') ?? 0;
    int totalScore = _progressBox.get('matematika_total') ?? 0;

    // Fallback to old Prefs keys if Hive is empty (for migration/resilience)
    if (totalStars == 0 && _prefs != null) {
      totalStars = _prefs!.getInt('mat_total_stars') ?? 0;
    }
    if (totalScore == 0 && _prefs != null) {
      totalScore = _prefs!.getInt('mat_total_score') ?? 0;
    }

    int streak = _progressBox.get('matematika_streak') ?? 0;
    if (streak == 0 && _prefs != null) {
      streak = _prefs!.getInt('mat_streak') ?? 0;
    }

    int completedCount = 0;
    int gamesCompleted = 0;

    if (_prefs != null) {
      final counts = [5, 5, 3, 5, 5, 3, 5];
      for (int lvl = 0; lvl < counts.length; lvl++) {
        bool levelComplete = true;
        for (int g = 0; g < counts[lvl]; g++) {
          if (_prefs!.getBool('mat_level_${lvl}_game_$g') == true) {
            gamesCompleted++;
          } else {
            levelComplete = false;
          }
        }
        if (levelComplete) completedCount++;
      }
    }

    return {
      'completedLevels': completedCount,
      'totalLevels': 7,
      'totalStars': totalStars,
      'totalScore': totalScore,
      'streak': streak,
      'gamesCompleted': gamesCompleted,
      'totalGames': 31,
    };
  }

  // PAMILYA (ANG AKING SARILI / PAMILYA) PROGRESS
  Future<void> updatePamilyaProgress(
      int categoryIndex, int level, int gameIndex, bool completed,
      {int earnedStars = 0}) async {
    await _ensureInitialized();
    if (!_isInitialized) return;

    final levelKey = 'pamilya_cat_${categoryIndex}_level_$level';
    final gameKey =
        'pamilya_cat_${categoryIndex}_level_${level}_game_$gameIndex';

    // Update Hive
    Map<String, dynamic> games =
        Map<String, dynamic>.from(_progressBox.get('pamilya_games') ?? {});

    // Check if this specific game was already completed
    bool isNewGameCompletion = (games[gameKey] != true) && completed == true;

    games[gameKey] = completed;
    await _progressBox.put('pamilya_games', games);

    // Update SharedPreferences for dashboard consistency
    if (_prefs != null) {
      await _prefs!.setBool(gameKey, completed);
      await _prefs!.setBool(levelKey, true);
    }

    if (isNewGameCompletion) {
      int currentStars = _progressBox.get('pamilya_stars') ?? 0;
      int currentScore = _progressBox.get('pamilya_total') ?? 0;

      await _progressBox.put('pamilya_stars', currentStars + earnedStars);
      await _progressBox.put('pamilya_total', currentScore + 10);

      if (_prefs != null) {
        await _prefs!.setInt('pamilya_stars', currentStars + earnedStars);
        await _prefs!.setInt('pamilya_total', currentScore + 10);
      }

      // AWARD TO MAIN USER PROFILE
      await addStars(earnedStars);
    }

    // Update streak regardless of new completion (just playing counts)
    int streak = _progressBox.get('pamilya_streak') ?? 0;
    await _progressBox.put('pamilya_streak', streak + 1);
    await _progressBox.put(
        'pamilya_last_played', DateTime.now().toIso8601String());

    if (_prefs != null) {
      await _prefs!.setInt('pamilya_streak', streak + 1);
    }

    // Update level completion in Hive
    final globalIdx = categoryIndex == 0 ? level : 4 + level;
    List<dynamic> completedLevels =
        List.from(_progressBox.get('pamilya_levels') ?? List.filled(9, false));
    if (globalIdx < completedLevels.length) {
      completedLevels[globalIdx] = true;
      await _progressBox.put('pamilya_levels', completedLevels);
    }

    await _syncToFirebase();
    notifyListeners();
  }

  Map<String, dynamic> getPamilyaProgress() {
    if (!_isInitialized) {
      return {
        'completedLevels': 0,
        'totalLevels': 5,
        'totalStars': 0,
        'totalScore': 0,
        'streak': 0,
        'gamesCompleted': 0,
        'totalGames': 25,
        'levelDetails': [false, false, false, false, false],
        'gameDetails': {},
      };
    }
    List<dynamic> completedLevels =
        _progressBox.get('pamilya_levels') ?? List.filled(9, false);
    int totalStars = _progressBox.get('pamilya_stars') ?? 0;
    int totalScore = _progressBox.get('pamilya_total') ?? 0;

    // Fallback to old Prefs keys
    if (totalStars == 0 && _prefs != null) {
      totalStars = _prefs!.getInt('pamilya_total_stars') ?? 0;
    }
    if (totalScore == 0 && _prefs != null) {
      totalScore = _prefs!.getInt('pamilya_total_score') ?? 0;
    }

    int streak = _progressBox.get('pamilya_streak') ?? 0;
    if (streak == 0 && _prefs != null) {
      streak = _prefs!.getInt('pamilya_streak') ?? 0;
    }
    Map<String, dynamic> games =
        Map<String, dynamic>.from(_progressBox.get('pamilya_games') ?? {});

    int completedCount = 0;
    for (var completed in completedLevels) {
      if (completed == true) completedCount++;
    }

    int gamesCompleted = games.values.where((v) => v == true).length;

    return {
      'completedLevels': completedCount,
      'totalLevels': 5,
      'totalStars': totalStars,
      'totalScore': totalScore,
      'streak': streak,
      'gamesCompleted': gamesCompleted,
      'totalGames': 25,
      'levelDetails': completedLevels,
      'gameDetails': games,
    };
  }

  // MAGBASA TAYO PROGRESS
  Future<void> updateMagbasaProgress(
      String category, int activityIndex, bool completed) async {
    await _ensureInitialized();
    if (!_isInitialized) return;

    final key = 'magbasa_${category}_$activityIndex';

    // Check if it was already completed to prevent double-rewarding
    bool wasAlreadyCompleted = _progressBox.get(key) == true;
    if (!wasAlreadyCompleted && _prefs != null) {
      wasAlreadyCompleted =
          _prefs!.getBool('${category}_activity_$activityIndex') == true;
    }

    await _progressBox.put(key, completed);

    Map<String, dynamic> categoryData =
        Map<String, dynamic>.from(_progressBox.get('magbasa_$category') ?? {});
    categoryData['$activityIndex'] = completed;
    await _progressBox.put('magbasa_$category', categoryData);

    // Update SharedPreferences
    if (_prefs != null) {
      await _prefs!.setBool('${category}_activity_$activityIndex', completed);
    }

    if (!wasAlreadyCompleted && completed) {
      // Award stars only for the first time
      await addStars(5);
    }

    await _updateMagbasaTotalProgress();
    await _syncToFirebase();
    notifyListeners();
  }

  Future<void> _updateMagbasaTotalProgress() async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    int totalCompleted = 0;
    final categories = ['tula', 'kwento', 'kanta'];

    for (var category in categories) {
      Map<String, dynamic> categoryData = Map<String, dynamic>.from(
          _progressBox.get('magbasa_$category') ?? {});
      totalCompleted += categoryData.values.where((v) => v == true).length;
    }

    await _progressBox.put('magbasa_total', totalCompleted);
  }

  Map<String, dynamic> getMagbasaProgress() {
    Map<String, dynamic> progress = {
      'tula': {'completed': 0, 'total': 5},
      'kwento': {'completed': 0, 'total': 5},
      'kanta': {'completed': 0, 'total': 13},
      'totalCompleted': 0,
      'totalActivities': 23,
    };

    if (_prefs != null) {
      for (int i = 0; i < 5; i++) {
        if (_prefs!.getBool('tula_activity_$i') == true) {
          progress['tula']['completed'] =
              (progress['tula']['completed'] as int) + 1;
        }
      }
      for (int i = 0; i < 5; i++) {
        if (_prefs!.getBool('kwento_activity_$i') == true) {
          progress['kwento']['completed'] =
              (progress['kwento']['completed'] as int) + 1;
        }
      }
      for (int i = 0; i < 13; i++) {
        if (_prefs!.getBool('kanta_activity_$i') == true) {
          progress['kanta']['completed'] =
              (progress['kanta']['completed'] as int) + 1;
        }
      }
    }

    progress['totalCompleted'] = (progress['tula']['completed'] as int) +
        (progress['kwento']['completed'] as int) +
        (progress['kanta']['completed'] as int);

    return progress;
  }

  // KULAY-SAYA PROGRESS
  Future<void> updateKulayProgress(String activity, bool completed,
      {String? category, int? index}) async {
    await _ensureInitialized();
    if (!_isInitialized) return;

    if (category != null && index != null) {
      final key = 'kulay_page_${category}_$index';
      await _progressBox.put(key, completed);
      // Update SharedPrefs for dashboard consistency
      if (_prefs != null) {
        await _prefs!.setBool(key, completed);
      }
    } else {
      await _progressBox.put('kulay_$activity', completed);
      // Also update prefs if it's one of the base activities
      if (_prefs != null) {
        await _prefs!.setBool('kulay_$activity', completed);
      }
    }

    await _updateKulayTotalProgress();
    await _syncToFirebase();
    notifyListeners();
  }

  Future<void> _updateKulayTotalProgress() async {
    if (!_isInitialized) return;
    int totalCompleted = 0;

    // Base activities
    final activities = ['basic', 'mixing', 'objects', 'coloring'];
    for (var activity in activities) {
      if (_progressBox.get('kulay_$activity') == true) {
        totalCompleted++;
      }
    }

    // Page completions
    final totals = {'Animals': 3, 'Flowers': 2, 'Fruits': 2, 'Toys': 2};
    for (var cat in totals.keys) {
      for (int i = 0; i < totals[cat]!; i++) {
        if (_progressBox.get('kulay_page_${cat}_$i') == true ||
            (_prefs?.getBool('kulay_page_${cat}_$i') == true)) {
          totalCompleted++;
        }
      }
    }

    int currentScore = _progressBox.get('kulay_total') ?? 0;
    await _progressBox.put('kulay_total', totalCompleted);

    // Reward points for new completions
    if (totalCompleted > currentScore) {
      await addStars(5);
    }
  }

  Map<String, dynamic> getKulayProgress() {
    int totalCompleted = 0;

    // Base activities from Hive
    bool basic = false, mixing = false, objects = false, coloring = false;

    if (_isInitialized) {
      basic = _progressBox.get('kulay_basic') ?? false;
      mixing = _progressBox.get('kulay_mixing') ?? false;
      objects = _progressBox.get('kulay_objects') ?? false;
      coloring = _progressBox.get('kulay_coloring') ?? false;

      if (basic) totalCompleted++;
      if (mixing) totalCompleted++;
      if (objects) totalCompleted++;
      if (coloring) totalCompleted++;
    }

    // Page completions (check both for resilience)
    final totals = {'Animals': 3, 'Flowers': 2, 'Fruits': 2, 'Toys': 2};
    for (var cat in totals.keys) {
      for (int i = 0; i < totals[cat]!; i++) {
        final key = 'kulay_page_${cat}_$i';
        bool done = false;
        if (_isInitialized) {
          done = _progressBox.get(key) ?? false;
        }
        if (!done && _prefs != null) {
          done = _prefs!.getBool(key) ?? false;
        }

        if (done) totalCompleted++;
      }
    }

    return {
      'basic': basic,
      'mixing': mixing,
      'objects': objects,
      'coloring': coloring,
      'totalCompleted': totalCompleted,
      'totalActivities': 13, // 4 base + 9 pages
    };
  }

  // SUNDAN MO PROGRESS
  Future<void> updateSundanProgress(
      String mode, int index, bool completed) async {
    await _ensureInitialized();
    if (!_isInitialized) return;
    final key = 'sundan_${mode}_$index';

    // Check if already completed to prevent double-rewarding
    bool wasAlreadyCompleted = _progressBox.get(key) == true;

    await _progressBox.put(key, completed);

    List<dynamic> modeList = _progressBox.get('sundan_$mode') ??
        List.filled(mode == 'numbers' ? 10 : 26, false);
    if (index < modeList.length) {
      modeList[index] = completed;
      await _progressBox.put('sundan_$mode', modeList);
    }

    // Update SharedPreferences for dashboard
    if (_prefs != null) {
      String prefKey = '';
      if (mode == 'uppercase') {
        const allUpper = [
          'A',
          'B',
          'C',
          'D',
          'E',
          'F',
          'G',
          'H',
          'I',
          'J',
          'K',
          'L',
          'M',
          'N',
          'O',
          'P',
          'Q',
          'R',
          'S',
          'T',
          'U',
          'V',
          'W',
          'X',
          'Y',
          'Z'
        ];
        if (index < allUpper.length) {
          prefKey = 'sundan_upper_${allUpper[index]}';
        }
      } else if (mode == 'lowercase') {
        const allLower = [
          'a',
          'b',
          'c',
          'd',
          'e',
          'f',
          'g',
          'h',
          'i',
          'j',
          'k',
          'l',
          'm',
          'n',
          'o',
          'p',
          'q',
          'r',
          's',
          't',
          'u',
          'v',
          'w',
          'x',
          'y',
          'z'
        ];
        if (index < allLower.length) {
          prefKey = 'sundan_lower_${allLower[index]}';
        }
      } else if (mode == 'numbers') {
        const allNums = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
        if (index < allNums.length) {
          prefKey = 'sundan_num_${allNums[index]}';
        }
      }

      if (prefKey.isNotEmpty) {
        if (!wasAlreadyCompleted && _prefs!.getBool(prefKey) == true) {
          wasAlreadyCompleted = true;
        }
        await _prefs!.setBool(prefKey, completed);
      }
    }

    if (!wasAlreadyCompleted && completed) {
      await addStars(2); // Tracing is easier, so reward per first completion
    }

    await _updateSundanTotalProgress();
    await _syncToFirebase();
    notifyListeners();
  }

  Future<void> _updateSundanTotalProgress() async {
    if (!_isInitialized) return;
    List<dynamic> uppercase =
        _progressBox.get('sundan_uppercase') ?? List.filled(26, false);
    List<dynamic> lowercase =
        _progressBox.get('sundan_lowercase') ?? List.filled(26, false);
    List<dynamic> numbers =
        _progressBox.get('sundan_numbers') ?? List.filled(10, false);

    int uppercaseCompleted = uppercase.where((v) => v == true).length;
    int lowercaseCompleted = lowercase.where((v) => v == true).length;
    int numbersCompleted = numbers.where((v) => v == true).length;

    int overallTotal =
        uppercaseCompleted + lowercaseCompleted + numbersCompleted;
    await _progressBox.put('sundan_total', overallTotal);
  }

  Map<String, dynamic> getSundanProgress() {
    int uppercaseCompleted = 0;
    int lowercaseCompleted = 0;
    int numbersCompleted = 0;

    if (_prefs != null) {
      final allUpper = [
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z'
      ];
      final allLower = [
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z'
      ];
      final allNums = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

      for (var l in allUpper) {
        if (_prefs!.getBool('sundan_upper_$l') == true) {
          uppercaseCompleted++;
        }
      }
      for (var l in allLower) {
        if (_prefs!.getBool('sundan_lower_$l') == true) {
          lowercaseCompleted++;
        }
      }
      for (var n in allNums) {
        if (_prefs!.getBool('sundan_num_$n') == true) {
          numbersCompleted++;
        }
      }
    }

    int totalCompleted =
        uppercaseCompleted + lowercaseCompleted + numbersCompleted;

    if (!_isInitialized) {
      return {
        'uppercase': {'completed': uppercaseCompleted, 'total': 26},
        'lowercase': {'completed': lowercaseCompleted, 'total': 26},
        'numbers': {'completed': numbersCompleted, 'total': 10},
        'totalCompleted': totalCompleted,
        'totalActivities': 62,
      };
    }

    return {
      'uppercase': {
        'completed': uppercaseCompleted,
        'total': 26,
      },
      'lowercase': {
        'completed': lowercaseCompleted,
        'total': 26,
      },
      'numbers': {
        'completed': numbersCompleted,
        'total': 10,
      },
      'totalCompleted': totalCompleted,
      'totalActivities': 62,
    };
  }

  // OVERALL PROGRESS
  Map<String, dynamic> getAllProgress() {
    if (!_isInitialized) {
      return {
        'magbasa': {
          'tula': {'completed': 0, 'total': 5},
          'kwento': {'completed': 0, 'total': 5},
          'kanta': {'completed': 0, 'total': 13},
          'totalCompleted': 0,
          'totalActivities': 23,
        },
        'kulay': {
          'basic': false,
          'mixing': false,
          'objects': false,
          'coloring': false,
          'totalCompleted': 0,
          'totalActivities': 9,
        },
        'sundan': {
          'uppercase': {'completed': 0, 'total': 26},
          'lowercase': {'completed': 0, 'total': 26},
          'numbers': {'completed': 0, 'total': 10},
          'totalCompleted': 0,
          'totalActivities': 62,
        },
        'matematika': {
          'completedLevels': 0,
          'totalLevels': 7,
          'totalStars': 0,
          'totalScore': 0,
          'streak': 0,
          'gamesCompleted': 0,
          'totalGames': 31,
        },
        'pamilya': {
          'completedLevels': 0,
          'totalLevels': 5,
          'totalStars': 0,
          'totalScore': 0,
          'streak': 0,
          'gamesCompleted': 0,
          'totalGames': 25,
          'levelDetails': [false, false, false, false, false],
          'gameDetails': {},
        },
        'totalCompleted': 0,
        'totalActivities': 150,
        'overallProgress': 0.0,
      };
    }

    final magbasa = getMagbasaProgress();
    final kulay = getKulayProgress();
    final sundan = getSundanProgress();
    final matematika = getMatematikaProgress();
    final pamilya = getPamilyaProgress();

    final totalCompleted = (magbasa['totalCompleted'] as int) +
        (kulay['totalCompleted'] as int) +
        (sundan['totalCompleted'] as int) +
        (matematika['gamesCompleted'] as int) +
        (pamilya['gamesCompleted'] as int);

    final totalActivities = (magbasa['totalActivities'] as int) +
        (kulay['totalActivities'] as int) +
        (sundan['totalActivities'] as int) +
        (matematika['totalGames'] as int) +
        (pamilya['totalGames'] as int);

    double percentage =
        totalActivities > 0 ? (totalCompleted / totalActivities) * 100 : 0.0;

    return {
      'magbasa': magbasa,
      'kulay': kulay,
      'sundan': sundan,
      'matematika': matematika,
      'pamilya': pamilya,
      'totalCompleted': totalCompleted,
      'totalActivities': totalActivities,
      'percentage': percentage,
      'grade': _getGradeFromPercentage(percentage),
      'overallProgress':
          totalActivities > 0 ? totalCompleted / totalActivities : 0.0,
    };
  }

  String _getGradeFromPercentage(double percentage) {
    if (percentage >= 90) {
      return 'Outstanding';
    }
    if (percentage >= 80) {
      return 'Very Satisfactory';
    }
    if (percentage >= 75) {
      return 'Satisfactory';
    }
    if (percentage > 0) {
      return 'Developing';
    }
    return 'Not Started';
  }

  /// Sync this profile to Firestore
  Future<void> _syncToFirebase() async {
    await _ensureInitialized();
    if (_currentStudentId == null || _userProfile == null) return;

    // GUARD: If we have an ID but haven't synced from Cloud yet,
    // DO NOT push local empty state to prevent data wipe.
    if (!_hasSyncedFromCloud) {
      debugPrint('Sync deferred: Waiting for initial cloud pull...');
      return;
    }

    try {
      final progressData = getAllProgress();
      final profileData = _userProfile!.toJson();

      // Store raw keys from SharedPreferences too for full backup
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) =>
              k.startsWith('matematika_') ||
              k.startsWith('pamilya_') ||
              k.startsWith('sundan_') ||
              k.startsWith('kulay_') ||
              k.startsWith('magbasa_') ||
              k.startsWith(
                  'mat_') // Keep mat_ for legacy support during transition
          );

      final Map<String, dynamic> rawProgressData = {};
      for (var key in keys) {
        rawProgressData[key] = prefs.get(key);
      }

      // ALSO add Hive-only global keys that are NOT in SharedPreferences
      final hiveKeys = [
        'pamilya_levels',
        'matematika_levels',
        'pamilya_games',
        'matematika_games',
        'sundan_total',
        'kulay_total',
        'magbasa_total'
      ];
      for (var key in hiveKeys) {
        final val = _progressBox.get(key);
        if (val != null) rawProgressData[key] = val;
      }

      await FirebaseFirestore.instance
          .collection('students')
          .doc(_currentStudentId)
          .update({
        'progress': progressData,
        'profile': profileData,
        'rawProgress': rawProgressData,
        'creations': _progressBox.get('coloring_creations'),
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error syncing to Firebase: $e');
    }
  }

  // STARS AND ACHIEVEMENTS
  Future<void> addStars(int stars) async {
    await _ensureInitialized();
    if (_userProfile != null) {
      _userProfile!.stars += stars;
      await _profileBox.put('currentUser', _userProfile!.toJson());
      await _syncToFirebase();
      notifyListeners();
    }
  }

  Future<void> addAchievement(String achievement) async {
    await _ensureInitialized();
    if (_userProfile != null) {
      _userProfile!.achievements[achievement] =
          (_userProfile!.achievements[achievement] ?? 0) + 1;
      _userProfile!.lessonsCompleted += 1;
      await _profileBox.put('currentUser', _userProfile!.toJson());
      await _syncToFirebase();
      notifyListeners();
    }
  }

  // RESET PROGRESS
  Future<void> resetAllProgress() async {
    await _ensureInitialized();
    await _progressBox.clear();
    _initProgressBox();
    await _syncToFirebase();
    notifyListeners();
  }

  // GET SPECIFIC PROGRESS
  bool isMagbasaActivityCompleted(String category, int index) {
    if (!_isInitialized) return false;
    return _progressBox.get('magbasa_${category}_$index') ?? false;
  }

  bool isKulayActivityCompleted(String activity) {
    if (!_isInitialized) return false;
    return _progressBox.get('kulay_$activity') ?? false;
  }

  bool isSundanActivityCompleted(String mode, int index) {
    if (!_isInitialized) return false;
    return _progressBox.get('sundan_${mode}_$index') ?? false;
  }

  bool isMatematikaLevelCompleted(int level) {
    if (!_isInitialized) return false;
    List<dynamic> completedLevels = _progressBox.get('matematika_levels') ??
        [false, false, false, false, false, false, false];
    return level < completedLevels.length ? completedLevels[level] : false;
  }

  bool isMatematikaGameCompleted(int level, int gameIndex) {
    if (!_isInitialized) return false;
    Map<String, dynamic> games =
        Map<String, dynamic>.from(_progressBox.get('matematika_games') ?? {});
    return games['level${level}_game$gameIndex'] ?? false;
  }

  bool isPamilyaLevelCompleted(int categoryIndex, int level) {
    if (!_isInitialized) return false;
    // Map cat-level to a flat index (0-3 for cat 0, 4-8 for cat 1)
    final globalIdx = categoryIndex == 0 ? level : 4 + level;
    List<dynamic> completedLevels =
        _progressBox.get('pamilya_levels') ?? List.filled(9, false);

    // Also check SharedPreferences/Keys
    final levelKey = 'pamilya_cat_${categoryIndex}_level_$level';
    if (_prefs != null && _prefs!.getBool(levelKey) == true) return true;

    return globalIdx < completedLevels.length
        ? (completedLevels[globalIdx] == true)
        : false;
  }

  bool isPamilyaGameCompleted(int categoryIndex, int level, int gameIndex) {
    if (!_isInitialized) return false;
    final gameKey =
        'pamilya_cat_${categoryIndex}_level_${level}_game_$gameIndex';

    // Check Hive
    Map<String, dynamic> games =
        Map<String, dynamic>.from(_progressBox.get('pamilya_games') ?? {});
    if (games.containsKey(gameKey)) return games[gameKey] ?? false;

    // Fallback to SharedPreferences if not in Hive yet
    if (_prefs != null) {
      return _prefs!.getBool(gameKey) ?? false;
    }

    return false;
  }

  @override
  void dispose() {
    _stopProfileListener();
    super.dispose();
  }
}
