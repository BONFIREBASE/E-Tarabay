import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import '../widgets/custom_back_button.dart';
import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
      'color': color.value,
      'size': size,
      'isEraser': isEraser,
    };
  }

  factory ColoringStroke.fromMap(Map<String, dynamic> map) {
    return ColoringStroke(
      points: (map['points'] as List)
          .map((p) => Offset(p['dx'] as double, p['dy'] as double))
          .toList(),
      color: Color(map['color'] as int),
      size: map['size'] as double,
      isEraser: map['isEraser'] as bool,
    );
  }
}

class MyCreation {
  final String name;
  final DateTime date;
  final String thumbnailPath;
  final String sourcePagePath;
  final String base64Image;
  final List<ColoringStroke> strokes;
  bool isFavorite;
  int? stars;
  int durationSeconds; // time spent coloring

  MyCreation({
    required this.name,
    required this.date,
    required this.thumbnailPath,
    this.sourcePagePath = '',
    this.base64Image = '',
    required this.strokes,
    this.isFavorite = false,
    this.stars,
    this.durationSeconds = 0,
  });

  String get formattedDuration {
    final d = Duration(seconds: durationSeconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  String getTimeAgoLocalized(BuildContext context) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return AppLocalizations.of(context)!.justNow;
    return AppLocalizations.of(context)!.timeAgo(diff.inMinutes);
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
      ..color = stroke.isEraser ? stroke.color : stroke.color.withOpacity(1.0);

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first,
        stroke.size / 2,
        Paint()
          ..style = PaintingStyle.fill
          ..color =
              stroke.isEraser ? stroke.color : stroke.color.withOpacity(1.0),
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
  double _brushSize = 30.0;
  bool _isEraser = false;
  MyCreation? _editingCreation;

  // ── Zoom & pan ─────────────────────────────────────────────────────────────
  bool _isZoomMode = false;
  DateTime? _coloringStartTime;
  final TransformationController _transformationController =
      TransformationController();

  // ── Bucket fill ────────────────────────────────────────────────────────────
  img.Image? _baseImage;
  img.Image? _coloredImage;
  ui.Image? _displayImage;
  int _filledPixelsCount = 0;
  double _lastSide = 300;
  bool _isLoadingAutoSave = false;
  final GlobalKey _canvasKey = GlobalKey();

  // Bucket fill undo/redo
  final List<img.Image> _bucketUndoImages = [];
  final List<int> _bucketUndoPixelCounts = [];
  final List<img.Image> _bucketRedoImages = [];
  final List<int> _bucketRedoPixelCounts = [];

  // ── Audio ──────────────────────────────────────────────────────────────────
  late AudioPlayer _audioPlayer;

  // ── Progress & animations ──────────────────────────────────────────────────
  late AnimationController _rippleController;
  late Animation<double> _rippleAnim;
  Offset? _lastPos;
  Offset? _tapDownPos;
  DateTime? _tapDownTime;

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
          name: 'Cat',
          imagePath: 'assets/images/paint2.png',
          difficulty: 'Easy',
          timeEstimate: '5 min',
          colors: 3),
      ColoringPage(
          name: 'Elephant',
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
          name: 'Apple',
          imagePath: 'assets/images/paint6.png',
          difficulty: 'Easy',
          timeEstimate: '3 min',
          colors: 2),
      ColoringPage(
          name: 'Banana',
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
    AudioManager.instance.playModuleMusic(ModuleMusic.kulay);
    _loadCreations();

    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _rippleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _rippleAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _rippleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rippleController.dispose();
    _transformationController.dispose();
    AudioManager.instance.resumeHomeMusic();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Gesture: separate drawing (1 pointer) from zoom/pan (2+ pointers)
  // ─────────────────────────────────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────────────────────
  //  Drawing (single-finger pan gestures on the INNER canvas)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _undo() async {
    if (_strokes.isNotEmpty) {
      setState(() => _redoStack.add(_strokes.removeLast()));
      _autoSave();
      return;
    }
    if (_bucketUndoImages.isEmpty) return;

    _bucketRedoImages.add(_coloredImage!.clone());
    _bucketRedoPixelCounts.add(_filledPixelsCount);
    _coloredImage = _bucketUndoImages.removeLast();
    _filledPixelsCount = _bucketUndoPixelCounts.removeLast();
    final uiImg = await _imageToUi(_coloredImage!);
    if (!mounted) return;
    setState(() => _displayImage = uiImg);
    _autoSave();
  }

  Future<void> _redo() async {
    if (_redoStack.isNotEmpty) {
      setState(() => _strokes.add(_redoStack.removeLast()));
      _autoSave();
      return;
    }
    if (_bucketRedoImages.isEmpty) return;

    _bucketUndoImages.add(_coloredImage!.clone());
    _bucketUndoPixelCounts.add(_filledPixelsCount);
    _coloredImage = _bucketRedoImages.removeLast();
    _filledPixelsCount = _bucketRedoPixelCounts.removeLast();
    final uiImg = await _imageToUi(_coloredImage!);
    if (!mounted) return;
    setState(() => _displayImage = uiImg);
    _autoSave();
  }

  void _clearAll() {
    setState(() {
      _strokes.clear();
      _redoStack.clear();
      _activeStroke = null;
      _filledPixelsCount = 0;
      if (_baseImage != null) {
        _coloredImage = _baseImage!.clone();
      }
      _displayImage = null;
    });
    _bucketUndoImages.clear();
    _bucketUndoPixelCounts.clear();
    _bucketRedoImages.clear();
    _bucketRedoPixelCounts.clear();
    _autoSave();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Bucket fill helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadPageImage() async {
    if (_selectedPage == null) return;
    try {
      final data = await rootBundle.load(_selectedPage!.imagePath);
      final bytes = data.buffer.asUint8List();
      _baseImage = img.decodeImage(bytes);
      if (_baseImage == null) return;
      _coloredImage = _baseImage!.clone();
      _displayImage = await _imageToUi(_coloredImage!);
    } catch (e) {
      debugPrint('Error loading coloring image: $e');
    }
  }

  Future<ui.Image> _imageToUi(img.Image image) async {
    final pngBytes = img.encodePng(image);
    final codec = await ui.instantiateImageCodec(pngBytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  String _autoSaveKey(String pageName) => 'kulay_autosave_$pageName';

  Future<String> _autoSaveImagePath(String pageName) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/kulay_autosave_$pageName.png';
  }

  Future<void> _autoSave() async {
    if (_selectedPage == null) return;
    final pageName = _selectedPage!.name;
    final key = _autoSaveKey(pageName);
    final prefs = await SharedPreferences.getInstance();

    // Save strokes
    final strokesJson = jsonEncode(_strokes.map((s) => s.toMap()).toList());
    await prefs.setString('${key}_strokes', strokesJson);

    // Save bucket-fill image
    if (_coloredImage != null) {
      final path = await _autoSaveImagePath(pageName);
      final bytes = img.encodePng(_coloredImage!);
      await File(path).writeAsBytes(bytes);
      await prefs.setString('${key}_imagePath', path);
    }

    // Save metadata
    await prefs.setInt('${key}_filledPixels', _filledPixelsCount);
    await prefs.setInt('${key}_color', _selectedColor.value);
    await prefs.setDouble('${key}_brushSize', _brushSize);
    await prefs.setBool('${key}_isEraser', _isEraser);
  }

  Future<void> _loadAutoSave() async {
    if (_selectedPage == null) return;
    final pageName = _selectedPage!.name;
    final key = _autoSaveKey(pageName);
    final prefs = await SharedPreferences.getInstance();

    final strokesJson = prefs.getString('${key}_strokes');
    final imagePath = prefs.getString('${key}_imagePath');
    final filledPixels = prefs.getInt('${key}_filledPixels');
    final colorVal = prefs.getInt('${key}_color');
    final brushSize = prefs.getDouble('${key}_brushSize');
    final isEraser = prefs.getBool('${key}_isEraser');

    List<ColoringStroke>? loadedStrokes;
    img.Image? loadedColoredImage;
    ui.Image? loadedDisplayImage;

    if (strokesJson != null && strokesJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(strokesJson);
        loadedStrokes = decoded
            .map((m) => ColoringStroke.fromMap(m as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error loading autosave strokes: $e');
      }
    }

    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final image = img.decodeImage(bytes);
          if (image != null && _baseImage != null) {
            loadedColoredImage = image;
            loadedDisplayImage = await _imageToUi(loadedColoredImage);
          }
        }
      } catch (e) {
        debugPrint('Error loading autosave image: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      if (loadedStrokes != null) {
        _strokes.clear();
        _strokes.addAll(loadedStrokes);
      }
      if (loadedColoredImage != null) _coloredImage = loadedColoredImage;
      if (loadedDisplayImage != null) _displayImage = loadedDisplayImage;
      if (filledPixels != null) _filledPixelsCount = filledPixels;
      if (colorVal != null) _selectedColor = Color(colorVal);
      if (brushSize != null) _brushSize = brushSize;
      if (isEraser != null) _isEraser = isEraser;
      _isLoadingAutoSave = false;
    });
  }

  Future<void> _clearAutoSaveForPage(String pageName) async {
    final key = _autoSaveKey(pageName);
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('${key}_strokes');
    await prefs.remove('${key}_imagePath');
    await prefs.remove('${key}_filledPixels');
    await prefs.remove('${key}_color');
    await prefs.remove('${key}_brushSize');
    await prefs.remove('${key}_isEraser');

    final imagePath = await _autoSaveImagePath(pageName);
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _clearAutoSave() async {
    if (_selectedPage == null) return;
    await _clearAutoSaveForPage(_selectedPage!.name);
  }

  Offset _localToImageCoords(Offset local, double side) {
    if (_baseImage == null) return Offset.zero;
    final imgW = _baseImage!.width.toDouble();
    final imgH = _baseImage!.height.toDouble();
    final imgRatio = imgW / imgH;

    double drawW, drawH, offsetX, offsetY;
    if (imgRatio > 1.0) {
      drawW = side;
      drawH = side / imgRatio;
      offsetX = 0;
      offsetY = (side - drawH) / 2;
    } else {
      drawH = side;
      drawW = side * imgRatio;
      offsetX = (side - drawW) / 2;
      offsetY = 0;
    }

    final x = ((local.dx - offsetX) / drawW * imgW)
        .toInt()
        .clamp(0, _baseImage!.width - 1);
    final y = ((local.dy - offsetY) / drawH * imgH)
        .toInt()
        .clamp(0, _baseImage!.height - 1);
    return Offset(x.toDouble(), y.toDouble());
  }

  Color _sampleBaseColor(Offset local) {
    if (_baseImage == null) return Colors.white;
    final coords = _localToImageCoords(local, _lastSide);
    final ix = coords.dx.toInt().clamp(0, _baseImage!.width - 1);
    final iy = coords.dy.toInt().clamp(0, _baseImage!.height - 1);
    final p = _baseImage!.getPixel(ix, iy);
    return Color.fromARGB(255, p.r.toInt(), p.g.toInt(), p.b.toInt());
  }

  int _floodFillBfs(
    img.Image image,
    int startX,
    int startY,
    int fillR,
    int fillG,
    int fillB, {
    int threshold = 20,
    int maxPixels = 15000,
  }) {
    final w = image.width;
    final h = image.height;
    if (startX < 0 || startX >= w || startY < 0 || startY >= h) return 0;

    final startPixel = image.getPixel(startX, startY);
    final startR = startPixel.r.toInt();
    final startG = startPixel.g.toInt();
    final startB = startPixel.b.toInt();
    final startA = startPixel.a.toInt();

    // Already filled with same color? Skip.
    if (startR == fillR && startG == fillG && startB == fillB) return 0;

    // Use Set for visited when image is huge, List<bool> for small/medium
    final int pixelCount = w * h;
    final bool useSet = pixelCount > 250000;
    final Set<int>? visitedSet = useSet ? <int>{} : null;
    final List<bool>? visitedList =
        useSet ? null : List<bool>.filled(pixelCount, false);

    final qx = <int>[startX];
    final qy = <int>[startY];
    int head = 0;

    if (useSet) {
      visitedSet!.add(startY * w + startX);
    } else {
      visitedList![startY * w + startX] = true;
    }

    int filled = 0;

    while (head < qx.length) {
      final x = qx[head];
      final y = qy[head];
      head++;

      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final a = pixel.a.toInt();

      // Skip transparent line-art pixels (alpha < 50)
      if (a < 50) continue;

      // Skip pixels that differ too much from the starting color
      if ((r - startR).abs() > threshold ||
          (g - startG).abs() > threshold ||
          (b - startB).abs() > threshold ||
          (a - startA).abs() > threshold) {
        continue;
      }

      pixel.r = fillR;
      pixel.g = fillG;
      pixel.b = fillB;
      pixel.a = 255;
      filled++;

      if (filled >= maxPixels) break;

      void tryAdd(int nx, int ny) {
        if (nx < 0 || nx >= w || ny < 0 || ny >= h) return;
        final idx = ny * w + nx;
        if (useSet) {
          if (visitedSet!.contains(idx)) return;
          visitedSet.add(idx);
        } else {
          if (visitedList![idx]) return;
          visitedList[idx] = true;
        }
        qx.add(nx);
        qy.add(ny);
      }

      tryAdd(x + 1, y);
      tryAdd(x - 1, y);
      tryAdd(x, y + 1);
      tryAdd(x, y - 1);
    }
    return filled;
  }

  void _onBucketTap(Offset localPosition) {
    if (_coloredImage == null || _baseImage == null) return;

    final coords = _localToImageCoords(localPosition, _lastSide);
    final imgX = coords.dx.toInt();
    final imgY = coords.dy.toInt();

    final fillR = _selectedColor.red;
    final fillG = _selectedColor.green;
    final fillB = _selectedColor.blue;

    // Save snapshot for undo before modifying (cap at 10)
    if (_bucketUndoImages.length >= 10) {
      _bucketUndoImages.removeAt(0);
      _bucketUndoPixelCounts.removeAt(0);
    }
    _bucketUndoImages.add(_coloredImage!.clone());
    _bucketUndoPixelCounts.add(_filledPixelsCount);
    _bucketRedoImages.clear();
    _bucketRedoPixelCounts.clear();

    final filledCount = _floodFillBfs(
      _coloredImage!,
      imgX,
      imgY,
      fillR,
      fillG,
      fillB,
      threshold: 40,
    );

    if (filledCount == 0) return;

    _filledPixelsCount += filledCount;

    _imageToUi(_coloredImage!).then((uiImg) {
      if (!mounted) return;
      setState(() {
        _displayImage = uiImg;
        _lastPos = localPosition;
      });
      _rippleController.forward(from: 0);
    });
    _autoSave();

    HapticFeedback.lightImpact();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Save
  // ─────────────────────────────────────────────────────────────────────────

  void _showStarRatingDialog(MyCreation creation) {
    int selectedStars = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(AppLocalizations.of(context)!.rateYourArtwork,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.howManyStars,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final idx = i + 1;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedStars = idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        idx <= selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 40,
                        color: idx <= selectedStars
                            ? const Color(0xFFFFB800)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
              onPressed: () {
                creation.stars = selectedStars > 0 ? selectedStars : null;
                _saveCreationsToHive();
                Navigator.pop(context);
                _snack(AppLocalizations.of(context)!.saved);
                setState(() {
                  _strokes.clear();
                  _redoStack.clear();
                  _activeStroke = null;
                  _editingCreation = null;
                  _selectedPage = null;
                });
              },
              child: Text(AppLocalizations.of(context)!.done,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>> _captureThumbnailData() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        return {'path': _selectedPage!.imagePath, 'base64': ''};
      }

      final image = await boundary.toImage(pixelRatio: 1.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return {'path': _selectedPage!.imagePath, 'base64': ''};
      }

      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/creation_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes);

      String base64Str = '';
      try {
        final decoded = img.decodeImage(pngBytes);
        if (decoded != null) {
          final resized = img.copyResize(decoded, width: 220);
          final jpegBytes = img.encodeJpg(resized, quality: 60);
          base64Str = base64Encode(jpegBytes);
        }
      } catch (e) {
        debugPrint('Error encoding base64 thumbnail: $e');
      }

      return {'path': path, 'base64': base64Str};
    } catch (e) {
      debugPrint('Error capturing thumbnail: $e');
      return {'path': _selectedPage!.imagePath, 'base64': ''};
    }
  }

  bool _isCurrentPageSaved() {
    if (_selectedPage == null) return false;
    if (_editingCreation != null) return true;
    return _myCreations.any((c) =>
        c.sourcePagePath == _selectedPage!.imagePath ||
        c.thumbnailPath == _selectedPage!.imagePath);
  }

  String _localizedPageName(String name) {
    final l10n = AppLocalizations.of(context)!;
    switch (name) {
      case 'Puppy':
        return l10n.pagePuppy;
      case 'Cat':
        return l10n.pageKuting;
      case 'Elephant':
        return l10n.pageElepante;
      case 'Flower Basket':
        return l10n.pageFlowerBasket;
      case 'Rose':
        return l10n.pageRose;
      case 'Apple':
        return l10n.pageMansanas;
      case 'Banana':
        return l10n.pageSaging;
      case 'Teddy Bear':
        return l10n.pageTeddyBear;
      case 'Soda Pop':
        return l10n.pageSodaPop;
      default:
        return name;
    }
  }

  void _saveCreation() {
    if (_strokes.isEmpty) {
      _snack(AppLocalizations.of(context)!.colorSomethingFirst);
      return;
    }
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(AppLocalizations.of(context)!.saveYourArtwork,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.giveArtworkName,
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
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              final thumbData = await _captureThumbnailData();
              final thumbnailPath = thumbData['path'] ?? _selectedPage!.imagePath;
              final base64Img = thumbData['base64'] ?? '';
              final elapsed = _coloringStartTime != null
                  ? DateTime.now().difference(_coloringStartTime!).inSeconds
                  : 0;
              late MyCreation creation;
              if (_editingCreation != null) {
                // Update existing creation in-place
                final idx = _myCreations.indexOf(_editingCreation!);
                if (idx >= 0) {
                  creation = MyCreation(
                    name: ctrl.text.trim().isEmpty
                        ? _editingCreation!.name
                        : ctrl.text.trim(),
                    date: DateTime.now(),
                    thumbnailPath: thumbnailPath,
                    sourcePagePath: _selectedPage!.imagePath,
                    base64Image: base64Img.isNotEmpty
                        ? base64Img
                        : _editingCreation!.base64Image,
                    strokes: List.from(_strokes),
                    isFavorite: _editingCreation!.isFavorite,
                    stars: _editingCreation!.stars,
                    durationSeconds:
                        _editingCreation!.durationSeconds + elapsed,
                  );
                  _myCreations[idx] = creation;
                } else {
                  creation = _editingCreation!;
                }
                setState(() => _editingCreation = null);
              } else {
                creation = MyCreation(
                  name: ctrl.text.trim().isEmpty
                      ? '${AppLocalizations.of(context)!.myArtworkDefault} ${_myCreations.length + 1}'
                      : ctrl.text.trim(),
                  date: DateTime.now(),
                  thumbnailPath: thumbnailPath,
                  sourcePagePath: _selectedPage!.imagePath,
                  base64Image: base64Img,
                  strokes: List.from(_strokes),
                  durationSeconds: elapsed,
                );
                setState(() => _myCreations.add(creation));

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

              // Sync to UserProvider
              if (mounted) {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final cat = _categories[_selectedCategory];
                final pageIndex = cat.pages.indexOf(_selectedPage!);
                userProvider.updateKulayProgress('coloring', true,
                    category: cat.name, index: pageIndex);
              }

              _saveCreationsToHive();
              _clearAutoSave();
              if (mounted) {
                Navigator.pop(context);
                if (creation.stars == null) {
                  _showStarRatingDialog(creation);
                } else {
                  _snack(AppLocalizations.of(context)!.saved);
                  setState(() {
                    _strokes.clear();
                    _redoStack.clear();
                    _activeStroke = null;
                    _editingCreation = null;
                    _selectedPage = null;
                  });
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.save,
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
                sourcePagePath: item['sourcePagePath'] ?? '',
                base64Image: item['base64Image'] ?? '',
                strokes: strokes,
                isFavorite: item['isFavorite'] ?? false,
                stars: item['stars'],
                durationSeconds: item['durationSeconds'] ?? 0,
              ));
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading creations: $e');
    }
    await _syncKulayProgressWithCreations();
  }

  Future<void> _syncKulayProgressWithCreations() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    for (final cat in _categories) {
      for (int i = 0; i < cat.pages.length; i++) {
        final page = cat.pages[i];
        final hasCreation = _myCreations.any((c) =>
            c.sourcePagePath == page.imagePath ||
            c.thumbnailPath == page.imagePath);
        if (!hasCreation && userProvider.isKulayPageCompleted(cat.name, i)) {
          await userProvider.updateKulayProgress('coloring', false,
              category: cat.name, index: i);
        }
      }
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
          'sourcePagePath': c.sourcePagePath,
          'base64Image': c.base64Image,
          'isFavorite': c.isFavorite,
          'stars': c.stars,
          'durationSeconds': c.durationSeconds,
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
      _snack(AppLocalizations.of(context)!.errorSaveLocal, isError: true);
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
                        ? LucideIcons.circle_alert
                        : LucideIcons.circle_check,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: _appBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FE), Color(0xFFEDF1F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: IndexedStack(
          index: _selectedTab,
          children: [_buildColoringTab(), _buildCreationsTab()],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      leading: CustomBackButton(
        iconColor: AppColors.textDark,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(AppLocalizations.of(context)!.coloringBook,
          style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: Colors.white,
          child: Row(children: [
            _tabBtn(
                0, LucideIcons.brush, AppLocalizations.of(context)!.color),
            _tabBtn(1, LucideIcons.folder_open,
                AppLocalizations.of(context)!.myCreations),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: on
                ? const LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: const Color(0xFF00F2FE).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: on ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: on ? FontWeight.bold : FontWeight.w500,
                    color: on ? Colors.white : Colors.grey.shade600)),
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

  IconData _categoryIcon(String name) {
    switch (name) {
      case 'Animals':
        return LucideIcons.paw_print;
      case 'Flowers':
        return LucideIcons.flower;
      case 'Fruits':
        return LucideIcons.apple;
      case 'Toys':
        return LucideIcons.blocks;
      default:
        return LucideIcons.palette;
    }
  }

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
              hintText: AppLocalizations.of(context)!.searchColoringPages,
              prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
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
                  Icon(_categoryIcon(c.name),
                      size: 15,
                      color: sel ? Colors.white : c.color),
                  const SizedBox(width: 6),
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
                child: Text(AppLocalizations.of(context)!.noResults,
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
    // Check if this page is already completed (local creations + provider)
    final pageIndex = cat.pages.indexOf(page);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bool isCompleted = _myCreations.any((c) =>
            c.sourcePagePath == page.imagePath ||
            c.thumbnailPath == page.imagePath) ||
        (pageIndex >= 0 &&
            userProvider.isKulayPageCompleted(cat.name, pageIndex));

    return GestureDetector(
      onTap: () {
        if (isCompleted) {
          _snack(AppLocalizations.of(context)!.finishedAlready);
          return;
        }
        setState(() {
          _selectedPage = page;
          _strokes.clear();
          _redoStack.clear();
          _activeStroke = null;
          _baseImage = null;
          _coloredImage = null;
          _displayImage = null;
          _filledPixelsCount = 0;
          _isLoadingAutoSave = true;
          _coloringStartTime = DateTime.now();
        });
        _loadPageImage().then((_) => _loadAutoSave());
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isCompleted
                    ? Colors.green.withOpacity(0.5)
                    : cat.color.withOpacity(0.25),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: cat.color.withOpacity(0.12),
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
                        errorBuilder: (_, __, ___) => Icon(LucideIcons.palette,
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
                        child: Icon(LucideIcons.check, size: 16, color: Colors.white),
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
              Text(_localizedPageName(page.name),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(children: [
                _diffChip(page.difficulty),
                const SizedBox(width: 8),
                Icon(LucideIcons.timer,
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
      Expanded(
        child: Stack(
          children: [
            _drawingArea(),
            if (_isLoadingAutoSave)
              Container(
                color: Colors.white.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading your artwork...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      _toolPanel(),
    ]);
  }

  Widget _canvasHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(children: [
        IconButton(
          icon: const Icon(LucideIcons.arrow_left),
          color: AppColors.textDark,
          onPressed: () => setState(() {
            _selectedPage = null;
            _editingCreation = null;
          }),
        ),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_localizedPageName(_selectedPage!.name),
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
              '${_selectedPage!.colors} ${AppLocalizations.of(context)!.colorsLabel} • ${_selectedPage!.timeEstimate}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ])),
      ]),
    );
  }

  Widget _drawingArea() {
    return Container(
      color: const Color(0xFFDDE0EA),
      child: Stack(children: [
        Positioned.fill(
          child: Center(
            child: LayoutBuilder(builder: (ctx, cst) {
              final side = cst.biggest.shortestSide.clamp(200.0, 500.0);
              return InteractiveViewer(
                transformationController: _transformationController,
                panEnabled: _isZoomMode,
                scaleEnabled: _isZoomMode,
                minScale: 1.0,
                maxScale: 5.0,
                clipBehavior: Clip.none,
                child: SizedBox(
                    width: side, height: side, child: _drawingSurface(side)),
              );
            }),
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
    _lastSide = side;
    return RepaintBoundary(
      key: _canvasKey,
      child: ClipRect(
        child: Stack(fit: StackFit.expand, children: [
          // 1. White background
          Container(color: Colors.white),

          // 2. Image — bucket-filled display or original PNG
          IgnorePointer(
            child: _displayImage != null
                ? RawImage(
                    image: _displayImage,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  )
                : Image.asset(
                    _selectedPage!.imagePath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.image_off,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            Text(AppLocalizations.of(context)!.imageNotFound,
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 13)),
                          ]),
                    ),
                  ),
          ),

          // 3. Color strokes drawn ON TOP
          //    Tap = bucket fill, Drag = brush stroke.
          //    Blocked in Zoom mode so pan gestures pass through.
          IgnorePointer(
            ignoring: _isZoomMode,
            child: Listener(
              onPointerDown: (e) {
                _tapDownPos = e.localPosition;
                _tapDownTime = DateTime.now();
                _redoStack.clear();
                setState(() {
                  _activeStroke = ColoringStroke(
                    points: [e.localPosition],
                    color: _isEraser
                        ? _sampleBaseColor(e.localPosition)
                        : _selectedColor,
                    size: _brushSize,
                    isEraser: _isEraser,
                  );
                  _lastPos = e.localPosition;
                });
              },
              onPointerMove: (e) {
                if (_activeStroke == null) return;
                setState(() {
                  _activeStroke = _activeStroke!.copyWith(
                    points: [..._activeStroke!.points, e.localPosition],
                  );
                  _lastPos = e.localPosition;
                });
              },
              onPointerUp: (e) {
                if (_activeStroke != null) {
                  final wasTap = _tapDownPos != null &&
                      (e.localPosition - _tapDownPos!).distance < 10 &&
                      _tapDownTime != null &&
                      DateTime.now().difference(_tapDownTime!).inMilliseconds <
                          300;
                  if (wasTap) {
                    setState(() => _activeStroke = null);
                    _onBucketTap(e.localPosition);
                  } else {
                    setState(() {
                      _strokes.add(_activeStroke!);
                      _activeStroke = null;
                    });
                    _rippleController.forward(from: 0);
                    _autoSave();
                  }
                }
                _tapDownPos = null;
                _tapDownTime = null;
              },
              onPointerCancel: (e) {
                if (_activeStroke != null) setState(() => _activeStroke = null);
                _tapDownPos = null;
                _tapDownTime = null;
              },
              child: CustomPaint(
                painter: StrokePainter(
                    strokes: _strokes, activeStroke: _activeStroke),
                size: Size(side, side),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ]),
      ),
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
          Icon(LucideIcons.brush, size: 13, color: Colors.grey.shade400),
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
            icon: _isZoomMode
                ? LucideIcons.maximize
                : LucideIcons.minimize,
            label: _isZoomMode
                ? AppLocalizations.of(context)!.zoomOff
                : AppLocalizations.of(context)!.zoomOn,
            active: _isZoomMode,
            onTap: () => setState(() => _isZoomMode = !_isZoomMode),
          ),
          _tBtn(
            icon:
                _isEraser ? LucideIcons.brush : LucideIcons.wand_sparkles,
            label: _isEraser
                ? AppLocalizations.of(context)!.brush
                : AppLocalizations.of(context)!.eraser,
            active: _isEraser,
            onTap: () => setState(() => _isEraser = !_isEraser),
          ),
          _tBtn(
              icon: LucideIcons.undo_2,
              label: AppLocalizations.of(context)!.undo,
              active: false,
              disabled: _strokes.isEmpty && _bucketUndoImages.isEmpty,
              onTap: _undo),
          _tBtn(
              icon: LucideIcons.redo_2,
              label: AppLocalizations.of(context)!.redo,
              active: false,
              disabled: _redoStack.isEmpty && _bucketRedoImages.isEmpty,
              onTap: _redo),
          _tBtn(
            icon: LucideIcons.trash_2,
            label: AppLocalizations.of(context)!.clear,
            active: false,
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text(AppLocalizations.of(context)!.clearCanvasQuestion),
                content:
                    Text(AppLocalizations.of(context)!.eraseColoringWarning),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      _clearAll();
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.clear,
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          _tBtn(
              icon: _editingCreation != null
                  ? LucideIcons.save
                  : (_isCurrentPageSaved()
                      ? LucideIcons.eye
                      : LucideIcons.save),
              label: _editingCreation != null
                  ? AppLocalizations.of(context)!.update
                  : (_isCurrentPageSaved()
                      ? 'View'
                      : AppLocalizations.of(context)!.save),
              active: false,
              onTap: _editingCreation != null
                  ? _saveCreation
                  : (_isCurrentPageSaved()
                      ? () => setState(() => _selectedTab = 1)
                      : _saveCreation)),
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
              const Icon(LucideIcons.palette, size: 44, color: AppColors.primary),
        ),
        const SizedBox(height: 18),
        Text(AppLocalizations.of(context)!.noArtworksYet,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context)!.colorPagePrompt,
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
          icon: const Icon(LucideIcons.brush, color: Colors.white, size: 18),
          label: Text(AppLocalizations.of(context)!.startColoring,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _creationCard(MyCreation creation) {
    return GestureDetector(
      onTap: () => _showCreationDetail(creation),
      child: Container(
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
                    child: creation.thumbnailPath.startsWith('assets/')
                        ? Image.asset(creation.thumbnailPath,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, __, ___) => Icon(LucideIcons.image,
                                size: 40, color: Colors.grey.shade300))
                        : Image.file(File(creation.thumbnailPath),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, __, ___) => Icon(LucideIcons.image,
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
                            ? LucideIcons.heart
                            : LucideIcons.heart,
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
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              if (creation.stars != null)
                Row(
                  children: [
                    ...List.generate(
                        5,
                        (i) => Icon(
                              i < creation.stars! ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 14,
                              color: i < creation.stars!
                                  ? const Color(0xFFFFB800)
                                  : const Color(0xFFCBD5E1),
                            )),
                  ],
                )
              else
                const SizedBox.shrink(),
              const SizedBox(height: 4),
              Row(children: [
                Icon(LucideIcons.clock,
                    size: 10, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text(creation.formattedDuration,
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                const Spacer(),
                Text(AppLocalizations.of(context)!.tapToView,
                    style: TextStyle(
                        fontSize: 9,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showCreationDetail(MyCreation creation) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(creation.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            if (creation.stars != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          5,
                          (i) => Icon(
                                i < creation.stars! ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 28,
                                color: i < creation.stars!
                                    ? const Color(0xFFFFB800)
                                    : const Color(0xFFCBD5E1),
                              )),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${creation.stars} / 5 Stars • Color Detail & Completeness',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: const Color(0xFFF0F1FF),
                    child: creation.thumbnailPath.startsWith('assets/')
                        ? Image.asset(creation.thumbnailPath,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high)
                        : Image.file(File(creation.thumbnailPath),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                '${creation.date.day}/${creation.date.month}/${creation.date.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(LucideIcons.pencil, size: 18),
                      label: Text(AppLocalizations.of(context)!.edit),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        for (final cat in _categories) {
                          for (final page in cat.pages) {
                            if (page.imagePath == creation.thumbnailPath ||
                                creation.sourcePagePath == page.imagePath) {
                              setState(() {
                                _selectedPage = page;
                                _strokes
                                  ..clear()
                                  ..addAll(creation.strokes);
                                _redoStack.clear();
                                _activeStroke = null;
                                _editingCreation = creation;
                                _selectedTab = 0;
                                _coloringStartTime = DateTime.now();
                              });
                              return;
                            }
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon:
                          const Icon(LucideIcons.trash_2, size: 18, color: Colors.red),
                      label: Text(AppLocalizations.of(context)!.delete,
                          style: const TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeleteCreation(creation);
                      },
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

  void _confirmDeleteCreation(MyCreation creation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(LucideIcons.triangle_alert, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(AppLocalizations.of(context)!.deleteArtwork)),
          ],
        ),
        content: Text(AppLocalizations.of(context)!.confirmDeleteArtwork),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCreation(creation);
            },
            child: Text(AppLocalizations.of(context)!.delete,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCreation(MyCreation creation) async {
    setState(() => _myCreations.remove(creation));
    _saveCreationsToHive();
    if (!creation.thumbnailPath.startsWith('assets/')) {
      try {
        File(creation.thumbnailPath).deleteSync();
      } catch (e) {
        debugPrint('Error deleting thumbnail: $e');
      }
    }

    // Reset the original coloring page so it can be colored again
    if (creation.sourcePagePath.isNotEmpty) {
      for (final cat in _categories) {
        final pageIndex = cat.pages.indexWhere(
          (p) => p.imagePath == creation.sourcePagePath,
        );
        if (pageIndex >= 0) {
          final pageName = cat.pages[pageIndex].name;
          _clearAutoSaveForPage(pageName);
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.updateKulayProgress('coloring', false,
              category: cat.name, index: pageIndex);
          break;
        }
      }
    }

    _snack(AppLocalizations.of(context)!.artworkDeleted);
    await _syncKulayProgressWithCreations();
  }
}
