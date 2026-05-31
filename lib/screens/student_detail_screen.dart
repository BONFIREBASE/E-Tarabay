import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentName;
  final Map<String, dynamic> studentData;

  const StudentDetailScreen({
    super.key,
    required this.studentName,
    required this.studentData,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> safeMap(dynamic value) {
      if (value == null) return {};
      try {
        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
      } catch (e) {
        debugPrint('Error casting map: $e');
      }
      return {};
    }

    final progress = safeMap(studentData['progress']);
    final profile = safeMap(studentData['profile']);

    final overallProgress = (progress['overallProgress'] ?? 0.0).toDouble();
    final totalCompleted = (progress['totalCompleted'] ?? 0).toInt();
    final totalActivities = (progress['totalActivities'] ?? 0).toInt();

    final magbasa = safeMap(progress['magbasa']);
    final kulay = safeMap(progress['kulay']);
    final traceit = safeMap(progress['traceit']);
    final matematika = safeMap(progress['matematika']);
    final pamilya = safeMap(progress['pamilya']);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!.studentProgressTitle(studentName),
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.overallProgress,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text('${(overallProgress * 100).toInt()}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: overallProgress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn(AppLocalizations.of(context)!.activities,
                          '$totalCompleted / $totalActivities'),
                      _buildStatColumn(AppLocalizations.of(context)!.stars,
                          '${profile['stars'] ?? 0} ⭐'),
                      _buildStatColumn(AppLocalizations.of(context)!.lessons,
                          '${profile['lessonsCompleted'] ?? 0} 📚'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.moduleBreakdown,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 16),

            _buildModuleCard(
              title: AppLocalizations.of(context)!.magbasaTitle,
              icon: Icons.menu_book,
              color: AppColors.alphabet,
              completed: magbasa['totalCompleted'] ?? 0,
              total: magbasa['totalActivities'] ?? 23,
            ),
            _buildModuleCard(
              title: AppLocalizations.of(context)!.traceTitle,
              icon: Icons.edit,
              color: AppColors.success,
              completed: traceit['totalCompleted'] ?? 0,
              total: traceit['totalActivities'] ?? 62,
            ),
            _buildModuleCard(
              title: AppLocalizations.of(context)!.kulaySaya,
              icon: Icons.palette,
              color: AppColors.colors,
              completed: kulay['totalCompleted'] ?? 0,
              total: kulay['totalActivities'] ?? 4,
            ),
            _buildModuleCard(
              title: AppLocalizations.of(context)!.matematika,
              icon: Icons.calculate,
              color: AppColors.numbers,
              completed: matematika['gamesCompleted'] ?? 0,
              total: matematika['totalGames'] ?? 31,
              extraInfo: AppLocalizations.of(context)!
                  .scoreLabel(matematika['totalScore'] ?? 0),
            ),
            _buildModuleCard(
              title: AppLocalizations.of(context)!.angAkingSariliTitle,
              icon: Icons.family_restroom,
              color: AppColors.family,
              completed: pamilya['gamesCompleted'] ?? 0,
              total: pamilya['totalGames'] ?? 25,
              extraInfo: AppLocalizations.of(context)!
                  .scoreLabel(pamilya['totalScore'] ?? 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }

  Widget _buildModuleCard(
      {required String title,
      required IconData icon,
      required Color color,
      required int completed,
      required int total,
      String? extraInfo}) {
    double progress = total > 0 ? completed / total : 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark)),
                      Text('$completed / $total',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: color)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                  if (extraInfo != null) ...[
                    const SizedBox(height: 6),
                    Text(extraInfo,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500)),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
