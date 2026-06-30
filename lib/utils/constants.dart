import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color background = Color(0xFFF8F9FF);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
  
  static const Color alphabet = Color(0xFFFF6B6B);
  static const Color numbers = Color(0xFF4ECDC4);
  static const Color colors = Color(0xFFFFB347);
  static const Color shapes = Color(0xFF95D9C3);
  static const Color animals = Color(0xFFA8E6CF);
  static const Color family = Color(0xFFFF99C8);
  static const Color body = Color(0xFFA0D6B4);
}

/// Maps an avatar preset key (e.g. 'boy1', 'girl2', 'female') to the matching
/// character image so kids can easily tell male from female.
String avatarAssetForPreset(String preset) {
  final p = preset.toLowerCase();
  if (p.startsWith('girl') || p == 'female') {
    return 'assets/images/female.png';
  }
  return 'assets/images/male.png';
}

/// Soft background tint behind a character avatar, based on gender.
Color avatarTintForPreset(String preset) {
  final p = preset.toLowerCase();
  if (p.startsWith('girl') || p == 'female') {
    return const Color(0xFFFFE1EC);
  }
  return const Color(0xFFDCEBFF);
}