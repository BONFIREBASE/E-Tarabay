import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Keys used by TraceItScreen.
class _TraceItKeys {
  static String upperKey(String l) => 'traceit_upper_$l';
  static String lowerKey(String l) => 'traceit_lower_$l';
  static String numKey(String n) => 'traceit_num_$n';
}

/// Keys used by KulayScreen — must match kulay_screen.dart exactly.
class _KulayKeys {
  static String pageKey(String cat, int i) => 'kulay_page_${cat}_$i';
  static const String totalCreations = 'kulay_total_creations';
  static const String lastColored = 'kulay_last_colored';
  static const String totalStrokes = 'kulay_total_strokes';
}

/// Keys used by MagbasaScreen — must match magbasa_screen.dart exactly.
class _MagbasaKeys {
  static String activityKey(String cat, int i) => '${cat}_activity_$i';
}

class _MatematikaKeys {
  static String levelKey(int level, int game) =>
      'mat_level_${level}_game_$game';
  static const String totalScore = 'mat_total_score';
  static const String totalStars = 'mat_total_stars';
}

// ─────────────────────────────────────────────────────────────────────────────
//  FOR PARENTS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class ForParentsScreen extends StatefulWidget {
  const ForParentsScreen({super.key});

  @override
  State<ForParentsScreen> createState() => _ForParentsScreenState();
}

