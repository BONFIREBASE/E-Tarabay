import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/pamilya_content.dart';
import '../providers/language_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/success_modal.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';
import 'dart:async';
import 'package:flutter_lucide/flutter_lucide.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  BADGE MODEL
// ─────────────────────────────────────────────────────────────────────────────
class FamilyBadge {
  final String emoji;
  String title;
  String description;
  final Color color;
  bool isEarned;

  FamilyBadge({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    this.isEarned = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class PamilyaScreen extends StatefulWidget {
  const PamilyaScreen({super.key});

  @override
  State<PamilyaScreen> createState() => _PamilyaScreenState();
}

class _PamilyaScreenState extends State<PamilyaScreen>
    with TickerProviderStateMixin {
  // ── Navigation ─────────────────────────────────────────────────────────────
  int _selectedMainCategory = 0;
  int _selectedLevel = 0;
  int _currentGameIndex = 0;

  // ── Scoring ────────────────────────────────────────────────────────────────
  int _totalScore = 0;
  int _totalStars = 0;
  int _levelStars = 0;
  int _levelScore = 0;
  int _wrongAttempts = 0;

  // ── Timer ──────────────────────────────────────────────────────────────────
  int _secondsLeft = 60;
  Timer? _timer;
  final bool _timerEnabled = true;

  // ── Feedback ───────────────────────────────────────────────────────────────
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.transparent;
  bool _showCorrectOverlay = false;

  // ── Sarili states ──────────────────────────────────────────────────────────
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  int? _selectedGender;
  int? _selectedEmotionAnswer;
  bool _showEmotionExplanation = false;
  int? _selectedRoutineAnswer;
  int? _selectedFoodIndex;
  int? _selectedColorIndex;
  int? _selectedGameIndex;
  int? _selectedAnimalIndex;

  // ── Pamilya states ─────────────────────────────────────────────────────────
  int? _selectedFamilyAnswer;
  String? _selectedFamilyMember;
  bool _showingFamilyInfo = false;
  int? _selectedRoleAnswer;
  int? _selectedActivityAnswer;
  bool _myHomeCompleted = false;
  int? _selectedRoomIndex;

  // ── Badges ─────────────────────────────────────────────────────────────────
  late List<FamilyBadge> _badges;
  List<FamilyBadge> _newlyEarnedBadges = [];

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _starBurstController;
  late AnimationController _timerPulseController;
  late AnimationController _celebrationController;
  late AnimationController _characterController;
  late Animation<double> _starBurstAnim;
  late Animation<double> _timerPulseAnim;
  late Animation<double> _characterAnim;

  bool _characterHappy = false;
  late AudioPlayer _audioPlayer;

  String get _currentLang =>
      Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;

  // ─────────────────────────────────────────────────────────────────────────
  //  DATA
  // ─────────────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _mainCategories =>
      PamilyaContent.getMainCategories(_currentLang);

  List<List<String>> get _categoryLevelTitles =>
      PamilyaContent.getCategoryLevelTitles(_currentLang);

  final List<List<IconData>> _categoryLevelIcons = [
    [
      LucideIcons.user,
      LucideIcons.smile,
      LucideIcons.clock,
      LucideIcons.heart
    ],
    [
      LucideIcons.users,
      LucideIcons.briefcase,
      LucideIcons.party_popper,
      LucideIcons.workflow,
      LucideIcons.house
    ],
  ];

  // ── Sarili Level 1 ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _sariliLevel1Games =>
      PamilyaContent.getSariliLevel1Games(_currentLang);

  // ── Sarili Level 2: Emotions (full Ilocano) ────────────────────────────────
  List<Map<String, dynamic>> get _sariliLevel2Games =>
      PamilyaContent.getSariliLevel2Games(_currentLang);

  // ── Sarili Level 3: Daily Routines ─────────────────────────────────────────
  List<Map<String, dynamic>> get _sariliLevel3Games =>
      PamilyaContent.getSariliLevel3Games(_currentLang);

  // ── Sarili Level 4: Preferences ────────────────────────────────────────────
  List<Map<String, dynamic>> get _sariliLevel4Games =>
      PamilyaContent.getSariliLevel4Games(_currentLang);

  // ── Pamilya Level 1: Family Members ────────────────────────────────────────
  List<Map<String, dynamic>> get _pamilyaLevel1Games =>
      PamilyaContent.getPamilyaLevel1Games(_currentLang);

  // ── Pamilya Level 2: Family Roles ──────────────────────────────────────────
  List<Map<String, dynamic>> get _pamilyaLevel2Games =>
      PamilyaContent.getPamilyaLevel2Games(_currentLang);

  // ── Pamilya Level 3: Family Activities ─────────────────────────────────────
  List<Map<String, dynamic>> get _pamilyaLevel3Games =>
      PamilyaContent.getPamilyaLevel3Games(_currentLang);

  // ── Pamilya Level 4: Family Tree ───────────────────────────────────────────
  List<Map<String, dynamic>> get _pamilyaLevel4Games =>
      PamilyaContent.getPamilyaLevel4Games(_currentLang);

  // ── Pamilya Level 5: Our Home ──────────────────────────────────────────────
  List<Map<String, dynamic>> get _pamilyaLevel5Games =>
      PamilyaContent.getPamilyaLevel5Games(_currentLang);

  // ── Family Tree ────────────────────────────────────────────────────────────
  Map<String, dynamic> get _familyTreeData =>
      PamilyaContent.getFamilyTreeData(_currentLang);

  // ── My Home ────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _homeRooms =>
      PamilyaContent.getHomeRooms(_currentLang);

  String _getMainCategoryTitle(int index) {
    if (index == 0) {
      return AppLocalizations.of(context)!.angAkingSarili.replaceAll('\n', ' ');
    }
    if (index == 1) {
      return AppLocalizations.of(context)!.atAkingPamilya.replaceAll('\n', ' ');
    }
    return '';
  }

  String _getLevelTitle(int catIndex, int lvlIndex) {
    if (catIndex == 0) {
      switch (lvlIndex) {
        case 0:
          return AppLocalizations.of(context)!.allAboutMe;
        case 1:
          return AppLocalizations.of(context)!.myEmotions;
        case 2:
          return AppLocalizations.of(context)!.dailyRoutines;
        case 3:
          return AppLocalizations.of(context)!.myPreferences;
      }
    } else {
      switch (lvlIndex) {
        case 0:
          return AppLocalizations.of(context)!.familyMembers;
        case 1:
          return AppLocalizations.of(context)!.familyRoles;
        case 2:
          return AppLocalizations.of(context)!.familyActivities;
        case 3:
          return AppLocalizations.of(context)!.familyTree;
        case 4:
          return AppLocalizations.of(context)!.myHome;
      }
    }
    return '';
  }

  String _getLevelSubTitle(int catIndex, int lvlIndex) {
    if (catIndex == 0) {
      switch (lvlIndex) {
        case 0:
          return AppLocalizations.of(context)!.aboutMeSubtitle;
        case 1:
          return AppLocalizations.of(context)!.myEmotionsSubtitle;
        case 2:
          return AppLocalizations.of(context)!.dailyRoutinesSubtitle;
        case 3:
          return AppLocalizations.of(context)!.myPreferencesSubtitle;
      }
    } else {
      switch (lvlIndex) {
        case 0:
          return AppLocalizations.of(context)!.familyMembersSubtitle;
        case 1:
          return AppLocalizations.of(context)!.familyRolesSubtitle;
        case 2:
          return AppLocalizations.of(context)!.familyActivitiesSubtitle;
        case 3:
          return AppLocalizations.of(context)!.familyTreeSubtitle;
        case 4:
          return AppLocalizations.of(context)!.myHomeSubtitle;
      }
    }
    return '';
  }

  String _getGameString(Map<String, dynamic> game, String key) {
    final id = game['id'] as String;
    if (key == 'question') {
      switch (id) {
        case 'about_name':
          return AppLocalizations.of(context)!.whatIsYourName;
        case 'about_age':
          return AppLocalizations.of(context)!.howOldAreYou;
        case 'about_gender':
          return AppLocalizations.of(context)!.areYouBoyOrGirl;
      }
    } else if (key == 'description') {
      switch (id) {
        case 'about_name':
          return AppLocalizations.of(context)!.whatIsYourNameDescription;
        case 'about_age':
          return AppLocalizations.of(context)!.howOldAreYouDescription;
        case 'about_gender':
          return AppLocalizations.of(context)!.genderDescription;
      }
    } else if (key == 'hint') {
      switch (id) {
        case 'about_name':
          return AppLocalizations.of(context)!.typeNameHint;
        case 'about_age':
          return AppLocalizations.of(context)!.ageHint;
      }
    }
    return game[key] ?? '';
  }
  // ─────────────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _currentGames {
    if (_selectedMainCategory == 0) {
      switch (_selectedLevel) {
        case 0:
          return _sariliLevel1Games;
        case 1:
          return _sariliLevel2Games;
        case 2:
          return _sariliLevel3Games;
        case 3:
          return _sariliLevel4Games;
        default:
          return _sariliLevel1Games;
      }
    } else {
      switch (_selectedLevel) {
        case 0:
          return _pamilyaLevel1Games;
        case 1:
          return _pamilyaLevel2Games;
        case 2:
          return _pamilyaLevel3Games;
        case 3:
          return _pamilyaLevel4Games;
        case 4:
          return _pamilyaLevel5Games;
        default:
          return _pamilyaLevel1Games;
      }
    }
  }

  int get _starsFromWrong {
    if (_wrongAttempts == 0) return 3;
    if (_wrongAttempts == 1) return 2;
    return 1;
  }

  String get _currentMainTitle =>
      _mainCategories[_selectedMainCategory]['title'];
  Color get _currentMainColor =>
      _mainCategories[_selectedMainCategory]['color'];

  // ─────────────────────────────────────────────────────────────────────────
  //  Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    AudioManager.instance.playModuleMusic(ModuleMusic.pamilya);

    _badges = [
      FamilyBadge(
          emoji: '👤',
          title: 'Ammok ti Bagik',
          description: 'Nakompleto ti "Ti Bagik"',
          color: const Color(0xFFFF6B6B)),
      FamilyBadge(
          emoji: '😊',
          title: 'Rikna Esperto',
          description: 'Nakompleto ti "Dagiti Riknak"',
          color: const Color(0xFFFF9F43)),
      FamilyBadge(
          emoji: '⏰',
          title: 'Aramid Esperto',
          description: 'Nakompleto ti "Inaldaw nga Aramid"',
          color: const Color(0xFF4ECDC4)),
      FamilyBadge(
          emoji: '❤️',
          title: 'Ammok ti Kayatko',
          description: 'Nakompleto ti "Paboritok"',
          color: const Color(0xFFFF6B9D)),
      FamilyBadge(
          emoji: '👨‍👩‍👧‍👦',
          title: 'Miyembro Esperto',
          description: 'Nakompleto ti "Dagiti Miyembro"',
          color: const Color(0xFF6C5CE7)),
      FamilyBadge(
          emoji: '🏆',
          title: 'Trabaho Esperto',
          description: 'Nakompleto ti "Trabaho iti Pamilya"',
          color: const Color(0xFFFD79A8)),
      FamilyBadge(
          emoji: '🎉',
          title: 'Aramid Esperto',
          description: 'Nakompleto ti "Aramid ti Pamilya"',
          color: const Color(0xFF00B894)),
      FamilyBadge(
          emoji: '🌳',
          title: 'Puno Esperto',
          description: 'Nakompleto ti "Puno ti Pamilya"',
          color: const Color(0xFF55EFC4)),
      FamilyBadge(
          emoji: '🏠',
          title: 'Balay Esperto',
          description: 'Nakompleto ti "Ti Balaymi"',
          color: const Color(0xFF74B9FF)),
    ];

    _starBurstController = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _timerPulseController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _celebrationController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _characterController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _starBurstAnim =
        CurvedAnimation(parent: _starBurstController, curve: Curves.elasticOut);
    _timerPulseAnim =
        Tween<double>(begin: 1.0, end: 1.18).animate(_timerPulseController);
    _characterAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _characterController, curve: Curves.elasticOut),
    );

