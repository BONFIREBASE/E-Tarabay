import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MagbasaTulaScreen extends StatefulWidget {
  final int activityIndex;
  final String activityTitle;

  const MagbasaTulaScreen({
    super.key,
    required this.activityIndex,
    required this.activityTitle,
  });

  @override
  State<MagbasaTulaScreen> createState() => _MagbasaTulaScreenState();
}

class _MagbasaTulaScreenState extends State<MagbasaTulaScreen> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.alphabet,
        title: Text(
          widget.activityTitle,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _isCompleted),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📖',
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
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 48),
                        SizedBox(height: 16),
                        Text(AppLocalizations.of(context)!.poemFinishedGreatJob, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // Pop dialog
                  Navigator.of(context).pop(true); // Pop screen
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alphabet,
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