import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CustomBackButton extends StatelessWidget {
  final Color iconColor;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const CustomBackButton({
    super.key,
    this.iconColor = Colors.white,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // If background color is null, we generate a highly transparent version of the icon color
    final bgColor = backgroundColor ?? iconColor.withOpacity(0.15);

    return SafeArea(
      bottom: false,
      child: GestureDetector(
        onTap: onPressed ?? () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8), // Ensures it doesn't touch the very edges of the AppBar
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.arrow_left,
            color: iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