    _audioPlayer = AudioPlayer();

    _initSmartResume();

    if (_timerEnabled) _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateBadgeTitles();
  }

  void _updateBadgeTitles() {
    if (_badges.isEmpty) return;
    final loc = AppLocalizations.of(context)!;
    final titles = [
      loc.badgeKnowMyself,
      loc.badgeEmotionExpert,
      loc.badgeRoutineExpert,
      loc.badgePreferenceExpert,
      loc.badgeMemberExpert,
      loc.badgeWorkExpert,
      loc.badgeActivityExpert,
      loc.badgeTreeExpert,
      loc.badgeHouseExpert,
    ];
    final descriptions = [
      loc.badgeKnowMyselfDesc,
      loc.badgeEmotionExpertDesc,
      loc.badgeRoutineExpertDesc,
      loc.badgePreferenceExpertDesc,
      loc.badgeMemberExpertDesc,
      loc.badgeWorkExpertDesc,
      loc.badgeActivityExpertDesc,
      loc.badgeTreeExpertDesc,
      loc.badgeHouseExpertDesc,
    ];
    for (int i = 0; i < _badges.length && i < titles.length; i++) {
      _badges[i].title = titles[i];
      _badges[i].description = descriptions[i];
    }
  }

  Future<void> _initSmartResume() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Safety wait for provider initialization (same as SplashScreen fix)
      int retryCount = 0;
      while (!userProvider.isInitialized && retryCount < 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        retryCount++;
      }

      // 1. Find the first uncompleted CATEGORY and LEVEL
      int savedMainCat = 0;
      int savedLevel = 0;
      bool found = false;

      for (int c = 0; c < _mainCategories.length; c++) {
        for (int l = 0; l < _categoryLevelTitles[c].length; l++) {
          if (!userProvider.isPamilyaLevelCompleted(c, l)) {
            savedMainCat = c;
            savedLevel = l;
            found = true;
            break;
          }
        }
        if (found) break;
      }

      // If all completed, default to last
      if (!found) {
        savedMainCat = _mainCategories.length - 1;
        savedLevel = _categoryLevelTitles[savedMainCat].length - 1;
      }

      if (mounted) {
        setState(() {
          _selectedMainCategory = savedMainCat;
          _selectedLevel = savedLevel;

          final pProgress = userProvider.getPamilyaProgress();
          _totalStars = pProgress['totalStars'] ?? 0;

          // Sync badges based on UserProvider before resetting level state
          for (int i = 0; i < _badges.length; i++) {
            int cat = i < 4 ? 0 : 1;
            int lvl = i < 4 ? i : i - 4;
            _badges[i].isEarned =
                userProvider.isPamilyaLevelCompleted(cat, lvl);
          }

          _resetLevelState();
        });
      }
    } catch (e) {
      debugPrint('Pamilya Smart Resume failed: $e');
      _resetLevelState();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _ageController.dispose();
    _placeController.dispose();
    _starBurstController.dispose();
    _timerPulseController.dispose();
    _celebrationController.dispose();
    _characterController.dispose();
    _audioPlayer.dispose();

    // Ensure music unmuted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager.instance.resumeMusic();
    });
    AudioManager.instance.resumeHomeMusic();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Timer
  // ─────────────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isPamilyaGameCompleted(
          _selectedMainCategory, _selectedLevel, _currentGameIndex)) {
        return;
      }
    } catch (_) {}

    _secondsLeft = 60;
    _timerPulseController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _timerPulseController.stop();
        _onTimeout();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timerPulseController.stop();
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timerPulseController.stop();
  }

  void _resumeTimer() {
    if (_timerEnabled && _secondsLeft > 0) _startTimer();
  }

  void _onTimeout() {
    _showFeedback('⏰ ${AppLocalizations.of(context)!.timeOut}', Colors.orange);
    _resetQuestionState();
    if (_timerEnabled) _startTimer();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  State reset
  // ─────────────────────────────────────────────────────────────────────────

  void _resetLevelState() {
    // Determine the first uncompleted game index for the current level
    int firstUncompleted = 0;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final total = _currentGames.length;
      for (int i = 0; i < total; i++) {
        if (!userProvider.isPamilyaGameCompleted(
            _selectedMainCategory, _selectedLevel, i)) {
          firstUncompleted = i;
          break;
        }
        if (i == total - 1) firstUncompleted = total - 1;
      }
    } catch (_) {
      firstUncompleted = 0;
    }

    _currentGameIndex = firstUncompleted;
    _levelStars = 0;
    _levelScore = 0;
    _wrongAttempts = 0;
    _resetQuestionState();
  }

  void _resetQuestionState() {
    setState(() {
      _selectedGender = null;
      _selectedEmotionAnswer = null;
      _showEmotionExplanation = false;
      _selectedRoutineAnswer = null;
      _selectedFoodIndex = null;
      _selectedColorIndex = null;
      _selectedGameIndex = null;
      _selectedAnimalIndex = null;
      _selectedFamilyAnswer = null;
      _selectedFamilyMember = null;
      _showingFamilyInfo = false;
      _selectedRoleAnswer = null;
      _selectedActivityAnswer = null;
      _myHomeCompleted = false;
      _selectedRoomIndex = null;
      _showCorrectOverlay = false;
      _feedbackMessage = '';
      _characterHappy = false;
    });
  }

  void _switchMainCategory(int index) {
    _stopTimer();
    setState(() {
      _selectedMainCategory = index;
      _selectedLevel = 0;
      _resetLevelState();
    });
    if (_timerEnabled) _startTimer();
  }

  void _switchLevel(int level) {
    _stopTimer();
    setState(() {
      _selectedLevel = level;
      _resetLevelState();
    });
    if (_timerEnabled) _startTimer();
  }

  void _advanceOrComplete() {
    final total = _currentGames.length;
    if (_currentGameIndex < total - 1) {
      setState(() {
        _currentGameIndex++;
        _wrongAttempts = 0;
        _resetQuestionState();
      });
      if (_timerEnabled) _startTimer();
    } else {
      _awardBadge();
      _showLevelComplete();
    }
  }

  void _awardBadge() {
    // Determine which badge index to award
    int badgeIdx;
    if (_selectedMainCategory == 0) {
      badgeIdx = _selectedLevel;
    } else {
      badgeIdx = 4 + _selectedLevel;
    }
    if (badgeIdx < _badges.length && !_badges[badgeIdx].isEarned) {
      setState(() {
        _badges[badgeIdx].isEarned = true;
        _newlyEarnedBadges = [_badges[badgeIdx]];
      });
      _showBadgesModal();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Correct / Wrong
  // ─────────────────────────────────────────────────────────────────────────

  void _onCorrect() {
    if (_showCorrectOverlay) return;
    HapticFeedback.heavyImpact();
    _stopTimer();

    final earned = _starsFromWrong;
    setState(() {
      _totalScore += 10 * earned;
      _totalStars += earned;
      _levelStars += earned;
      _levelScore += 10 * earned;
      _showCorrectOverlay = true;
      _characterHappy = true;
    });

    _starBurstController.forward(from: 0);
    _celebrationController.forward(from: 0);
    _characterController
        .forward(from: 0)
        .then((_) => _characterController.reverse());

    final points = 10 * earned;
    final msg =
        '⭐ ${AppLocalizations.of(context)!.goodJob} ⭐ +$points ${AppLocalizations.of(context)!.pointsLabel}';
    _showFeedback(msg, const Color(0xFF2E7D32));
    _saveQuestionProgress(earned);

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _showCorrectOverlay = false;
        _celebrationController.reset();
        _characterHappy = false;
      });
      _advanceOrComplete();
    });
  }

  void _saveQuestionProgress(int earned) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updatePamilyaProgress(
      _selectedMainCategory,
      _selectedLevel,
      _currentGameIndex,
      true,
      earnedStars: earned,
    );
  }

  void _onWrong() {
    if (_showCorrectOverlay) return;
    HapticFeedback.vibrate();
    _stopTimer();

    setState(() {
      _wrongAttempts++;
      _characterHappy = false;
      // We don't have a wrong overlay in PamilyaScreen yet?
      // I'll just show feedback.
    });

    _showFeedback(AppLocalizations.of(context)!.incorrectAnswer, Colors.red);
    _saveQuestionProgress(0);

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      _advanceOrComplete();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Game handlers
  // ─────────────────────────────────────────────────────────────────────────

  void _handleTextSubmit(String value) {
    _pauseTimer();
    final trimmed = value.trim();

    // Smart Checker: Prevent random junk/single letters
    if (trimmed.length < 2) {
      _showFeedback('❌ ${AppLocalizations.of(context)!.tooShort}', Colors.red);
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 800), _resumeTimer);
      return;
    }

    // Pattern check: Ensure it's not just random repeated characters (e.g., "aaaaa")
    final uniqueChars = trimmed.toLowerCase().split('').toSet();
    if (uniqueChars.length == 1 && trimmed.length > 2) {
      _showFeedback(
          '❌ ${AppLocalizations.of(context)!.invalidInput}', Colors.red);
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 800), _resumeTimer);
      return;
    }

    if (trimmed.isNotEmpty) {
      _showFeedback('✓ ${AppLocalizations.of(context)!.saved}', Colors.green);
      Future.delayed(const Duration(seconds: 1), _onCorrect);
    } else {
      _showFeedback(
          '✗ ${AppLocalizations.of(context)!.selectAnswer}', Colors.orange);
      Future.delayed(const Duration(milliseconds: 500), _resumeTimer);
    }
  }

  void _handleGenderSelection(int index) {
    _pauseTimer();
    setState(() => _selectedGender = index);
    _showFeedback('✓ ${AppLocalizations.of(context)!.correct}', Colors.green);
    Future.delayed(const Duration(seconds: 1), _onCorrect);
  }

  void _handleEmotionAnswer(
      int index, int correct, String explanation, String tip) {
    _pauseTimer();
    setState(() => _selectedEmotionAnswer = index);
    if (index == correct) {
      _showEmojiExplation(explanation, tip);
    } else {
      _onWrong();
    }
  }

  void _showEmojiExplation(String explanation, String tip) {
    setState(() => _showEmotionExplanation = true);
    _showFeedback('✓ ${AppLocalizations.of(context)!.correct}', Colors.green);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _showFeedback('💡 $tip', Colors.blue);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showEmotionExplanation = false);
        _onCorrect();
      }
    });
  }

  void _handleRoutineAnswer(
      int index, int correct, String explanation, String tip) {
    _pauseTimer();
    setState(() => _selectedRoutineAnswer = index);
    if (index == correct) {
      _showFeedback('✓ ${AppLocalizations.of(context)!.correct} $explanation',
          Colors.green);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _showFeedback('💡 $tip', Colors.blue);
      });
      Future.delayed(const Duration(seconds: 3), _onCorrect);
    } else {
      _onWrong();
    }
  }

  void _handlePreferenceSelection(int index, String type) {
    _pauseTimer();
    setState(() {
      if (type == 'food') {
        _selectedFoodIndex = index;
      } else if (type == 'color') {
        _selectedColorIndex = index;
      } else if (type == 'game') {
        _selectedGameIndex = index;
      } else if (type == 'animal') {
        _selectedAnimalIndex = index;
      }
    });
    _showFeedback('✓ ${AppLocalizations.of(context)!.correct}', Colors.green);
    Future.delayed(const Duration(seconds: 1), _onCorrect);
  }

  void _handleFamilyAnswer(int index, int correct, Map<String, dynamic> game) {
    _pauseTimer();
    setState(() => _selectedFamilyAnswer = index);
    if (index == correct) {
      setState(() {
        _selectedFamilyMember = game['member'];
        _showingFamilyInfo = true;
      });
      _showFeedback(
          '✓ ${AppLocalizations.of(context)!.correct} ${game['member']}!',
          Colors.green);

      // Play audio if available
      if (game['audioPath'] != null) {
        _playItemAudio(game['audioPath']);
      }

      Future.delayed(const Duration(seconds: 2), _onCorrect);
    } else {
      _onWrong();
    }
  }

  void _handleRoleAnswer(int index, int correct, String explanation) {
    _pauseTimer();
    setState(() => _selectedRoleAnswer = index);
    if (index == correct) {
      _showFeedback('✓ ${AppLocalizations.of(context)!.correct} $explanation',
          Colors.green);
      Future.delayed(const Duration(seconds: 2), _onCorrect);
    } else {
      _onWrong();
    }
  }

  void _handleActivityAnswer(int index, int correct, String explanation) {
    _pauseTimer();
    setState(() => _selectedActivityAnswer = index);
    if (index == correct) {
      _showFeedback('✓ ${AppLocalizations.of(context)!.correct} $explanation',
          Colors.green);
      Future.delayed(const Duration(seconds: 2), _onCorrect);
    } else {
      _showFeedback('✗ ${AppLocalizations.of(context)!.tryAgain}', Colors.red);
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => _selectedActivityAnswer = null);
        _resumeTimer();
      });
    }
  }

  void _handleFamilyTreeComplete() {
    _pauseTimer();
    _showFeedback(
        '✓ ${AppLocalizations.of(context)!.iLearnedFamilyTree}', Colors.green);
    Future.delayed(const Duration(seconds: 2), _onCorrect);
  }

  void _handleRoomTap(int index) {
    _pauseTimer();
    setState(() => _selectedRoomIndex = index);
    final room = _homeRooms[index];
    _showFeedback('🏠 ${room['name']}: ${room['activity']}', _currentMainColor);
    Future.delayed(const Duration(seconds: 2), () {
      if (index == _homeRooms.length - 1 ||
          _selectedRoomIndex == _homeRooms.length - 1) {
        _handleMyHomeComplete();
      } else {
        _resumeTimer();
      }
    });
  }

  void _handleMyHomeComplete() {
    _pauseTimer();
    setState(() => _myHomeCompleted = true);
    _showFeedback(
        '✓ ${AppLocalizations.of(context)!.thatIsOurHome}', Colors.green);
    Future.delayed(const Duration(seconds: 2), _onCorrect);
  }

  void _showFeedback(String msg, Color color) {
    setState(() {
      _feedbackMessage = msg;
      _feedbackColor = color;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _feedbackMessage == msg) {
        setState(() {
          _feedbackMessage = '';
          _feedbackColor = Colors.transparent;
        });
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Dialogs
  // ─────────────────────────────────────────────────────────────────────────

  void _showLevelComplete() {
    _stopTimer();
    final total = _currentGames.length;
    final avgStars = total == 0 ? 1 : (_levelStars / total).ceil().clamp(1, 3);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.awardPamilyaLevelCompletion(
        _selectedMainCategory, _selectedLevel);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessModal(
        title: AppLocalizations.of(context)!.levelCompleted(_selectedLevel + 1),
        subtitle: _getLevelTitle(_selectedMainCategory, _selectedLevel),
        score: _levelScore,
        stars: avgStars,
        badges: _newlyEarnedBadges.map((b) => '${b.emoji} ${b.title}').toList(),
        primaryLabel: _selectedLevel <
                _categoryLevelTitles[_selectedMainCategory].length - 1
            ? AppLocalizations.of(context)!.next
            : AppLocalizations.of(context)!.finished,
        onPrimaryTap: () {
          Navigator.pop(context);
          _newlyEarnedBadges = [];
          if (_selectedLevel <
              _categoryLevelTitles[_selectedMainCategory].length - 1) {
            _switchLevel(_selectedLevel + 1);
          } else {
            _showCategoryComplete();
          }
        },
        secondaryLabel: AppLocalizations.of(context)!.ulitin,
        onSecondaryTap: () {
          Navigator.pop(context);
          _newlyEarnedBadges = [];
          _switchLevel(_selectedLevel);
        },
        mainColor: _currentMainColor,
      ),
    );
  }

  void _showCategoryComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessModal(
        title: AppLocalizations.of(context)!.proudOfYou,
        subtitle: AppLocalizations.of(context)!
            .categoryCompleted(_getMainCategoryTitle(_selectedMainCategory)),
        score: _totalScore,
        stars: 3,
        primaryLabel: AppLocalizations.of(context)!.continueText,
        onPrimaryTap: () {
          Navigator.pop(context);
        },
        secondaryLabel: AppLocalizations.of(context)!.back,
        onSecondaryTap: () {
          Navigator.pop(context);
        },
        mainColor: _currentMainColor,
      ),
    );
  }

  void _showBadgesModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.badgesWithIcon,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemCount: _badges.length,
              itemBuilder: (_, i) {
                final b = _badges[i];
                return Container(
                  decoration: BoxDecoration(
                    color: b.isEarned
                        ? b.color.withOpacity(0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: b.isEarned ? b.color : Colors.grey.shade300),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(b.isEarned ? b.emoji : '🔒',
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(b.isEarned ? b.title : '???',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: b.isEarned
                                    ? b.color
                                    : Colors.grey.shade400),
                            textAlign: TextAlign.center),
                      ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: CustomBackButton(
        iconColor: AppColors.textDark,
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getMainCategoryTitle(_selectedMainCategory),
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(AppLocalizations.of(context)!.level(_selectedLevel + 1),
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ],
      ),
      actions: [
        _buildTimerPill(),
        _buildAppBarPill(
          icon: '⭐',
          label: '$_totalStars',
          color: Colors.orange,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey.withOpacity(0.12),
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildAppBarPill({
    required String icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerPill() {
    return AnimatedBuilder(
      animation: _timerPulseAnim,
      builder: (_, __) {
        final urgent = _secondsLeft <= 10;
        final color = urgent ? Colors.red : _currentMainColor;
        return Transform.scale(
          scale: urgent ? _timerPulseAnim.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.25), width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(LucideIcons.timer, color: color, size: 15),
              const SizedBox(width: 4),
              Text('$_secondsLeft',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            ]),
          ),
        );
      },
    );
  }

  Future<void> _playItemAudio(String path) async {
    try {
      await AudioManager.instance.pauseMusic();
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));

      // Resume background music when item audio finishes
      _audioPlayer.onPlayerComplete.first.then((_) {
        if (mounted) {
          AudioManager.instance.resumeMusic();
        }
      });
    } catch (e) {
      debugPrint('Error playing item audio: $e');
      AudioManager.instance.resumeMusic();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Real-time account deletion check
    if (userProvider.isAccountDeleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FE), Color(0xFFEDF1F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                _buildMainCategoryTabs(),
                _buildLevelTabs(),
                _buildProgressHeader(),
                Expanded(child: _buildGameContent()),
                _buildFeedbackBanner(),
              ],
            ),
            if (_showCorrectOverlay) _buildCorrectOverlay(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TABS
  // ─────────────────────────────────────────────────────────────────────────

  // ── Gradient themes per level ─────────────────────────────────────────────
  static const List<List<Color>> _levelGradients = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)], // 0: Coral Sunset
    [Color(0xFF4FACFE), Color(0xFF00F2FE)], // 1: Ocean Blue
    [Color(0xFF11998E), Color(0xFF38EF7D)], // 2: Emerald Green
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // 3: Royal Purple
    [Color(0xFFFFB75E), Color(0xFFED8F03)], // 4: Sunburst Amber
    [Color(0xFFFF512F), Color(0xFFDD2476)], // 5: Warm Rose
    [Color(0xFF4364F7), Color(0xFF6FB1FC)], // 6: Electric Blue
    [Color(0xFF43E97B), Color(0xFF38F9D7)], // 7: Mint
    [Color(0xFFF093FB), Color(0xFFF5576C)], // 8: Pink Flamingo
  ];

  List<Color> _currentGradient() {
    final idx = _selectedMainCategory == 0
        ? _selectedLevel
        : 4 + _selectedLevel;
    return _levelGradients[idx % _levelGradients.length];
  }

  Widget _buildMainCategoryTabs() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_mainCategories.length, (i) {
          final active = _selectedMainCategory == i;
          final color = _mainCategories[i]['color'] as Color;
          final gradientColors = i == 0
              ? [const Color(0xFF4FACFE), const Color(0xFF00F2FE)]
              : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)];
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchMainCategory(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: active
                      ? LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: active ? null : color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: active
                      ? null
                      : Border.all(color: color.withOpacity(0.2), width: 1.5),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: gradientColors.last.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ]
                      : [],
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_mainCategories[i]['icon'],
                              color: active ? Colors.white : color, size: 20),
                          const SizedBox(width: 8),
                          Text(_getMainCategoryTitle(i),
                              style: TextStyle(
                                  color: active ? Colors.white : color,
                                  fontWeight: active
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 14)),
                        ]),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLevelTabs() {
    final icons = _categoryLevelIcons[_selectedMainCategory];
    final titlesCount = _categoryLevelIcons[_selectedMainCategory].length;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: List.generate(titlesCount, (i) {
            final active = _selectedLevel == i;
            final badgeIdx = _selectedMainCategory == 0 ? i : 4 + i;
            final earned =
                badgeIdx < _badges.length && _badges[badgeIdx].isEarned;
            final gradientColors = _levelGradients[
                (_selectedMainCategory == 0 ? i : 4 + i) % _levelGradients.length];
            return GestureDetector(
              onTap: () {
                if (earned && !active) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.alreadyDone),
                    backgroundColor: _currentMainColor,
                    duration: const Duration(seconds: 1),
                  ));
                  return;
                }
                _switchLevel(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  gradient: active
                      ? LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: active
                      ? null
                      : (earned
                          ? const Color(0xFFE8F5E9)
                          : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(25),
                  border: earned && !active
                      ? Border.all(color: Colors.green.withOpacity(0.4), width: 1.5)
                      : null,
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: gradientColors.last.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        earned && !active
                            ? LucideIcons.circle_check
                            : icons[i],
                        size: 16,
                        color: active
                            ? Colors.white
                            : (earned
                                ? Colors.green
                                : Colors.grey.shade600)),
                    const SizedBox(width: 7),
                    Text(
                      _getLevelTitle(_selectedMainCategory, i),
                      style: TextStyle(
                        color: active
                            ? Colors.white
                            : (earned ? Colors.green.shade800 : Colors.grey.shade700),
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final total = _currentGames.length;
    final progress = total == 0 ? 0.0 : (_currentGameIndex + 1) / total;
    final activeGradient = _currentGradient();
    final icons = _categoryLevelIcons[_selectedMainCategory];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: activeGradient),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icons[_selectedLevel],
                      color: Colors.white, size: 14),
                ),
                const SizedBox(width: 8),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getLevelTitle(_selectedMainCategory, _selectedLevel),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                          _getLevelSubTitle(
                              _selectedMainCategory, _selectedLevel),
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade600)),
                    ]),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${_currentGameIndex + 1} / $total',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.02, 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: activeGradient),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: activeGradient.last.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildFeedbackBanner() {
    if (_feedbackMessage.isEmpty) return const SizedBox(height: 16);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _feedbackColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _feedbackColor.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(_feedbackMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildCorrectOverlay() {
    return IgnorePointer(
      child: Center(
        child: ScaleTransition(
          scale: _starBurstAnim,
          child: Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26A96C), Color(0xFF11998E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 35,
                    spreadRadius: 12)
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(LucideIcons.circle_check, color: Colors.white, size: 58),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.straightOrCorrect,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  '🎉 ⭐ ✨',
                  style: TextStyle(fontSize: 22),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  GAME CONTENT ROUTER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildGameContent() {
    Widget gameWidget;
    if (_selectedMainCategory == 0) {
      switch (_selectedLevel) {
        case 0:
          gameWidget = _buildSariliGame1();
          break;
        case 1:
          gameWidget = _buildSariliGame2();
          break;
        case 2:
          gameWidget = _buildSariliGame3();
          break;
        case 3:
          gameWidget = _buildSariliGame4();
          break;
        default:
          gameWidget = _buildSariliGame1();
      }
    } else {
      switch (_selectedLevel) {
        case 0:
          gameWidget = _buildFamilyMembersGame();
          break;
        case 1:
          gameWidget = _buildFamilyRolesGame();
          break;
        case 2:
          gameWidget = _buildFamilyActivitiesGame();
          break;
        case 3:
          gameWidget = _buildFamilyTreeGame();
          break;
        case 4:
          gameWidget = _buildMyHomeGame();
          break;
        default:
          gameWidget = _buildFamilyMembersGame();
      }
    }

    final userProvider = Provider.of<UserProvider>(context);
    final isCompleted = userProvider.isPamilyaGameCompleted(
        _selectedMainCategory, _selectedLevel, _currentGameIndex);

    if (isCompleted && !_showCorrectOverlay) {
      return Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: IgnorePointer(child: gameWidget),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green, width: 3),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.circle_check,
                      color: Colors.green, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.finishedAlready,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return gameWidget;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SHARED CARD WRAPPER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _gameCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  /// Consistent question header used across every Pamilya game.
  Widget _questionBox(String question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _currentMainColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        question,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _currentMainColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  Widget _choiceTile({
    required String label,
    required bool isSelected,
    required bool? isCorrect,
    required VoidCallback onTap,
    double minHeight = 54,
  }) {
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isSelected && isCorrect == true) {
      borderColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade800;
    } else if (isSelected && isCorrect == false) {
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red.shade800;
    } else {
      borderColor = Colors.grey.shade300;
      bgColor = Colors.white;
      textColor = Colors.grey.shade800;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(children: [
          if (isSelected && isCorrect == true)
            const Icon(LucideIcons.circle_check, color: Colors.green, size: 20),
          if (isSelected && isCorrect == false)
            const Icon(LucideIcons.circle_x, color: Colors.red, size: 20),
          if (!isSelected || isCorrect == null) const SizedBox(width: 4),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal))),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SARILI GAME 1: All About Me
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSariliGame1() {
    final game = _sariliLevel1Games[_currentGameIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: _currentMainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16)),
              child: Text(game['icon'], style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(_getGameString(game, 'question'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 20),
          if (game['type'] == 'text_input') _buildTextInput(game),
          if (game['type'] == 'age_input') _buildAgeInput(game),
          if (game['type'] == 'choice' && game['id'] == 'about_gender')
            _buildGenderChoice(game),
          if (game['type'] == 'info') _buildInfoCard(game),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _currentMainColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(LucideIcons.lightbulb, color: _currentMainColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(_getGameString(game, 'description'),
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700))),
            ]),
          ),
        ])),
      ]),
    );
  }

  Widget _buildCharacterWidget() {
    return AnimatedBuilder(
      animation: _characterAnim,
      builder: (_, __) => Transform.scale(
        scale: _characterAnim.value,
        child: SizedBox(
          height: 80,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_characterHappy ? '😊' : '🙂',
                style: const TextStyle(fontSize: 52)),
            const SizedBox(width: 12),
            if (_characterHappy)
              Text(AppLocalizations.of(context)!.straightOrCorrect,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green))
            else
              Text(_currentMainTitle,
                  style: TextStyle(
                      fontSize: 15,
                      color: _currentMainColor,
                      fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextInput(Map<String, dynamic> game) {
    final ctrl =
        game['id'] == 'about_home' ? _placeController : _nameController;
    return Column(children: [
      TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: _getGameString(game, 'hint'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      const SizedBox(height: 14),
      ElevatedButton(
        onPressed: () => _handleTextSubmit(ctrl.text),
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentMainColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(AppLocalizations.of(context)!.save,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  Widget _buildAgeInput(Map<String, dynamic> game) {
    return Column(children: [
      TextField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: _getGameString(game, 'hint'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      const SizedBox(height: 14),
      ElevatedButton(
        onPressed: () => _handleTextSubmit(_ageController.text),
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentMainColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(AppLocalizations.of(context)!.save,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  Widget _buildGenderChoice(Map<String, dynamic> game) {
    return Row(
      children: List.generate(game['options'].length, (i) {
        final sel = _selectedGender == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => _handleGenderSelection(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: sel ? _currentMainColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel ? _currentMainColor : Colors.grey.shade300,
                    width: 2),
                boxShadow: sel
                    ? [
                        BoxShadow(
                            color: _currentMainColor.withOpacity(0.3),
                            blurRadius: 10)
                      ]
                    : [],
              ),
              child: Column(children: [
                Text(i == 0 ? '👧' : '👦',
                    style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 6),
                Text(
                    i == 0
                        ? AppLocalizations.of(context)!.girl
                        : AppLocalizations.of(context)!.boy,
                    style: TextStyle(
                        color: sel ? Colors.white : Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ]),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.25)),
      ),
      child: Column(children: [
        Text(game['info'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(game['example'],
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _onCorrect,
          style: ElevatedButton.styleFrom(
              backgroundColor: _currentMainColor,
              foregroundColor: Colors.white),
          child: Text(AppLocalizations.of(context)!.iKnowIt,
              style: const TextStyle(fontSize: 15)),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SARILI GAME 2: Emotions
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSariliGame2() {
    final game = _sariliLevel2Games[_currentGameIndex];
    final choices = game['choices'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          _questionBox(game['question']),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            final sel = _selectedEmotionAnswer == i;
            final correct = i == game['correct'];
            return _choiceTile(
              label: choices[i],
              isSelected: sel,
              isCorrect: sel ? correct : null,
              onTap: () => _handleEmotionAnswer(
                  i, game['correct'], game['explanation'], game['tip']),
            );
          }),
          if (_showEmotionExplanation)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14)),
              child: Text(game['explanation'],
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center),
            ),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SARILI GAME 3: Daily Routines
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSariliGame3() {
    final game = _sariliLevel3Games[_currentGameIndex];
    final choices = game['choices'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          _questionBox(game['question']),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            final sel = _selectedRoutineAnswer == i;
            final correct = i == game['correct'];
            return _choiceTile(
              label: choices[i],
              isSelected: sel,
              isCorrect: sel ? correct : null,
              onTap: () => _handleRoutineAnswer(
                  i, game['correct'], game['explanation'], game['tip']),
            );
          }),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SARILI GAME 4: Preferences
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSariliGame4() {
    final game = _sariliLevel4Games[_currentGameIndex];
    final options = game['options'] as List;
    final emojis = game['emojis'] as List;
    final type = game['id'].toString().replaceFirst('preference_', '');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          _questionBox(game['question']),
          const SizedBox(height: 6),
          Text(game['description'],
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: List.generate(options.length, (i) {
              bool sel = false;
              if (type == 'food') {
                sel = _selectedFoodIndex == i;
              } else if (type == 'color') {
                sel = _selectedColorIndex == i;
              } else if (type == 'game') {
                sel = _selectedGameIndex == i;
              } else if (type == 'animal') {
                sel = _selectedAnimalIndex == i;
              }

              return GestureDetector(
                onTap: () => _handlePreferenceSelection(i, type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel ? _currentMainColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? _currentMainColor : Colors.grey.shade300,
                        width: 2),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: _currentMainColor.withOpacity(0.3),
                                blurRadius: 10)
                          ]
                        : [],
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emojis[i], style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 6),
                        Text(options[i],
                            style: TextStyle(
                                color:
                                    sel ? Colors.white : Colors.grey.shade700,
                                fontWeight:
                                    sel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12),
                            textAlign: TextAlign.center),
                      ]),
                ),
              );
            }),
          ),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAMILYA GAME 1: Family Members
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFamilyMembersGame() {
    final game = _pamilyaLevel1Games[_currentGameIndex];
    final choices = game['choices'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          _questionBox(game['question']),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            final sel = _selectedFamilyAnswer == i;
            final correct = i == game['correct'];
            return _choiceTile(
              label: choices[i],
              isSelected: sel,
              isCorrect: sel ? correct : null,
              onTap: () => _handleFamilyAnswer(i, game['correct'], game),
            );
          }),
          if (_showingFamilyInfo && _selectedFamilyMember != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentMainColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _currentMainColor.withOpacity(0.4)),
              ),
              child: Column(children: [
                Text(game['emoji'], style: const TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                Text(
                    AppLocalizations.of(context)!
                        .familyRoleSentence(game['member'], game['roles']),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('📖 ${game['note']}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center),
                ),
              ]),
            ),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAMILYA GAME 2: Family Roles
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFamilyRolesGame() {
    final game = _pamilyaLevel2Games[_currentGameIndex];
    final choices = game['choices'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          _questionBox(game['question']),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            final sel = _selectedRoleAnswer == i;
            final correct = i == game['correct'];
            return _choiceTile(
              label: choices[i],
              isSelected: sel,
              isCorrect: sel ? correct : null,
              onTap: () =>
                  _handleRoleAnswer(i, game['correct'], game['explanation']),
            );
          }),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAMILYA GAME 3: Family Activities
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFamilyActivitiesGame() {
    final game = _pamilyaLevel3Games[_currentGameIndex];
    final choices = game['choices'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          _questionBox(game['question']),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            final sel = _selectedActivityAnswer == i;
            final correct = i == game['correct'];
            return _choiceTile(
              label: choices[i],
              isSelected: sel,
              isCorrect: sel ? correct : null,
              onTap: () => _handleActivityAnswer(
                  i, game['correct'], game['explanation']),
            );
          }),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAMILYA GAME 4: Family Tree (Interactive)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFamilyTreeGame() {
    final generations = _familyTreeData['generations'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _gameCard(
            child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(LucideIcons.workflow,
                color: _currentMainColor, size: 24),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.familyTreeTitle,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _currentMainColor)),
          ]),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context)!.familyTreeDesc,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),

          // Tree visualization
          ...List.generate(generations.length, (gi) {
            final gen = generations[gi];
            final members = gen['members'] as List;
            final genColor = gen['color'] as Color;

            return Column(children: [
              // Generation connector line
              if (gi > 0)
                Container(width: 2, height: 24, color: Colors.grey.shade300),

              // Generation container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: genColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: genColor.withOpacity(0.3), width: 1.5),
                ),
                child: Column(children: [
                  Text(gen['title'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: genColor)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: members
                        .map((m) => GestureDetector(
                              onTap: () => _showFeedback(
                                  '${m['emoji']} ${m['relation']}', genColor),
                              child: Column(children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: genColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: genColor.withOpacity(0.5),
                                        width: 2),
                                  ),
                                  child: Center(
                                      child: Text(m['emoji'],
                                          style:
                                              const TextStyle(fontSize: 26))),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 72,
                                  child: Text(m['relation'],
                                      style: const TextStyle(fontSize: 9),
                                      textAlign: TextAlign.center),
                                ),
                              ]),
                            ))
                        .toList(),
                  ),
                ]),
              ),
              const SizedBox(height: 4),
            ]);
          }),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Text(AppLocalizations.of(context)!.familyTreeTapHint,
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleFamilyTreeComplete,
              icon: const Icon(LucideIcons.circle_check, color: Colors.white),
              label: Text(AppLocalizations.of(context)!.iLearnedFamilyTree,
                  style: const TextStyle(fontSize: 15, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentMainColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAMILYA GAME 5: My Home (Interactive Room Tap)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMyHomeGame() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _gameCard(
            child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(LucideIcons.house, color: _currentMainColor, size: 26),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.ourHomeTitle,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _currentMainColor)),
          ]),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context)!.tapEachRoomPrompt,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),

          // Simple house illustration
          _buildHouseIllustration(),

          const SizedBox(height: 20),

          // Room tiles
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: List.generate(_homeRooms.length, (i) {
              final room = _homeRooms[i];
              final visited =
                  _selectedRoomIndex != null && _selectedRoomIndex! >= i;
              final roomColor = room['color'] as Color;
              return GestureDetector(
                onTap: () => _handleRoomTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: visited ? roomColor.withOpacity(0.15) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: visited ? roomColor : Colors.grey.shade300,
                        width: 2),
                    boxShadow: visited
                        ? [
                            BoxShadow(
                                color: roomColor.withOpacity(0.2),
                                blurRadius: 8)
                          ]
                        : [],
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(room['emoji'],
                            style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 6),
                        Text(room['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: visited
                                    ? roomColor
                                    : Colors.grey.shade700)),
                        if (visited)
                          const Icon(LucideIcons.circle_check,
                              color: Colors.green, size: 16),
                      ]),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          if (_selectedRoomIndex != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (_homeRooms[_selectedRoomIndex!]['color'] as Color)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '🏠 ${_homeRooms[_selectedRoomIndex!]['name']}: ${_homeRooms[_selectedRoomIndex!]['activity']}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 16),

          if (!_myHomeCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleMyHomeComplete,
                icon: const Icon(LucideIcons.house, color: Colors.white),
                label: Text(AppLocalizations.of(context)!.thatIsOurHome,
                    style: const TextStyle(fontSize: 15, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentMainColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
        ])),
      ]),
    );
  }

  Widget _buildHouseIllustration() {
    return SizedBox(
      height: 130,
      child: Stack(alignment: Alignment.bottomCenter, children: [
        // House body
        Positioned(
          bottom: 0,
          child: Container(
            width: 180,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.brown.shade200,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Windows
                  Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: Colors.lightBlue.shade200,
                          borderRadius: BorderRadius.circular(4))),
                  // Door
                  Container(
                      width: 32,
                      height: 52,
                      margin: const EdgeInsets.only(top: 38),
                      decoration: BoxDecoration(
                          color: Colors.brown.shade600,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)))),
                  Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: Colors.lightBlue.shade200,
                          borderRadius: BorderRadius.circular(4))),
                ]),
          ),
        ),
        // Roof
        Positioned(
          top: 0,
          child: CustomPaint(
            painter: _TrianglePainter(Colors.brown.shade400),
            child: const SizedBox(width: 200, height: 55),
          ),
        ),
        // Chimney
        Positioned(
          top: 6,
          right: 52,
          child: Container(
              width: 16,
              height: 28,
              decoration: BoxDecoration(
                  color: Colors.brown.shade600,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)))),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TRIANGLE PAINTER (house roof)
// ─────────────────────────────────────────────────────────────────────────────
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Keep old TrianglePainter name for backward compatibility
class TrianglePainter extends _TrianglePainter {
  TrianglePainter(super.color);
}
