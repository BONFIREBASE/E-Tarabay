// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../main.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/success_modal.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  TANDAAN MO! — Memory / Matching Game
// ─────────────────────────────────────────────────────────────────────────────

class TandaanScreen extends StatefulWidget {
  const TandaanScreen({super.key});

  @override
  State<TandaanScreen> createState() => _TandaanScreenState();
}

class _CardData {
  final int id;
  final String emoji;
  final String label;
  bool isFlipped = false;
  bool isMatched = false;

  _CardData({
    required this.id,
    required this.emoji,
    required this.label,
  });
}

class _TandaanScreenState extends State<TandaanScreen>
    with TickerProviderStateMixin {
  // ── Navigation ─────────────────────────────────────────────────────────────
  int _selectedCategory = 0;
  int _currentRound = 0;

  // ── Scoring ──────────────────────────────────────────────────────────────
  int _totalStars = 0;
  int _categoryStars = 0;
  int _wrongAttempts = 0;

  // ── Timer ────────────────────────────────────────────────────────────────
  int _secondsLeft = 60;
  Timer? _timer;

  // ── Feedback ─────────────────────────────────────────────────────────────
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.transparent;
  bool _showCorrectOverlay = false;
  bool _showWrongOverlay = false;

  // ── Card state ───────────────────────────────────────────────────────────
  List<_CardData> _cards = [];
  int? _firstFlippedIndex;
  bool _isProcessing = false;

  // ── Completion tracking ──────────────────────────────────────────────────
  final Set<int> _completedCategories = {};
  final Map<int, List<bool>> _categoryRoundProgress = {};

  // ── Animations ───────────────────────────────────────────────────────────
  late AnimationController _starBurstController;
  late Animation<double> _starBurstAnim;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  late AnimationController _timerPulseController;
  late Animation<double> _timerPulseAnim;

  // ── Category data ────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _categories = const [
    {
      'title_en': 'Animals',
      'title_tl': 'Hayop',
      'title_il': 'Ayup',
      'color': AppColors.animals,
      'pairs': [
        {
          'emoji': '🐶',
          'label_en': 'Dog',
          'label_tl': 'Aso',
          'label_il': 'Aso'
        },
        {
          'emoji': '🐱',
          'label_en': 'Cat',
          'label_tl': 'Pusa',
          'label_il': 'Pusa'
        },
        {
          'emoji': '🐮',
          'label_en': 'Cow',
          'label_tl': 'Baka',
          'label_il': 'Baka'
        },
        {
          'emoji': '🐷',
          'label_en': 'Pig',
          'label_tl': 'Baboy',
          'label_il': 'Baboy'
        },
        {
          'emoji': '🐔',
          'label_en': 'Chicken',
          'label_tl': 'Manok',
          'label_il': 'Manok'
        },
        {
          'emoji': '🐰',
          'label_en': 'Rabbit',
          'label_tl': 'Kuneho',
          'label_il': 'Kuneho'
        },
      ],
    },
    {
      'title_en': 'Fruits',
      'title_tl': 'Prutas',
      'title_il': 'Prutas',
      'color': AppColors.colors,
      'pairs': [
        {
          'emoji': '🍎',
          'label_en': 'Apple',
          'label_tl': 'Mansanas',
          'label_il': 'Mansanas'
        },
        {
          'emoji': '🍌',
          'label_en': 'Banana',
          'label_tl': 'Saging',
          'label_il': 'Saging'
        },
        {
          'emoji': '🍇',
          'label_en': 'Grapes',
          'label_tl': 'Ubas',
          'label_il': 'Ubas'
        },
        {
          'emoji': '🍊',
          'label_en': 'Orange',
          'label_tl': 'Kahel',
          'label_il': 'Kahel'
        },
        {
          'emoji': '🍓',
          'label_en': 'Strawberry',
          'label_tl': 'Presa',
          'label_il': 'Presa'
        },
        {
          'emoji': '🍍',
          'label_en': 'Pineapple',
          'label_tl': 'Pinya',
          'label_il': 'Pinya'
        },
      ],
    },
    {
      'title_en': 'Shapes',
      'title_tl': 'Hugis',
      'title_il': 'Hugis',
      'color': AppColors.shapes,
      'pairs': [
        {
          'emoji': '🔴',
          'label_en': 'Circle',
          'label_tl': 'Bilog',
          'label_il': 'Bilog'
        },
        {
          'emoji': '🟦',
          'label_en': 'Square',
          'label_tl': 'Parisukat',
          'label_il': 'Parisukat'
        },
        {
          'emoji': '🔺',
          'label_en': 'Triangle',
          'label_tl': 'Tatsulok',
          'label_il': 'Tatsulok'
        },
        {
          'emoji': '⭐',
          'label_en': 'Star',
          'label_tl': 'Bituin',
          'label_il': 'Bituen'
        },
        {
          'emoji': '❤️',
          'label_en': 'Heart',
          'label_tl': 'Puso',
          'label_il': 'Puso'
        },
        {
          'emoji': '🔷',
          'label_en': 'Diamond',
          'label_tl': 'Diamante',
          'label_il': 'Diamante'
        },
      ],
    },
    {
      'title_en': 'Letters',
      'title_tl': 'Letra',
      'title_il': 'Letra',
      'color': AppColors.alphabet,
      'pairs': [
        {
          'emoji': 'Aa',
          'label_en': 'A a',
          'label_tl': 'A a',
          'label_il': 'A a'
        },
        {
          'emoji': 'Bb',
          'label_en': 'B b',
          'label_tl': 'B b',
          'label_il': 'B b'
        },
        {
          'emoji': 'Cc',
          'label_en': 'C c',
          'label_tl': 'C c',
          'label_il': 'C c'
        },
        {
          'emoji': 'Dd',
          'label_en': 'D d',
          'label_tl': 'D d',
          'label_il': 'D d'
        },
        {
          'emoji': 'Ee',
          'label_en': 'E e',
          'label_tl': 'E e',
          'label_il': 'E e'
        },
        {
          'emoji': 'Ff',
          'label_en': 'F f',
          'label_tl': 'F f',
          'label_il': 'F f'
        },
      ],
    },
  ];

  // Rounds per category: pair count for each round
  final List<List<int>> _roundConfigs = const [
    [3, 4, 5], // Animals: 3 pairs, 4 pairs, 5 pairs
    [3, 4, 5], // Fruits
    [3, 4, 5], // Shapes
    [3, 4, 5], // Letters
  ];

  List<IconData> get _categoryIcons => const [
        LucideIcons.paw_print,
        LucideIcons.coffee,
        LucideIcons.shapes,
        LucideIcons.whole_word,
      ];

  // ── Getters ──────────────────────────────────────────────────────────────

  Map<String, dynamic> get _currentCategory => _categories[_selectedCategory];
  int get _currentPairCount => _roundConfigs[_selectedCategory][_currentRound];
  int get _totalRounds => _roundConfigs[_selectedCategory].length;
  bool get _allCategoriesCompleted =>
      _completedCategories.length == _categories.length;

  bool get _currentCategoryCompleted =>
      _completedCategories.contains(_selectedCategory);

  @override
  void initState() {
    super.initState();
    AudioManager.instance.playModuleMusic(ModuleMusic.tandaan);
    _starBurstController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _starBurstAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starBurstController, curve: Curves.elasticOut),
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
    _timerPulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _timerPulseAnim =
        Tween<double>(begin: 1.0, end: 1.18).animate(_timerPulseController);

    _loadCompletedCategories().then((_) {
      if (!_currentCategoryCompleted) {
        _initRound();
        _startTimer();
      }
    });
  }

  Future<void> _loadCompletedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    int firstUncompleted = -1; // -1 means not found yet

    for (int cat = 0; cat < _categories.length; cat++) {
      bool allDone = true;
      final rounds = <bool>[];
      for (int round = 0; round < 3; round++) {
        final done = prefs.getBool('tandaan_cat_${cat}_round_$round') == true;
        rounds.add(done);
        if (!done) allDone = false;
      }
      if (mounted) {
        setState(() {
          _categoryRoundProgress[cat] = rounds;
          if (allDone) _completedCategories.add(cat);
        });
      }
      if (!allDone && firstUncompleted == -1) {
        firstUncompleted = cat; // First incomplete category found
      }
    }

    // If all done, land on the last category; otherwise on first uncompleted
    final target =
        firstUncompleted == -1 ? _categories.length - 1 : firstUncompleted;

    if (mounted && target != _selectedCategory) {
      setState(() {
        _selectedCategory = target;
        _currentRound = 0;
        _categoryStars = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _starBurstController.dispose();
    _shakeController.dispose();
    _timerPulseController.dispose();
    AudioManager.instance.resumeHomeMusic();
    super.dispose();
  }

  // ── Game init ────────────────────────────────────────────────────────────

  void _initRound() {
    final cat = _currentCategory;
    final allPairs = List<Map<String, dynamic>>.from(cat['pairs'] as List);
    allPairs.shuffle(Random());
    final selectedPairs = allPairs.take(_currentPairCount).toList();

    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final labelKey = lang.currentLanguage == 'il'
        ? 'label_il'
        : (lang.currentLanguage == 'tl' ? 'label_tl' : 'label_en');

    final List<_CardData> newCards = [];
    for (int i = 0; i < selectedPairs.length; i++) {
      final pair = selectedPairs[i];
      final emoji = pair['emoji'] as String;
      final label = pair[labelKey] as String;
      // Add each pair twice
      newCards.add(_CardData(id: i, emoji: emoji, label: label));
      newCards.add(_CardData(id: i, emoji: emoji, label: label));
    }
    newCards.shuffle(Random());

    setState(() {
      _cards = newCards;
      _firstFlippedIndex = null;
      _isProcessing = false;
      _wrongAttempts = 0;
    });
  }

  // ── Timer ────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 30 + (_currentPairCount * 8);
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
      _currentRound = 0;
      _categoryStars = 0;
    });
    _initRound();
    _startTimer();
  }

  // ── Category switch ────────────────────────────────────────────────────────

  void _switchCategory(int index) {
    if (_selectedCategory == index) return;
    _stopTimer();
    setState(() {
      _selectedCategory = index;
      _currentRound = 0;
      _categoryStars = 0;
    });
    // A completed category is locked — show its "done" state, no replay.
    if (_currentCategoryCompleted) return;
    _initRound();
    _startTimer();
  }

  // ── Card tap logic ───────────────────────────────────────────────────────

  void _onCardTap(int index) {
    if (_allCategoriesCompleted) {
      _showAlreadyFinishedDialog();
      return;
    }
    if (_isProcessing) return;
    if (_cards[index].isMatched) return;
    if (_cards[index].isFlipped) return;

    HapticFeedback.lightImpact();

    setState(() => _cards[index].isFlipped = true);

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
      return;
    }

    final first = _firstFlippedIndex!;
    final second = index;

    if (_cards[first].id == _cards[second].id) {
      // Match!
      _isProcessing = true;
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() {
          _cards[first].isMatched = true;
          _cards[second].isMatched = true;
          _firstFlippedIndex = null;
          _isProcessing = false;
        });
        _checkRoundComplete();
      });
    } else {
      // No match
      _isProcessing = true;
      _wrongAttempts++;
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _cards[first].isFlipped = false;
          _cards[second].isFlipped = false;
          _firstFlippedIndex = null;
          _isProcessing = false;
        });
      });
    }
  }

  void _checkRoundComplete() {
    final allMatched = _cards.every((c) => c.isMatched);
    if (!allMatched) return;

    _stopTimer();
    final earned = _starsFromWrong;
    setState(() {
      _totalStars += earned;
      _categoryStars += earned;
      _showCorrectOverlay = true;
    });
    _starBurstController.forward(from: 0);

    _showFeedback(
      '${List.filled(earned, '⭐').join()} ${AppLocalizations.of(context)!.goodJobPoints(earned * 10)}',
      const Color(0xFF2E7D32),
    );

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _showCorrectOverlay = false);
      _advanceOrComplete();
    });
  }

  int get _starsFromWrong {
    if (_wrongAttempts == 0) return 3;
    if (_wrongAttempts <= 2) return 2;
    return 1;
  }

  void _advanceOrComplete() async {
    // Record the round that was just finished so per-round progress (and the
    // Lessons screen counter) actually advances instead of only saving the
    // very last round on category completion.
    await _markRoundDone(_currentRound);
    if (_currentRound < _totalRounds - 1) {
      setState(() => _currentRound++);
      _initRound();
      _startTimer();
    } else {
      _showCategoryComplete();
    }
  }

  /// Persist a single completed round and refresh the local progress state.
  Future<void> _markRoundDone(int round) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'tandaan_cat_${_selectedCategory}_round_$round', true);

    if (mounted) {
      setState(() {
        _categoryRoundProgress[_selectedCategory] ??= [false, false, false];
        _categoryRoundProgress[_selectedCategory]![round] = true;
      });
    }

    // Mark the whole category complete once all three rounds are done.
    bool allDone = true;
    for (int r = 0; r < 3; r++) {
      if (prefs.getBool('tandaan_cat_${_selectedCategory}_round_$r') != true) {
        allDone = false;
        break;
      }
    }
    if (allDone && mounted) {
      setState(() => _completedCategories.add(_selectedCategory));
    }
  }

  void _showAlreadyFinishedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
  }

  void _showCategoryComplete() {
    _stopTimer();
    final avgStars = _totalRounds == 0
        ? 1
        : (_categoryStars / _totalRounds).ceil().clamp(1, 3);

    _saveProgress(avgStars);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessModal(
        title: AppLocalizations.of(context)!.congratulations,
        subtitle: _getCategoryTitleLocalized(_selectedCategory),
        score: _totalStars * 10,
        stars: avgStars,
        primaryLabel: _selectedCategory < _categories.length - 1
            ? AppLocalizations.of(context)!.continueText
            : AppLocalizations.of(context)!.done,
        onPrimaryTap: () {
          Navigator.pop(context);
          if (_selectedCategory < _categories.length - 1) {
            _switchCategory(_selectedCategory + 1);
          } else {
            Navigator.pop(context);
          }
        },
        secondaryLabel: AppLocalizations.of(context)!.back,
        onSecondaryTap: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        mainColor: _currentCategory['color'] as Color,
      ),
    );
  }

  Future<void> _saveProgress(int stars) async {
    final prefs = await SharedPreferences.getInstance();

    // Ensure the final round is recorded (per-round saving happens in
    // _advanceOrComplete, but guard here for the last round too).
    await _markRoundDone(_currentRound);

    final totalKey = 'tandaan_total_stars';
    final prev = prefs.getInt(totalKey) ?? 0;
    await prefs.setInt(totalKey, prev + stars);
  }

  // ── Feedback ───────────────────────────────────────────────────────────────

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

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _getCategoryTitleLocalized(int index) {
    final cat = _categories[index];
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final key = lang.currentLanguage == 'il'
        ? 'title_il'
        : (lang.currentLanguage == 'tl' ? 'title_tl' : 'title_en');
    return cat[key] as String;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildCategoryTabs(),
              if (!_currentCategoryCompleted) _buildProgressHeader(),
              Expanded(
                child: _currentCategoryCompleted
                    ? _buildCompletedView()
                    : _buildCardGrid(),
              ),
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
        AppLocalizations.of(context)!.tandaanTitle,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (!_currentCategoryCompleted)
          AnimatedBuilder(
            animation: _timerPulseAnim,
            builder: (_, __) {
              final urgent = _secondsLeft <= 10;
              return Transform.scale(
                scale: urgent ? _timerPulseAnim.value : 1.0,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: List.generate(_categories.length, (i) {
            final active = _selectedCategory == i;
            final color = _categories[i]['color'] as Color;
            final completed = _completedCategories.contains(i);

            return GestureDetector(
              onTap: () {
                if (completed && !active) {
                  _showAlreadyFinishedDialog();
                  return;
                }
                _switchCategory(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? color
                      : (completed
                          ? Colors.green.withOpacity(0.08)
                          : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(20),
                  border: completed && !active
                      ? Border.all(color: Colors.green.withOpacity(0.3))
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          completed && !active
                              ? LucideIcons.circle_check
                              : _categoryIcons[i],
                          size: 14,
                          color: active
                              ? Colors.white
                              : (completed
                                  ? Colors.green
                                  : Colors.grey.shade500),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getCategoryTitleLocalized(i),
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : (completed
                                    ? Colors.green
                                    : Colors.grey.shade600),
                            fontWeight:
                                active ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildRoundDots(i, active, color),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRoundDots(int catIndex, bool active, Color color) {
    final rounds = _categoryRoundProgress[catIndex] ?? [false, false, false];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (r) {
        final done = rounds[r];
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: done
                ? (active ? Colors.white : Colors.green)
                : (active
                    ? Colors.white.withOpacity(0.4)
                    : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildProgressHeader() {
    final progress = _totalRounds == 0 ? 0.0 : _currentRound / _totalRounds;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context)!.round} ${_currentRound + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_currentRound + 1} / $_totalRounds',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: _currentCategory['color'] as Color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    if (_cards.isEmpty) return const Center(child: CircularProgressIndicator());

    // Balance the grid into two even rows: 6→3×2, 8→4×2, 10→5×2.
    final crossAxisCount = (_cards.length / 2).ceil();
    final color = _currentCategory['color'] as Color;
    const spacing = 12.0;
    const rows = 2;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Instruction card
          _buildInstructionCard(color),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Largest square that fits both the width (columns) and the
                // height (2 rows), so cards stay square instead of stretched.
                final cellFromWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
                        crossAxisCount;
                final cellFromHeight =
                    (constraints.maxHeight - (rows - 1) * spacing) / rows;
                final cell = cellFromWidth < cellFromHeight
                    ? cellFromWidth
                    : cellFromHeight;
                final gridWidth =
                    cell * crossAxisCount + spacing * (crossAxisCount - 1);

                return Center(
                  child: SizedBox(
                    width: gridWidth,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        return _buildCard(index, card);
                      },
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

  /// Shown when the current category is already fully completed — like the
  /// Matematika module, a finished tab stays done and cannot be replayed.
  Widget _buildCompletedView() {
    final color = _currentCategory['color'] as Color;
    final next = _nextUncompletedCategory();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.circle_check,
                  color: Colors.green, size: 64),
            ),
            const SizedBox(height: 20),
            Text(
              _getCategoryTitleLocalized(_selectedCategory),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.doneAlready,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(LucideIcons.star, color: Colors.amber, size: 26),
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (next != null)
              SizedBox(
                width: 220,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _switchCategory(next),
                  icon: const Icon(LucideIcons.arrow_right, size: 20),
                  label: Text(AppLocalizations.of(context)!.continueText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.party_popper,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.finishedAlready,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  int? _nextUncompletedCategory() {
    for (int i = 0; i < _categories.length; i++) {
      if (!_completedCategories.contains(i)) return i;
    }
    return null;
  }

  Widget _buildInstructionCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.lightbulb, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.matchThePairs,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.flipCardsToMatch,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index, _CardData card) {
    final color = _currentCategory['color'] as Color;
    final isEmoji = card.emoji.length <= 2 && card.emoji != 'Aa';
    final showFront = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutBack,
        decoration: BoxDecoration(
          gradient: showFront
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.78)],
                ),
          color: showFront
              ? (card.isMatched ? Colors.green.withOpacity(0.12) : Colors.white)
              : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: card.isMatched ? Colors.green : color.withOpacity(0.45),
            width: card.isMatched ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (card.isMatched ? Colors.green : color).withOpacity(0.30),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(anim),
              child: FadeTransition(
                opacity: anim,
                child: child,
              ),
            );
          },
          child: showFront
              ? Stack(
                  key: ValueKey('front_$index'),
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                card.emoji,
                                style: TextStyle(
                                  fontSize: isEmoji ? 34 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                card.label,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (card.isMatched)
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(LucideIcons.circle_check,
                            color: Colors.green, size: 16),
                      ),
                  ],
                )
              : Container(
                  key: ValueKey('back_$index'),
                  alignment: Alignment.center,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
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
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
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
                      color: Colors.white, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.goodJob,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '+${_starsFromWrong * 10} ${AppLocalizations.of(context)!.pointsLabel}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
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
          builder: (_, __) {
            final shake = sin(_shakeAnim.value * pi * 6) * 12;
            return Transform.translate(
              offset: Offset(shake, 0),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: const Center(
                  child:
                      Icon(LucideIcons.x, color: Colors.white, size: 72),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
