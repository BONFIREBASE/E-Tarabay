import 'package:flutter/widgets.dart' show Color;

class Lesson {
  final String id;
  final String title;
  final String category;
  final String emoji;
  final Color color;
  final int items;
  final int starsEarned;

  Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.color,
    required this.items,
    this.starsEarned = 0,
  });

  String? get titleIlocano => null;

  String? get titleFilipino => null;

  static List<Lesson> getLessons() {
    return [
      Lesson(
        id: 'alphabet',
        title: 'Alphabet',
        category: 'alphabet',
        emoji: '🔤',
        color: AppColors.alphabet,
        items: 5,
      ),
      Lesson(
        id: 'numbers',
        title: 'Numbers',
        category: 'numbers',
        emoji: '🔢',
        color: AppColors.numbers,
        items: 5,
      ),
      Lesson(
        id: 'colors',
        title: 'Colors',
        category: 'colors',
        emoji: '🎨',
        color: AppColors.colors,
        items: 4,
      ),
      Lesson(
        id: 'shapes',
        title: 'Shapes',
        category: 'shapes',
        emoji: '⬛',
        color: AppColors.shapes,
        items: 3,
      ),
      Lesson(
        id: 'animals',
        title: 'Animals',
        category: 'animals',
        emoji: '🐶',
        color: AppColors.animals,
        items: 3,
      ),
      Lesson(
        id: 'myBody',
        title: 'My Body',
        category: 'myBody',
        emoji: '🦶',
        color: AppColors.body,
        items: 4,
      ),
      Lesson(
        id: 'myFamily',
        title: 'My Family',
        category: 'myFamily',
        emoji: '👨‍👩‍👧',
        color: AppColors.family,
        items: 3,
      ),
      Lesson(
        id: 'math',
        title: 'Math',
        category: 'math',
        emoji: '➕',
        color: AppColors.numbers,
        items: 4,
      ),
    ];
  }
}

class AppColors {
  static const Color alphabet = Color(0xFFFF6B6B);
  static const Color numbers = Color(0xFF4ECDC4);
  static const Color colors = Color(0xFFFFB347);
  static const Color shapes = Color(0xFF95D9C3);
  static const Color animals = Color(0xFFA8E6CF);
  static const Color family = Color(0xFFFF99C8);
  static const Color body = Color(0xFFA0D6B4);
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color success = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
}