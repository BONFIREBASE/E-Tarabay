import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import '../widgets/success_modal.dart';

class ColoringCategory {
  final String name;
  final String icon;
  final Color color;
  final List<ColoringPage> pages;
  const ColoringCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.pages,
  });
}

class ColoringPage {
  final String name;
  final String imagePath;
  final String difficulty;
  final String timeEstimate;
  final int colors;
  const ColoringPage({
    required this.name,
    required this.imagePath,
    required this.difficulty,
    required this.timeEstimate,
    required this.colors,
  });
}

class ColoringStroke {
  final List<Offset> points;
  final Color color;
  final double size;
  final bool isEraser;

  const ColoringStroke({
    required this.points,
    required this.color,
    required this.size,
    this.isEraser = false,
  });

  ColoringStroke copyWith({List<Offset>? points}) {
    return ColoringStroke(
      points: points ?? this.points,
      color: color,
      size: size,
      isEraser: isEraser,
    );
  }
}

class MyCreation {
  final String name;
  final DateTime date;
  final String thumbnailPath;
  final List<ColoringStroke> strokes;
  bool isFavorite;

  MyCreation({
    required this.name,
    required this.date,
    required this.thumbnailPath,
    required this.strokes,
    this.isFavorite = false,
  });

  String getTimeAgoLocalized(BuildContext context) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return Translations.getJustNow(context);
    if (diff.inMinutes < 60)
      return Translations.getTimeAgo(context, diff.inMinutes, 'm');
    if (diff.inHours < 24)
      return Translations.getTimeAgo(context, diff.inHours, 'h');
    return Translations.getTimeAgo(context, diff.inDays, 'd');
  }
}

class StrokePainter extends CustomPainter {
  final List<ColoringStroke> strokes;
  final ColoringStroke? activeStroke;

  const StrokePainter({required this.strokes, this.activeStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      _draw(canvas, s);
    }
    if (activeStroke != null) _draw(canvas, activeStroke!);
  }

