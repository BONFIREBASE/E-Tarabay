// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/success_modal.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PROGRESS KEYS  (shared with for_parents_screen.dart)
// ─────────────────────────────────────────────────────────────────────────────
class SundanProgressKeys {
  // sundan_upper_A, sundan_upper_B … sundan_lower_a … sundan_num_1 …
  static String upperKey(String letter) => 'sundan_upper_$letter';
  static String lowerKey(String letter) => 'sundan_lower_$letter';
  static String numKey(String num) => 'sundan_num_$num';

  static const String totalAttempts = 'sundan_total_attempts';
  static const String totalCompleted = 'sundan_total_completed';
  static const String lastActivity = 'sundan_last_activity';
}

// ─────────────────────────────────────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────
class LetterData {
  final String letter;
  final String sound;
  final String example;
  final Color color;
  final int difficulty;
  final List<Offset> points;

  const LetterData({
    required this.letter,
    required this.sound,
    required this.example,
    required this.color,
    required this.difficulty,
    required this.points,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  CONFETTI PARTICLE
// ─────────────────────────────────────────────────────────────────────────────
class _ConfettiParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;
  double opacity;

  _ConfettiParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    this.opacity = 1.0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  CONFETTI PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
//  LETTER TRACING PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class LetterTracingPainter extends CustomPainter {
  final List<Offset> guidePoints;
  final List<Offset> tracedPoints;
  final Color color;
  final bool isCompleted;
  final Set<int> visitedPoints;
  final double scale;
  final Offset offset;

  LetterTracingPainter({
    required this.guidePoints,
    required this.tracedPoints,
    required this.color,
    required this.isCompleted,
    required this.visitedPoints,
    required this.scale,
    required this.offset,
  });

  Offset _t(Offset p) =>
      Offset(p.dx * scale + offset.dx, p.dy * scale + offset.dy);

  @override
  void paint(Canvas canvas, Size size) {
    if (guidePoints.isEmpty) return;
    final tg = guidePoints.map(_t).toList();

    const guideStroke = 54.0; // Increased from 44
    const userStroke = 24.0; // Increased from 18

    // 1. Guide road
    canvas.drawPath(
      _buildPath(tg),
      Paint()
        ..color = color.withOpacity(0.25) // Increased opacity from 0.18
        ..style = PaintingStyle.stroke
        ..strokeWidth = guideStroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 2. Dashed centre line
    final dashPaint = Paint()
      ..color = Colors.grey.shade600 // Darker grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 // Thicker from 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < tg.length - 1; i++) {
      _drawDashedLine(canvas, tg[i], tg[i + 1], dashPaint);
    }

    // 3. Status/Progress Visuals (Entire path becomes theme color as you trace)
    if (visitedPoints.isNotEmpty) {
      canvas.drawPath(
        _buildPath(tg),
        Paint()
          ..color = isCompleted ? Colors.green : color.withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = guideStroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // 4. User stroke
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

    // 5. Removed numbering logic from circles - now just clean guide dots
    for (int i = 0; i < tg.length; i++) {
      final isVisited = visitedPoints.contains(i);
      final dotColor = isVisited
          ? (isCompleted ? Colors.green : color)
          : Colors.grey.shade400;

      canvas.drawCircle(
          tg[i],
          isVisited ? 8 : 4, // Subtle pulse when visited
          Paint()
            ..color = dotColor
            ..style = PaintingStyle.fill);
    }

    // 6. Pulse Start Hint (if empty)
    if (tracedPoints.isEmpty && tg.isNotEmpty) {
      canvas.drawCircle(
          tg[0], 12, Paint()..color = Colors.blue.withOpacity(0.4));
    }
  }

  Path _buildPath(List<Offset> pts) {
    // Optimization: Only build paths for non-empty segments
    if (pts.length < 2) return Path();
    final path = Path();
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path;
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dashLen = 8.0;
    const gapLen = 6.0;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len;
    final uy = dy / len;
    double d = 0;
    bool drawing = true;
    while (d < len) {
      final d2 = (d + (drawing ? dashLen : gapLen)).clamp(0.0, len);
      if (drawing) {
        canvas.drawLine(
          Offset(a.dx + ux * d, a.dy + uy * d),
          Offset(a.dx + ux * d2, a.dy + uy * d2),
          paint,
        );
      }
      d = d2;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(LetterTracingPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SundanScreen extends StatefulWidget {
  const SundanScreen({super.key});

  @override
  State<SundanScreen> createState() => _SundanScreenState();
}

class _SundanScreenState extends State<SundanScreen>
    with TickerProviderStateMixin {
  // ── UI state ───────────────────────────────────────────────────────────────
  int _selectedMode = 0; // 0=Uppercase, 1=Lowercase, 2=Numbers
  int _selectedIndex = 0;
  int _score = 0;
  int _stars = 0;

  // ── Tracing state ──────────────────────────────────────────────────────────
  List<Offset> _tracedPoints = [];
  bool _isCompleted = false;
  double _tracingProgress = 0.0;
  Set<int> _visitedPoints =
      {}; // Using set for order-independent (but proximity-based) progress
  bool _outOfBounds = false;
  int _wrongAttempts = 0;

  // ── Feedback ───────────────────────────────────────────────────────────────
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.transparent;

  // ── Canvas transform ────────────────────────────────────────────────────────
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;
  Size _canvasSize = Size.zero;

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _successController;
  late Animation<double> _scaleAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _confettiController;
  late AnimationController _warningController;
  late Animation<double> _warningAnimation;

  final List<_ConfettiParticle> _confettiParticles = [];
  final Random _rng = Random();

  static const double _hitRadius = 20.0;

  // ── Progress tracking (SharedPreferences) ──────────────────────────────────
  SharedPreferences? _prefs;
  // Completed sets per mode
  final Set<int> _completedUpper = {};
  final Set<int> _completedLower = {};
  final Set<int> _completedNums = {};

  // ─────────────────────────────────────────────────────────────────────────
  //  Letter data
  // ─────────────────────────────────────────────────────────────────────────

  final List<LetterData> _uppercaseLetters = const [
    LetterData(
        letter: 'A',
        sound: 'ay',
        example: 'Apple',
        color: Colors.red,
        difficulty: 2,
        points: [
          Offset(150, 60), // Peak
          Offset(110, 180), // Left bottom
          Offset(150, 60), // Back to Peak
          Offset(190, 180), // Right bottom
          Offset(140, 125), // Cross start
          Offset(160, 125) // Cross end
        ]),
    LetterData(
        letter: 'B',
        sound: 'bee',
        example: 'Ball',
        color: Colors.blue,
        difficulty: 3,
        points: [
          Offset(120, 60), // Top left
          Offset(120, 180), // Bottom left
          Offset(120, 60), // Back to top
          Offset(155, 60), // Top curve mid
          Offset(170, 90), // Top curve outer
          Offset(120, 115), // Middle intersect
          Offset(175, 125), // Bottom curve outer
          Offset(175, 170), // Bottom curve lower
          Offset(120, 180) // Bottom end
        ]),
    LetterData(
        letter: 'C',
        sound: 'see',
        example: 'Cat',
        color: Colors.green,
        difficulty: 2,
        points: [
          Offset(160, 70),
          Offset(130, 60),
          Offset(115, 80),
          Offset(115, 120),
          Offset(130, 140),
          Offset(160, 150)
        ]),
    LetterData(
        letter: 'D',
        sound: 'dee',
        example: 'Dog',
        color: Colors.orange,
        difficulty: 3,
        points: [
          Offset(120, 60),
          Offset(120, 180),
          Offset(120, 60),
          Offset(150, 70),
          Offset(170, 100),
          Offset(170, 140),
          Offset(150, 170),
          Offset(120, 180)
        ]),
    LetterData(
        letter: 'E',
        sound: 'ee',
        example: 'Elephant',
        color: Colors.purple,
        difficulty: 2,
        points: [
          Offset(160, 60),
          Offset(120, 60),
          Offset(120, 180),
          Offset(160, 180),
          Offset(120, 120),
          Offset(150, 120)
        ]),
    LetterData(
        letter: 'F',
        sound: 'ef',
        example: 'Fish',
        color: Colors.pink,
        difficulty: 2,
        points: [
          Offset(120, 60),
          Offset(120, 180),
          Offset(120, 60),
          Offset(160, 60),
          Offset(120, 120),
          Offset(150, 120)
        ]),
    LetterData(
        letter: 'G',
        sound: 'jee',
        example: 'Goat',
        color: Colors.teal,
        difficulty: 3,
        points: [
          Offset(160, 70),
          Offset(130, 60),
          Offset(115, 80),
          Offset(115, 120),
          Offset(130, 150),
          Offset(160, 160),
          Offset(175, 140),
          Offset(175, 110),
          Offset(150, 110)
        ]),
    LetterData(
        letter: 'H',
        sound: 'aych',
        example: 'Hat',
        color: Colors.brown,
        difficulty: 2,
        points: [
          Offset(120, 60),
          Offset(120, 180),
          Offset(170, 60),
          Offset(170, 180),
          Offset(120, 120),
          Offset(170, 120)
        ]),
    LetterData(
        letter: 'I',
        sound: 'eye',
        example: 'Igloo',
        color: Colors.indigo,
        difficulty: 1,
        points: [
          Offset(120, 60),
          Offset(170, 60),
          Offset(145, 60),
          Offset(145, 180),
          Offset(120, 180),
          Offset(170, 180)
        ]),
    LetterData(
        letter: 'J',
        sound: 'jay',
        example: 'Jet',
        color: Colors.cyan,
        difficulty: 2,
        points: [
          Offset(120, 60),
          Offset(170, 60),
          Offset(160, 60),
          Offset(160, 155),
          Offset(148, 172),
          Offset(128, 162)
        ]),
    LetterData(
        letter: 'K',
        sound: 'kay',
        example: 'Kite',
        color: Colors.lime,
        difficulty: 3,
        points: [
          Offset(120, 60),
          Offset(120, 180),
          Offset(120, 120),
          Offset(155, 60),
          Offset(120, 120),
          Offset(155, 180)
        ]),
    LetterData(
        letter: 'L',
        sound: 'el',
        example: 'Lion',
        color: Colors.amber,
        difficulty: 1,
        points: [Offset(120, 60), Offset(120, 180), Offset(160, 180)]),
    LetterData(
        letter: 'M',
        sound: 'em',
        example: 'Monkey',
        color: Colors.deepPurple,
        difficulty: 3,
        points: [
          Offset(110, 180),
          Offset(110, 60),
          Offset(145, 120),
          Offset(180, 60),
          Offset(180, 180)
        ]),
    LetterData(
        letter: 'N',
        sound: 'en',
        example: 'Nest',
        color: Colors.deepOrange,
        difficulty: 2,
        points: [
          Offset(120, 180),
          Offset(120, 60),
          Offset(170, 180),
          Offset(170, 60)
        ]),
    LetterData(
        letter: 'O',
        sound: 'oh',
        example: 'Orange',
        color: Colors.lightBlue,
        difficulty: 2,
        points: [
          Offset(150, 60),
          Offset(125, 75),
          Offset(115, 100),
          Offset(115, 140),
          Offset(125, 165),
          Offset(150, 180),
          Offset(175, 165),
          Offset(185, 140),
          Offset(185, 100),
          Offset(175, 75),
          Offset(150, 60)
        ]),
    LetterData(
        letter: 'P',
        sound: 'pee',
        example: 'Pig',
        color: Colors.lightGreen,
        difficulty: 2,
        points: [
          Offset(120, 60),
          Offset(120, 180),
          Offset(120, 60),
          Offset(155, 70),
          Offset(165, 90),
          Offset(155, 110),
          Offset(120, 110)
        ]),
    LetterData(
        letter: 'Q',
        sound: 'cue',
        example: 'Queen',
        color: Colors.pinkAccent,
        difficulty: 3,
        points: [
          Offset(150, 60),
          Offset(125, 75),
          Offset(115, 100),
          Offset(115, 140),
          Offset(125, 165),
          Offset(150, 180),
          Offset(175, 165),
          Offset(185, 140),
          Offset(185, 100),
          Offset(175, 75),
          Offset(150, 60),
          Offset(155, 155),
          Offset(175, 180)
        ]),
    LetterData(
        letter: 'R',
        sound: 'ar',
        example: 'Rabbit',
        color: Colors.purpleAccent,
        difficulty: 3,
        points: [
          Offset(120, 60),
          Offset(120, 180),
          Offset(120, 60),
          Offset(155, 70),
          Offset(165, 90),
          Offset(155, 110),
          Offset(120, 110),
          Offset(145, 110),
          Offset(170, 180)
        ]),
    LetterData(
        letter: 'S',
        sound: 'ess',
        example: 'Sun',
        color: Colors.teal,
        difficulty: 3,
        points: [
          Offset(165, 65),
          Offset(140, 60),
          Offset(120, 75),
          Offset(120, 100),
          Offset(145, 115),
          Offset(170, 130),
          Offset(170, 155),
          Offset(148, 170),
          Offset(120, 165)
        ]),
    LetterData(
        letter: 'T',
        sound: 'tee',
        example: 'Tree',
        color: Colors.cyan,
        difficulty: 1,
        points: [
          Offset(120, 60),
          Offset(170, 60),
          Offset(145, 60),
          Offset(145, 180)
        ]),
    LetterData(
        letter: 'U',
        sound: 'you',
        example: 'Umbrella',
        color: Colors.amber,
        difficulty: 2,
        points: [
          Offset(120, 60),
          Offset(120, 145),
          Offset(133, 165),
          Offset(150, 172),
          Offset(167, 165),
          Offset(180, 145),
          Offset(180, 60)
        ]),
    LetterData(
        letter: 'V',
        sound: 'vee',
        example: 'Violin',
        color: Colors.lightBlue,
        difficulty: 1,
        points: [Offset(120, 60), Offset(150, 180), Offset(180, 60)]),
    LetterData(
        letter: 'W',
        sound: 'double-you',
        example: 'Whale',
        color: Colors.lightGreen,
        difficulty: 3,
        points: [
          Offset(110, 60),
          Offset(130, 180),
          Offset(150, 110),
          Offset(170, 180),
          Offset(190, 60)
        ]),
    LetterData(
        letter: 'X',
        sound: 'ex',
        example: 'X-ray',
        color: Colors.red,
        difficulty: 2,
        points: [
          Offset(120, 60),
          Offset(180, 180),
          Offset(180, 60),
          Offset(120, 180)
        ]),
    LetterData(
        letter: 'Y',
        sound: 'why',
        example: 'Yarn',
        color: Colors.blue,
        difficulty: 2,
        points: [
          Offset(120, 60),
          Offset(150, 120),
          Offset(180, 60),
          Offset(150, 120),
          Offset(150, 180)
        ]),
    LetterData(
        letter: 'Z',
        sound: 'zee',
        example: 'Zebra',
        color: Colors.green,
        difficulty: 2,
        points: [
          Offset(120, 60),
          Offset(180, 60),
          Offset(120, 180),
          Offset(180, 180)
        ]),
  ];

  final List<LetterData> _lowercaseLetters = const [
    LetterData(
        letter: 'a',
        sound: 'ay',
        example: 'apple',
        color: Colors.red,
        difficulty: 2,
        points: [
          Offset(170, 100),
          Offset(148, 80),
          Offset(125, 88),
          Offset(118, 110),
          Offset(125, 135),
          Offset(148, 148),
          Offset(170, 140),
          Offset(170, 160),
          Offset(148, 170)
        ]),
    LetterData(
        letter: 'b',
        sound: 'bee',
        example: 'ball',
        color: Colors.blue,
        difficulty: 3,
        points: [
          Offset(120, 60),
          Offset(120, 180),
          Offset(120, 105),
          Offset(145, 82),
          Offset(168, 88),
          Offset(175, 110),
          Offset(168, 135),
          Offset(145, 148),
          Offset(120, 140)
        ]),
    LetterData(
        letter: 'c',
        sound: 'see',
        example: 'cat',
        color: Colors.green,
        difficulty: 1,
        points: [
          Offset(165, 82),
          Offset(140, 75),
          Offset(120, 90),
          Offset(118, 120),
          Offset(128, 148),
          Offset(155, 158)
        ]),
    LetterData(
        letter: 'd',
        sound: 'dee',
        example: 'dog',
        color: Colors.orange,
        difficulty: 3,
        points: [
          Offset(170, 60),
          Offset(170, 180),
          Offset(170, 105),
          Offset(148, 82),
          Offset(125, 88),
          Offset(118, 110),
          Offset(125, 135),
          Offset(148, 148),
          Offset(170, 140)
        ]),
    LetterData(
        letter: 'e',
        sound: 'ee',
        example: 'elephant',
        color: Colors.purple,
        difficulty: 2,
        points: [
          Offset(120, 115),
          Offset(165, 115),
          Offset(172, 105),
          Offset(165, 85),
          Offset(142, 75),
          Offset(120, 88),
          Offset(118, 115),
          Offset(125, 145),
          Offset(155, 158)
        ]),
    LetterData(
        letter: 'f',
        sound: 'ef',
        example: 'fish',
        color: Colors.pink,
        difficulty: 2,
        points: [
          Offset(165, 68),
          Offset(148, 60),
          Offset(138, 75),
          Offset(138, 180),
          Offset(122, 95),
          Offset(158, 95)
        ]),
    LetterData(
        letter: 'g',
        sound: 'jee',
        example: 'goat',
        color: Colors.teal,
        difficulty: 3,
        points: [
          Offset(170, 82),
          Offset(148, 72),
          Offset(125, 82),
          Offset(118, 105),
          Offset(125, 132),
          Offset(148, 145),
          Offset(170, 138),
          Offset(170, 185),
          Offset(155, 205),
          Offset(128, 202)
        ]),
    LetterData(
        letter: 'h',
        sound: 'aych',
        example: 'hat',
        color: Colors.brown,
        difficulty: 2,
        points: [
          Offset(120, 60),
          Offset(120, 180),
          Offset(120, 108),
          Offset(142, 85),
          Offset(162, 85),
          Offset(172, 100),
          Offset(172, 180)
        ]),
    LetterData(
        letter: 'i',
        sound: 'eye',
        example: 'igloo',
        color: Colors.indigo,
        difficulty: 1,
        points: [
          Offset(148, 85),
          Offset(148, 175),
          Offset(142, 50),
          Offset(148, 42),
          Offset(155, 50)
        ]),
    LetterData(
        letter: 'j',
        sound: 'jay',
        example: 'jet',
        color: Colors.cyan,
        difficulty: 2,
        points: [
          Offset(162, 85),
          Offset(162, 175),
          Offset(148, 195),
          Offset(132, 185),
          Offset(155, 50),
          Offset(162, 42),
          Offset(170, 50)
        ]),
    LetterData(
        letter: 'k',
        sound: 'kay',
        example: 'kite',
        color: Colors.lime,
        difficulty: 3,
        points: [
          Offset(120, 60),
          Offset(120, 180),
          Offset(120, 122),
          Offset(145, 100),
          Offset(168, 80),
          Offset(120, 122),
          Offset(145, 145),
          Offset(168, 168)
        ]),
    LetterData(
        letter: 'l',
        sound: 'el',
        example: 'lion',
        color: Colors.amber,
        difficulty: 1,
        points: [Offset(148, 60), Offset(148, 170), Offset(140, 182)]),
    LetterData(
        letter: 'm',
        sound: 'em',
        example: 'monkey',
        color: Colors.deepPurple,
        difficulty: 3,
        points: [
          Offset(112, 82),
          Offset(112, 180),
          Offset(112, 105),
          Offset(130, 85),
          Offset(152, 85),
          Offset(162, 100),
          Offset(162, 180),
          Offset(162, 105),
          Offset(180, 85),
          Offset(200, 85),
          Offset(210, 100),
          Offset(210, 180)
        ]),
    LetterData(
        letter: 'n',
        sound: 'en',
        example: 'nest',
        color: Colors.deepOrange,
        difficulty: 2,
        points: [
          Offset(120, 82),
          Offset(120, 180),
          Offset(120, 108),
          Offset(142, 85),
          Offset(162, 85),
          Offset(172, 100),
          Offset(172, 180)
        ]),
    LetterData(
        letter: 'o',
        sound: 'oh',
        example: 'orange',
        color: Colors.lightBlue,
        difficulty: 2,
        points: [
          Offset(148, 78),
          Offset(125, 88),
          Offset(115, 112),
          Offset(118, 140),
          Offset(135, 158),
          Offset(158, 162),
          Offset(178, 150),
          Offset(185, 128),
          Offset(182, 102),
          Offset(165, 82),
          Offset(148, 78)
        ]),
    LetterData(
        letter: 'p',
        sound: 'pee',
        example: 'pig',
        color: Colors.lightGreen,
        difficulty: 3,
        points: [
          Offset(120, 82),
          Offset(120, 215),
          Offset(120, 108),
          Offset(145, 85),
          Offset(168, 92),
          Offset(175, 115),
          Offset(165, 138),
          Offset(142, 148),
          Offset(120, 140)
        ]),
    LetterData(
        letter: 'q',
        sound: 'cue',
        example: 'queen',
        color: Colors.pinkAccent,
        difficulty: 3,
        points: [
          Offset(172, 82),
          Offset(172, 215),
          Offset(172, 108),
          Offset(148, 85),
          Offset(125, 92),
          Offset(118, 115),
          Offset(128, 138),
          Offset(150, 148),
          Offset(172, 140)
        ]),
    LetterData(
        letter: 'r',
        sound: 'ar',
        example: 'rabbit',
        color: Colors.purpleAccent,
        difficulty: 1,
        points: [
          Offset(120, 82),
          Offset(120, 180),
          Offset(120, 108),
          Offset(142, 85),
          Offset(165, 85)
        ]),
    LetterData(
        letter: 's',
        sound: 'ess',
        example: 'sun',
        color: Colors.teal,
        difficulty: 2,
        points: [
          Offset(165, 85),
          Offset(138, 80),
          Offset(120, 95),
          Offset(125, 118),
          Offset(148, 128),
          Offset(168, 140),
          Offset(165, 162),
          Offset(140, 170),
          Offset(118, 162)
        ]),
    LetterData(
        letter: 't',
        sound: 'tee',
        example: 'tree',
        color: Colors.cyan,
        difficulty: 2,
        points: [
          Offset(148, 60),
          Offset(148, 175),
          Offset(138, 185),
          Offset(128, 95),
          Offset(172, 95)
        ]),
    LetterData(
        letter: 'u',
        sound: 'you',
        example: 'umbrella',
        color: Colors.amber,
        difficulty: 2,
        points: [
          Offset(120, 82),
          Offset(120, 148),
          Offset(132, 168),
          Offset(150, 175),
          Offset(168, 168),
          Offset(178, 148),
          Offset(178, 82),
          Offset(178, 180)
        ]),
    LetterData(
        letter: 'v',
        sound: 'vee',
        example: 'violin',
        color: Colors.lightBlue,
        difficulty: 1,
        points: [Offset(120, 82), Offset(150, 175), Offset(180, 82)]),
    LetterData(
        letter: 'w',
        sound: 'double-you',
        example: 'whale',
        color: Colors.lightGreen,
        difficulty: 2,
        points: [
          Offset(112, 82),
          Offset(130, 175),
          Offset(150, 115),
          Offset(170, 175),
          Offset(190, 82)
        ]),
    LetterData(
        letter: 'x',
        sound: 'ex',
        example: 'x-ray',
        color: Colors.red,
        difficulty: 2,
        points: [
          Offset(120, 82),
          Offset(180, 175),
          Offset(180, 82),
          Offset(120, 175)
        ]),
    LetterData(
        letter: 'y',
        sound: 'why',
        example: 'yarn',
        color: Colors.blue,
        difficulty: 3,
        points: [
          Offset(120, 82),
          Offset(150, 145),
          Offset(180, 82),
          Offset(150, 145),
          Offset(138, 180),
          Offset(125, 205)
        ]),
    LetterData(
        letter: 'z',
        sound: 'zee',
        example: 'zebra',
        color: Colors.green,
        difficulty: 2,
        points: [
          Offset(120, 82),
          Offset(180, 82),
          Offset(120, 175),
          Offset(180, 175)
        ]),
  ];

  final List<LetterData> _numbers = const [
    LetterData(
        letter: '1',
        sound: 'one',
        example: 'One',
        color: Colors.red,
        difficulty: 1,
        points: [Offset(130, 80), Offset(150, 60), Offset(150, 180)]),
    LetterData(
        letter: '2',
        sound: 'two',
        example: 'Two',
        color: Colors.blue,
        difficulty: 2,
        points: [
          Offset(122, 75),
          Offset(148, 62),
          Offset(172, 75),
          Offset(175, 98),
          Offset(122, 155),
          Offset(122, 178),
          Offset(178, 178)
        ]),
    LetterData(
        letter: '3',
        sound: 'three',
        example: 'Three',
        color: Colors.green,
        difficulty: 2,
        points: [
          Offset(122, 65),
          Offset(175, 65),
          Offset(175, 105),
          Offset(138, 118),
          Offset(175, 132),
          Offset(175, 172),
          Offset(122, 172)
        ]),
    LetterData(
        letter: '4',
        sound: 'four',
        example: 'Four',
        color: Colors.orange,
        difficulty: 2,
        points: [
          Offset(162, 60),
          Offset(118, 128),
          Offset(178, 128),
          Offset(162, 60),
          Offset(162, 185)
        ]),
    LetterData(
        letter: '5',
        sound: 'five',
        example: 'Five',
        color: Colors.purple,
        difficulty: 2,
        points: [
          Offset(172, 62),
          Offset(118, 62),
          Offset(118, 112),
          Offset(172, 112),
          Offset(178, 148),
          Offset(165, 172),
          Offset(118, 168)
        ]),
    LetterData(
        letter: '6',
        sound: 'six',
        example: 'Six',
        color: Colors.teal,
        difficulty: 3,
        points: [
          Offset(172, 65),
          Offset(138, 62),
          Offset(118, 80),
          Offset(118, 148),
          Offset(132, 172),
          Offset(158, 178),
          Offset(178, 162),
          Offset(178, 138),
          Offset(162, 118),
          Offset(135, 115),
          Offset(118, 130)
        ]),
    LetterData(
        letter: '7',
        sound: 'seven',
        example: 'Seven',
        color: Colors.pink,
        difficulty: 1,
        points: [Offset(118, 62), Offset(178, 62), Offset(138, 185)]),
    LetterData(
        letter: '8',
        sound: 'eight',
        example: 'Eight',
        color: Colors.brown,
        difficulty: 3,
        points: [
          Offset(150, 62),
          Offset(128, 72),
          Offset(118, 90),
          Offset(125, 115),
          Offset(150, 125),
          Offset(175, 115),
          Offset(182, 90),
          Offset(172, 72),
          Offset(150, 62),
          Offset(150, 125),
          Offset(125, 138),
          Offset(118, 158),
          Offset(128, 178),
          Offset(150, 188),
          Offset(172, 178),
          Offset(182, 158),
          Offset(175, 138),
          Offset(150, 125)
        ]),
    LetterData(
        letter: '9',
        sound: 'nine',
        example: 'Nine',
        color: Colors.indigo,
        difficulty: 3,
        points: [
          Offset(178, 100),
          Offset(172, 72),
          Offset(150, 60),
          Offset(128, 70),
          Offset(118, 92),
          Offset(122, 118),
          Offset(142, 132),
          Offset(168, 128),
          Offset(178, 108),
          Offset(178, 155),
          Offset(165, 185)
        ]),
    LetterData(
        letter: '10',
        sound: 'ten',
        example: 'Ten',
        color: Colors.cyan,
        difficulty: 3,
        points: [
          Offset(78, 80),
          Offset(95, 65),
          Offset(95, 185),
          Offset(130, 62),
          Offset(112, 75),
          Offset(108, 110),
          Offset(112, 148),
          Offset(132, 172),
          Offset(158, 172),
          Offset(175, 148),
          Offset(178, 110),
          Offset(172, 75),
          Offset(150, 62),
          Offset(130, 62)
        ]),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  //  Getters
  // ─────────────────────────────────────────────────────────────────────────

  List<LetterData> get _currentLetters {
    if (_selectedMode == 0) return _uppercaseLetters;
    if (_selectedMode == 1) return _lowercaseLetters;
    return _numbers;
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
    _loadProgress();

    _successController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut));

    _pulseController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this)
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _confettiController = AnimationController(
        duration: const Duration(milliseconds: 2500), vsync: this)
      ..addListener(_updateConfetti);

    _warningController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _warningAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _warningController, curve: Curves.easeInOut));

    _loadProgress();
    _initSmartResume();
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

      // Mode 0=Upper, 1=Lower, 2=Numbers
      int targetMode = 0;
      int targetIndex = 0;
      bool found = false;

      // Mode 0: Uppercase (A-Z)
      for (int i = 0; i < 26; i++) {
        if (!userProvider.isSundanActivityCompleted('uppercase', i)) {
          targetMode = 0;
          targetIndex = i;
          found = true;
          break;
        }
      }

      if (!found) {
        // Mode 1: Lowercase (a-z)
        for (int i = 0; i < 26; i++) {
          if (!userProvider.isSundanActivityCompleted('lowercase', i)) {
            targetMode = 1;
            targetIndex = i;
            found = true;
            break;
          }
        }
      }

      if (!found) {
        // Mode 2: Numbers (1-10)
        for (int i = 0; i < 10; i++) {
          if (!userProvider.isSundanActivityCompleted('numbers', i)) {
            targetMode = 2;
            targetIndex = i;
            found = true;
            break;
          }
        }
      }

      // If all completed, default to the last mode/item
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
      }
    } catch (e) {
      debugPrint('Sundan Smart Resume failed: $e');
    }
  }

  @override
  void dispose() {
    _successController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _warningController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Progress persistence
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadProgress() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < _uppercaseLetters.length; i++) {
        final k = SundanProgressKeys.upperKey(_uppercaseLetters[i].letter);
        if (_prefs!.getBool(k) == true) _completedUpper.add(i);
      }
      for (int i = 0; i < _lowercaseLetters.length; i++) {
        final k = SundanProgressKeys.lowerKey(_lowercaseLetters[i].letter);
        if (_prefs!.getBool(k) == true) _completedLower.add(i);
      }
      for (int i = 0; i < _numbers.length; i++) {
        final k = SundanProgressKeys.numKey(_numbers[i].letter);
        if (_prefs!.getBool(k) == true) _completedNums.add(i);
      }
    });
  }

  void _syncToUserProvider(int modeIndex, int letterIndex) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    String modeKey = modeIndex == 0
        ? 'uppercase'
        : modeIndex == 1
            ? 'lowercase'
            : 'numbers';
    userProvider.updateSundanProgress(modeKey, letterIndex, true);
    userProvider.addStars(3); // Award stars for completion
  }

  Future<void> _saveLetterComplete(int modeIndex, int letterIndex) async {
    if (_prefs == null) return;
    String key;
    if (modeIndex == 0) {
      key = SundanProgressKeys.upperKey(_uppercaseLetters[letterIndex].letter);
    } else if (modeIndex == 1) {
      key = SundanProgressKeys.lowerKey(_lowercaseLetters[letterIndex].letter);
    } else {
      key = SundanProgressKeys.numKey(_numbers[letterIndex].letter);
    }
    await _prefs!.setBool(key, true);

    // Update totals
    final attempts =
        (_prefs!.getInt(SundanProgressKeys.totalAttempts) ?? 0) + 1;
    final completed =
        (_prefs!.getInt(SundanProgressKeys.totalCompleted) ?? 0) + 1;
    await _prefs!.setInt(SundanProgressKeys.totalAttempts, attempts);
    await _prefs!.setInt(SundanProgressKeys.totalCompleted, completed);

    final modeName = modeIndex == 0
        ? 'Uppercase'
        : modeIndex == 1
            ? 'Lowercase'
            : 'Numbers';
    final letter = modeIndex == 0
        ? _uppercaseLetters[letterIndex].letter
        : modeIndex == 1
            ? _lowercaseLetters[letterIndex].letter
            : _numbers[letterIndex].letter;
    await _prefs!
        .setString(SundanProgressKeys.lastActivity, '$modeName: $letter');

    _syncToUserProvider(modeIndex, letterIndex);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Canvas transform
  // ─────────────────────────────────────────────────────────────────────────

  void _computeTransform(Size canvasSize) {
    if (_canvasSize == canvasSize) return;
    _canvasSize = canvasSize;
    const designW = 300.0;
    const designH = 240.0;
    const padding = 12.0; // Reduced padding
    final scaleX = (canvasSize.width - padding * 2) / designW;
    final scaleY = (canvasSize.height - padding * 2) / designH;
    _canvasScale =
        (scaleX < scaleY ? scaleX : scaleY) * 1.15; // Increased scale by 15%
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

  double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final len = ab.distance;
    if (len == 0) return (p - a).distance;
    final t = (ap.dx * ab.dx + ap.dy * ab.dy) / (len * len);
    final tc = t.clamp(0.0, 1.0);
    final proj = Offset(a.dx + tc * ab.dx, a.dy + tc * ab.dy);
    return (p - proj).distance;
  }

  // ── Hit detection ─────────────────────────────────────────────────────────

  bool _isOnPath(Offset designPt) {
    if (_isCompleted) return true;
    final pts = _currentLetter.points;
    for (int i = 0; i < pts.length - 1; i++) {
      if (_distToSegment(designPt, pts[i], pts[i + 1]) <= _hitRadius * 1.5) {
        // Increased hit area
        return true;
      }
    }
    return false;
  }

  void _onPanStart(DragStartDetails d) {
    if (_canvasSize == Size.zero) return;
    if (_isCompleted) {
      _showFeedback('Nalpasem daytoyen! 🌟 (Good Job!)', Colors.green);
      return;
    }
    final designPt = _toDesign(d.localPosition);

    // START ANYWHERE ON PATH: Child no longer forced into one starting dot
    if (!_isOnPath(designPt)) {
      _triggerWarning('Magsimula sa linya!');
      return;
    }

    setState(() {
      _tracedPoints = [_toScreen(designPt)];
      _visitedPoints = {};
      _outOfBounds = false;
      _tracingProgress = 0.0;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_isCompleted || _tracedPoints.isEmpty) return;
    final designPt = _toDesign(d.localPosition);
    final screenPt = _toScreen(designPt);
    final pts = _currentLetter.points;

    // 1. Path adherence check
    if (!_isOnPath(designPt)) {
      setState(() => _outOfBounds = true);
      _triggerWarning('Manatili sa loob ng linya!');
      return;
    }

    // 2. PROXIMITY DETECTION: Mark points as "covered" regardless of sequence
    for (int i = 0; i < pts.length; i++) {
      if ((designPt - pts[i]).distance <= _hitRadius * 1.8) {
        _visitedPoints.add(i);
      }
    }

    setState(() {
      _outOfBounds = false;
      _tracingProgress = _visitedPoints.length / pts.length;
      if (_tracedPoints.isEmpty ||
          (screenPt - _tracedPoints.last).distance > 3.0) {
        _tracedPoints.add(screenPt);
      }
    });

    // 3. COMPLETION: If 90% of the skeletal points are covered
    if (_tracingProgress >= 0.90 && !_isCompleted) {
      _completeTracing();
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (_isCompleted) return;
    // Don't auto-reset points here; let the child draw freely until completion or manual clear
    setState(() => _outOfBounds = false);
  }

  void _resetTracing() {
    setState(() {
      _tracedPoints = [];
      _isCompleted = _currentCompletedSet.contains(_selectedIndex);
      _tracingProgress = 0.0;
      _visitedPoints = {};
      _outOfBounds = false;
      _wrongAttempts = 0;
      _canvasSize = Size.zero;
    });
    _confettiParticles.clear();
    _successController.reset();
    _confettiController.stop();
  }

  void _completeTracing() {
    if (_isCompleted) return;
    setState(() {
      _isCompleted = true;
      _tracingProgress = 1.0;
      _score += 10;
      _stars += 3;
    });

    // Mark this letter/number as done
    _currentCompletedSet.add(_selectedIndex);
    _saveLetterComplete(_selectedMode, _selectedIndex);

    _successController.forward(from: 0);
    _spawnConfetti();
    _showFeedback('🌟 Good Job! +10 puntos', Colors.green);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_selectedIndex < _currentLetters.length - 1) {
        setState(() {
          _selectedIndex++;
          _resetTracing();
        });
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

    setState(() {
      _wrongAttempts++;
    });

    if (_wrongAttempts >= 5) {
      _showFeedback('Masyadong mahirap? Lipat tayo sa susunod!', Colors.blue);
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _nextLetter();
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Confetti
  // ─────────────────────────────────────────────────────────────────────────

  void _spawnConfetti() {
    _confettiParticles.clear();
    const colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.pink,
      Colors.orange,
      Colors.purple,
      Colors.cyan
    ];
    final cx = _canvasSize.width / 2;
    final cy = _canvasSize.height / 3;
    for (int i = 0; i < 60; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 3.0 + _rng.nextDouble() * 5;
      _confettiParticles.add(_ConfettiParticle(
        position: Offset(cx, cy),
        velocity: Offset(cos(angle) * speed, sin(angle) * speed - 6),
        color: colors[_rng.nextInt(colors.length)],
        size: 8 + _rng.nextDouble() * 8,
        rotation: _rng.nextDouble() * 2 * pi,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 0.3,
        opacity: 1.0,
      ));
    }
    _confettiController.forward(from: 0);
  }

  void _updateConfetti() {
    if (!mounted) return;
    setState(() {
      for (final p in _confettiParticles) {
        p.position += p.velocity;
        p.velocity = Offset(p.velocity.dx * 0.98, p.velocity.dy + 0.25);
        p.rotation += p.rotationSpeed;
        p.opacity = (1.0 - _confettiController.value).clamp(0.0, 1.0);
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Reset / nav
  // ─────────────────────────────────────────────────────────────────────────

  void _nextLetter() {
    if (_selectedIndex < _currentLetters.length - 1) {
      setState(() {
        _selectedIndex++;
        _resetTracing();
      });
    }
  }

  void _prevLetter() {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex--;
        _resetTracing();
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Feedback & Dialog
  // ─────────────────────────────────────────────────────────────────────────

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
        ? "Dakkel a Letra"
        : _selectedMode == 1
            ? "Bassit a Letra"
            : "Dagiti Numero";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessModal(
        title: 'Naammuammon!',
        subtitle: 'Nalpasem amin dagiti $modeName!',
        score: _score,
        stars: 3,
        primaryLabel: 'Agtuloy',
        onPrimaryTap: () => Navigator.pop(context),
        secondaryLabel: 'Uliten',
        onSecondaryTap: () {
          Navigator.pop(context);
          _resetTracing();
          setState(() => _selectedIndex = 0);
        },
        mainColor: AppColors.primary,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Surotem, Kabaelam!',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        actions: [
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
                  _buildModeTab(0, 'ABC', 'Upper'),
                  _buildModeTab(1, 'abc', 'Lower'),
                  _buildModeTab(2, '123', 'Numbers'),
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
                  Text('Letter ${_currentLetter.letter}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text('${_currentLetter.example} • "${_currentLetter.sound}"',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ])),
            // Completed count chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${_currentCompletedSet.length}/${_currentLetters.length} ✓',
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 6),
            Column(children: [
              Text('Puntos',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text('$_score',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ]),
          ]),
        ),

        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _tracingProgress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _isCompleted ? Colors.green : _currentLetter.color),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('${(_tracingProgress * 100).toInt()}%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isCompleted ? Colors.green : _currentLetter.color)),
          ]),
        ),

        // Navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
                icon: const Icon(Icons.arrow_left,
                    size: 30, color: AppColors.primary),
                onPressed: _prevLetter),
            Text('${_selectedIndex + 1} / ${_currentLetters.length}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600)),
            IconButton(
                icon: const Icon(Icons.arrow_right,
                    size: 30, color: AppColors.primary),
                onPressed: _nextLetter),
          ]),
        ),

        // Canvas
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: _warningAnimation,
              builder: (_, child) => Container(
                width: size.width * 0.88,
                height: size.width * 0.88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: _outOfBounds
                      ? Border.all(
                          color: Colors.orange
                              .withOpacity(0.6 + _warningAnimation.value * 0.4),
                          width: 3)
                      : Border.all(color: Colors.grey.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _isCompleted
                          ? Colors.green.withOpacity(0.25)
                          : _currentLetter.color.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: child,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: LayoutBuilder(builder: (_, constraints) {
                  final cs = Size(constraints.maxWidth, constraints.maxHeight);
                  _computeTransform(cs);
                  return GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Stack(fit: StackFit.expand, children: [
                      // Ghost
                      Center(
                          child: Opacity(
                              opacity: 0.06,
                              child: Text(_currentLetter.letter,
                                  style: TextStyle(
                                      fontSize: 180,
                                      fontWeight: FontWeight.bold,
                                      color: _currentLetter.color)))),
                      // Tracing
                      CustomPaint(
                        painter: LetterTracingPainter(
                          guidePoints: _currentLetter.points,
                          tracedPoints: _tracedPoints,
                          color: _currentLetter.color,
                          isCompleted: _isCompleted,
                          visitedPoints: _visitedPoints,
                          scale: _canvasScale,
                          offset: _canvasOffset,
                        ),
                      ),
                      // Confetti
                      if (_confettiParticles.isNotEmpty)
                        CustomPaint(
                            painter: _ConfettiPainter(_confettiParticles)),
                      // Success overlay
                      if (_isCompleted)
                        Center(
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.green.withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 4)
                                ],
                              ),
                              child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white, size: 48),
                                    SizedBox(height: 8),
                                    Text('Good Job! 🌟',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                            ),
                          ),
                        ),
                      // Pulsing start hint
                      if (!_isCompleted &&
                          _tracedPoints.isEmpty &&
                          _canvasSize != Size.zero)
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (_, __) {
                            final startScreen =
                                _toScreen(_currentLetter.points.first);
                            return Positioned(
                              left: startScreen.dx - 22,
                              top: startScreen.dy - 22,
                              child: Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              Colors.blue.withOpacity(0.2)))),
                            );
                          },
                        ),
                    ]),
                  );
                }),
              ),
            ),
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

        // Reset button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: OutlinedButton.icon(
            onPressed: _resetTracing,
            icon: const Icon(Icons.refresh),
            label: const Text('Ulitin'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
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
          borderRadius: BorderRadius.circular(20),
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
