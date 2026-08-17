import 'dart:convert';
import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentName;
  final Map<String, dynamic> studentData;

  const StudentDetailScreen({
    super.key,
    required this.studentName,
    required this.studentData,
  });

  Future<void> _showResetSpecificActivityDialog(BuildContext context) async {
    final targetStudentId = (studentData['id'] ??
            studentData['studentId'] ??
            studentData['docId'] ??
            '')
        .toString();

    final activities = [
      {'key': 'matematika', 'label': 'Matematika (Numbers & Counting)', 'icon': LucideIcons.calculator, 'color': Colors.blue},
      {'key': 'pamilya', 'label': 'Aking Sarili at Pamilya', 'icon': LucideIcons.users, 'color': Colors.purple},
      {'key': 'traceit', 'label': 'Pagsulat / Trace It (Alphabet & Numbers)', 'icon': LucideIcons.pencil, 'color': Colors.teal},
      {'key': 'magbasa', 'label': 'Magbasa (Kwento, Tula, Kanta)', 'icon': LucideIcons.book_open, 'color': Colors.indigo},
      {'key': 'tandaan', 'label': 'Tandaan (Memory Matching Game)', 'icon': LucideIcons.brain, 'color': Colors.amber.shade800},
      {'key': 'kulay', 'label': 'Kulayan Mo (Coloring & Art)', 'icon': LucideIcons.palette, 'color': Colors.pink},
    ];

    final selected = <String>{};

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(LucideIcons.list_restart, color: Colors.orange, size: 24),
                  SizedBox(width: 8),
                  Text('Reset Specific Activity',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Piliin ang mga activity na nais i-reset para kay $studentName:',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: activities.map((act) {
                            final key = act['key'] as String;
                            final isChecked = selected.contains(key);
                            final color = act['color'] as Color;
                            return CheckboxListTile(
                              value: isChecked,
                              activeColor: color,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                              secondary: Icon(act['icon'] as IconData, color: color),
                              title: Text(
                                act['label'] as String,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              onChanged: (val) {
                                setDialogState(() {
                                  if (val == true) {
                                    selected.add(key);
                                  } else {
                                    selected.remove(key);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Kanselahin', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: selected.isEmpty
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          final auth = AuthService();
                          final success = await auth.resetStudentSpecificActivities(
                              targetStudentId, selected.toList());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Matagumpay na na-reset ang napiling activities.'
                                    : 'Hindi na-reset ang activities. Subukan muli.'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                            if (success) {
                              try {
                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                if (userProvider.currentStudentId == targetStudentId) {
                                  await userProvider.resetAllProgressLocally();
                                }
                              } catch (_) {}
                            }
                          }
                        },
                  child: Text('I-reset (${selected.length})'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmResetActivity(BuildContext context) async {
    final targetStudentId = (studentData['id'] ??
            studentData['studentId'] ??
            studentData['docId'] ??
            '')
        .toString();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.rotate_ccw, color: Colors.red),
            SizedBox(width: 8),
            Text('Reset ALL Activities', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Sigurado ka bang nais mong i-reset ang LAHAT ng activity progress para kay $studentName? Hindi na ito maibabalik.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final auth = AuthService();
      final success = await auth.resetStudentActivityProgress(targetStudentId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Activity progress reset successfully.'
                : 'Failed to reset progress.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          try {
            final userProvider =
                Provider.of<UserProvider>(context, listen: false);
            if (userProvider.currentStudentId == targetStudentId) {
              await userProvider.resetAllProgressLocally();
            }
          } catch (_) {}
          Navigator.pop(context);
        }
      }
    }
  }

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
    final List creations = studentData['creations'] is List ? studentData['creations'] as List : [];

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
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotate_ccw, color: Colors.white),
            tooltip: 'Reset Activity',
            onPressed: () => _confirmResetActivity(context),
          ),
        ],
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
              icon: LucideIcons.book_open,
              color: AppColors.alphabet,
              completed: magbasa['totalCompleted'] ?? 0,
              total: magbasa['totalActivities'] ?? 23,
            ),
            _buildModuleCard(
              title: AppLocalizations.of(context)!.traceTitle,
              icon: LucideIcons.pencil,
              color: AppColors.success,
              completed: traceit['totalCompleted'] ?? 0,
              total: traceit['totalActivities'] ?? 62,
            ),
            _buildModuleCard(
              title: AppLocalizations.of(context)!.kulaySaya,
              icon: LucideIcons.palette,
              color: AppColors.colors,
              completed: kulay['totalCompleted'] ?? 0,
              total: kulay['totalActivities'] ?? 4,
            ),
            _buildModuleCard(
              title: AppLocalizations.of(context)!.matematika,
              icon: LucideIcons.calculator,
              color: AppColors.numbers,
              completed: matematika['gamesCompleted'] ?? 0,
              total: matematika['totalGames'] ?? 31,
              extraInfo: AppLocalizations.of(context)!
                  .scoreLabel(matematika['totalScore'] ?? 0),
            ),
            _buildModuleCard(
              title: AppLocalizations.of(context)!.angAkingSariliTitle,
              icon: LucideIcons.users,
              color: AppColors.family,
              completed: pamilya['gamesCompleted'] ?? 0,
              total: pamilya['totalGames'] ?? 25,
              extraInfo: AppLocalizations.of(context)!
                  .scoreLabel(pamilya['totalScore'] ?? 0),
            ),
            const SizedBox(height: 24),

            // Student Artworks / Kulay Gallery Section
            Row(
              children: [
                const Icon(LucideIcons.palette, color: AppColors.colors, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Student Artworks (${creations.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildArtworksGallery(context, creations),
            const SizedBox(height: 32),

            // Reset Activity Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(LucideIcons.list_restart, size: 20),
                label: const Text(
                  'Reset Specific Activity',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showResetSpecificActivityDialog(context),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade300, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(LucideIcons.rotate_ccw, size: 18),
                label: const Text(
                  'Reset All Activities',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _confirmResetActivity(context),
              ),
            ),
            const SizedBox(height: 24),
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

  Widget _buildArtworksGallery(BuildContext context, List creations) {
    if (creations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.image_off, color: Colors.grey.shade400, size: 36),
            const SizedBox(height: 8),
            Text(
              'No artwork creations saved yet.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: creations.length,
        itemBuilder: (context, index) {
          final creation = creations[index] is Map ? creations[index] as Map : {};
          final name = creation['name'] ?? 'Artwork';
          final base64Img = creation['base64Image'] as String? ?? '';
          final stars = creation['stars'] as int?;

          Widget imageWidget;
          if (base64Img.isNotEmpty) {
            try {
              final bytes = base64Decode(base64Img);
              imageWidget = Image.memory(bytes, fit: BoxFit.cover);
            } catch (_) {
              imageWidget = Container(
                color: Colors.grey.shade200,
                child: const Icon(LucideIcons.image, color: Colors.grey),
              );
            }
          } else {
            imageWidget = Container(
              color: Colors.grey.shade200,
              child: const Icon(LucideIcons.palette, color: AppColors.colors),
            );
          }

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showArtworkPreview(context, name, base64Img, stars),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: imageWidget,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (stars != null && stars > 0)
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFFFFB800), size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  '$stars Stars',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showArtworkPreview(BuildContext context, String name, String base64Img, int? stars) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: base64Img.isNotEmpty
                    ? Image.memory(
                        base64Decode(base64Img),
                        width: 260,
                        height: 260,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        width: 260,
                        height: 260,
                        color: Colors.grey.shade100,
                        child: const Icon(LucideIcons.palette, size: 60, color: Colors.grey),
                      ),
              ),
              if (stars != null && stars > 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    stars,
                    (index) => const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB800),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