class _ForParentsScreenState extends State<ForParentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // ── Trace It data ─────────────────────────────────────────────────────────
  final Set<String> _traceDoneUpper = {};
  final Set<String> _traceDoneLower = {};
  final Set<String> _traceDoneNums = {};

  bool _traceUpperExpanded = false;
  bool _traceLowerExpanded = false;
  bool _traceNumsExpanded = false;

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

  // ── Kulay data ───────────────────────────────────────────────────────────
  // category name → completed page indices
  final Map<String, Set<int>> _kulayDone = {
    'Animals': {},
    'Flowers': {},
    'Fruits': {},
    'Toys': {},
  };
  // category name → total pages
  final Map<String, int> _kulayTotal = {
    'Animals': 3,
    'Flowers': 2,
    'Fruits': 2,
    'Toys': 2,
  };
  // category name → pages list (name, difficulty)
  static const Map<String, List<Map<String, String>>> _kulayPages = {
    'Animals': [
      {'name': 'Puppy', 'difficulty': 'Easy'},
      {'name': 'Kuting', 'difficulty': 'Easy'},
      {'name': 'Elepante', 'difficulty': 'Medium'},
    ],
    'Flowers': [
      {'name': 'Flower Basket', 'difficulty': 'Medium'},
      {'name': 'Rose', 'difficulty': 'Hard'},
    ],
    'Fruits': [
      {'name': 'Mansanas', 'difficulty': 'Easy'},
      {'name': 'Saging', 'difficulty': 'Easy'},
    ],
    'Toys': [
      {'name': 'Teddy Bear', 'difficulty': 'Medium'},
      {'name': 'Soda Pop', 'difficulty': 'Easy'},
    ],
  };
  static const Map<String, Color> _kulayColors = {
    'Animals': Colors.orange,
    'Flowers': Colors.pink,
    'Fruits': Colors.red,
    'Toys': Colors.brown,
  };
  static const Map<String, String> _kulayIcons = {
    'Animals': '🐶',
    'Flowers': '🌸',
    'Fruits': '🍎',
    'Toys': '🧸',
  };

  int _kulayTotalCreations = 0;
  String _kulayLastColored = '—';
  int _kulayTotalStrokes = 0;

  // ── Magbasa data ─────────────────────────────────────────────────────────
  static const Map<String, int> _magbasaTotals = {
    'tula': 5,
    'kwento': 5,
    'kanta': 13,
  };
  static const Map<String, String> _magbasaIcons = {
    'tula': '📖',
    'kwento': '📚',
    'kanta': '🎵',
  };
  static const Map<String, Color> _magbasaColors = {
    'tula': Color(0xFFFF6B6B),
    'kwento': Color(0xFFFFB347),
    'kanta': Color(0xFF26A96C),
  };
  static const Map<String, String> _magbasaLabels = {
    'tula': 'Tula',
    'kwento': 'Kwento',
    'kanta': 'Kanta',
  };
  // category → completed indices
  final Map<String, Set<int>> _magbasaDone = {
    'tula': {},
    'kwento': {},
    'kanta': {},
  };

  // ── Matematika data ──────────────────────────────────────────────────────
  static const List<String> _matLevelTitles = [
    'Bilangen dagiti Banag',
    'I-drag ti Numero',
    'Iparis babaen ti Linya',
    'Pasii ti Balloon',
    'Adu wenno Bassit?',
    'Puzzle ti Numero',
    'Pagsasaruno dagiti Numero',
  ];
  static const List<int> _matLevelGameCounts = [5, 5, 3, 5, 5, 3, 5];
  // level → completed game indices
  final List<Set<int>> _matDone = List.generate(7, (_) => {});
  int _matTotalScore = 0;
  int _matTotalStars = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAllProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Load progress from SharedPreferences
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadAllProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Trace It
    for (final l in _allUpper) {
      if (prefs.getBool(_TraceItKeys.upperKey(l)) == true)
        _traceDoneUpper.add(l);
    }
    for (final l in _allLower) {
      if (prefs.getBool(_TraceItKeys.lowerKey(l)) == true)
        _traceDoneLower.add(l);
    }
    for (final n in _allNums) {
      if (prefs.getBool(_TraceItKeys.numKey(n)) == true) _traceDoneNums.add(n);
    }

    // Kulay
    for (final cat in _kulayDone.keys) {
      final total = _kulayTotal[cat] ?? 0;
      for (int i = 0; i < total; i++) {
        if (prefs.getBool(_KulayKeys.pageKey(cat, i)) == true) {
          _kulayDone[cat]!.add(i);
        }
      }
    }
    _kulayTotalCreations = prefs.getInt(_KulayKeys.totalCreations) ?? 0;
    _kulayLastColored = prefs.getString(_KulayKeys.lastColored) ?? '—';
    _kulayTotalStrokes = prefs.getInt(_KulayKeys.totalStrokes) ?? 0;

    // Magbasa
    for (final cat in _magbasaDone.keys) {
      final total = _magbasaTotals[cat] ?? 0;
      for (int i = 0; i < total; i++) {
        if (prefs.getBool(_MagbasaKeys.activityKey(cat, i)) == true) {
          _magbasaDone[cat]!.add(i);
        }
      }
    }

    // Matematika
    for (int lvl = 0; lvl < _matLevelGameCounts.length; lvl++) {
      for (int g = 0; g < _matLevelGameCounts[lvl]; g++) {
        if (prefs.getBool(_MatematikaKeys.levelKey(lvl, g)) == true) {
          _matDone[lvl].add(g);
        }
      }
    }
    _matTotalScore = prefs.getInt(_MatematikaKeys.totalScore) ?? 0;
    _matTotalStars = prefs.getInt(_MatematikaKeys.totalStars) ?? 0;

    setState(() => _isLoading = false);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.forParents,
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.primary,
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAllProgress();
            },
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.overviewTab),
              Tab(text: AppLocalizations.of(context)!.kulaySaya),
              Tab(text: AppLocalizations.of(context)!.traceItTitle),
              Tab(text: AppLocalizations.of(context)!.magbasaTab),
              Tab(text: AppLocalizations.of(context)!.matematikaTab),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildKulayTab(),
          _buildTraceItTab(),
          _buildMagbasaTab(),
          _buildMatematikaTab(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  OVERVIEW TAB
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    final totalTrace =
        _traceDoneUpper.length + _traceDoneLower.length + _traceDoneNums.length;
    final maxTrace = _allUpper.length + _allLower.length + _allNums.length;
    final totalKulay = _kulayDone.values.fold<int>(0, (s, e) => s + e.length);
    final maxKulay = _kulayTotal.values.fold<int>(0, (s, e) => s + e);
    final totalMagbasa =
        _magbasaDone.values.fold<int>(0, (s, e) => s + e.length);
    final maxMagbasa = _magbasaTotals.values.fold<int>(0, (s, e) => s + e);
    final totalMat = _matDone.fold<int>(0, (s, e) => s + e.length);
    final maxMat = _matLevelGameCounts.fold<int>(0, (s, e) => s + e);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Welcome card
        _gradientCard(
          gradient: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.waving_hand_rounded,
                  color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.hello,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 6),
            Text(AppLocalizations.of(context)!.forParentsSubtitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 16),

        // Summary cards row – Kulay & Sundan
        Row(children: [
          Expanded(
              child: _summaryCard(
            icon: '🎨',
            label: AppLocalizations.of(context)!.kulaySaya,
            value: '$totalKulay/$maxKulay',
            subtitle: AppLocalizations.of(context)!.pagesLabel,
            color: Colors.orange,
            progress: maxKulay > 0 ? totalKulay / maxKulay : 0,
          )),
          const SizedBox(width: 12),
          Expanded(
              child: _summaryCard(
            icon: '✏️',
            label: AppLocalizations.of(context)!.traceItTitle,
            value: '$totalTrace/$maxTrace',
            subtitle: AppLocalizations.of(context)!.lettersLabel,
            color: Colors.indigo,
            progress: maxTrace > 0 ? totalTrace / maxTrace : 0,
          )),
        ]),
        const SizedBox(height: 12),

        // Summary cards row – Magbasa & Matematika
        Row(children: [
          Expanded(
              child: _summaryCard(
            icon: '📖',
            label: AppLocalizations.of(context)!.magbasaTab,
            value: '$totalMagbasa/$maxMagbasa',
            subtitle: AppLocalizations.of(context)!.activitiesLabel,
            color: const Color(0xFFFF6B6B),
            progress: maxMagbasa > 0 ? totalMagbasa / maxMagbasa : 0,
          )),
          const SizedBox(width: 12),
          Expanded(
              child: _summaryCard(
            icon: '🔢',
            label: AppLocalizations.of(context)!.matematikaTab,
            value: '$totalMat/$maxMat',
            subtitle: AppLocalizations.of(context)!.gamesLabel,
            color: Colors.teal,
            progress: maxMat > 0 ? totalMat / maxMat : 0,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _summaryCard(
            icon: '🖼️',
            label: AppLocalizations.of(context)!.artworksLabel,
            value: '$_kulayTotalCreations',
            subtitle: AppLocalizations.of(context)!.savedCountLabel,
            color: Colors.teal,
            progress: null,
          )),
          const SizedBox(width: 12),
          Expanded(
              child: _summaryCard(
            icon: '🖊️',
            label: AppLocalizations.of(context)!.traceItTitle,
            value: '$totalTrace/$maxTrace',
            subtitle: AppLocalizations.of(context)!.lettersLabel,
            color: Colors.deepPurple,
            progress: maxTrace > 0 ? totalTrace / maxTrace : 0,
          )),
        ]),
        const SizedBox(height: 20),

        // Recent activity
        _sectionHeader(AppLocalizations.of(context)!.recentActivity,
            Icons.history_rounded),
        const SizedBox(height: 10),
        _recentActivityCard('🎨 ${AppLocalizations.of(context)!.kulaySaya}',
            _kulayLastColored, Colors.orange),
        const SizedBox(height: 8),
        _recentActivityCard(
            '✏️ ${AppLocalizations.of(context)!.traceItTitle}',
            '$totalTrace / $maxTrace ${AppLocalizations.of(context)!.lettersLabel}',
            Colors.indigo),
        const SizedBox(height: 20),

        // Quick tips
        _sectionHeader(
            AppLocalizations.of(context)!.forParents, Icons.lightbulb_rounded),
        const SizedBox(height: 10),
        _tipCard('🎨', 'Kulay-Saya',
            'Hikayatin ang inyong anak na kulayin ang lahat ng pahina sa bawat kategorya.'),
        const SizedBox(height: 8),
        _tipCard('✏️', AppLocalizations.of(context)!.traceItTitle,
            'Gabayan ang inyong anak na sundan ang tamang direksyon ng bawat letra.'),
        const SizedBox(height: 8),
        _tipCard('📖', 'Magbasa',
            'Basahin nang malakas kasama ang inyong anak ang mga tula, kwento at kanta.'),
        const SizedBox(height: 8),
        _tipCard('🔢', 'Matematika',
            'Hikayatin ang inyong anak na matapos ang bawat laro para mas lumago ang kakayahan sa bilang.'),
        const SizedBox(height: 8),
        _tipCard('⏰', 'Oras ng Pag-aaral',
            'Mag-practice nang 15-20 minuto araw-araw para sa pinakamabuting resulta.'),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  KULAY-SAYA TAB
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildKulayTab() {
    final totalDone = _kulayDone.values.fold<int>(0, (s, e) => s + e.length);
    final totalPages = _kulayTotal.values.fold<int>(0, (s, e) => s + e);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header summary card
        _gradientCard(
          gradient: [Colors.orange.shade400, Colors.deepOrange.shade400],
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('🎨', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.kulaySayaProgress,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('$totalDone / $totalPages pahina',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalPages > 0 ? totalDone / totalPages : 0,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 10,
                        )),
                    const SizedBox(height: 4),
                    Text(
                        '${totalPages > 0 ? (totalDone / totalPages * 100).toInt() : 0}% kumpleto',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12)),
                  ])),
              const SizedBox(width: 16),
              Column(children: [
                _statBubble('$_kulayTotalCreations', 'Obra'),
                const SizedBox(height: 8),
                _statBubble('$_kulayTotalStrokes', 'Strokes'),
              ]),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Last colored
        _infoRow(Icons.access_time, AppLocalizations.of(context)!.recentColor,
            _kulayLastColored),
        const SizedBox(height: 16),

        // Per-category breakdown
        _sectionHeader('Progreso sa Bawat Kategorya', Icons.grid_view_rounded),
        const SizedBox(height: 12),

        ..._kulayDone.keys.map((catName) {
          final done = _kulayDone[catName]!.length;
          final total = _kulayTotal[catName] ?? 0;
          final color = _kulayColors[catName] ?? Colors.grey;
          final icon = _kulayIcons[catName] ?? '🖼️';
          final pages = _kulayPages[catName] ?? [];
          final progress = total > 0 ? done / total : 0.0;

          // Difficulty breakdown
          int easyDone = 0, medDone = 0, hardDone = 0;
          for (int i = 0; i < pages.length; i++) {
            if (_kulayDone[catName]!.contains(i)) {
              final d = pages[i]['difficulty'] ?? '';
              if (d == 'Easy') {
                easyDone++;
              } else if (d == 'Medium') {
                medDone++;
              } else if (d == 'Hard') {
                hardDone++;
              }
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(children: [
              // Category header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.06),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(children: [
                  Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text(icon,
                              style: const TextStyle(fontSize: 22)))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(catName,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Expanded(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(color),
                                      minHeight: 7))),
                          const SizedBox(width: 10),
                          Text('$done/$total',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: color)),
                        ]),
                      ])),
                ]),
              ),

              // Individual pages
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  ...List.generate(pages.length, (i) {
                    final isDone = _kulayDone[catName]!.contains(i);
                    final diff = pages[i]['difficulty'] ?? '';
                    final diffColor = diff == 'Easy'
                        ? Colors.green
                        : diff == 'Medium'
                            ? Colors.orange
                            : Colors.red;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDone
                            ? color.withOpacity(0.06)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isDone
                                ? color.withOpacity(0.3)
                                : Colors.grey.shade200),
                      ),
                      child: Row(children: [
                        Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isDone ? color : Colors.grey.shade400,
                            size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(pages[i]['name'] ?? '',
                                style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        isDone ? color : Colors.grey.shade700,
                                    fontWeight: isDone
                                        ? FontWeight.w600
                                        : FontWeight.normal))),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: diffColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(diff,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: diffColor,
                                    fontWeight: FontWeight.w600))),
                      ]),
                    );
                  }),

                  // Difficulty summary chips
                  if (done > 0) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      if (easyDone > 0)
                        _diffChip('Easy $easyDone', Colors.green),
                      if (medDone > 0) ...[
                        const SizedBox(width: 6),
                        _diffChip('Medium $medDone', Colors.orange)
                      ],
                      if (hardDone > 0) ...[
                        const SizedBox(width: 6),
                        _diffChip('Hard $hardDone', Colors.red)
                      ],
                    ]),
                  ],
                ]),
              ),
            ]),
          );
        }),

        // My Creations section
        const SizedBox(height: 4),
        _sectionHeader('Mga Nai-save na Obra', Icons.collections_rounded),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.teal.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ],
          ),
          child: Row(children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Center(
                    child: Text('🖼️', style: TextStyle(fontSize: 26)))),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(AppLocalizations.of(context)!.totalSaved,
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  Text(
                      '$_kulayTotalCreations ${AppLocalizations.of(context)!.artworks}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                ])),
            if (_kulayTotalCreations > 0)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(14)),
                  child: Text('${_kulayTotalCreations}x',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TRACE IT TAB
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTraceItTab() {
    final totalDone =
        _traceDoneUpper.length + _traceDoneLower.length + _traceDoneNums.length;
    final totalAll = _allUpper.length + _allLower.length + _allNums.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header summary
        _gradientCard(
          gradient: [Colors.indigo.shade400, Colors.purple.shade400],
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('✏️', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.traceItTitle,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('$totalDone / $totalAll natatapos',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalAll > 0 ? totalDone / totalAll : 0,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 10,
                        )),
                    const SizedBox(height: 4),
                    Text(
                        '${totalAll > 0 ? (totalDone / totalAll * 100).toInt() : 0}% kumpleto',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12)),
                  ])),
            ]),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Uppercase ────────────────────────────────────────────────────────
        _tracingSection(
          title: AppLocalizations.of(context)!.uppercaseLettersTitle,
          icon: '🔠',
          color: Colors.indigo,
          total: _allUpper.length,
          done: _traceDoneUpper.length,
          letters: _allUpper,
          completedSet: _traceDoneUpper,
          isExpanded: _traceUpperExpanded,
          onToggle: () =>
              setState(() => _traceUpperExpanded = !_traceUpperExpanded),
        ),
        const SizedBox(height: 14),

        // ── Lowercase ───────────────────────────────────────────────────────
        _tracingSection(
          title: AppLocalizations.of(context)!.lowercaseLettersTitle,
          icon: '🔡',
          color: Colors.purple,
          total: _allLower.length,
          done: _traceDoneLower.length,
          letters: _allLower,
          completedSet: _traceDoneLower,
          isExpanded: _traceLowerExpanded,
          onToggle: () =>
              setState(() => _traceLowerExpanded = !_traceLowerExpanded),
        ),
        const SizedBox(height: 14),

        // ── Numbers ──────────────────────────────────────────────────────────
        _tracingSection(
          title: AppLocalizations.of(context)!.numbersTitle,
          icon: '🔢',
          color: Colors.teal,
          total: _allNums.length,
          done: _traceDoneNums.length,
          letters: _allNums,
          completedSet: _traceDoneNums,
          isExpanded: _traceNumsExpanded,
          onToggle: () =>
              setState(() => _traceNumsExpanded = !_traceNumsExpanded),
          isNumbers: true,
        ),
        const SizedBox(height: 20),

        // Tips for parents
        _sectionHeader('Tips para sa Magulang', Icons.lightbulb_rounded),
        const SizedBox(height: 10),
        _tipCard('✏️', 'Tamang Hawak ng Lapis',
            'Siguraduhin na tamang hawak ng inyong anak ang stylus o daliri habang nag-tracing.'),
        const SizedBox(height: 8),
        _tipCard('🔄', 'Ulit-ulitin',
            'Hikayatin ang inyong anak na ulit-ulitin ang mga letra na hindi pa kumpleto.'),
        const SizedBox(height: 8),
        _tipCard('🌟', 'Purihin ang Inyong Anak',
            'Purihin ang bawat tagumpay, malaki man o maliit, para mapalakas ang kanilang kumpiyansa.'),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  MAGBASA TAB
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMagbasaTab() {
    final totalDone = _magbasaDone.values.fold<int>(0, (s, e) => s + e.length);
    final totalItems = _magbasaTotals.values.fold<int>(0, (s, e) => s + e);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        _gradientCard(
          gradient: [const Color(0xFFFF6B6B), const Color(0xFFFFB347)],
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('📖', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.magbasaProgress,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('$totalDone / $totalItems aktibidad',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalItems > 0 ? totalDone / totalItems : 0,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 10,
                        )),
                    const SizedBox(height: 4),
                    Text(
                        '${totalItems > 0 ? (totalDone / totalItems * 100).toInt() : 0}% kumpleto',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12)),
                  ])),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        _sectionHeader('Progreso sa Bawat Kategorya', Icons.grid_view_rounded),
        const SizedBox(height: 12),

        ..._magbasaDone.keys.map((cat) {
          final done = _magbasaDone[cat]!.length;
          final total = _magbasaTotals[cat] ?? 0;
          final color = _magbasaColors[cat] ?? Colors.grey;
          final icon = _magbasaIcons[cat] ?? '📖';
          final label = _magbasaLabels[cat] ?? cat;
          final progress = total > 0 ? done / total : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.15), shape: BoxShape.circle),
                    child: Center(
                        child:
                            Text(icon, style: const TextStyle(fontSize: 22)))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Expanded(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                    minHeight: 7))),
                        const SizedBox(width: 10),
                        Text('$done/$total',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color)),
                      ]),
                    ])),
              ]),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(total, (i) {
                  final isDone = _magbasaDone[cat]!.contains(i);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDone
                          ? color.withOpacity(0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isDone ? color : Colors.grey.shade300,
                          width: isDone ? 1.5 : 1),
                    ),
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Text('${i + 1}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDone ? color : Colors.grey.shade500)),
                          if (isDone) Icon(Icons.check, size: 8, color: color),
                        ])),
                  );
                }),
              ),
            ]),
          );
        }),

        const SizedBox(height: 4),
        _sectionHeader('Tips para sa Magulang', Icons.lightbulb_rounded),
        const SizedBox(height: 10),
        _tipCard('📖', 'Tula',
            'Basahin nang malakas ang mga tula kasama ang inyong anak para mapabuti ang pagbigkas.'),
        const SizedBox(height: 8),
        _tipCard('📚', 'Kwento',
            'Itanong sa inyong anak ang tungkol sa kwento pagkatapos basahin para mapalakas ang pag-unawa.'),
        const SizedBox(height: 8),
        _tipCard('🎵', 'Kanta',
            'Awitin nang magkasama ang mga kanta para maging masaya ang pag-aaral.'),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  MATEMATIKA TAB
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMatematikaTab() {
    final totalDone = _matDone.fold<int>(0, (s, e) => s + e.length);
    final totalGames = _matLevelGameCounts.fold<int>(0, (s, e) => s + e);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        _gradientCard(
          gradient: [Colors.teal.shade400, Colors.cyan.shade400],
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('🔢', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.matematikaProgress,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('$totalDone / $totalGames laro',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalGames > 0 ? totalDone / totalGames : 0,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 10,
                        )),
                    const SizedBox(height: 4),
                    Text(
                        '${totalGames > 0 ? (totalDone / totalGames * 100).toInt() : 0}% kumpleto',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12)),
                  ])),
              const SizedBox(width: 16),
              Column(children: [
                _statBubble('$_matTotalScore', 'Puntos'),
                const SizedBox(height: 8),
                _statBubble('$_matTotalStars ⭐', 'Bituen'),
              ]),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        _sectionHeader('Progreso sa Bawat Laro', Icons.grid_view_rounded),
        const SizedBox(height: 12),

        ...List.generate(_matLevelTitles.length, (lvl) {
          final done = _matDone[lvl].length;
          final total = _matLevelGameCounts[lvl];
          final progress = total > 0 ? done / total : 0.0;
          const color = Colors.teal;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.15), shape: BoxShape.circle),
                    child: Center(
                        child: Text('${lvl + 1}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color)))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(_matLevelTitles[lvl],
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Expanded(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            color),
                                    minHeight: 7))),
                        const SizedBox(width: 10),
                        Text('$done/$total',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color)),
                      ]),
                    ])),
              ]),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(total, (g) {
                  final isDone = _matDone[lvl].contains(g);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDone
                          ? color.withOpacity(0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isDone ? color : Colors.grey.shade300,
                          width: isDone ? 1.5 : 1),
                    ),
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Text('${g + 1}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: color)),
                          if (isDone)
                            const Icon(Icons.check, size: 8, color: color),
                        ])),
                  );
                }),
              ),
            ]),
          );
        }),

        const SizedBox(height: 4),
        _sectionHeader('Tips para sa Magulang', Icons.lightbulb_rounded),
        const SizedBox(height: 10),
        _tipCard('🔢', 'Bilangan',
            'Gumamit ng tunay na bagay tulad ng prutas o laruan para matulungan ang inyong anak na mabilang.'),
        const SizedBox(height: 8),
        _tipCard('⭐', 'Papuri',
            'Purihin ang inyong anak sa bawat tamang sagot para mapalakas ang kanilang kumpiyansa sa matematika.'),
        const SizedBox(height: 8),
        _tipCard('🎮', 'Laro',
            'Ang mga laro ay dinisenyo para maging masaya — hayaan ang inyong anak na mag-enjoy sa pag-aaral.'),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Reusable widgets
  // ─────────────────────────────────────────────────────────────────────────

  Widget _tracingSection({
    required String title,
    required String icon,
    required Color color,
    required int total,
    required int done,
    required List<String> letters,
    required Set<String> completedSet,
    required bool isExpanded,
    required VoidCallback onToggle,
    bool isNumbers = false,
  }) {
    final progress = total > 0 ? done / total : 0.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: [
        // Header row (tappable to expand)
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: isExpanded
                  ? const BorderRadius.vertical(top: Radius.circular(20))
                  : BorderRadius.circular(20),
            ),
            child: Row(children: [
              Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.15), shape: BoxShape.circle),
                  child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 22)))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Expanded(
                          child: Text(title,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: color))),
                      Text('$done/$total',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: color)),
                    ]),
                    const SizedBox(height: 6),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 7)),
                    const SizedBox(height: 4),
                    Text('${(progress * 100).toInt()}% kumpleto',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500)),
                  ])),
              const SizedBox(width: 8),
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: color),
            ]),
          ),
        ),

        // Expandable letter grid
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: letters.map((l) {
                final isDone = completedSet.contains(l);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isNumbers ? 48 : 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:
                        isDone ? color.withOpacity(0.15) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDone ? color : Colors.grey.shade300,
                      width: isDone ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Text(l,
                            style: TextStyle(
                              fontSize: isNumbers ? 13 : 14,
                              fontWeight: FontWeight.bold,
                              color: isDone ? color : Colors.grey.shade500,
                            )),
                        if (isDone) Icon(Icons.check, size: 8, color: color),
                      ])),
                );
              }).toList(),
            ),
          ),
      ]),
    );
  }

  Widget _gradientCard({required List<Color> gradient, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _summaryCard({
    required String icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ]),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        Text(subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        if (progress != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 5)),
        ],
      ]),
    );
  }

  Widget _statBubble(String value, String label) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }

  Widget _diffChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(children: [
      Icon(icon, color: AppColors.primary, size: 18),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _recentActivityCard(String activity, String detail, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(activity,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(detail,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ])),
        Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
      ]),
    );
  }

  Widget _tipCard(String emoji, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.amber.withOpacity(0.05), blurRadius: 6)
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(body,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
        ])),
      ]),
    );
  }
}
