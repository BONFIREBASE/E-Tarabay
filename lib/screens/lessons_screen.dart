import 'package:e_tarabay/l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import 'matematika_screen.dart';
import 'pamilya_screen.dart';
import 'kulay_screen.dart';
import 'trace_it_screen.dart';
import 'magbasa_screen.dart';
import 'tandaan_screen.dart';
import '../widgets/custom_header_app_bar.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import '../widgets/staggered_entrance.dart';
import '../utils/page_transitions.dart';
import 'awards_screen.dart';
import 'settings_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SharedPreferences key helpers — must match each feature screen exactly
// ─────────────────────────────────────────────────────────────────────────────

class _KulayKeys {
  static String pageKey(String cat, int i) => 'kulay_page_${cat}_$i';
}

class _MagbasaKeys {
  static String activityKey(String cat, int i) => '${cat}_activity_$i';
}

class _MatematikaKeys {
  static String levelKey(int level, int game) =>
      'mat_level_${level}_game_$game';
}

// ─────────────────────────────────────────────────────────────────────────────
//  LESSONS SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> with RouteAware {
  bool _isLoading = true;

  // ── Trace It progress ──────────────────────────────────────────────────────
  static const List<String> _allUpper = [
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
  static const List<String> _allLower = [
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
  static const List<String> _allNums = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];
  // ── Trace It progress ──────────────────────────────────────────────────────
  int _traceItDone = 0;
  final int _traceItTotal = 62; // 26 + 26 + 10

  // ── Kulay progress ─────────────────────────────────────────────────────────
  static const Map<String, int> _kulayTotals = {
    'Animals': 3,
    'Flowers': 2,
    'Fruits': 2,
    'Toys': 2,
  };
  int _kulayDone = 0;
  final int _kulayTotal = 9; // 3+2+2+2

  // ── Magbasa progress ───────────────────────────────────────────────────────
  static const Map<String, int> _magbasaTotals = {
    'tula': 5,
    'kwento': 5,
    'kanta': 13,
  };
  int _magbasaDone = 0;
  final int _magbasaTotal = 23; // 5+5+13

  // ── Matematika progress ────────────────────────────────────────────────────
  static const List<int> _matGameCounts = [5, 5, 3, 5, 5, 3, 5];
  int _matDone = 0;
  final int _matTotal = 31; // sum of _matGameCounts

  // ── Tandaan progress ───────────────────────────────────────────────────
  int _tandaanDone = 0;
  final int _tandaanTotal = 12; // 4 categories × 3 rounds

  // ── Pamilya progress (still from UserProvider) ────────────────────────────
  int _pamilyaDone = 0;
  int _pamilyaTotal = 5;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  // Reload whenever the screen comes back into focus (e.g. after playing a game)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called automatically when returning to this page from a pushed route.
  @override
  void didPopNext() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // ── Trace It ───────────────────────────────────────────────────────────────
    int traceItCount = 0;
    for (final l in _allUpper) {
      if (prefs.getBool('traceit_upper_$l') == true) traceItCount++;
    }
    for (final l in _allLower) {
      if (prefs.getBool('traceit_lower_$l') == true) traceItCount++;
    }
    for (final n in _allNums) {
      if (prefs.getBool('traceit_num_$n') == true) traceItCount++;
    }

    // ── Kulay ────────────────────────────────────────────────────────────────
    int kulayCount = 0;
    for (final cat in _kulayTotals.keys) {
      final total = _kulayTotals[cat]!;
      for (int i = 0; i < total; i++) {
        if (prefs.getBool(_KulayKeys.pageKey(cat, i)) == true) kulayCount++;
      }
    }

    // ── Magbasa ──────────────────────────────────────────────────────────────
    int magbasaCount = 0;
    for (final cat in _magbasaTotals.keys) {
      final total = _magbasaTotals[cat]!;
      for (int i = 0; i < total; i++) {
        if (prefs.getBool(_MagbasaKeys.activityKey(cat, i)) == true) {
          magbasaCount++;
        }
      }
    }

    // ── Matematika ───────────────────────────────────────────────────────────
    int matCount = 0;
    for (int lvl = 0; lvl < _matGameCounts.length; lvl++) {
      for (int g = 0; g < _matGameCounts[lvl]; g++) {
        if (prefs.getBool(_MatematikaKeys.levelKey(lvl, g)) == true) matCount++;
      }
    }

    // ── Tandaan ────────────────────────────────────────────────────────────────
    int tandaanCount = 0;
    for (int cat = 0; cat < 4; cat++) {
      for (int round = 0; round < 3; round++) {
        if (prefs.getBool('tandaan_cat_${cat}_round_$round') == true) {
          tandaanCount++;
        }
      }
    }

    // ── Pamilya (from UserProvider) ───────────────────────────────────────────
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final providerProgress = userProvider.getAllProgress();
    final pamilya = providerProgress['pamilya'] as Map? ?? {};
    final pamilyaDone = pamilya['completedLevels'] ?? 0;
    final pamilyaTotal = pamilya['totalLevels'] ?? 5;

    setState(() {
      _traceItDone = traceItCount;
      _kulayDone = kulayCount;
      _magbasaDone = magbasaCount;
      _matDone = matCount;
      _tandaanDone = tandaanCount;
      _pamilyaDone = pamilyaDone;
      _pamilyaTotal = pamilyaTotal;
      _isLoading = false;
    });
  }

  // ── Totals for header ───────────────────────────────────────────────────────
  int get _totalCompleted =>
      _traceItDone +
      _kulayDone +
      _magbasaDone +
      _matDone +
      _tandaanDone +
      _pamilyaDone;

  int get _totalActivities =>
      _traceItTotal +
      _kulayTotal +
      _magbasaTotal +
      _matTotal +
      _tandaanTotal +
      _pamilyaTotal;

  double get _overallProgress =>
      _totalActivities > 0 ? _totalCompleted / _totalActivities : 0.0;

  // ─────────────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: CustomHeaderAppBar(
        title: AppLocalizations.of(context)!.lessons,
        baseColor: AppColors.primary,
        showBackButton: false,
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        selectedIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          switch (index) {
            case 0:
              Navigator.pop(context);
              break;
            case 2:
              context.pushReplacementPremium(const AwardsScreen());
              break;
            case 3:
              context.pushReplacementPremium(const SettingsScreen());
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
              'assets/images/bg_lesson.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StaggeredEntrance(
              index: 0,
              child: _buildHeader(context),
            ),
            const SizedBox(height: 20),
            StaggeredEntrance(
              index: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                      context, AppLocalizations.of(context)!.matematika),
                  _buildMatematikaCard(context),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StaggeredEntrance(
              index: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context,
                      AppLocalizations.of(context)!.angAkingSariliTitle),
                  _buildPamilyaCard(context),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StaggeredEntrance(
              index: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                      context, AppLocalizations.of(context)!.kulaySaya),
                  _buildKulayCard(context),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StaggeredEntrance(
              index: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                      context, AppLocalizations.of(context)!.traceItTitle),
                  _buildTraceItCard(context),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StaggeredEntrance(
              index: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                      context, AppLocalizations.of(context)!.magbasaTitle),
                  _buildMagbasaCard(context),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StaggeredEntrance(
              index: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                      context, AppLocalizations.of(context)!.tandaanTitle),
                  _buildTandaanCard(context),
                ],
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Header
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.lessons,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_totalCompleted/$_totalActivities ${AppLocalizations.of(context)!.activities}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _overallProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Section title
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Individual lesson cards
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMatematikaCard(BuildContext context) {
    return _buildLessonCard(
      context: context,
      title: AppLocalizations.of(context)!.matematika,
      subtitle:
          '$_matDone/$_matTotal ${AppLocalizations.of(context)!.activities}',
      icon: LucideIcons.calculator,
      color: AppColors.numbers,
      progress: _matTotal > 0 ? _matDone / _matTotal : 0.0,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MatematikaScreen()),
        );
        // Refresh progress when returning from the game
        setState(() => _isLoading = true);
        _loadProgress();
      },
    );
  }

  Widget _buildPamilyaCard(BuildContext context) {
    return _buildLessonCard(
      context: context,
      title: AppLocalizations.of(context)!.angAkingSariliTitle,
      subtitle:
          '$_pamilyaDone/$_pamilyaTotal ${AppLocalizations.of(context)!.levels}',
      icon: LucideIcons.user,
      color: AppColors.family,
      progress: _pamilyaTotal > 0 ? _pamilyaDone / _pamilyaTotal : 0.0,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PamilyaScreen()),
        );
        setState(() => _isLoading = true);
        _loadProgress();
      },
    );
  }

  Widget _buildKulayCard(BuildContext context) {
    return _buildLessonCard(
      context: context,
      title: AppLocalizations.of(context)!.kulaySaya,
      subtitle:
          '$_kulayDone/$_kulayTotal ${AppLocalizations.of(context)!.activities}',
      icon: LucideIcons.palette,
      color: AppColors.colors,
      progress: _kulayTotal > 0 ? _kulayDone / _kulayTotal : 0.0,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KulayScreen()),
        );
        setState(() => _isLoading = true);
        _loadProgress();
      },
    );
  }

  Widget _buildTraceItCard(BuildContext context) {
    return _buildLessonCard(
      context: context,
      title: AppLocalizations.of(context)!.traceItTitle,
      subtitle:
          '$_traceItDone/$_traceItTotal ${AppLocalizations.of(context)!.activities}',
      icon: LucideIcons.square_pen,
      color: AppColors.success,
      progress: _traceItTotal > 0 ? _traceItDone / _traceItTotal : 0.0,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TraceItScreen()),
        );
        setState(() => _isLoading = true);
        _loadProgress();
      },
    );
  }

  Widget _buildMagbasaCard(BuildContext context) {
    return _buildLessonCard(
      context: context,
      title: AppLocalizations.of(context)!.magbasaTitle,
      subtitle:
          '$_magbasaDone/$_magbasaTotal ${AppLocalizations.of(context)!.activities}',
      icon: LucideIcons.book_open,
      color: AppColors.alphabet,
      progress: _magbasaTotal > 0 ? _magbasaDone / _magbasaTotal : 0.0,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MagbasaScreen()),
        );
        setState(() => _isLoading = true);
        _loadProgress();
      },
    );
  }

  Widget _buildTandaanCard(BuildContext context) {
    return _buildLessonCard(
      context: context,
      title: AppLocalizations.of(context)!.tandaanTitle,
      subtitle:
          '$_tandaanDone/$_tandaanTotal ${AppLocalizations.of(context)!.activities}',
      icon: LucideIcons.brain,
      color: AppColors.shapes,
      progress: _tandaanTotal > 0 ? _tandaanDone / _tandaanTotal : 0.0,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TandaanScreen()),
        );
        setState(() => _isLoading = true);
        _loadProgress();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Reusable card widget
  // ─────────────────────────────────────────────────────────────────────────

  void _showCompletedDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title),
        content: Text(AppLocalizations.of(context)!.lessonFinishedPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.okButton),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
    required VoidCallback onTap,
  }) {
    final bool isCompleted = progress >= 0.999; // Using float margin

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isCompleted ? () => _showCompletedDialog(title) : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(isCompleted ? LucideIcons.circle_check : icon,
                        color: isCompleted ? Colors.green : color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? Colors.green.shade700
                                : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCompleted ? 'TAPOS NA!' : subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: isCompleted
                                ? Colors.green
                                : Colors.grey.shade600,
                            fontWeight: isCompleted
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isCompleted ? LucideIcons.lock : LucideIcons.chevron_right,
                    color: isCompleted ? Colors.green : Colors.grey.shade400,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