  void _draw(Canvas canvas, ColoringStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.size
      ..color = stroke.isEraser
          ? Colors.white.withOpacity(0.95)
          : stroke.color.withOpacity(0.85);

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first,
        stroke.size / 2,
        Paint()
          ..style = PaintingStyle.fill
          ..color = stroke.isEraser
              ? Colors.white.withOpacity(0.95)
              : stroke.color.withOpacity(0.85),
      );
      return;
    }

    final path = Path()..moveTo(stroke.points[0].dx, stroke.points[0].dy);

    for (int i = 1; i < stroke.points.length - 1; i++) {
      final mid = Offset(
        (stroke.points[i].dx + stroke.points[i + 1].dx) / 2,
        (stroke.points[i].dy + stroke.points[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(
        stroke.points[i].dx,
        stroke.points[i].dy,
        mid.dx,
        mid.dy,
      );
    }
    path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(StrokePainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class KulayScreen extends StatefulWidget {
  const KulayScreen({super.key});

  @override
  State<KulayScreen> createState() => _KulayScreenState();
}

class _KulayScreenState extends State<KulayScreen>
    with TickerProviderStateMixin {
  // ── Navigation ─────────────────────────────────────────────────────────────
  int _selectedTab = 0;
  int _selectedCategory = 0;
  ColoringPage? _selectedPage;
  String _searchQuery = '';

  // ── Drawing state ──────────────────────────────────────────────────────────
  final List<ColoringStroke> _strokes = [];
  final List<ColoringStroke> _redoStack = [];
  ColoringStroke? _activeStroke;

  Color _selectedColor = const Color(0xFFFF3B30);
  double _brushSize = 22.0;
  bool _isEraser = false;

  // ── Zoom & pan ─────────────────────────────────────────────────────────────
  double _scale = 1.0;
  late TransformationController _transformationController;

  int _pointerCount = 0;
  bool _isZoomMode = false;

  static const double _minScale = 1.0;
  static const double _maxScale = 6.0;

  // ── Progress & animations ──────────────────────────────────────────────────
  double _coloringProgress = 0.0;

  late AnimationController _rippleController;
  late Animation<double> _rippleAnim;
  Offset? _lastPos;

  late AnimationController _doneController;
  late Animation<double> _doneAnim;

  // ── My Creations ───────────────────────────────────────────────────────────
  final List<MyCreation> _myCreations = [];
  int _sortMode = 0;

  // ── Palette ────────────────────────────────────────────────────────────────
  final List<Color> _palette = const [
    Color(0xFFFF3B30),
    Color(0xFFFF9500),
    Color(0xFFFFCC00),
    Color(0xFF34C759),
    Color(0xFF00C7BE),
    Color(0xFF007AFF),
    Color(0xFF5856D6),
    Color(0xFFFF2D55),
    Color(0xFFAF52DE),
    Color(0xFFFF6B35),
    Color(0xFF30D158),
    Color(0xFF64D2FF),
    Color(0xFF8E6A00),
    Color(0xFF636366),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFFFF9F0A),
    Color(0xFF4DB6AC),
    Color(0xFFBF5AF2),
    Color(0xFF6AC4DC),
  ];

  // ── Categories ─────────────────────────────────────────────────────────────
  final List<ColoringCategory> _categories = const [
    ColoringCategory(name: 'Animals', icon: '🐶', color: Colors.orange, pages: [
      ColoringPage(
          name: 'Puppy',
          imagePath: 'assets/images/paint1.png',
          difficulty: 'Easy',
          timeEstimate: '5 min',
          colors: 4),
      ColoringPage(
          name: 'Kuting',
          imagePath: 'assets/images/paint2.png',
          difficulty: 'Easy',
          timeEstimate: '5 min',
          colors: 3),
      ColoringPage(
          name: 'Elepante',
          imagePath: 'assets/images/paint3.png',
          difficulty: 'Medium',
          timeEstimate: '8 min',
          colors: 2),
    ]),
    ColoringCategory(name: 'Flowers', icon: '🌸', color: Colors.pink, pages: [
      ColoringPage(
          name: 'Flower Basket',
          imagePath: 'assets/images/paint4.png',
          difficulty: 'Medium',
          timeEstimate: '10 min',
          colors: 5),
      ColoringPage(
          name: 'Rose',
          imagePath: 'assets/images/paint5.png',
          difficulty: 'Hard',
          timeEstimate: '12 min',
          colors: 3),
    ]),
    ColoringCategory(name: 'Fruits', icon: '🍎', color: Colors.red, pages: [
      ColoringPage(
          name: 'Mansanas',
          imagePath: 'assets/images/paint6.png',
          difficulty: 'Easy',
          timeEstimate: '3 min',
          colors: 2),
      ColoringPage(
          name: 'Saging',
          imagePath: 'assets/images/paint7.png',
          difficulty: 'Easy',
          timeEstimate: '4 min',
          colors: 2),
    ]),
    ColoringCategory(name: 'Toys', icon: '🧸', color: Colors.brown, pages: [
      ColoringPage(
          name: 'Teddy Bear',
          imagePath: 'assets/images/paint8.png',
          difficulty: 'Medium',
          timeEstimate: '8 min',
          colors: 3),
      ColoringPage(
          name: 'Soda Pop',
          imagePath: 'assets/images/paint9.png',
          difficulty: 'Easy',
          timeEstimate: '5 min',
          colors: 3),
    ]),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  //  Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(() {
      if (mounted) {
        setState(() {
          _scale = _transformationController.value.getMaxScaleOnAxis();
        });
      }
    });

    _loadCreations();

    _rippleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _rippleAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _rippleController, curve: Curves.easeOut));

    _doneController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _doneAnim =
        CurvedAnimation(parent: _doneController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _rippleController.dispose();
    _doneController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Gesture: separate drawing (1 pointer) from zoom/pan (2+ pointers)
  // ─────────────────────────────────────────────────────────────────────────

  void _onDoubleTap() {
    if (_scale > 1.5) {
      _transformationController.value = Matrix4.identity();
    } else {
      final target = (_scale * 2.5).clamp(_minScale, _maxScale);
      _transformationController.value = Matrix4.identity()..scale(target);
    }
    setState(() {
      _scale = _transformationController.value.getMaxScaleOnAxis();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Drawing (single-finger pan gestures on the INNER canvas)
  // ─────────────────────────────────────────────────────────────────────────

  void _paintStart(DragStartDetails d) {
    if (_isZoomMode) return;
    _redoStack.clear();
    setState(() {
      _activeStroke = ColoringStroke(
        points: [d.localPosition],
        color: _selectedColor,
        size: _brushSize,
        isEraser: _isEraser,
      );
      _lastPos = d.localPosition;
    });
  }

  void _paintUpdate(DragUpdateDetails d) {
    if (_isZoomMode || _activeStroke == null) return;
    setState(() {
      _activeStroke = _activeStroke!.copyWith(
        points: [..._activeStroke!.points, d.localPosition],
      );
      _lastPos = d.localPosition;
    });
  }

  void _paintEnd(DragEndDetails d) {
    if (_activeStroke == null) return;
    setState(() {
      _strokes.add(_activeStroke!);
      _activeStroke = null;
    });
    _rippleController.forward(from: 0);
    _updateProgress();
  }

  void _paintTap(TapDownDetails d) {
    if (_isZoomMode) return;
    _redoStack.clear();
    final dot = ColoringStroke(
      points: [d.localPosition, d.localPosition],
      color: _selectedColor,
      size: _brushSize,
      isEraser: _isEraser,
    );
    setState(() {
      _strokes.add(dot);
      _lastPos = d.localPosition;
    });
    _rippleController.forward(from: 0);
    _updateProgress();
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _redoStack.add(_strokes.removeLast()));
    _updateProgress();
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() => _strokes.add(_redoStack.removeLast()));
    _updateProgress();
  }

  void _clearAll() {
    setState(() {
      _strokes.clear();
      _redoStack.clear();
      _activeStroke = null;
      _coloringProgress = 0.0;
    });
  }

  void _updateProgress() {
    if (_selectedPage == null) return;
    final expected = ((_selectedPage!.colors) * 50).toDouble();
    setState(() {
      _coloringProgress = (_strokes.length / expected).clamp(0.0, 1.0);
    });

    if (_coloringProgress >= 1.0) {
      _doneController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 1500), _showCompletionModal);
    }
  }

  void _showCompletionModal() {
    if (_selectedPage == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessModal(
        title: Translations.getBeautifulArtwork(context),
        subtitle:
            Translations.getFinishedColoring(context, _selectedPage!.name),
        score: _strokes.length,
        stars: 3,
        primaryLabel: '${Translations.getSave(context)} (Save)',
        onPrimaryTap: () {
          Navigator.pop(context);
          _saveCreation();
        },
        secondaryLabel: Translations.getOthers(context),
        onSecondaryTap: () {
          Navigator.pop(context);
          setState(() {
            _selectedPage = null;
          });
        },
        mainColor: const Color(0xFF34C759),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Save
  // ─────────────────────────────────────────────────────────────────────────

  void _saveCreation() {
    if (_strokes.isEmpty) {
      _snack('Color something first!');
      return;
    }
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('💾 ${Translations.getSaveYourArtwork(context)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: Translations.getGiveArtworkName(context),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Translations.getCancel(context))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              final creation = MyCreation(
                name: ctrl.text.trim().isEmpty
                    ? 'My Art ${_myCreations.length + 1}'
                    : ctrl.text.trim(),
                date: DateTime.now(),
                thumbnailPath: _selectedPage!.imagePath,
                strokes: List.from(_strokes),
              );
              setState(() {
                _myCreations.add(creation);
              });

              // Sync to UserProvider
              if (mounted) {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final cat = _categories[_selectedCategory];
                final pageIndex = cat.pages.indexOf(_selectedPage!);
                userProvider.updateKulayProgress('coloring', true,
                    category: cat.name, index: pageIndex);

                // Update specific keys for Parents Screen
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('kulay_total_creations',
                      (prefs.getInt('kulay_total_creations') ?? 0) + 1);
                  await prefs.setString(
                      'kulay_last_colored', _selectedPage!.name);
                  await prefs.setInt(
                      'kulay_total_strokes',
                      (prefs.getInt('kulay_total_strokes') ?? 0) +
                          _strokes.length);
                } catch (e) {
                  debugPrint('Error updating parents prefs: $e');
                }
              }

              _saveCreationsToHive();
              if (mounted) {
                Navigator.pop(context);
                _snack('✓ ${Translations.getSaved(context)}');
              }
            },
            child: Text(Translations.getSave(context),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCreations() async {
    try {
      final box = await Hive.openBox('userProgress');
      final List? savedRaw = box.get('coloring_creations');
      if (savedRaw != null) {
        setState(() {
          _myCreations.clear();
          for (var item in savedRaw) {
            if (item is Map) {
              final strokesRaw = item['strokes'] as List?;
              final List<ColoringStroke> strokes = [];
              if (strokesRaw != null) {
                for (var s in strokesRaw) {
                  final pointsRaw = s['points'] as List?;
                  final List<Offset> points = [];
                  if (pointsRaw != null) {
                    for (var p in pointsRaw) {
                      points.add(Offset(p['dx'], p['dy']));
                    }
                  }
                  strokes.add(ColoringStroke(
                    points: points,
                    color: Color(s['color']),
                    size: s['size'],
                    isEraser: s['isEraser'] ?? false,
                  ));
                }
              }
              _myCreations.add(MyCreation(
                name: item['name'],
                date: DateTime.fromMillisecondsSinceEpoch(item['date']),
                thumbnailPath: item['thumbnailPath'],
                strokes: strokes,
                isFavorite: item['isFavorite'] ?? false,
              ));
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading creations: $e');
    }
  }

  Future<void> _saveCreationsToHive() async {
    try {
      final box = await Hive.openBox('userProgress');
      final List<Map<String, dynamic>> data = _myCreations.map((c) {
        return {
          'name': c.name,
          'date': c.date.millisecondsSinceEpoch,
          'thumbnailPath': c.thumbnailPath,
          'isFavorite': c.isFavorite,
          'strokes': c.strokes.map((s) {
            return {
              'points': s.points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
              'color': s.color.value,
              'size': s.size,
              'isEraser': s.isEraser,
            };
          }).toList(),
        };
      }).toList();
      await box.put('coloring_creations', data);
    } catch (e) {
      debugPrint('Error saving creations: $e');
      _snack('Error: Could not save artwork locally.');
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: (isError ? Colors.red : AppColors.primary)
                    .withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isError ? Colors.red : AppColors.primary)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: isError ? Colors.red : AppColors.primary,
                    size: 40),
              ),
              const SizedBox(height: 20),
              Text(msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
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
      backgroundColor: const Color(0xFFF2F3F8),
      appBar: _appBar(),
      body: IndexedStack(
        index: _selectedTab,
        children: [_buildColoringTab(), _buildCreationsTab()],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: AppColors.textDark,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(Translations.getColoringBook(context),
          style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: Colors.white,
          child: Row(children: [
            _tabBtn(0, Icons.brush_rounded, Translations.getColor(context)),
            _tabBtn(1, Icons.folder_open_rounded,
                Translations.getMyCreations(context)),
          ]),
        ),
      ),
    );
  }

  Widget _tabBtn(int idx, IconData icon, String label) {
    final on = _selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: on ? AppColors.primary : Colors.transparent,
                      width: 3))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: on ? AppColors.primary : Colors.grey),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: on ? AppColors.primary : Colors.grey)),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  COLORING TAB
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildColoringTab() {
    if (_selectedPage == null) return _gallery();
    return _canvas();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  GALLERY
  // ─────────────────────────────────────────────────────────────────────────

  Widget _gallery() {
    final cat = _categories[_selectedCategory];
    final pages = cat.pages
        .where((p) =>
            _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery))
        .toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)
              ]),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: Translations.getSearchColoringPages(context),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 46,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (_, i) {
            final c = _categories[i];
            final sel = _selectedCategory == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8, bottom: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? c.color : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border:
                      Border.all(color: sel ? c.color : Colors.grey.shade300),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                              color: c.color.withOpacity(0.3), blurRadius: 8)
                        ]
                      : [],
                ),
                child: Row(children: [
                  Text(c.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(c.name,
                      style: TextStyle(
                          color: sel ? Colors.white : Colors.grey.shade700,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13)),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 6),
      Expanded(
        child: pages.isEmpty
            ? Center(
                child: Text('No results',
                    style: TextStyle(color: Colors.grey.shade400)))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16),
                itemCount: pages.length,
                itemBuilder: (_, i) => _pageCard(pages[i], cat),
              ),
      ),
    ]);
  }

  Widget _pageCard(ColoringPage page, ColoringCategory cat) {
    // Check if this page is already completed
    final bool isCompleted =
        _myCreations.any((c) => c.thumbnailPath == page.imagePath);

    return GestureDetector(
      onTap: () {
        if (isCompleted) {
          _snack('Natapos mo na daytoyen! 🎨 (Finished already!)');
          return;
        }
        setState(() {
          _selectedPage = page;
          _strokes.clear();
          _redoStack.clear();
          _activeStroke = null;
          _coloringProgress = 0.0;
          _scale = 1.0;
          _transformationController.value = Matrix4.identity();
        });
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: cat.color.withOpacity(0.08),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20))),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        page.imagePath,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        color: isCompleted ? Colors.grey.shade400 : null,
                        colorBlendMode:
                            isCompleted ? BlendMode.saturation : null,
                        errorBuilder: (_, __, ___) => Icon(Icons.color_lens,
                            size: 52, color: cat.color.withOpacity(0.4)),
                      ),
                    ),
                  ),
                  if (isCompleted)
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check, size: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(page.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(children: [
                _diffChip(page.difficulty),
                const SizedBox(width: 8),
                Icon(Icons.timer_outlined,
                    size: 11, color: Colors.grey.shade500),
                const SizedBox(width: 2),
                Text(page.timeEstimate,
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _diffChip(String d) {
    final c = d == 'Easy'
        ? const Color(0xFF34C759)
        : d == 'Medium'
            ? const Color(0xFFFF9500)
            : const Color(0xFFFF3B30);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
      child: Text(d,
          style: const TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CANVAS SCREEN
  // ─────────────────────────────────────────────────────────────────────────

  Widget _canvas() {
    return Column(children: [
      _canvasHeader(),
      _progressBar(),
      Expanded(child: _drawingArea()),
      _toolPanel(),
    ]);
  }

  Widget _canvasHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textDark,
          onPressed: () => setState(() => _selectedPage = null),
        ),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_selectedPage!.name,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
              '${_selectedPage!.colors} colors • ${_selectedPage!.timeEstimate}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ])),
        GestureDetector(
          onTap: () {
            setState(() => _isZoomMode = !_isZoomMode);
            _snack(_isZoomMode
                ? 'Zoom mode: Multi-touch allowed'
                : 'Brush mode: Click to color');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: _isZoomMode
                    ? Colors.orange.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _isZoomMode ? Colors.orange : AppColors.primary,
                    width: 1)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_isZoomMode ? Icons.zoom_in_rounded : Icons.brush_rounded,
                    size: 14,
                    color: _isZoomMode ? Colors.orange : AppColors.primary),
                const SizedBox(width: 4),
                Text(_isZoomMode ? 'Zoom' : 'Brush',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            _isZoomMode ? Colors.orange : AppColors.primary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: _onDoubleTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Text('${(_scale * 100).toInt()}%',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
            icon: const Icon(Icons.save_rounded),
            color: AppColors.primary,
            onPressed: _saveCreation),
      ]),
    );
  }

  Widget _progressBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _coloringProgress,
              backgroundColor: Colors.grey.shade200,
              color: _coloringProgress >= 1.0
                  ? const Color(0xFF34C759)
                  : AppColors.primary,
              minHeight: 7,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('${(_coloringProgress * 100).toInt()}%',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _coloringProgress >= 1.0
                    ? const Color(0xFF34C759)
                    : AppColors.primary)),
      ]),
    );
  }

  Widget _drawingArea() {
    return Container(
      color: const Color(0xFFDDE0EA),
      child: Stack(children: [
        Positioned.fill(
          child: Listener(
            onPointerDown: (_) => setState(() => _pointerCount++),
            onPointerUp: (_) => setState(
                () => _pointerCount = (_pointerCount - 1).clamp(0, 10)),
            onPointerCancel: (_) => setState(
                () => _pointerCount = (_pointerCount - 1).clamp(0, 10)),
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: _minScale,
              maxScale: _maxScale,
              panEnabled: _isZoomMode,
              scaleEnabled: _isZoomMode,
              onInteractionUpdate: (details) {
                if (_isZoomMode) {
                  setState(() => _scale =
                      _transformationController.value.getMaxScaleOnAxis());
                }
              },
              child: Center(
                child: LayoutBuilder(builder: (ctx, cst) {
                  final side = cst.biggest.shortestSide.clamp(200.0, 500.0);
                  return SizedBox(
                      width: side, height: side, child: _drawingSurface(side));
                }),
              ),
            ),
          ),
        ),

        // ── Mini-map ────────────────────────────────────────────────
        if (_scale > 1.5)
          Positioned(
            bottom: 12,
            right: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.35), blurRadius: 8)
                    ]),
                child: Image.asset(
                  _selectedPage!.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),

        // ── Ripple ──────────────────────────────────────────────────
        if (_lastPos != null)
          AnimatedBuilder(
            animation: _rippleAnim,
            builder: (_, __) {
              final r = 55 * _rippleAnim.value;
              return Positioned(
                left: _lastPos!.dx - r,
                top: _lastPos!.dy - r,
                child: Opacity(
                  opacity: (1 - _rippleAnim.value).clamp(0.0, 1.0),
                  child: Container(
                    width: r * 2,
                    height: r * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _selectedColor, width: 2.5),
                    ),
                  ),
                ),
              );
            },
          ),

        // ── Completion banner ────────────────────────────────────────
        if (_coloringProgress >= 1.0)
          AnimatedBuilder(
            animation: _doneAnim,
            builder: (_, __) => Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Transform.scale(
                    scale: _doneAnim.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 22),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.93),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5)
                        ],
                      ),
                      child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🎨', style: TextStyle(fontSize: 44)),
                            SizedBox(height: 8),
                            Text('Nalpas! Great Work! 🌟',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DRAWING SURFACE
  //
  //  Stack order (bottom → top):
  //    1. White background
  //    2. PNG image  (the line art)
  //    3. CustomPaint strokes  ← drawn ON TOP so color is always visible
  //    4. GestureDetector captures touch on the top-most layer
  // ─────────────────────────────────────────────────────────────────────────

  Widget _drawingSurface(double side) {
    return ClipRect(
      child: Stack(fit: StackFit.expand, children: [
        // 1. White background
        Container(color: Colors.white),

        // 2. PNG line art — visible through the transparent parts of strokes
        IgnorePointer(
          child: Image.asset(
            _selectedPage!.imagePath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text('Image not found',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13)),
                  ]),
            ),
          ),
        ),

        // 3. Color strokes drawn ON TOP of the PNG
        //    GestureDetector here captures single-finger drawing
        GestureDetector(
          onPanStart: _paintStart,
          onPanUpdate: _paintUpdate,
          onPanEnd: _paintEnd,
          onTapDown: _paintTap,
          child: RepaintBoundary(
            child: CustomPaint(
              painter:
                  StrokePainter(strokes: _strokes, activeStroke: _activeStroke),
              size: Size(side, side),
              // Transparent child so gestures pass through unpainted areas
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TOOL PANEL
  // ─────────────────────────────────────────────────────────────────────────

  Widget _toolPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Color palette
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _palette.length,
            itemBuilder: (_, i) {
              final c = _palette[i];
              final sel = !_isEraser && _selectedColor == c;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedColor = c;
                  _isEraser = false;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: sel ? 40 : 30,
                  height: sel ? 40 : 30,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: sel
                          ? Colors.black87
                          : (c == Colors.white
                              ? Colors.grey.shade300
                              : Colors.transparent),
                      width: sel ? 2.5 : 1,
                    ),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: c.withOpacity(0.55),
                                blurRadius: 10,
                                spreadRadius: 1)
                          ]
                        : [],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Brush size
        Row(children: [
          Icon(Icons.brush, size: 13, color: Colors.grey.shade400),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: _brushSize,
                min: 5,
                max: 50,
                activeColor: AppColors.primary,
                inactiveColor: Colors.grey.shade200,
                onChanged: (v) => setState(() => _brushSize = v),
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isEraser ? Colors.white : _selectedColor,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Container(
                width: (_brushSize / 50 * 22).clamp(3.0, 22.0),
                height: (_brushSize / 50 * 22).clamp(3.0, 22.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isEraser
                      ? Colors.grey.shade400
                      : Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ]),

        const SizedBox(height: 6),

        // Tool buttons
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _tBtn(
            icon:
                _isEraser ? Icons.brush_rounded : Icons.auto_fix_normal_rounded,
            label: _isEraser ? 'Brush' : 'Eraser',
            active: _isEraser,
            onTap: () => setState(() => _isEraser = !_isEraser),
          ),
          _tBtn(
              icon: Icons.undo_rounded,
              label: 'Undo',
              active: false,
              disabled: _strokes.isEmpty,
              onTap: _undo),
          _tBtn(
              icon: Icons.redo_rounded,
              label: 'Redo',
              active: false,
              disabled: _redoStack.isEmpty,
              onTap: _redo),
          _tBtn(
            icon: Icons.delete_sweep_rounded,
            label: 'Clear',
            active: false,
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text('Clear Canvas?'),
                content: const Text('This will erase all your coloring.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      _clearAll();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          _tBtn(
              icon: Icons.save_rounded,
              label: 'Save',
              active: false,
              onTap: _saveCreation),
        ]),
      ]),
    );
  }

  Widget _tBtn(
      {required IconData icon,
      required String label,
      required bool active,
      required VoidCallback onTap,
      bool disabled = false}) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.3 : 1.0,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: active ? Colors.white : AppColors.primary, size: 18),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: active ? AppColors.primary : Colors.grey.shade600,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  MY CREATIONS TAB
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCreationsTab() {
    List<MyCreation> list = List.from(_myCreations);
    if (_sortMode == 1) {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortMode == 2) {
      list = list.where((c) => c.isFavorite).toList();
    } else {
      list.sort((a, b) => b.date.compareTo(a.date));
    }

    if (list.isEmpty) return _emptyCreations();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(children: [
          Text(
              '${_myCreations.length} artwork${_myCreations.length == 1 ? '' : 's'}',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          _sc(0, 'Recent'),
          const SizedBox(width: 6),
          _sc(1, 'A–Z'),
          const SizedBox(width: 6),
          _sc(2, '❤️'),
        ]),
      ),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.80,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16),
          itemCount: list.length,
          itemBuilder: (_, i) => _creationCard(list[i]),
        ),
      ),
    ]);
  }

  Widget _sc(int mode, String label) {
    final sel = _sortMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _sortMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
            color: sel ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14)),
        child: Text(label,
            style: TextStyle(
                color: sel ? Colors.white : Colors.grey.shade600,
                fontSize: 11,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _emptyCreations() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle),
          child:
              const Icon(Icons.color_lens, size: 44, color: AppColors.primary),
        ),
        const SizedBox(height: 18),
        const Text('Awan pay dagiti pinarsua.',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Kulayan ti maysa a pahina\nket idulin ti artwork mo!',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 13)),
          onPressed: () => setState(() => _selectedTab = 0),
          icon: const Icon(Icons.brush_rounded, color: Colors.white, size: 18),
          label: const Text('Start Coloring',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _creationCard(MyCreation creation) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Stack(fit: StackFit.expand, children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                color: const Color(0xFFF0F1FF),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(creation.thumbnailPath,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => Icon(Icons.image,
                          size: 40, color: Colors.grey.shade300)),
                )),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() => creation.isFavorite = !creation.isFavorite);
                  _saveCreationsToHive();
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                      creation.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: creation.isFavorite
                          ? Colors.red
                          : Colors.grey.shade400,
                      size: 15),
                ),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(11, 8, 11, 11),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(creation.name,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.schedule_rounded,
                  size: 10, color: Colors.grey.shade400),
              const SizedBox(width: 3),
              Text(creation.getTimeAgoLocalized(context),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  for (final cat in _categories) {
                    for (final page in cat.pages) {
                      if (page.imagePath == creation.thumbnailPath) {
                        setState(() {
                          _selectedPage = page;
                          _strokes
                            ..clear()
                            ..addAll(creation.strokes);
                          _redoStack.clear();
                          _activeStroke = null;
                          _selectedTab = 0;
                          _scale = 1.0;
                          _coloringProgress =
                              (_strokes.length / (page.colors * 50))
                                  .clamp(0.0, 1.0);
                        });
                        return;
                      }
                    }
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('I-edit',
                      style: TextStyle(
                          fontSize: 9,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
