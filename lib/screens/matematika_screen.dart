import 'package:e_tarabay/l10n/app_localizations.dart';
// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../main.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/language_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/success_modal.dart';
import '../widgets/custom_back_button.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

// ─── CustomPainter: draws animated lines between matched nodes ───────────────
class _Game3LinePainter extends CustomPainter {
  final List<Offset> leftDots;
  final List<Offset> rightDots;
  final Map<int, int> matches;
  final Map<int, bool> wrongFlash;

  _Game3LinePainter({
    required this.leftDots,
    required this.rightDots,
    required this.matches,
    required this.wrongFlash,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final entry in matches.entries) {
      final leftIdx = entry.key;
      final rightIdx = entry.value;

      if (leftIdx >= leftDots.length || rightIdx >= rightDots.length) continue;

      final isWrong = wrongFlash[leftIdx] == true;
      final color = isWrong ? Colors.red : Colors.green;

      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final p1 = leftDots[leftIdx];
      final p2 = rightDots[rightIdx];
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2 - 10);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, p2.dx, p2.dy);
      canvas.drawPath(path, linePaint);

      canvas.drawCircle(p1, 5.5, dotPaint);
      canvas.drawCircle(p2, 5.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_Game3LinePainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────

class MatematikaScreen extends StatefulWidget {
  const MatematikaScreen({super.key});

  @override
  State<MatematikaScreen> createState() => _MatematikaScreenState();
}

class _MatematikaScreenState extends State<MatematikaScreen>
    with TickerProviderStateMixin {
  int _selectedLevel = 0;
  int _currentGameIndex = 0;

  int _totalScore = 0;
  int _totalStars = 0;
  int _levelStars = 0;
  int _levelScore = 0;
  int _wrongAttempts = 0;

  int _secondsLeft = 30;
  Timer? _timer;

  String _feedbackMessage = '';
  Color _feedbackColor = Colors.transparent;
  bool _showCorrectOverlay = false;

  int? _selectedAnswer;

  bool _dropCorrect = false;
  bool _dropWrong = false;

  // Game 3 – node matching state
  int? _selectedLeftIndex;
  final Map<int, int> _lineMatches = {};
  List<int> _shuffledRightIndices = [];

  // Game 3 – new node/line fields
  final List<GlobalKey> _leftNodeKeys = [];
  final List<GlobalKey> _rightNodeKeys = [];
  final GlobalKey _game3StackKey = GlobalKey();
  final Map<int, bool> _wrongFlash = {};
  bool _showWrongCenter = false;
  bool _showCelebration = false;
  bool _showWrongOverlay = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  final Set<int> _poppedBalloons = {};
  final Set<int> _wrongBalloons = {};

  String? _selectedSide;

  List<int> _puzzleNumbers = [];
  bool _isPuzzleSolved = false;
  int? _puzzleSelectedIndex;

  int _dailyStreak = 0;
  int _consecutiveCorrectStreak = 0;

  late AnimationController _starBurstController;
  late AnimationController _timerPulseController;
  late Animation<double> _starBurstAnim;
  late Animation<double> _timerPulseAnim;

  // ─── Game data ──────────────────────────────────────────────────────────────

  final List<Map<String, dynamic>> _game1Levels = const [
    {
      'question_en': 'How many apples?',
      'item_name_en': 'apples',
      'item_name_il': 'mansanas',
      'item_name_tl': 'mansanas',
      'objects': ['🍎', '🍎', '🍎'],
      'answers': [1, 2, 3],
      'correct': 3,
    },
    {
      'question_en': 'How many bananas?',
      'item_name_en': 'bananas',
      'item_name_il': 'saging',
      'item_name_tl': 'saging',
      'objects': ['🍌', '🍌'],
      'answers': [1, 2, 3],
      'correct': 2,
    },
    {
      'question_en': 'How many dogs?',
      'item_name_en': 'dogs',
      'item_name_il': 'aso',
      'item_name_tl': 'aso',
      'objects': ['🐶'],
      'answers': [1, 2, 3],
      'correct': 1,
    },
    {
      'question_en': 'How many fish?',
      'item_name_en': 'fish',
      'item_name_il': 'isda',
      'item_name_tl': 'isda',
      'objects': ['🐟', '🐟', '🐟', '🐟'],
      'answers': [2, 3, 4],
      'correct': 4,
    },
    {
      'question_en': 'How many birds?',
      'item_name_en': 'birds',
      'item_name_il': 'billit',
      'item_name_tl': 'ibon',
      'objects': ['🐦', '🐦', '🐦', '🐦', '🐦'],
      'answers': [3, 4, 5],
      'correct': 5,
    },
  ];

  final List<Map<String, dynamic>> _game2Levels = const [
    {
      'objects': ['🍎', '🍎', '🍎'],
      'correct': 3,
      'choices': [1, 2, 3]
    },
    {
      'objects': ['🍌', '🍌'],
      'correct': 2,
      'choices': [1, 2, 3]
    },
    {
      'objects': ['🐶'],
      'correct': 1,
      'choices': [1, 2, 3]
    },
    {
      'objects': ['🐟', '🐟', '🐟', '🐟'],
      'correct': 4,
      'choices': [2, 3, 4]
    },
    {
      'objects': ['🐦', '🐦', '🐦', '🐦', '🐦'],
      'correct': 5,
      'choices': [3, 4, 5]
    },
  ];

  final List<Map<String, dynamic>> _game3Levels = const [
    {
      'target_cat_en': 'fruit',
      'target_cat_il': 'prutas',
      'target_cat_tl': 'prutas',
      'pairs': [
        {
          'objects': ['🍎'],
          'count': 1
        },
        {
          'objects': ['🍎', '🍎'],
          'count': 2
        },
        {
          'objects': ['🍎', '🍎', '🍎'],
          'count': 3
        },
      ],
    },
    {
      'target_cat_en': 'animal',
      'target_cat_il': 'ayup',
      'target_cat_tl': 'hayop',
      'pairs': [
        {
          'objects': ['🐶'],
          'count': 1
        },
        {
          'objects': ['🐱', '🐱'],
          'count': 2
        },
        {
          'objects': ['🐭', '🐭', '🐭'],
          'count': 3
        },
      ],
    },
    {
      'target_cat_en': 'fruit',
      'target_cat_il': 'prutas',
      'target_cat_tl': 'prutas',
      'pairs': [
        {
          'objects': ['🍌'],
          'count': 1
        },
        {
          'objects': ['🍇', '🍇'],
          'count': 2
        },
        {
          'objects': ['🍒', '🍒', '🍒'],
          'count': 3
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _game4Levels = const [
    {
      'target': 3,
      'balloons': [1, 3, 2, 1, 3, 2, 3]
    },
    {
      'target': 2,
      'balloons': [2, 1, 3, 2, 1, 2, 3]
    },
    {
      'target': 1,
      'balloons': [1, 2, 3, 1, 2, 1, 3]
    },
    {
      'target': 4,
      'balloons': [2, 4, 1, 3, 4, 2, 4]
    },
    {
      'target': 5,
      'balloons': [3, 5, 2, 4, 5, 1, 5]
    },
  ];

  final List<Map<String, dynamic>> _game5Levels = const [
    {
      'type': 'more',
      'leftObjects': ['🍎', '🍎', '🍎'],
      'leftCount': 3,
      'rightObjects': ['🍎'],
      'rightCount': 1,
      'correct': 'left',
    },
    {
      'type': 'less',
      'leftObjects': ['🍌'],
      'leftCount': 1,
      'rightObjects': ['🍌', '🍌'],
      'rightCount': 2,
      'correct': 'left',
    },
    {
      'type': 'more',
      'leftObjects': ['🐶', '🐶'],
      'leftCount': 2,
      'rightObjects': ['🐶', '🐶', '🐶'],
      'rightCount': 3,
      'correct': 'right',
    },
    {
      'type': 'equal',
      'leftObjects': ['🍎', '🍎'],
      'leftCount': 2,
      'rightObjects': ['🍎', '🍎'],
      'rightCount': 2,
      'correct': 'equal',
    },
    {
      'type': 'more',
      'leftObjects': ['🐟', '🐟', '🐟', '🐟'],
      'leftCount': 4,
      'rightObjects': ['🐟', '🐟'],
      'rightCount': 2,
      'correct': 'left',
    },
  ];

  final List<Map<String, dynamic>> _game6Levels = const [
    {
      'sequence': '1 → 2 → 3',
      'scrambled': [3, 1, 2],
      'correct': [1, 2, 3]
    },
    {
      'sequence': '2 → 4 → 6',
      'scrambled': [6, 2, 4],
      'correct': [2, 4, 6]
    },
    {
      'sequence': '1 → 3 → 5',
      'scrambled': [5, 1, 3],
      'correct': [1, 3, 5]
    },
  ];

  final List<Map<String, dynamic>> _game7Levels = const [
    {
      'sequence': [1, 2, null, 4, 5],
      'answers': [2, 3, 4],
      'correct': 3
    },
    {
      'sequence': [2, 3, 4, null, 6],
      'answers': [4, 5, 6],
      'correct': 5
    },
    {
      'sequence': [1, null, 3, 4, 5],
      'answers': [1, 2, 3],
      'correct': 2
    },
    {
      'sequence': [null, 2, 3, 4, 5],
      'answers': [1, 2, 3],
      'correct': 1
    },
    {
      'sequence': [3, 4, 5, null, 7],
      'answers': [5, 6, 7],
      'correct': 6
    },
  ];

  final List<String> _levelTitles = const [
    'Bilangen dagiti Banag',
    'I-drag ti Numero',
    'Iparis babaen ti Linya',
    'Pasii ti Balloon',
    'Adu wenno Bassit?',
    'Puzzle ti Numero',
    'Pagsasaruno dagiti Numero',
  ];

  final List<IconData> _levelIcons = const [
    Icons.looks_one_rounded,
    LucideIcons.grip_vertical,
    LucideIcons.arrow_left_right,
    LucideIcons.party_popper,
    LucideIcons.scale,
    LucideIcons.puzzle,
    LucideIcons.list_ordered,
  ];

  static const List<Color> _balloonColors = [
    Color(0xFFEF5350),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
    Color(0xFFEC407A),
    Color(0xFF26C6DA),
  ];

  // ─── Computed getters ────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _currentGames {
    switch (_selectedLevel) {
      case 0:
        return _game1Levels;
      case 1:
        return _game2Levels;
      case 2:
        return _game3Levels;
      case 3:
        return _game4Levels;
      case 4:
        return _game5Levels;
      case 5:
        return _game6Levels;
      case 6:
        return _game7Levels;
      default:
        return _game1Levels;
    }
  }

  Map<String, dynamic> get _currentGame {
    final games = _currentGames;
    if (games.isEmpty) return {};
    return games[_currentGameIndex % games.length];
  }

  int get _starsFromWrong {
    if (_wrongAttempts == 0) return 3;
    if (_wrongAttempts == 1) return 2;
    return 1;
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    AudioManager.instance.playModuleMusic(ModuleMusic.matematika);

    _starBurstController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _timerPulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _starBurstAnim = CurvedAnimation(
      parent: _starBurstController,
      curve: Curves.elasticOut,
    );
    _timerPulseAnim =
        Tween<double>(begin: 1.0, end: 1.18).animate(_timerPulseController);
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _dailyStreak = 3;
    _initSmartResume();
    _startTimer();
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

      // 1. Find the first uncompleted LEVEL
      int firstUncompletedLevel = 0;
      for (int l = 0; l < _levelTitles.length; l++) {
        if (!userProvider.isMatematikaLevelCompleted(l)) {
          firstUncompletedLevel = l;
          break;
        }
        if (l == _levelTitles.length - 1) {
          firstUncompletedLevel = _levelTitles.length - 1;
        }
      }

      if (mounted) {
        setState(() {
          _selectedLevel = firstUncompletedLevel;
          _resetLevelState();
        });
      }
    } catch (e) {
      debugPrint('Smart Resume failed: $e');
      _resetLevelState();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _starBurstController.dispose();
    _timerPulseController.dispose();
    _shakeController.dispose();
    AudioManager.instance.resumeHomeMusic();
    super.dispose();
  }

  // ─── Timer ───────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isMatematikaGameCompleted(
          _selectedLevel, _currentGameIndex)) {
        return;
      }
    } catch (_) {}

    int calculatedTime = 15 + (_consecutiveCorrectStreak * 3);
    if (calculatedTime > 30) calculatedTime = 30;
    _secondsLeft = calculatedTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _onTimeout();
      }
    });
  }

  void _stopTimer() => _timer?.cancel();

  void _onTimeout() {
    _showFeedback('⏰ ${AppLocalizations.of(context)!.timeOut}', Colors.orange);
    setState(() {
      _currentGameIndex = 0;
      _levelStars = 0;
      _levelScore = 0;
      _wrongAttempts = 0;
      _resetQuestionState();
    });
    _startTimer();
  }

  // ─── State reset ─────────────────────────────────────────────────────────────

  void _resetLevelState() {
    // Determine the first uncompleted game index for the current level
    int firstUncompleted = 0;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final total = _currentGames.length;
      for (int i = 0; i < total; i++) {
        if (!userProvider.isMatematikaGameCompleted(_selectedLevel, i)) {
          firstUncompleted = i;
          break;
        }
        // If all are completed, we go to the last one or show a completion state
        if (i == total - 1) firstUncompleted = total - 1;
      }
    } catch (_) {
      // Fallback if Provider is not ready
      firstUncompleted = 0;
    }

    _currentGameIndex = firstUncompleted;
    _levelStars = 0;
    _levelScore = 0;
    _wrongAttempts = 0;
    _resetQuestionState();
  }

  void _resetQuestionState() {
    _selectedAnswer = null;
    _dropCorrect = false;
    _dropWrong = false;
    _selectedSide = null;
    _lineMatches.clear();
    _selectedLeftIndex = null;
    _poppedBalloons.clear();
    _wrongBalloons.clear();
    _showCorrectOverlay = false;

    // Game 3 extra reset
    _wrongFlash.clear();
    _showWrongCenter = false;
    _showCelebration = false;
    _showWrongOverlay = false;

    if (_selectedLevel == 2) _initLineMatching();
    if (_selectedLevel == 5) _initPuzzle();
  }

  // ─── Game 3: node matching init ──────────────────────────────────────────────

  void _initLineMatching() {
    final count = (_currentGame['pairs'] as List<dynamic>).length;
    _shuffledRightIndices = List<int>.generate(count, (i) => i)
      ..shuffle(Random());
    _lineMatches.clear();
    _selectedLeftIndex = null;
    _wrongFlash.clear();
    _showWrongCenter = false;
    _showCelebration = false;

    _leftNodeKeys
      ..clear()
      ..addAll(List.generate(count, (_) => GlobalKey()));
    _rightNodeKeys
      ..clear()
      ..addAll(List.generate(count, (_) => GlobalKey()));
  }

  void _initPuzzle() {
    _puzzleNumbers = List<int>.from(_currentGame['scrambled'] as List<dynamic>);
    _isPuzzleSolved = false;
    _puzzleSelectedIndex = null;
  }

  // ─── Level switch ────────────────────────────────────────────────────────────

  void _switchLevel(int level) {
    _stopTimer();
    setState(() {
      _selectedLevel = level;
      _resetLevelState();
    });
    _startTimer();
  }

  String _getLevelTitleLocalized(int index) {
    switch (index) {
      case 0:
        return AppLocalizations.of(context)!.counting;
      case 1:
        return AppLocalizations.of(context)!.dragNumber;
      case 2:
        return AppLocalizations.of(context)!.lineMatch;
      case 3:
        return AppLocalizations.of(context)!.popBalloon;
      case 4:
        return AppLocalizations.of(context)!.moreOrLess;
      case 5:
        return AppLocalizations.of(context)!.numberPuzzle;
      case 6:
        return AppLocalizations.of(context)!.numberSequence;
      default:
        return '';
    }
  }

  String _getHowManyFromMap(Map<String, dynamic> game) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final key = lang.currentLanguage == 'il'
        ? 'item_name_il'
        : (lang.currentLanguage == 'tl' ? 'item_name_tl' : 'item_name_en');
    return AppLocalizations.of(context)!.howMany(game[key] ?? 'items');
  }

  String _getMatchFromMap(Map<String, dynamic> game) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final key = lang.currentLanguage == 'il'
        ? 'target_cat_il'
        : (lang.currentLanguage == 'tl' ? 'target_cat_tl' : 'target_cat_en');
    return AppLocalizations.of(context)!.matchWithNumber(game[key] ?? 'items');
  }

  void _advanceOrComplete() {
    final total = _currentGames.length;
    if (_currentGameIndex < total - 1) {
      setState(() {
        _currentGameIndex++;
        _wrongAttempts = 0;
        _resetQuestionState();
      });
      _startTimer();
    } else {
      _showLevelComplete();
    }
  }

  // ─── Correct / wrong ─────────────────────────────────────────────────────────

  void _onCorrect() {
    if (_showCorrectOverlay) return;
    HapticFeedback.heavyImpact();
    _stopTimer();

    final earned = _starsFromWrong;
    setState(() {
      if (earned == 3) {
        _consecutiveCorrectStreak++;
      } else {
        _consecutiveCorrectStreak = 0;
      }
      _totalScore += 10 * earned;
      _totalStars += earned;
      _levelStars += earned;
      _levelScore += 10 * earned;
      _showCorrectOverlay = true;
    });

    _starBurstController.forward(from: 0);
    _showFeedback(
      '${List.filled(earned, '⭐').join()} ${AppLocalizations.of(context)!.goodJobPoints(10 * earned)}',
      const Color(0xFF2E7D32),
    );

    _saveQuestionProgress(earned);

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _showCorrectOverlay = false);
      _advanceOrComplete();
    });
  }

  void _onWrong() {
    HapticFeedback.vibrate();
    _shakeController.forward(from: 0);
    _stopTimer();

    setState(() {
      _wrongAttempts++;
      _consecutiveCorrectStreak = 0;
      _showWrongOverlay = true;
    });

    _showFeedback(AppLocalizations.of(context)!.incorrectAnswer, Colors.red);
    // Even if it's wrong, we call _saveQuestionProgress with 0 stars
    // so it counts as "completed" in the progress logic.
    _saveQuestionProgress(0);

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _showWrongOverlay = false;
        _selectedAnswer = null;
        _dropCorrect = false;
        _dropWrong = false;
        _selectedSide = null;
      });
      _advanceOrComplete();
    });
  }

  void _saveQuestionProgress(int earned) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateMatematikaProgress(_dailyStreak);
    userProvider.updateMatematikaGameProgress(
        _selectedLevel, _currentGameIndex, true);

    // ── Also persist directly so ForParentsScreen can read progress ──────
    _persistMatematikaProgress(earned);
  }

  Future<void> _persistMatematikaProgress(int earned) async {
    final prefs = await SharedPreferences.getInstance();
    final gameKey = 'mat_level_${_selectedLevel}_game_$_currentGameIndex';
    final alreadyDone = prefs.getBool(gameKey) ?? false;

    // Mark this specific game as done
    await prefs.setBool(gameKey, true);

    // Only accumulate total score and stars on first completion
    if (!alreadyDone) {
      final prevScore = prefs.getInt('mat_total_score') ?? 0;
      final prevStars = prefs.getInt('mat_total_stars') ?? 0;
      await prefs.setInt('mat_total_score', prevScore + (10 * earned));
      await prefs.setInt('mat_total_stars', prevStars + earned);
    }
  }

  // ─── Game handlers ───────────────────────────────────────────────────────────

  void _checkMCQ(int correct) {
    if (_selectedAnswer == null) {
      _showFeedback(AppLocalizations.of(context)!.chooseFirst, Colors.orange);
      return;
    }
    if (_selectedAnswer == correct) {
      _onCorrect();
    } else {
      _onWrong();
    }
  }

  void _handleDrop(int droppedValue, int correct) {
    if (droppedValue == correct) {
      setState(() => _dropCorrect = true);
      Future.delayed(const Duration(milliseconds: 350), _onCorrect);
    } else {
      setState(() => _dropWrong = true);
      _onWrong();
    }
  }

  // ── Game 3: node tap handlers ─────────────────────────────────────────────

  void _handleLeftTap(int index) {
    if (_lineMatches.containsKey(index)) return;
    setState(() => _selectedLeftIndex = index);
  }

  void _handleRightTap(int shuffledIndex) {
    if (_selectedLeftIndex == null) {
      _showFeedback(
          AppLocalizations.of(context)!.chooseLeftFirst, Colors.orange);
      return;
    }
    if (_lineMatches.containsValue(shuffledIndex)) return;

    final pairs = _currentGame['pairs'] as List<dynamic>;
    final leftIdx = _selectedLeftIndex!;
    final origRight = _shuffledRightIndices[shuffledIndex];
    final correctCnt = pairs[leftIdx]['count'] as int;
    final isCorrect = correctCnt == origRight + 1;

    if (isCorrect) {
      HapticFeedback.lightImpact();
      setState(() {
        _lineMatches[leftIdx] = shuffledIndex;
        _selectedLeftIndex = null;
      });

      if (_lineMatches.length == pairs.length) {
        _starBurstController.forward(from: 0);
        setState(() => _showCelebration = true);
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (!mounted) return;
          setState(() => _showCelebration = false);
          _onCorrect();
        });
      }
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _lineMatches[leftIdx] = shuffledIndex;
        _wrongFlash[leftIdx] = true;
        _selectedLeftIndex = null;
        _showWrongCenter = true;
      });
      _shakeController.forward(from: 0);

      Future.delayed(const Duration(milliseconds: 750), () {
        if (!mounted) return;
        setState(() {
          _lineMatches.remove(leftIdx);
          _wrongFlash.remove(leftIdx);
          _showWrongCenter = false;
        });
        _onWrong();
      });
    }
  }

  // ── Dot position helper ───────────────────────────────────────────────────

  List<Offset> _getDotPositions(List<GlobalKey> keys, {required bool isLeft}) {
    final stackBox =
        _game3StackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return [];
    return keys.map((key) {
      final ctx = key.currentContext;
      if (ctx == null) return Offset.zero;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) return Offset.zero;
      final pos = box.localToGlobal(Offset.zero, ancestor: stackBox);
      final size = box.size;
      return isLeft
          ? Offset(pos.dx + size.width, pos.dy + size.height / 2)
          : Offset(pos.dx, pos.dy + size.height / 2);
    }).toList();
  }

  // ── Balloon handler ───────────────────────────────────────────────────────

  void _handleBalloonTap(int balloonIndex, int value, int target) {
    if (_poppedBalloons.contains(balloonIndex)) return;
    if (_wrongBalloons.contains(balloonIndex)) return;

    if (value == target) {
      HapticFeedback.lightImpact();
      final balloons = _currentGame['balloons'] as List<dynamic>;
      final allCorrectIndices = <int>{};
      for (int i = 0; i < balloons.length; i++) {
        if (balloons[i] == target) allCorrectIndices.add(i);
      }
      setState(() => _poppedBalloons.add(balloonIndex));
      if (_poppedBalloons.containsAll(allCorrectIndices)) {
        Future.delayed(const Duration(milliseconds: 350), _onCorrect);
      }
    } else {
      setState(() => _wrongBalloons.add(balloonIndex));
      _onWrong();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _wrongBalloons.remove(balloonIndex));
      });
    }
  }

  void _handleSideSelection(String tappedSide) {
    if (_showCorrectOverlay) return;
    if (_selectedSide != null) return;

    final correct = _currentGame['correct'] as String;
    final isCorrect = correct == 'equal' ? true : tappedSide == correct;

    setState(() => _selectedSide = tappedSide);

    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 300), _onCorrect);
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _selectedSide = null);
        _onWrong();
      });
    }
  }

  void _handleEqualButton() {
    if (_showCorrectOverlay) return;
    final correct = _currentGame['correct'] as String;
    if (correct == 'equal') {
      setState(() => _selectedSide = 'equal');
      Future.delayed(const Duration(milliseconds: 300), _onCorrect);
    } else {
      _onWrong();
    }
  }

  void _handlePuzzleTap(int index) {
    if (_isPuzzleSolved) return;

    if (_puzzleSelectedIndex == null) {
      setState(() => _puzzleSelectedIndex = index);
      return;
    }
    if (_puzzleSelectedIndex == index) {
      setState(() => _puzzleSelectedIndex = null);
      return;
    }

    setState(() {
      final tmp = _puzzleNumbers[_puzzleSelectedIndex!];
      _puzzleNumbers[_puzzleSelectedIndex!] = _puzzleNumbers[index];
      _puzzleNumbers[index] = tmp;
      _puzzleSelectedIndex = null;
    });
    HapticFeedback.lightImpact();

    final correct = List<int>.from(_currentGame['correct'] as List<dynamic>);
    if (_puzzleNumbers.join() == correct.join()) {
      setState(() => _isPuzzleSolved = true);
      Future.delayed(const Duration(milliseconds: 450), _onCorrect);
    }
  }

  // ─── Feedback ────────────────────────────────────────────────────────────────

  void _showFeedback(String msg, Color color) {
    setState(() {
      _feedbackMessage = msg;
      _feedbackColor = color;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _feedbackMessage = '';
          _feedbackColor = Colors.transparent;
        });
      }
    });
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────────

  void _showLevelComplete() {
    _stopTimer();
    final total = _currentGames.length;
    final avgStars = total == 0 ? 1 : (_levelStars / total).ceil().clamp(1, 3);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.awardMatematikaLevelCompletion(
        _selectedLevel, avgStars, _levelScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessModal(
        title: AppLocalizations.of(context)!.levelComplete(_selectedLevel + 1),
        subtitle: _getLevelTitleLocalized(_selectedLevel),
        score: _totalScore,
        stars: avgStars,
        streak: _dailyStreak,
        primaryLabel: _selectedLevel < _levelTitles.length - 1
            ? AppLocalizations.of(context)!.continueText
            : AppLocalizations.of(context)!.done,
        onPrimaryTap: () {
          Navigator.pop(context);
          if (_selectedLevel < _levelTitles.length - 1) {
            _switchLevel(_selectedLevel + 1);
          } else {
            Navigator.pop(context); // Go back to level selection
          }
        },
        secondaryLabel: AppLocalizations.of(context)!.back,
        onSecondaryTap: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        mainColor: AppColors.numbers,
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

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
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildLevelTabs(),
              _buildProgressHeader(),
              Expanded(child: _buildGameContent()),
              _buildFeedbackBanner(),
            ],
          ),
          if (_showCorrectOverlay) _buildCorrectOverlay(),
          if (_showWrongOverlay) _buildWrongOverlay(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: CustomBackButton(
        iconColor: AppColors.textDark,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.matematika,
        style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      actions: [
        AnimatedBuilder(
          animation: _timerPulseAnim,
          builder: (_, __) {
            final urgent = _secondsLeft <= 10;
            return Transform.scale(
              scale: urgent ? _timerPulseAnim.value : 1.0,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: urgent
                      ? Colors.red.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.timer,
                        color: urgent ? Colors.red : AppColors.primary,
                        size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_secondsLeft',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: urgent ? Colors.red : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '$_totalStars',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.amber),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLevelTabs() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: List.generate(_levelTitles.length, (i) {
            final active = _selectedLevel == i;
            final completed = userProvider.isMatematikaLevelCompleted(i);

            return GestureDetector(
              onTap: () {
                if (completed && !active) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: Text(AppLocalizations.of(context)!.finishedAlready,
                          textAlign: TextAlign.center),
                      content: Text(AppLocalizations.of(context)!.doneAlready,
                          textAlign: TextAlign.center),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.okButton),
                        )
                      ],
                    ),
                  );
                  return;
                }
                _switchLevel(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary
                      : (completed
                          ? Colors.green.withOpacity(0.08)
                          : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(20),
                  border: completed && !active
                      ? Border.all(color: Colors.green.withOpacity(0.3))
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        completed && !active
                            ? LucideIcons.circle_check
                            : _levelIcons[i],
                        size: 14,
                        color: active
                            ? Colors.white
                            : (completed
                                ? Colors.green
                                : Colors.grey.shade500)),
                    const SizedBox(width: 6),
                    Text(
                      _getLevelTitleLocalized(i),
                      style: TextStyle(
                        color: active
                            ? Colors.white
                            : (completed ? Colors.green : Colors.grey.shade600),
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.normal,
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
    final progress = total == 0 ? 0.0 : _currentGameIndex / total;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_getLevelTitleLocalized(_selectedLevel),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${_currentGameIndex + 1} / $total',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner() {
    if (_feedbackMessage.isEmpty) return const SizedBox(height: 16);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _feedbackColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _feedbackMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget _buildCorrectOverlay() {
    return IgnorePointer(
      child: Center(
        child: ScaleTransition(
          scale: _starBurstAnim,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.93),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.45),
                  blurRadius: 35,
                  spreadRadius: 12,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.circle_check,
                      color: Colors.white, size: 54),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.goodJob,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '🎉',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWrongOverlay() {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _shakeAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(sin(_shakeAnim.value * pi * 5) * 10, 0),
            child: child,
          ),
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFC62828).withOpacity(0.93),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.45),
                  blurRadius: 35,
                  spreadRadius: 12,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.circle_x,
                      color: Colors.white, size: 54),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.wrong,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Reusable widgets ────────────────────────────────────────────────────────

  Widget _checkButton(VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(LucideIcons.circle_check, color: Colors.white),
      label: Text(AppLocalizations.of(context)!.checkAnswer,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
      ),
    );
  }

  Widget _mcqTile(int answer) {
    final selected = _selectedAnswer == answer;
    return GestureDetector(
      onTap: () => setState(() => _selectedAnswer = answer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
        ),
        child: Center(
          child: Text(
            answer.toString(),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _gameCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)
        ],
      ),
      child: child,
    );
  }

  // ─── Game routing ─────────────────────────────────────────────────────────────

  Widget _buildGameContent() {
    if (_currentGames.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)!.noGamesAvailable2));
    }

    Widget gameWidget;
    switch (_selectedLevel) {
      case 0:
        gameWidget = _buildGame1();
        break;
      case 1:
        gameWidget = _buildGame2();
        break;
      case 2:
        gameWidget = _buildGame3();
        break;
      case 3:
        gameWidget = _buildGame4();
        break;
      case 4:
        gameWidget = _buildGame5();
        break;
      case 5:
        gameWidget = _buildGame6();
        break;
      case 6:
        gameWidget = _buildGame7();
        break;
      default:
        gameWidget = _buildGame1();
    }

    final userProvider = Provider.of<UserProvider>(context);
    final isCompleted = userProvider.isMatematikaGameCompleted(
        _selectedLevel, _currentGameIndex);

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

  // ─── Game 1: Count & pick ────────────────────────────────────────────────────

  Widget _buildGame1() {
    final game = _game1Levels[_currentGameIndex % _game1Levels.length];
    final objects = game['objects'] as List<dynamic>;
    final answers = game['answers'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _gameCard(
            child: Column(
              children: [
                Text(_getHowManyFromMap(game),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: objects
                      .map((o) => Text(o as String,
                          style: const TextStyle(fontSize: 44)))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(AppLocalizations.of(context)!.selectCorrectAnswer,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: answers
                .map((a) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _mcqTile(a as int),
                    ))
                .toList(),
          ),
          const SizedBox(height: 28),
          _checkButton(() => _checkMCQ(game['correct'] as int)),
        ],
      ),
    );
  }

  // ─── Game 2: Drag & drop ─────────────────────────────────────────────────────

  Widget _buildGame2() {
    final game = _game2Levels[_currentGameIndex % _game2Levels.length];
    final correct = game['correct'] as int;
    final choices = game['choices'] as List<dynamic>;
    final objects = game['objects'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _gameCard(
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!.countAndDragCorrectNumber,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: objects
                      .map((o) => Text(o as String,
                          style: const TextStyle(fontSize: 44)))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: choices.map((choiceValue) {
              final n = choiceValue as int;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Draggable<int>(
                  data: n,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _draggableChip(n, floating: true),
                  ),
                  childWhenDragging: _draggableChip(n, ghost: true),
                  child: _draggableChip(n),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          DragTarget<int>(
            onWillAccept: (_) => !_dropCorrect,
            onAccept: (val) => _handleDrop(val, correct),
            builder: (_, candidateData, __) {
              final hovering = candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 200,
                height: 90,
                decoration: BoxDecoration(
                  color: _dropCorrect
                      ? Colors.green.withOpacity(0.15)
                      : _dropWrong
                          ? Colors.red.withOpacity(0.12)
                          : hovering
                              ? AppColors.primary.withOpacity(0.12)
                              : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _dropCorrect
                        ? Colors.green
                        : _dropWrong
                            ? Colors.red
                            : hovering
                                ? AppColors.primary
                                : Colors.grey.shade300,
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: _dropCorrect
                      ? const Icon(LucideIcons.circle_check,
                          color: Colors.green, size: 40)
                      : _dropWrong
                          ? const Icon(LucideIcons.circle_x,
                              color: Colors.red, size: 40)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.arrow_down,
                                    color: hovering
                                        ? AppColors.primary
                                        : Colors.grey.shade400,
                                    size: 26),
                                const SizedBox(height: 4),
                                Text(
                                  hovering
                                      ? '${AppLocalizations.of(context)!.dropHere}'
                                      : AppLocalizations.of(context)!.dragHere,
                                  style: TextStyle(
                                    color: hovering
                                        ? AppColors.primary
                                        : Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _draggableChip(int n, {bool floating = false, bool ghost = false}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: ghost
            ? Colors.grey.shade200
            : floating
                ? AppColors.primary
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: ghost
            ? null
            : Border.all(
                color: floating
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.4),
                width: 2),
        boxShadow: floating
            ? [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 8))
              ]
            : ghost
                ? null
                : [
                    const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
      ),
      child: Center(
        child: Text(
          ghost ? '' : n.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: floating ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  // ─── Game 3: Node-to-node line matching ──────────────────────────────────────

  Widget _buildGame3() {
    final game = _currentGame;
    final pairs = game['pairs'] as List<dynamic>;
    final count = pairs.length;

    // Safety: ensure keys are initialised
    while (_leftNodeKeys.length < count) {
      _leftNodeKeys.add(GlobalKey());
    }
    while (_rightNodeKeys.length < count) {
      _rightNodeKeys.add(GlobalKey());
    }
    if (_shuffledRightIndices.length != count) _initLineMatching();

    final matched = _lineMatches.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Instruction
          Text(
            _getMatchFromMap(game),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            AppLocalizations.of(context)!.tapLeftTapRight,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Score badge  (fraction style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: RichText(
              text: TextSpan(
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '$matched',
                    style: TextStyle(
                      color:
                          matched == count ? Colors.green : AppColors.primary,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: ' / $count',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                  const TextSpan(
                    text: '  natugma',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Main matching area
          Expanded(
            child: Stack(
              key: _game3StackKey,
              children: [
                // ── Lines layer ────────────────────────────────────────
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: Listenable.merge(
                          [_shakeController, _starBurstController]),
                      builder: (_, __) {
                        final lDots =
                            _getDotPositions(_leftNodeKeys, isLeft: true);
                        final rDots =
                            _getDotPositions(_rightNodeKeys, isLeft: false);
                        return CustomPaint(
                          painter: _Game3LinePainter(
                            leftDots: lDots,
                            rightDots: rDots,
                            matches: Map.from(_lineMatches),
                            wrongFlash: Map.from(_wrongFlash),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── Nodes layer ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LEFT – emoji groups
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(count, (i) {
                            final objs = (pairs[i]['objects'] as List<dynamic>)
                                .cast<String>();
                            final isMatch = _lineMatches.containsKey(i);
                            final isSel = _selectedLeftIndex == i;
                            final isWrong = _wrongFlash[i] == true;
                            return _buildLeftNode(
                              nodeKey: _leftNodeKeys[i],
                              emojis: objs,
                              selected: isSel,
                              matched: isMatch,
                              isWrong: isWrong,
                              onTap: () => _handleLeftTap(i),
                            );
                          }),
                        ),
                      ),

                      // Centre gap (lines pass through here)
                      const SizedBox(width: 56),

                      // RIGHT – numbers (shuffled)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(count, (shuffled) {
                            final orig = _shuffledRightIndices[shuffled];
                            final isMatch =
                                _lineMatches.containsValue(shuffled);
                            return _buildRightNode(
                              nodeKey: _rightNodeKeys[shuffled],
                              number: orig + 1,
                              matched: isMatch,
                              onTap: () => _handleRightTap(shuffled),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Wrong answer banner ────────────────────────────────
                if (_showWrongCenter)
                  Center(
                    child: AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(sin(_shakeAnim.value * pi * 5) * 10, 0),
                        child: child,
                      ),
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828).withOpacity(0.93),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.45),
                              blurRadius: 30,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.circle_x,
                                color: Colors.white, size: 58),
                            const SizedBox(height: 6),
                            Text(
                              'Mali!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.tryAgain,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Celebration overlay ────────────────────────────────
                if (_showCelebration)
                  Center(
                    child: ScaleTransition(
                      scale: _starBurstAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 32,
                              spreadRadius: 8,
                            )
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🎉', style: TextStyle(fontSize: 44)),
                            SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.circle_check,
                                    color: Colors.white, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Nalpas! Good Job!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Left node widget ──────────────────────────────────────────────────────

  Widget _buildLeftNode({
    required Key nodeKey,
    required List<String> emojis,
    required bool selected,
    required bool matched,
    required bool isWrong,
    required VoidCallback onTap,
  }) {
    final Color border = isWrong
        ? Colors.red
        : matched
            ? Colors.green
            : selected
                ? AppColors.primary
                : Colors.grey.shade300;

    final Color bg = isWrong
        ? Colors.red.withOpacity(0.07)
        : matched
            ? Colors.green.withOpacity(0.07)
            : selected
                ? AppColors.primary.withOpacity(0.09)
                : Colors.white;

    return GestureDetector(
      key: nodeKey,
      onTap: (matched || isWrong) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 66,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 2.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.22),
                      blurRadius: 10)
                ]
              : [
                  const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child:
                  Text(emojis.join('  '), style: const TextStyle(fontSize: 22)),
            ),
            // Right-edge connector dot
            Positioned(
              right: -19,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isWrong
                        ? Colors.red
                        : matched
                            ? Colors.green
                            : selected
                                ? AppColors.primary
                                : Colors.grey.shade400,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),
            if (matched)
              const Positioned(
                top: 4,
                right: -2,
                child: Icon(LucideIcons.circle_check,
                    color: Colors.green, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  // ── Right node widget ─────────────────────────────────────────────────────

  Widget _buildRightNode({
    required Key nodeKey,
    required int number,
    required bool matched,
    required VoidCallback onTap,
  }) {
    final border = matched ? Colors.green : Colors.grey.shade300;
    final bg = matched ? Colors.green.withOpacity(0.07) : Colors.white;

    return GestureDetector(
      key: nodeKey,
      onTap: matched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 66,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 2.2),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: matched ? Colors.green : AppColors.textDark,
                ),
              ),
            ),
            // Left-edge connector dot
            Positioned(
              left: -19,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: matched ? Colors.green : Colors.grey.shade400,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Game 4: Pop the Balloon ─────────────────────────────────────────────────

  Widget _buildGame4() {
    final game = _game4Levels[_currentGameIndex % _game4Levels.length];
    final target = game['target'] as int;
    final balloons = game['balloons'] as List<dynamic>;

    final totalCorrect = balloons.where((b) => b == target).length;
    final popped = _poppedBalloons.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _gameCard(
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 17, color: Colors.black87),
                    children: [
                      TextSpan(
                          text:
                              AppLocalizations.of(context)!.popAllBalloonsWith +
                                  ' '),
                      TextSpan(
                        text: '$target',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$popped / $totalCorrect  ',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    ...List.generate(
                      totalCorrect,
                      (i) => Icon(
                        i < popped
                            ? LucideIcons.circle
                            : LucideIcons.circle,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: balloons.length,
              itemBuilder: (_, i) {
                final val = balloons[i] as int;
                final isPopped = _poppedBalloons.contains(i);
                final isWrong = _wrongBalloons.contains(i);
                final color = _balloonColors[i % _balloonColors.length];

                return GestureDetector(
                  onTap: () => _handleBalloonTap(i, val, target),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isPopped ? 0.0 : 1.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: isWrong ? 1.15 : 1.0,
                      child: _buildBalloon(val, color, isWrong),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalloon(int val, Color color, bool isWrong) {
    final c = isWrong ? Colors.red.shade300 : color;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 82,
          decoration: BoxDecoration(
            color: c,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                  color: c.withOpacity(0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Center(
            child: Text(
              val.toString(),
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
        Container(width: 2, height: 18, color: Colors.grey.shade500),
      ],
    );
  }

  // ─── Game 5: More / Less / Equal ─────────────────────────────────────────────

  Widget _buildGame5() {
    final game = _game5Levels[_currentGameIndex % _game5Levels.length];
    final correct = game['correct'] as String;
    final isEqual = correct == 'equal';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _gameCard(
            child: Text(
              game['type'] == 'more'
                  ? AppLocalizations.of(context)!.whichIsMore
                  : game['type'] == 'less'
                      ? AppLocalizations.of(context)!.whichIsLess
                      : AppLocalizations.of(context)!.isSameNumber,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _game5Side(
                  sideKey: 'left',
                  objects:
                      (game['leftObjects'] as List<dynamic>).cast<String>(),
                  count: game['leftCount'] as int,
                  label: AppLocalizations.of(context)!.left,
                  correct: correct,
                ),
                _game5Side(
                  sideKey: 'right',
                  objects:
                      (game['rightObjects'] as List<dynamic>).cast<String>(),
                  count: game['rightCount'] as int,
                  label: AppLocalizations.of(context)!.right,
                  correct: correct,
                ),
              ],
            ),
          ),
          if (isEqual) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleEqualButton,
                icon: const Icon(LucideIcons.scale, color: Colors.white),
                label: Text(AppLocalizations.of(context)!.theyAreSame,
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _game5Side({
    required String sideKey,
    required List<String> objects,
    required int count,
    required String label,
    required String correct,
  }) {
    final selected = _selectedSide == sideKey;
    final answered = _selectedSide != null;

    Color borderColor;
    Color bgColor;
    if (answered) {
      if (correct == 'equal') {
        borderColor = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.08);
      } else if (sideKey == correct) {
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.08);
      } else if (selected) {
        borderColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.08);
      } else {
        borderColor = Colors.grey.shade300;
        bgColor = Colors.white;
      }
    } else {
      borderColor = selected ? AppColors.primary : Colors.grey.shade300;
      bgColor = selected ? AppColors.primary.withOpacity(0.08) : Colors.white;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleSideSelection(sideKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: objects
                    .map((o) => Text(o, style: const TextStyle(fontSize: 34)))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$count',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Game 6: Number puzzle ────────────────────────────────────────────────────

  Widget _buildGame6() {
    final game = _currentGame;
    final correct = List<int>.from(game['correct'] as List<dynamic>);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _gameCard(
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!
                      .arrange(game['sequence'] as String),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.tapTwoToSwap,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_puzzleNumbers.length, (i) {
              final selected = _puzzleSelectedIndex == i;
              final inPlace = _puzzleNumbers[i] == correct[i];
              return GestureDetector(
                onTap: () => _handlePuzzleTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 74,
                  height: 74,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: _isPuzzleSolved
                        ? Colors.green.withOpacity(0.12)
                        : selected
                            ? AppColors.primary
                            : inPlace
                                ? Colors.green.withOpacity(0.08)
                                : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isPuzzleSolved
                          ? Colors.green
                          : selected
                              ? AppColors.primary
                              : inPlace
                                  ? Colors.green
                                  : Colors.grey.shade300,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08), blurRadius: 6)
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _puzzleNumbers[i].toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _isPuzzleSolved
                            ? Colors.green
                            : selected
                                ? Colors.white
                                : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.info,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Umiso nga urnos:: ${correct.join(' → ')}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
          if (_puzzleSelectedIndex != null) ...[
            const SizedBox(height: 12),
            Text(
              'Napili: ${_puzzleNumbers[_puzzleSelectedIndex!]}  — tappedan pay ti sabali tapno agsinnukat',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // ─── Game 7: Missing number ───────────────────────────────────────────────────

  Widget _buildGame7() {
    final game = _game7Levels[_currentGameIndex % _game7Levels.length];
    final sequence = game['sequence'] as List<dynamic>;
    final answers = game['answers'] as List<dynamic>;
    final correct = game['correct'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _gameCard(
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!.whatIsMissingNumber,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sequence.map((item) {
                    final isBlank = item == null;
                    return Container(
                      width: 46,
                      height: 46,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isBlank
                            ? (_selectedAnswer != null
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.grey.shade100)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isBlank
                              ? (_selectedAnswer != null
                                  ? AppColors.primary
                                  : Colors.grey.shade400)
                              : AppColors.primary.withOpacity(0.3),
                          width: isBlank ? 2.0 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: isBlank
                            ? Text(
                                _selectedAnswer?.toString() ?? '?',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedAnswer != null
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                              )
                            : Text(
                                (item as int).toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(AppLocalizations.of(context)!.selectCorrectAnswer,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: answers
                .map((a) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _mcqTile(a as int),
                    ))
                .toList(),
          ),
          const SizedBox(height: 28),
          _checkButton(() => _checkMCQ(correct)),
        ],
      ),
    );
  }
}
