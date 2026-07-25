import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class SuccessModal extends StatefulWidget {
  final String title;
  final String subtitle;
  final int score;
  final int stars;
  final int? streak;
  final List<String>? badges;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final String secondaryLabel;
  final VoidCallback onSecondaryTap;
  final Color mainColor;

  const SuccessModal({
    super.key,
    required this.title,
    required this.subtitle,
    required this.score,
    required this.stars,
    this.streak,
    this.badges,
    required this.primaryLabel,
    required this.onPrimaryTap,
    required this.secondaryLabel,
    required this.onSecondaryTap,
    this.mainColor = AppColors.primary,
  });

  @override
  State<SuccessModal> createState() => _SuccessModalState();
}

class _SuccessModalState extends State<SuccessModal> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Main Card
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 8),

                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final bool isFull = index < widget.stars;
                    return Icon(
                      LucideIcons.star,
                      color: isFull ? const Color(0xFFFFD700) : Colors.grey.shade300,
                      fill: isFull ? 1.0 : 0.0,
                      size: 48,
                    )
                        .animate(delay: (400 + (index * 150)).ms)
                        .scale(duration: 400.ms, curve: Curves.easeOutBack)
                        .shimmer(delay: 1200.ms, duration: 800.ms);
                  }),
                ),

                const SizedBox(height: 24),

                // Stats Container
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: widget.mainColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: widget.mainColor.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Score', widget.score.toString(),
                          LucideIcons.trophy, Colors.orange),
                      if (widget.streak != null) ...[
                        Container(
                            width: 1.5,
                            height: 30,
                            color: widget.mainColor.withOpacity(0.15)),
                        _buildStatItem(
                            'Streak',
                            widget.streak.toString(),
                            LucideIcons.flame,
                            Colors.deepOrange),
                      ],
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .scale(duration: 400.ms, curve: Curves.easeOutBack),

                // Badges
                if (widget.badges != null && widget.badges!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    children:
                        widget.badges!.map((b) => _buildBadge(b)).toList(),
                  ).animate().fadeIn(delay: 1000.ms),
                ],

                const SizedBox(height: 32),

                // Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: widget.onPrimaryTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.mainColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 4,
                          shadowColor: widget.mainColor.withOpacity(0.5),
                        ),
                        child: Text(
                          widget.primaryLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: widget.onSecondaryTap,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textLight,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                      ),
                      child: Text(
                        widget.secondaryLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.1),
              ],
            ),
          ),

          // Header Icon Banner
          Positioned(
            top: -40,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.mainColor,
                        widget.mainColor.withOpacity(0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.party_popper,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
              createParticlePath: drawStar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.award,
              color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8860B),
            ),
          ),
        ],
      ),
    );
  }

  /// A custom path to paint a star.
  Path drawStar(Size size) {
    final path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }
}
