import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class MagbasaKwentoScreen extends StatefulWidget {
  final int activityIndex;
  final String activityTitle;

  const MagbasaKwentoScreen({
    super.key,
    required this.activityIndex,
    required this.activityTitle,
  });

  @override
  State<MagbasaKwentoScreen> createState() => _MagbasaKwentoScreenState();
}

class _MagbasaKwentoScreenState extends State<MagbasaKwentoScreen> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.colors,
        title: Text(
          widget.activityTitle,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context, _isCompleted),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📝',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
            Text(
              widget.activityTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isCompleted = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.storyFinishedGreatJob),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  if (!context.mounted) return;
                  Navigator.pop(context, true);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colors,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(AppLocalizations.of(context)!.finishedExclamation),
            ),
          ],
        ),
      ),
    );
  }
}