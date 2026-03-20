import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class RewardAnimation extends StatelessWidget {
  final Color color;
  final VoidCallback onComplete;
  
  const RewardAnimation({
    super.key,
    required this.color,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            curve: Curves.elasticOut,
            onEnd: onComplete,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        size: 80 * value,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 10),
                      DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              'Great Job!',
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1,
                          pause: const Duration(milliseconds: 100),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}