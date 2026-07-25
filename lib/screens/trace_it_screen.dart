import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import '../data/letter_tracing_data.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/success_modal.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  HIDDEN-GUIDE TRACING PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _TracePainter extends CustomPainter {
  final List<Offset> guidePoints;
  final List<Offset> tracedPoints;
  final Color color;
  final bool isCompleted;
  final Set<int> visitedPoints;
  final double scale;
  final Offset offset;
  final double? guideProgress;
  final String _letter;

  _TracePainter({
    required this.guidePoints,
    required this.tracedPoints,
    required this.color,
    required this.isCompleted,
    required this.visitedPoints,
    required this.scale,
    required this.offset,
    required String letter,
    this.guideProgress,
  }) : _letter = letter;

  @override
  void paint(Canvas canvas, Size size) {
    const userStroke = 22.0;

    _drawLetter(canvas, size);

    // User stroke on top
    if (tracedPoints.length >= 2) {
      canvas.drawPath(
        _buildPath(tracedPoints),
        Paint()
          ..color = isCompleted ? Colors.green : color
          ..style = PaintingStyle.stroke
          ..strokeWidth = userStroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  /// Builds a laid-out paragraph for the current glyph with the given paint.
  ui.Paragraph _glyph(double fontSize, Paint paint, double maxWidth) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
    ))
      ..pushStyle(ui.TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        foreground: paint,
      ))
      ..addText(_letter);
    final p = pb.build();
    p.layout(ui.ParagraphConstraints(width: maxWidth));
    return p;
  }

  void _drawLetter(Canvas canvas, Size size) {
    final fontSize = (_letter.length > 1 ? 165.0 : 210.0) * scale;
    final full = Rect.fromLTWH(0, 0, size.width, size.height);

    // Filled glyph used as a mask so the dashes stay inside the letter.
    final fillPara =
        _glyph(fontSize, Paint()..color = const Color(0xFFFFFFFF), size.width);
    final textOffsetY = (size.height - fillPara.height) / 2;
    final glyphWidth = fillPara.maxIntrinsicWidth;
    final glyphLeft = (size.width - glyphWidth) / 2;

    if (isCompleted) {
      // Celebration: solid filled letter in green.
      final greenPara = _glyph(
          fontSize, Paint()..color = const Color(0xFF4CAF50), size.width);
      canvas.drawParagraph(greenPara, Offset(0, textOffsetY));
      return;
    }

    // 1. Dashed fill clipped to the letter body.
    canvas.saveLayer(full, Paint());
    canvas.drawParagraph(fillPara, Offset(0, textOffsetY));
    canvas.saveLayer(full, Paint()..blendMode = BlendMode.srcIn);
    final dashPaint = Paint()
      ..color = color.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    const lineSpacing = 15.0;
    const dashLen = 11.0;
    const gapLen = 8.0;
    for (double y = 0; y < size.height; y += lineSpacing) {
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y),
            Offset(math.min(x + dashLen, size.width), y), dashPaint);
        x += dashLen + gapLen;
      }
    }
    canvas.restore(); // dash layer
    canvas.restore(); // mask layer

    // 2. Hollow outline of the letter on top.
    final outlinePara = _glyph(
      fontSize,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeJoin = StrokeJoin.round
        ..color = color,
      size.width,
    );
    canvas.drawParagraph(outlinePara, Offset(0, textOffsetY));

    // 3. Per-letter start marker: map the letter's real stroke-start (and
    //    direction) from the guide data onto the rendered glyph box.
    final valid =
        guidePoints.where((p) => !p.dx.isNaN && !p.dy.isNaN).toList();
    if (valid.isNotEmpty) {
      double minX = valid.first.dx, maxX = valid.first.dx;
      double minY = valid.first.dy, maxY = valid.first.dy;
      for (final p in valid) {
        if (p.dx < minX) minX = p.dx;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dy > maxY) maxY = p.dy;
      }
      final gw = (maxX - minX).abs() < 1 ? 1.0 : (maxX - minX);
      final gh = (maxY - minY).abs() < 1 ? 1.0 : (maxY - minY);
      final p0 = valid.first;
      final nx = ((p0.dx - minX) / gw).clamp(0.0, 1.0);
      final ny = ((p0.dy - minY) / gh).clamp(0.0, 1.0);

      // Approximate the glyph's visual box within the paragraph.
      final glyphTop = textOffsetY + fillPara.height * 0.16;
      final glyphH = fillPara.height * 0.70;
      final at = Offset(glyphLeft + nx * glyphWidth, glyphTop + ny * glyphH);

      // Stroke direction from the first segment.
      double angle = math.pi / 2; // default: downward
      if (valid.length > 1) {
        final p1 = valid[1];
        angle = math.atan2(p1.dy - p0.dy, p1.dx - p0.dx);
      }
      _drawStartMarker(canvas, at, angle);
    }
  }

  void _drawStartMarker(Canvas canvas, Offset at, double angle) {
    final pulse = guideProgress != null && guideProgress! >= 0
        ? (0.85 + 0.15 * math.sin(guideProgress! * math.pi * 2))
        : 1.0;

    final arrowPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Direction arrow pointing the way the first stroke goes.
    final dir = Offset(math.cos(angle), math.sin(angle));
    final base = at + dir * 15;
    final tip = at + dir * 30;
    canvas.drawLine(base, tip, arrowPaint);
    final head1 =
        tip + Offset(math.cos(angle + 2.5), math.sin(angle + 2.5)) * 8;
    final head2 =
        tip + Offset(math.cos(angle - 2.5), math.sin(angle - 2.5)) * 8;
    canvas.drawLine(tip, head1, arrowPaint);
    canvas.drawLine(tip, head2, arrowPaint);

    // Start dot with a "1".
    canvas.drawCircle(
        at, 14 * pulse, Paint()..color = Colors.green.withOpacity(0.25));
    canvas.drawCircle(at, 9, Paint()..color = const Color(0xFF2E7D32));
    final tp = TextPainter(
      text: const TextSpan(
        text: '1',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  Path _buildPath(List<Offset> pts) {
    if (pts.length < 2) return Path();
    final path = Path();
    bool first = true;
    for (int i = 0; i < pts.length; i++) {
      if (pts[i].dx.isNaN || pts[i].dy.isNaN) {
        first = true;
        continue;
      }
      if (first) {
        path.moveTo(pts[i].dx, pts[i].dy);
        first = false;
      } else {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
    }
    return path;
  }

  /// Insert [steps] evenly-spaced points between each existing pair.
  static List<Offset> _densifyPoints(List<Offset> pts, int steps) {
    if (pts.length < 2 || steps <= 0) return pts;
    final out = <Offset>[pts[0]];
    for (int i = 1; i < pts.length; i++) {
      final p0 = pts[i - 1];
      final p1 = pts[i];
      for (int s = 1; s <= steps; s++) {
        final t = s / (steps + 1);
        out.add(Offset.lerp(p0, p1, t)!);
      }
      out.add(p1);
    }
    return out;
  }

  @override
  bool shouldRepaint(_TracePainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
//  POLYLINE MATH (shared by the drag-to-fill painter and gesture logic)
// ─────────────────────────────────────────────────────────────────────────────

double _polylineLength(List<Offset> pts) {
  double total = 0;
  for (int i = 1; i < pts.length; i++) {
    total += (pts[i] - pts[i - 1]).distance;
  }
  return total;
}

/// Returns the sub-polyline from the start up to [fraction] (0..1) of the
/// total length — used to render how much of a stroke has been filled.
List<Offset> _partialPolyline(List<Offset> pts, double fraction) {
  if (pts.isEmpty) return const [];
  if (pts.length < 2 || fraction <= 0) return [pts.first];
  if (fraction >= 1) return List.of(pts);
  final total = _polylineLength(pts);
  final target = total * fraction;
  final out = <Offset>[pts.first];
  double acc = 0;
  for (int i = 1; i < pts.length; i++) {
    final seg = (pts[i] - pts[i - 1]).distance;
    if (acc + seg >= target) {
      final t = seg == 0 ? 0.0 : (target - acc) / seg;
      out.add(Offset.lerp(pts[i - 1], pts[i], t)!);
      return out;
    }
    acc += seg;
    out.add(pts[i]);
  }
  return out;
}

/// Projects [p] onto the polyline, returning how far along the path the nearest
/// point is (progress 0..1) and the perpendicular distance to the path.
({double progress, double distance}) _projectOntoPolyline(
    List<Offset> pts, Offset p) {
  if (pts.isEmpty) return (progress: 0.0, distance: double.infinity);
  if (pts.length < 2) return (progress: 0.0, distance: (p - pts.first).distance);
  final total = _polylineLength(pts);
  double acc = 0, bestDist = double.infinity, bestProg = 0;
  for (int i = 1; i < pts.length; i++) {
    final a = pts[i - 1];
    final b = pts[i];
    final seg = (b - a).distance;
    if (seg == 0) continue;
    final abx = b.dx - a.dx, aby = b.dy - a.dy;
    double t = ((p.dx - a.dx) * abx + (p.dy - a.dy) * aby) / (seg * seg);
    t = t.clamp(0.0, 1.0);
    final proj = Offset(a.dx + abx * t, a.dy + aby * t);
    final d = (p - proj).distance;
    if (d < bestDist) {
      bestDist = d;
      bestProg = total > 0 ? (acc + seg * t) / total : 0.0;
    }
    acc += seg;
  }
  return (progress: bestProg, distance: bestDist);
}

/// Completion-based Star_Rating for an Uppercase_Letter_Session.
/// Pure function of Attempt_Count and stroke count — does NOT call
/// `_computeSmartScore` or any of its proximity/coverage/length/overlap
/// sub-scores (Requirement 5.2).
///
/// "Reasonable attempt range" = one attempt per stroke, plus up to 1 extra
/// restart, i.e. `attempts <= strokeCount + 1` is a "clean" run.
int _computeStarRating({required int attempts, required int strokeCount}) {
  final reasonable = strokeCount + 1;
  if (attempts <= reasonable) return 3;
  if (attempts <= reasonable + 3) return 2;
  return 1; // never 0 — reaching Letter_Completion_State always completed
}

// ─────────────────────────────────────────────────────────────────────────────
//  DRAG-TO-FILL PAINTER (uppercase letters)
// ─────────────────────────────────────────────────────────────────────────────
//
//  Renders each stroke of an uppercase letter as a light "track", fills the
//  completed portion in the letter's color as the child drags, and marks the
//  active stroke's start with a numbered, pulsing dot + direction arrow. No
//  image or SVG assets — pure CustomPainter drawing from the stroke skeletons.
class _StrokeFillPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<double> strokeProgress;
  final int activeStroke;
  final Color color;
  final bool isCompleted;
  final double scale;
  final Offset offset;
  final double? guideProgress;

  _StrokeFillPainter({
    required this.strokes,
    required this.strokeProgress,
    required this.activeStroke,
    required this.color,
    required this.isCompleted,
    required this.scale,
    required this.offset,
    this.guideProgress,
  });

  Offset _toScreen(Offset d) =>
      Offset(d.dx * scale + offset.dx, d.dy * scale + offset.dy);

  Path _screenPath(List<Offset> designPts) {
    final path = Path();
    if (designPts.isEmpty) return path;
    final p0 = _toScreen(designPts.first);
    path.moveTo(p0.dx, p0.dy);
    for (int i = 1; i < designPts.length; i++) {
      final p = _toScreen(designPts[i]);
      path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  /// Draws [path] as a dashed line using its path metrics.
  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      {double dash = 9, double gap = 7}) {
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = math.min(dist + dash, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trackWidth = 26.0 * scale;
    final fillWidth = 24.0 * scale;

    final trackPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillColor = isCompleted ? const Color(0xFF4CAF50) : color;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = fillWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. All stroke tracks (background).
    for (final stroke in strokes) {
      canvas.drawPath(_screenPath(stroke), trackPaint);
    }

    // 1b. Dashed centerline guide inside each track so the child sees the
    // path to follow. The fill drawn next covers the dashes as they trace.
    final guidePaint = Paint()
      ..color = (isCompleted ? const Color(0xFF4CAF50) : color)
          .withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    for (final stroke in strokes) {
      _drawDashedPath(canvas, _screenPath(stroke), guidePaint,
          dash: 9.0 * scale, gap: 7.0 * scale);
    }

    // 2. Filled portions.
    for (int i = 0; i < strokes.length; i++) {
      final prog = i < strokeProgress.length ? strokeProgress[i] : 0.0;
      if (prog <= 0) continue;
      final filled = _partialPolyline(strokes[i], prog);
      if (filled.length >= 2) {
        canvas.drawPath(_screenPath(filled), fillPaint);
      } else if (filled.isNotEmpty) {
        canvas.drawCircle(
            _toScreen(filled.first), fillWidth / 2, Paint()..color = fillColor);
      }
    }

    // 3. Active-stroke start marker (numbered dot + direction arrow).
    if (!isCompleted && activeStroke >= 0 && activeStroke < strokes.length) {
      final stroke = strokes[activeStroke];
      if (stroke.isNotEmpty) {
        final at = _toScreen(stroke.first);
        double angle = math.pi / 2;
        if (stroke.length > 1) {
          final n = _toScreen(stroke[1]);
          angle = math.atan2(n.dy - at.dy, n.dx - at.dx);
        }
        _drawStartMarker(canvas, at, angle, activeStroke + 1);
      }
    }
  }

  void _drawStartMarker(Canvas canvas, Offset at, double angle, int number) {
    final pulse = guideProgress != null && guideProgress! >= 0
        ? (0.85 + 0.15 * math.sin(guideProgress! * math.pi * 2))
        : 1.0;

    final arrowPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final dir = Offset(math.cos(angle), math.sin(angle));
    final base = at + dir * 20;
    final tip = at + dir * 38;
    canvas.drawLine(base, tip, arrowPaint);
    final head1 =
        tip + Offset(math.cos(angle + 2.5), math.sin(angle + 2.5)) * 9;
    final head2 =
        tip + Offset(math.cos(angle - 2.5), math.sin(angle - 2.5)) * 9;
    canvas.drawLine(tip, head1, arrowPaint);
    canvas.drawLine(tip, head2, arrowPaint);

    canvas.drawCircle(
        at, 16 * pulse, Paint()..color = Colors.green.withOpacity(0.25));
    canvas.drawCircle(at, 11, Paint()..color = const Color(0xFF2E7D32));
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_StrokeFillPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class TraceItScreen extends StatefulWidget {
  const TraceItScreen({super.key});

  @override
  State<TraceItScreen> createState() => _TraceItScreenState();
}

class _TraceItScreenState extends State<TraceItScreen>
    with TickerProviderStateMixin {
  // ── UI state ───────────────────────────────────────────────────────────────
  int _selectedMode = 0; // 0=Uppercase, 1=Lowercase, 2=Numbers
  int _selectedIndex = 0;
  int _score = 0;
  int _stars = 0;

  // ── Tracing state ──────────────────────────────────────────────────────────
  List<Offset> _tracedPoints = [];
  bool _isCompleted = false;
  Set<int> _visitedPoints = {};

  // Grid-based overlap detection – each cell counts stroke pass-throughs
  Map<int, int> _overlapGrid = {};
  static const double _gridCellSize = 12.0;
  bool _checking = false;

  // Store kid's drawing per letter so they can review it later
  final Map<int, List<Offset>> _completedTraces = {};

  // ── Feedback ───────────────────────────────────────────────────────────────
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.transparent;

  // ── Canvas transform ───────────────────────────────────────────────────────
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;
  Size _canvasSize = Size.zero;

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _successController;
  late Animation<double> _scaleAnimation;
  late AnimationController _warningController;
  late Animation<double> _warningAnimation;
  late PageController _pageController;

  // Guide dot animation
  late AnimationController _guideController;
  double _guideProgress = -1; // -1 = inactive, 0-1 = active

  final Set<int> _completedUpper = {};
  final Set<int> _completedLower = {};
  final Set<int> _completedNums = {};

  static const double _hitRadius = 20.0;

  // ── Drag-to-fill state (uppercase letters) ─────────────────────────────────
  List<List<Offset>> _strokes = [];
  List<double> _strokeProgress = [];
  int _activeStroke = 0;
  int _dragAttempts = 0;
  bool _dragging = false;
  // Design-space thresholds (same ~300x260 space as the stroke skeletons).
  static const double _startZoneRadius = 30.0;
  static const double _pathTolerance = 42.0;
  static const double _strokeCompleteThreshold = 0.85;
  // Cap how far progress can jump in a single drag update. This forces the
  // child to actually drag ALONG the stroke instead of jumping the finger to
  // the end — important for self-touching paths like O, 8, g, 6 and 9 where
  // the start and end points are near each other.
  static const double _maxProgressStep = 0.12;

  // Enlarge the drawn letter by scaling the skeleton around the glyph center.
  // Applied consistently to both rendering and drag hit-testing so they align.
  static const double _letterMagnify = 1.35;
  static const Offset _glyphCenter = Offset(150, 120);

  List<List<Offset>> _magnify(List<List<Offset>> strokes) => [
        for (final stroke in strokes)
          [
            for (final p in stroke)
              Offset(
                _glyphCenter.dx + (p.dx - _glyphCenter.dx) * _letterMagnify,
                _glyphCenter.dy + (p.dy - _glyphCenter.dy) * _letterMagnify,
              )
          ]
      ];

  // ─────────────────────────────────────────────────────────────────────────
  //  Getters
  // ─────────────────────────────────────────────────────────────────────────

  List<LetterData> get _currentLetters {
    if (_selectedMode == 0) return uppercaseLetters;
    if (_selectedMode == 1) return lowercaseLetters;
    return numberLetters;
  }

  LetterData get _currentLetter => _currentLetters[_selectedIndex];

  /// Whether the current item uses the guided drag-fill mechanic. True for any
  /// mode (uppercase, lowercase, numbers) that has a stroke skeleton.
  bool get _useDragFill =>
      strokesForMode(_selectedMode, _currentLetter.letter) != null;

  /// (Re)initialise the drag-to-fill stroke state for the current letter.
  void _initStrokes() {
    final raw = strokesForMode(_selectedMode, _currentLetter.letter);
    if (raw == null) {
      _strokes = [];
      _strokeProgress = [];
      _activeStroke = 0;
      _dragAttempts = 0;
      _dragging = false;
      return;
    }
    _strokes = _magnify(raw);
    _dragAttempts = 0;
    _dragging = false;
    if (_currentCompletedSet.contains(_selectedIndex)) {
      _strokeProgress = List<double>.filled(_strokes.length, 1.0);
      _activeStroke = _strokes.length;
    } else {
      _strokeProgress = List<double>.filled(_strokes.length, 0.0);
      _activeStroke = 0;
    }
  }

  Set<int> get _currentCompletedSet {
    if (_selectedMode == 0) return _completedUpper;
    if (_selectedMode == 1) return _completedLower;
    return _completedNums;
  }

  /// The furthest letter the student is allowed to reach: every completed
  /// letter plus the single next one they still need to trace. They can go
  /// back to finished letters but cannot skip ahead to ones "not yet present",
  /// so they can't randomly trace whatever they want.
  int get _maxReachableIndex {
    for (int i = 0; i < _currentLetters.length; i++) {
      if (!_currentCompletedSet.contains(i)) return i;
    }
    return _currentLetters.length - 1;
  }

  void _goToLetter(int index) {
    if (index < 0 || index >= _currentLetters.length) return;
    if (index > _maxReachableIndex) return; // cannot skip ahead
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    AudioManager.instance.playModuleMusic(ModuleMusic.traceIt);

    _successController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut));

    _warningController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _warningAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _warningController, curve: Curves.easeInOut));

    _pageController = PageController(initialPage: _selectedIndex);

    _guideController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _guideController.addListener(() {
      if (mounted) setState(() => _guideProgress = _guideController.value);
    });

    _initStrokes();
    _loadProgress();
    _initSmartResume();
  }

  Future<void> _initSmartResume() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      int retryCount = 0;
      while (!userProvider.isInitialized && retryCount < 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        retryCount++;
      }

      int targetMode = 0;
      int targetIndex = 0;
      bool found = false;

      for (int i = 0; i < uppercaseLetters.length; i++) {
        if (!userProvider.isTraceItActivityCompleted('uppercase', i)) {
          targetMode = 0;
          targetIndex = i;
          found = true;
          break;
        }
      }

      if (!found) {
        for (int i = 0; i < lowercaseLetters.length; i++) {
          if (!userProvider.isTraceItActivityCompleted('lowercase', i)) {
            targetMode = 1;
            targetIndex = i;
            found = true;
            break;
          }
        }
      }

      if (!found) {
        for (int i = 0; i < numberLetters.length; i++) {
          if (!userProvider.isTraceItActivityCompleted('numbers', i)) {
            targetMode = 2;
            targetIndex = i;
            found = true;
            break;
          }
        }
      }

      if (!found) {
        targetMode = 2;
        targetIndex = 9;
      }

      if (mounted) {
        setState(() {
          _selectedMode = targetMode;
          _selectedIndex = targetIndex;
          _resetTracing();
        });
        // Sync the PageView to the resumed letter via jumpToPage. Recreating
        // the controller here would NOT move the viewport (Flutter transfers
        // the old scroll position to the new controller), which desynced the
        // page from _selectedIndex.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              _pageController.hasClients &&
              _pageController.page?.round() != targetIndex) {
            _pageController.jumpToPage(targetIndex);
          }
        });
      }
    } catch (e) {
      debugPrint('TraceIt Smart Resume failed: $e');
    }
  }

  @override
  void dispose() {
    _successController.dispose();
    _warningController.dispose();
    _pageController.dispose();
    _guideController.dispose();
    AudioManager.instance.resumeHomeMusic();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Progress persistence
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadProgress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isInitialized) return;

    setState(() {
      _completedUpper.clear();
      _completedLower.clear();
      _completedNums.clear();

      for (int i = 0; i < uppercaseLetters.length; i++) {
        if (userProvider.isTraceItActivityCompleted('uppercase', i)) {
          _completedUpper.add(i);
        }
      }
      for (int i = 0; i < lowercaseLetters.length; i++) {
        if (userProvider.isTraceItActivityCompleted('lowercase', i)) {
          _completedLower.add(i);
        }
      }
      for (int i = 0; i < numberLetters.length; i++) {
        if (userProvider.isTraceItActivityCompleted('numbers', i)) {
          _completedNums.add(i);
        }
      }
    });
  }

  Future<void> _saveLetterComplete(int modeIndex, int letterIndex) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String modeKey = modeIndex == 0
        ? 'uppercase'
        : modeIndex == 1
            ? 'lowercase'
            : 'numbers';
    await userProvider.updateTraceItProgress(modeKey, letterIndex, true);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Canvas transform
  // ─────────────────────────────────────────────────────────────────────────

  void _computeTransform(Size canvasSize) {
    if (_canvasSize == canvasSize) return;
    _canvasSize = canvasSize;
    // The letter point data was authored in a ~300×260 design space where
    // glyphs occupy roughly x: 110–190, y: 60–180 (a ~80×120 active area).
    // The background Text is rendered at fontSize 260*scale, centered.
    // We scale the design space UP so the dashed guide fills the same area
    // as the background glyph.
    const designW = 300.0;
    const designH = 260.0;
    // Use nearly the full canvas (less padding) so the guide matches the large text.
    const padding = 12.0;
    final scaleX = (canvasSize.width - padding * 2) / designW;
    final scaleY = (canvasSize.height - padding * 2) / designH;
    _canvasScale = scaleX < scaleY ? scaleX : scaleY;
    // Center horizontally, shift down slightly to match font baseline.
    _canvasOffset = Offset(
      (canvasSize.width - designW * _canvasScale) / 2,
      (canvasSize.height - designH * _canvasScale) / 2 + 8 * _canvasScale,
    );
  }

  Offset _toDesign(Offset screen) => Offset(
        (screen.dx - _canvasOffset.dx) / _canvasScale,
        (screen.dy - _canvasOffset.dy) / _canvasScale,
      );

  Offset _toScreen(Offset design) => Offset(
        design.dx * _canvasScale + _canvasOffset.dx,
        design.dy * _canvasScale + _canvasOffset.dy,
      );

  void _onPanStart(DragStartDetails d) {
    if (_canvasSize == Size.zero) return;
    if (_isCompleted) {
      _showFeedback(AppLocalizations.of(context)!.doneAlready, Colors.green);
      return;
    }
    if (_useDragFill) {
      _onDragFillStart(d);
      return;
    }
    final designPt = _toDesign(d.localPosition);

    _guideController.stop();

    // Free draw: start anywhere on canvas
    setState(() {
      _guideProgress = -1;
      // Break marker for multi-stroke (prevents connecting line between strokes)
      if (_tracedPoints.isNotEmpty) {
        _tracedPoints.add(const Offset(double.nan, double.nan));
      }
      _tracedPoints.add(_toScreen(designPt));
      _outOfBounds = false;
      _checking = false;
    });
  }

  bool _outOfBounds = false;

  // ── Drag-to-fill gesture logic ─────────────────────────────────────────────

  void _onDragFillStart(DragStartDetails d) {
    if (_activeStroke >= _strokes.length) return;
    final designPt = _toDesign(d.localPosition);
    final start = _strokes[_activeStroke].first;
    if ((designPt - start).distance <= _startZoneRadius) {
      _guideController.stop();
      setState(() {
        _dragging = true;
        _dragAttempts++;
        _outOfBounds = false;
      });
    } else {
      _showFeedback(AppLocalizations.of(context)!.startAtDot, Colors.orange);
    }
  }

  void _onDragFillUpdate(DragUpdateDetails d) {
    if (!_dragging || _isCompleted || _activeStroke >= _strokes.length) return;
    final designPt = _toDesign(d.localPosition);
    final stroke = _strokes[_activeStroke];
    final proj = _projectOntoPolyline(stroke, designPt);

    // Off the stroke: pause progress and flash the warning border.
    if (proj.distance > _pathTolerance) {
      if (!_outOfBounds) {
        setState(() => _outOfBounds = true);
        _warningController
            .forward(from: 0)
            .then((_) => _warningController.reverse());
      }
      return;
    }

    setState(() {
      _outOfBounds = false;
      // Forward-only, and capped per update so progress can't leap ahead on
      // looping letters — the child must trace along the stroke.
      final cur = _strokeProgress[_activeStroke];
      if (proj.progress > cur) {
        _strokeProgress[_activeStroke] =
            math.min(proj.progress, cur + _maxProgressStep);
      }
    });

    if (_strokeProgress[_activeStroke] >= _strokeCompleteThreshold) {
      _completeActiveStroke();
    }
  }

  void _completeActiveStroke() {
    setState(() {
      _strokeProgress[_activeStroke] = 1.0;
      _activeStroke++;
      _dragging = false;
      _outOfBounds = false;
    });
    if (_activeStroke >= _strokes.length) {
      _completeDragFillLetter();
    } else {
      // Restart the pulse so the next stroke's start dot draws attention.
      _guideController
        ..reset()
        ..repeat();
    }
  }

  void _completeDragFillLetter() {
    if (_isCompleted) return;
    final stars = _computeStarRating(
      attempts: _dragAttempts,
      strokeCount: _strokes.length,
    );
    final earned = stars * 5;

    setState(() {
      _isCompleted = true;
      _dragging = false;
      _score += earned;
      _stars += stars;
    });

    _currentCompletedSet.add(_selectedIndex);
    _saveLetterComplete(_selectedMode, _selectedIndex);

    _guideController.stop();
    _successController.forward(from: 0);
    _showFeedback(
        AppLocalizations.of(context)!.goodJobPoints(earned), Colors.green);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_selectedIndex + 1 < _currentLetters.length) {
        _pageController.animateToPage(
          _selectedIndex + 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_useDragFill) {
      _onDragFillUpdate(d);
      return;
    }
    if (_isCompleted || _tracedPoints.isEmpty) return;
    final designPt = _toDesign(d.localPosition);
    final screenPt = _toScreen(designPt);
    final pts = _currentLetter.points;

    // Free-draw mode: mark ANY nearby guide point as visited (no order restriction)
    for (int i = 0; i < pts.length; i++) {
      double dist = (designPt - pts[i]).distance;
      double dynamicRadius =
          _hitRadius * (1.2 + (4 - _currentLetter.difficulty) * 0.15);
      if (dist <= dynamicRadius) {
        _visitedPoints.add(i);
      }
    }

    // Track which grid cell is being drawn on for overlap detection
    final cellX = (designPt.dx / _gridCellSize).floor();
    final cellY = (designPt.dy / _gridCellSize).floor();
    final cellKey = cellX * 10000 + cellY;
    _overlapGrid[cellKey] = (_overlapGrid[cellKey] ?? 0) + 1;

    setState(() {
      _outOfBounds = false;

      if (_tracedPoints.isEmpty ||
          (screenPt - _tracedPoints.last).distance > 2.0) {
        _tracedPoints.add(screenPt);
      }
    });
  }

  void _onPanEnd(DragEndDetails d) {
    if (_useDragFill) {
      setState(() {
        _dragging = false;
        _outOfBounds = false;
      });
      return;
    }
    if (_isCompleted) return;
    setState(() => _outOfBounds = false);
  }

  void _resetTracing() {
    final completed = _currentCompletedSet.contains(_selectedIndex);
    setState(() {
      _tracedPoints = [];
      _isCompleted = completed;
      _visitedPoints = {};
      _overlapGrid = {};
      _outOfBounds = false;
      _checking = false;
      _canvasSize = Size.zero;
      _guideProgress = completed ? -1 : 0;
      _initStrokes();
    });
    if (!completed) {
      _guideController.repeat();
    } else {
      _guideController.stop();
    }
    _successController.reset();
  }

  /// Computes a strict score that actually validates letter shape.
  /// Penalizes random scribbles, out-of-bounds drawing, and wrong path length.
  double _computeSmartScore() {
    final pts = _currentLetter.points;
    if (_tracedPoints.length < 3) return 0.0;

    final validPoints =
        _tracedPoints.where((p) => !p.dx.isNaN && !p.dy.isNaN).toList();
    if (validPoints.isEmpty) return 0.0;

    final designPts = validPoints.map(_toDesign).toList();
    // Densify guide points so ALL letters have smooth path validation
    final densePts = _TracePainter._densifyPoints(pts, 6);
    const outerRadius = _hitRadius * 2.0; // penalty beyond this
    const nearRadius = _hitRadius * 1.5;

    int nearCount = 0;
    int outOfBoundsCount = 0;
    for (final dp in designPts) {
      double minDist = double.infinity;
      for (final gp in densePts) {
        final d = (dp - gp).distance;
        if (d < minDist) minDist = d;
      }
      if (minDist <= nearRadius) nearCount++;
      if (minDist > outerRadius) outOfBoundsCount++;
    }

    // 1. Proximity: % of drawn points near the guide path
    double proximity = nearCount / designPts.length;

    // 2. Coverage: % of guide points touched (use original for visited check)
    double coverage = _visitedPoints.length / pts.length;

    // 3. Out-of-bounds penalty: drawn points far from ANY guide point
    double outOfBoundsPenalty = outOfBoundsCount / designPts.length;

    // 4. Path-length sanity: drawn length vs guide length
    double drawnLength = 0;
    for (int i = 1; i < designPts.length; i++) {
      drawnLength += (designPts[i] - designPts[i - 1]).distance;
    }
    double guideLength = 0;
    for (int i = 1; i < pts.length; i++) {
      guideLength += (pts[i] - pts[i - 1]).distance;
    }
    double lengthRatio = guideLength > 0 ? drawnLength / guideLength : 0;
    // Kids draw at different sizes — be lenient
    double lengthScore = 1.0;
    if (lengthRatio < 0.3 || lengthRatio > 3.0) {
      lengthScore = 0.0; // way off
    } else if (lengthRatio < 0.5 || lengthRatio > 2.0) {
      lengthScore = 0.5; // somewhat off
    }

    // 5. Prefer the child touches start and end, but don't require both
    bool touchedStart = false;
    bool touchedEnd = false;
    for (final dp in designPts) {
      if ((dp - pts.first).distance <= nearRadius) touchedStart = true;
      if ((dp - pts.last).distance <= nearRadius) touchedEnd = true;
    }
    double startEndScore = 0.5;
    if (touchedStart || touchedEnd) startEndScore = 0.75;
    if (touchedStart && touchedEnd) startEndScore = 1.0;

    // Combine everything — coverage and proximity matter most
    double rawScore = (coverage * 0.40) +
        (proximity * 0.30) +
        (lengthScore * 0.15) +
        (startEndScore * 0.15);

    // Moderate penalty for wild scribbling outside the letter
    rawScore -= outOfBoundsPenalty * 0.45;

    // ── Overlap penalty ──────────────────────────────────────────────────
    // Cells visited more than the threshold are considered "over-drawn".
    // A high ratio of over-drawn cells means the student is scribbling
    // or drawing over the same area repeatedly instead of tracing.
    const overlapThreshold = 3;
    int overlappedCells = 0;
    int totalDrawnCells = 0;
    for (final entry in _overlapGrid.entries) {
      if (entry.value > 1) totalDrawnCells++;
      if (entry.value > overlapThreshold) overlappedCells++;
    }
    final overlapRatio =
        totalDrawnCells > 0 ? overlappedCells / totalDrawnCells : 0.0;
    rawScore -= overlapRatio * 0.70; // heavy penalty for overlap

    return rawScore.clamp(0.0, 1.0);
  }

  void _checkTracing() {
    if (_isCompleted || _tracedPoints.length < 3) return;

    setState(() => _checking = true);

    final score = _computeSmartScore();
    if (score >= 0.65) {
      _completeTracing();
    } else {
      _triggerWarning(AppLocalizations.of(context)!.almostThere);
    }
  }

  void _completeTracing() {
    if (_isCompleted) return;
    setState(() {
      _isCompleted = true;
      _score += 15;
      _stars += 3;
    });

    _currentCompletedSet.add(_selectedIndex);
    _saveLetterComplete(_selectedMode, _selectedIndex);

    _successController.forward(from: 0);
    _showFeedback(
        AppLocalizations.of(context)!.goodJobPoints(15), Colors.green);

    // Store the kid's drawing for review
    _completedTraces[_selectedIndex] = List.from(_tracedPoints);

    // Auto-advance after a brief celebration
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_selectedIndex + 1 < _currentLetters.length) {
        _pageController.animateToPage(
          _selectedIndex + 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _triggerWarning(String msg) {
    _warningController
        .forward(from: 0)
        .then((_) => _warningController.reverse());
    _showFeedback(msg, Colors.orange);
  }

  void _showFeedback(String message, Color color) {
    setState(() {
      _feedbackMessage = message;
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

  void _showCompletionDialog() {
    final modeName = _selectedMode == 0
        ? AppLocalizations.of(context)!.uppercase
        : _selectedMode == 1
            ? AppLocalizations.of(context)!.lowercase
            : AppLocalizations.of(context)!.numbers;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessModal(
        title: AppLocalizations.of(context)!.iKnowIt,
        subtitle: AppLocalizations.of(context)!.categoryCompleted(modeName),
        score: _score,
        stars: 3,
        primaryLabel: AppLocalizations.of(context)!.continueText,
        onPrimaryTap: () => Navigator.pop(context),
        secondaryLabel: AppLocalizations.of(context)!.ulitin,
        onSecondaryTap: () {
          Navigator.pop(context);
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        mainColor: AppColors.primary,
      ),
    );
  }

  void _onPageChanged(int index) {
    if (index != _selectedIndex) {
      final wasCompleted = _currentCompletedSet.contains(index);
      setState(() {
        _selectedIndex = index;
        _isCompleted = wasCompleted;
        if (_isCompleted && _completedTraces.containsKey(index)) {
          _tracedPoints = List.from(_completedTraces[index]!);
          _visitedPoints = {};
          _guideProgress = -1;
        } else {
          _tracedPoints = [];
          _visitedPoints = {};
          _guideProgress = 0;
        }
        _outOfBounds = false;
        _checking = false;
        _canvasSize = Size.zero;
        _initStrokes();
      });
      if (!wasCompleted) {
        _guideController.repeat();
      } else {
        _guideController.stop();
      }
      _successController.reset();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.isAccountDeleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    }

    final size = MediaQuery.of(context).size;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leadingWidth: 60,
        leading: Center(
          child: CustomBackButton(
            iconColor: AppColors.textDark,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(loc.traceItTitle,
              maxLines: 1,
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Icon(LucideIcons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text('$_stars',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
            ]),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _buildModeTabs(),
        ),
      ),
      body: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _currentLetter.color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _currentLetter.color, width: 2),
              ),
              child: Center(
                  child: Text(_currentLetter.letter,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _currentLetter.color))),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(loc.letterLabel(_currentLetter.letter),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text('${_currentLetter.example} • "${_currentLetter.sound}"',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${_currentCompletedSet.length}/${_currentLetters.length} \u2713',
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 6),
            Column(children: [
              Text(loc.pointsLabel,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text('$_score',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ]),
          ]),
        ),

        // Navigation — back goes to finished letters, forward only up to the
        // current letter (can't jump ahead to untraced ones).
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildNavArrow(
              icon: LucideIcons.chevron_left,
              enabled: _selectedIndex > 0,
              onTap: () => _goToLetter(_selectedIndex - 1),
            ),
            const SizedBox(width: 18),
            Text('${_selectedIndex + 1} / ${_currentLetters.length}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600)),
            const SizedBox(width: 18),
            _buildNavArrow(
              icon: LucideIcons.chevron_right,
              enabled: _selectedIndex < _maxReachableIndex,
              onTap: () => _goToLetter(_selectedIndex + 1),
            ),
          ]),
        ),

        // Canvas
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _currentLetters.length,
            // Navigation is arrow-only so students can't swipe to letters they
            // haven't reached yet.
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final letter = _currentLetters[index];
              final rawStrokes = strokesForMode(_selectedMode, letter.letter);
              // Selected page reuses the already-magnified live strokes; other
              // pages magnify on the fly for their preview.
              final letterStrokes = rawStrokes == null
                  ? null
                  : (_selectedIndex == index ? _strokes : _magnify(rawStrokes));
              return Center(
                child: AnimatedBuilder(
                  animation: _warningAnimation,
                  builder: (_, child) => Container(
                    width: size.width,
                    height: size.height * 0.98,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: _outOfBounds && _selectedIndex == index
                          ? Border.all(
                              color: Colors.orange.withOpacity(
                                  0.6 + _warningAnimation.value * 0.4),
                              width: 3)
                          : Border.all(color: Colors.grey.shade100, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: _isCompleted && _selectedIndex == index
                              ? Colors.green.withOpacity(0.25)
                              : letter.color.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: LayoutBuilder(builder: (_, constraints) {
                      final cs =
                          Size(constraints.maxWidth, constraints.maxHeight);
                      _computeTransform(cs);
                      return GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: Stack(fit: StackFit.expand, children: [
                          // Uppercase letters use the guided drag-to-fill
                          // painter; lowercase/numbers keep the legacy painter.
                          CustomPaint(
                            painter: letterStrokes != null
                                ? _StrokeFillPainter(
                                    strokes: letterStrokes,
                                    strokeProgress: _selectedIndex == index
                                        ? _strokeProgress
                                        : List<double>.filled(
                                            letterStrokes.length,
                                            _currentCompletedSet.contains(index)
                                                ? 1.0
                                                : 0.0),
                                    activeStroke: _selectedIndex == index
                                        ? _activeStroke
                                        : (_currentCompletedSet.contains(index)
                                            ? letterStrokes.length
                                            : 0),
                                    color: letter.color,
                                    isCompleted:
                                        _currentCompletedSet.contains(index),
                                    scale: _canvasScale,
                                    offset: _canvasOffset,
                                    guideProgress: _selectedIndex == index
                                        ? _guideProgress
                                        : null,
                                  )
                                : _TracePainter(
                                    guidePoints: letter.points,
                                    tracedPoints: _selectedIndex == index
                                        ? _tracedPoints
                                        : [],
                                    color: letter.color,
                                    isCompleted:
                                        _currentCompletedSet.contains(index),
                                    visitedPoints: _selectedIndex == index
                                        ? _visitedPoints
                                        : {},
                                    scale: _canvasScale,
                                    offset: _canvasOffset,
                                    letter: letter.letter,
                                    guideProgress: _selectedIndex == index
                                        ? _guideProgress
                                        : null,
                                  ),
                          ),
                          // Success overlay
                          if (_isCompleted && _selectedIndex == index)
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.green.withOpacity(0.4),
                                          blurRadius: 15,
                                          spreadRadius: 2)
                                    ],
                                  ),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(LucideIcons.circle_check,
                                            color: Colors.white, size: 28),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(loc.goodJob,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                        ]),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ),

        // Feedback banner
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _feedbackMessage.isEmpty ? 0 : 48,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: _feedbackColor, borderRadius: BorderRadius.circular(12)),
          child: _feedbackMessage.isEmpty
              ? const SizedBox.shrink()
              : Text(_feedbackMessage,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  overflow: TextOverflow.ellipsis),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              // Clear button — resets the current letter's progress.
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetTracing,
                  icon: const Icon(LucideIcons.refresh_cw, size: 18),
                  label: Text(loc.clear),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              // Check button — only for the legacy freehand mechanic. The
              // drag-to-fill mechanic completes automatically, so no Check.
              if (!_useDragFill) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isCompleted ? null : _checkTracing,
                    icon: _checking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(LucideIcons.check, size: 20),
                    label: Text(loc.checkTracing),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isCompleted ? Colors.green : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildNavArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.12)
              : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
    );
  }

  void _switchMode(int index) {
    if (_selectedMode == index) return;
    // Jump to page 0 while the current mode's page count is still valid, THEN
    // switch mode. Letter counts differ per mode (26/26/10), so switching first
    // could leave the controller holding an out-of-range offset.
    if (_pageController.hasClients) _pageController.jumpToPage(0);
    setState(() {
      _selectedMode = index;
      _selectedIndex = 0;
      _resetTracing();
    });
  }

  /// Modern segmented control for the ABC / abc / 123 modes.
  Widget _buildModeTabs() {
    final loc = AppLocalizations.of(context)!;
    final modes = [
      (0, 'ABC', loc.upper, _completedUpper.length >= uppercaseLetters.length),
      (1, 'abc', loc.lower, _completedLower.length >= lowercaseLetters.length),
      (2, '123', loc.numbers, _completedNums.length >= numberLetters.length),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (final m in modes)
              Expanded(
                child: _buildModeSegment(
                  index: m.$1,
                  badge: m.$2,
                  label: m.$3,
                  completed: m.$4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSegment({
    required int index,
    required String badge,
    required String label,
    required bool completed,
  }) {
    final active = _selectedMode == index;
    final Color contentColor = active
        ? Colors.white
        : (completed ? Colors.green.shade600 : Colors.grey.shade600);

    return GestureDetector(
      onTap: () => _switchMode(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: contentColor,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: contentColor,
                ),
              ),
            ),
            if (completed) ...[
              const SizedBox(width: 5),
              Icon(
                LucideIcons.circle_check,
                size: 13,
                color: active ? Colors.white : Colors.green.shade600,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
