import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/letter_tracing_data.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/success_modal.dart';

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

  _TracePainter({
    required this.guidePoints,
    required this.tracedPoints,
    required this.color,
    required this.isCompleted,
    required this.visitedPoints,
    required this.scale,
    required this.offset,
    this.guideProgress,
  });

  Offset _toScreen(Offset design) => Offset(
        design.dx * scale + offset.dx,
        design.dy * scale + offset.dy,
      );

  @override
  void paint(Canvas canvas, Size size) {
    const userStroke = 24.0;

    // 1. User stroke
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

    // 2. Guide animation & faint letter outline
    // (drawn from the same points so dot and reference match perfectly)
    if (guideProgress != null &&
        guideProgress! >= 0 &&
        !isCompleted &&
        tracedPoints.isEmpty) {
      _drawGuide(canvas);
    }
  }

  void _drawGuide(Canvas canvas) {
    if (guidePoints.isEmpty) return;

    final screenPoints = _densifyPoints(guidePoints.map(_toScreen).toList(), 6);
    final movingPt = _getPointOnPath(screenPoints, guideProgress!);
    final pulse = 1.0 + math.sin(guideProgress! * math.pi * 4) * 0.3;

    // Animated dot tracing the letter path
    canvas.drawCircle(
      movingPt,
      10 * pulse,
      Paint()..color = color.withOpacity(0.22),
    );
    canvas.drawCircle(
      movingPt,
      5,
      Paint()..color = color.withOpacity(0.95),
    );
    canvas.drawCircle(
      movingPt,
      2,
      Paint()..color = Colors.white.withOpacity(0.95),
    );
  }

  Offset _getPointOnPath(List<Offset> points, double t) {
    if (points.isEmpty) return Offset.zero;
    if (points.length == 1) return points[0];

    double totalLength = 0;
    final lengths = <double>[0.0];
    for (int i = 1; i < points.length; i++) {
      totalLength += (points[i] - points[i - 1]).distance;
      lengths.add(totalLength);
    }

    if (totalLength == 0) return points[0];

    double target = t * totalLength;
    for (int i = 1; i < lengths.length; i++) {
      if (target <= lengths[i]) {
        double segT = (target - lengths[i - 1]) / (lengths[i] - lengths[i - 1]);
        return Offset.lerp(points[i - 1], points[i], segT)!;
      }
    }
    return points.last;
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
  bool _checking = false;

  // Store kid's drawing per letter so they can review it later
  Map<int, List<Offset>> _completedTraces = {};

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

  // ─────────────────────────────────────────────────────────────────────────
  //  Getters
  // ─────────────────────────────────────────────────────────────────────────

  List<LetterData> get _currentLetters {
    if (_selectedMode == 0) return uppercaseLetters;
    if (_selectedMode == 1) return lowercaseLetters;
    return numberLetters;
  }

  LetterData get _currentLetter => _currentLetters[_selectedIndex];

  Set<int> get _currentCompletedSet {
    if (_selectedMode == 0) return _completedUpper;
    if (_selectedMode == 1) return _completedLower;
    return _completedNums;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

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
          _pageController = PageController(initialPage: _selectedIndex);
          _resetTracing();
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
    const designW = 300.0;
    const designH = 260.0;
    const padding = 4.0;
    final scaleX = (canvasSize.width - padding * 2) / designW;
    final scaleY = (canvasSize.height - padding * 2) / designH;
    _canvasScale = scaleX < scaleY ? scaleX : scaleY;
    _canvasOffset = Offset(
      (canvasSize.width - designW * _canvasScale) / 2,
      (canvasSize.height - designH * _canvasScale) / 2,
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

  void _onPanUpdate(DragUpdateDetails d) {
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

    setState(() {
      _outOfBounds = false;

      if (_tracedPoints.isEmpty ||
          (screenPt - _tracedPoints.last).distance > 2.0) {
        _tracedPoints.add(screenPt);
      }
    });
  }

  void _onPanEnd(DragEndDetails d) {
    if (_isCompleted) return;
    setState(() => _outOfBounds = false);
  }

  void _resetTracing() {
    final completed = _currentCompletedSet.contains(_selectedIndex);
    setState(() {
      _tracedPoints = [];
      _isCompleted = completed;
      _visitedPoints = {};
      _outOfBounds = false;
      _checking = false;
      _canvasSize = Size.zero;
      _guideProgress = completed ? -1 : 0;
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
    final outerRadius = _hitRadius * 3.0; // penalty beyond this
    final nearRadius = _hitRadius * 2.0;

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
    if (lengthRatio < 0.2 || lengthRatio > 3.5) {
      lengthScore = 0.0; // way off
    } else if (lengthRatio < 0.4 || lengthRatio > 2.5) {
      lengthScore = 0.6; // somewhat off
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
    rawScore -= outOfBoundsPenalty * 0.35;

    return rawScore.clamp(0.0, 1.0);
  }

  void _checkTracing() {
    if (_isCompleted || _tracedPoints.length < 3) return;

    setState(() => _checking = true);

    final score = _computeSmartScore();
    if (score >= 0.60) {
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

  void _resetAllProgress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isInitialized) return;

    // Clear all traceit progress in UserProvider
    for (int i = 0; i < uppercaseLetters.length; i++) {
      await userProvider.updateTraceItProgress('uppercase', i, false);
    }
    for (int i = 0; i < lowercaseLetters.length; i++) {
      await userProvider.updateTraceItProgress('lowercase', i, false);
    }
    for (int i = 0; i < numberLetters.length; i++) {
      await userProvider.updateTraceItProgress('numbers', i, false);
    }

    setState(() {
      _completedUpper.clear();
      _completedLower.clear();
      _completedNums.clear();
      _completedTraces.clear();
      _score = 0;
      _stars = 0;
      _selectedIndex = 0;
      _selectedMode = 0;
      _resetTracing();
    });

    _pageController = PageController(initialPage: 0);
    _guideController.repeat();
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
        leading: CustomBackButton(
          iconColor: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(loc.traceItTitle,
            style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            color: Colors.grey.shade400,
            tooltip: 'Reset (test)',
            onPressed: _resetAllProgress,
          ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text('$_stars',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
            ]),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: Colors.white,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModeTab(0, 'ABC', loc.upper),
                  _buildModeTab(1, 'abc', loc.lower),
                  _buildModeTab(2, '123', loc.numbers),
                ]),
          ),
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

        // Navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${_selectedIndex + 1} / ${_currentLetters.length}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600)),
          ]),
        ),

        // Canvas
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _currentLetters.length,
            physics: _currentCompletedSet.contains(_selectedIndex)
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final letter = _currentLetters[index];
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
                          // Accurate letter reference (font glyph)
                          Center(
                              child: Opacity(
                                  opacity: 0.18,
                                  child: Text(letter.letter,
                                      style: TextStyle(
                                          fontSize: 260 * _canvasScale,
                                          fontWeight: FontWeight.bold,
                                          color: letter.color)))),
                          // Tracing painter
                          CustomPaint(
                            painter: _TracePainter(
                              guidePoints: letter.points,
                              tracedPoints:
                                  _selectedIndex == index ? _tracedPoints : [],
                              color: letter.color,
                              isCompleted: _currentCompletedSet.contains(index),
                              visitedPoints:
                                  _selectedIndex == index ? _visitedPoints : {},
                              scale: _canvasScale,
                              offset: _canvasOffset,
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
                                        const Icon(Icons.check_circle,
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
              // Clear button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetTracing,
                  icon: const Icon(Icons.refresh, size: 18),
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
              const SizedBox(width: 8),
              // Check button
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
                      : const Icon(Icons.check, size: 20),
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
          ),
        ),
      ]),
    );
  }

  Widget _buildModeTab(int index, String icon, String label) {
    final isSelected = _selectedMode == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = index;
          _selectedIndex = 0;
          _resetTracing();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Text(icon,
              style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.grey.shade600)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13)),
        ]),
      ),
    );
  }
}
