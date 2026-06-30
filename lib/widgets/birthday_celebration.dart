import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../l10n/app_localizations.dart';

/// Shows a full-screen, centered birthday celebration overlay with confetti,
/// floating balloons and an animated "Happy Birthday [name]!" greeting.
///
/// Used on both the student home screen and the teacher dashboard so the
/// celebration appears the moment a birthday child logs in.
Future<void> showBirthdayCelebration(
  BuildContext context, {
  required String name,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'birthday',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => BirthdayCelebrationOverlay(name: name),
    transitionBuilder: (_, anim, __, child) {
      return FadeTransition(opacity: anim, child: child);
    },
  );
}

class BirthdayCelebrationOverlay extends StatefulWidget {
  final String name;
  const BirthdayCelebrationOverlay({super.key, required this.name});

  @override
  State<BirthdayCelebrationOverlay> createState() =>
      _BirthdayCelebrationOverlayState();
}

class _BirthdayCelebrationOverlayState
    extends State<BirthdayCelebrationOverlay> {
  late final ConfettiController _confetti;

  static const _balloonColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFB347),
    Color(0xFF6C63FF),
    Color(0xFFFF99C8),
    Color(0xFF95D9C3),
  ];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 8));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti raining from the top center.
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              numberOfParticles: 24,
              maxBlastForce: 22,
              minBlastForce: 8,
              gravity: 0.18,
              emissionFrequency: 0.04,
              colors: _balloonColors,
            ),
          ),

          // Floating balloons behind the card.
          ..._buildBalloons(size),

          // Centered greeting card.
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFFF3F9)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouncing cake.
                  const Text('🎂', style: TextStyle(fontSize: 72))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        begin: 0,
                        end: -14,
                        duration: 900.ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .shimmer(
                        duration: 1400.ms,
                        color: Colors.amber.withValues(alpha: 0.5),
                      ),
                  const SizedBox(height: 18),

                  // Animated greeting text.
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'FuzzyBubbles',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6584),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    child: AnimatedTextKit(
                      isRepeatingAnimation: false,
                      animatedTexts: [
                        ScaleAnimatedText(
                          loc.birthdayGreeting(widget.name),
                          duration: const Duration(milliseconds: 1400),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    '🎉  🥳  🎈',
                    style: TextStyle(fontSize: 26),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 0.9, end: 1.1, duration: 700.ms),
                  const SizedBox(height: 22),

                  // Dismiss button.
                  FilledButton.tonal(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      loc.okButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBalloons(Size size) {
    final rnd = math.Random(7);
    return List.generate(6, (i) {
      final left = size.width * (0.08 + 0.16 * i) + rnd.nextDouble() * 12;
      final delay = (i * 250).ms;
      final drift = i.isEven ? -10.0 : 10.0;
      return Positioned(
        left: left.clamp(8.0, size.width - 48),
        bottom: -60,
        child: _Balloon(color: _balloonColors[i % _balloonColors.length])
            .animate(onPlay: (c) => c.repeat())
            .moveY(
              begin: 0,
              end: -(size.height + 120),
              duration: 6000.ms,
              delay: delay,
              curve: Curves.easeIn,
            )
            .moveX(
              begin: 0,
              end: drift,
              duration: 1500.ms,
              curve: Curves.easeInOut,
            ),
      );
    });
  }
}

class _Balloon extends StatelessWidget {
  final Color color;
  const _Balloon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        Container(width: 1.5, height: 26, color: Colors.white54),
      ],
    );
  }
}
