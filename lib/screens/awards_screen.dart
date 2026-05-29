import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';
import 'package:e_tarabay/l10n/app_localizations.dart';

class AwardsScreen extends StatelessWidget {
  const AwardsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final achievements = userProvider.userProfile?.achievements ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.awards,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.success,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FF),
              Colors.white,
            ],
          ),
        ),
        child: achievements.isEmpty
            ? _buildEmptyState(context)
            : _buildAwardsGrid(context, achievements),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              size: 60,
              color: AppColors.success.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.noAwardsYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              AppLocalizations.of(context)!.completeActivitiesToEarn,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardsGrid(BuildContext context, Map<String, int> achievements) {
    // Sample awards data - you can customize this based on your achievements
    final List<Map<String, dynamic>> awardsData = [
      {
        'id': 'first_steps',
        'title': AppLocalizations.of(context)!.firstSteps,
        'description': AppLocalizations.of(context)!.firstStepsDesc,
        'icon': Icons.directions_walk,
        'color': AppColors.primary,
        'progress': achievements['firstSteps'] ?? 0,
        'total': 1,
        'emoji': '👣',
      },
      {
        'id': 'math_wizard',
        'title': AppLocalizations.of(context)!.mathWhiz,
        'description': AppLocalizations.of(context)!.numberWizardDesc,
        'icon': Icons.calculate,
        'color': AppColors.numbers,
        'progress': achievements['mathWizard'] ?? 0,
        'total': 10,
        'emoji': '🔢',
      },
      {
        'id': 'reading_star',
        'title': AppLocalizations.of(context)!.bookworm,
        'description': AppLocalizations.of(context)!.bookwormDesc,
        'icon': Icons.menu_book,
        'color': AppColors.alphabet,
        'progress': achievements['readingStar'] ?? 0,
        'total': 5,
        'emoji': '📚',
      },
      {
        'id': 'color_artist',
        'title': AppLocalizations.of(context)!.colorArtist,
        'description': AppLocalizations.of(context)!.colorArtistDesc,
        'icon': Icons.palette,
        'color': AppColors.colors,
        'progress': achievements['colorArtist'] ?? 0,
        'total': 4,
        'emoji': '🎨',
      },
      {
        'id': 'family_hero',
        'title': AppLocalizations.of(context)!.familyHero,
        'description': AppLocalizations.of(context)!.familyHeroDesc,
        'icon': Icons.family_restroom,
        'color': AppColors.family,
        'progress': achievements['familyHero'] ?? 0,
        'total': 5,
        'emoji': '👨‍👩‍👧',
      },
      {
        'id': 'writing_star',
        'title': AppLocalizations.of(context)!.writingStar,
        'description': AppLocalizations.of(context)!.writingStarDesc,
        'icon': Icons.edit,
        'color': Colors.orange,
        'progress': achievements['writingStar'] ?? 0,
        'total': 26,
        'emoji': '✏️',
      },
      {
        'id': 'songbird',
        'title': AppLocalizations.of(context)!.songbird,
        'description': AppLocalizations.of(context)!.songbirdDesc,
        'icon': Icons.music_note,
        'color': AppColors.animals,
        'progress': achievements['songbird'] ?? 0,
        'total': 13,
        'emoji': '🎵',
      },
      {
        'id': 'perfect_score',
        'title': AppLocalizations.of(context)!.perfectScore,
        'description': AppLocalizations.of(context)!.perfectScoreDesc,
        'icon': Icons.star,
        'color': Colors.amber,
        'progress': achievements['perfectScore'] ?? 0,
        'total': 3,
        'emoji': '⭐',
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: awardsData.length,
      itemBuilder: (context, index) {
        final award = awardsData[index];
        final progress = award['progress'];
        final total = award['total'];
        final percentage = progress / total;
        final isCompleted = progress >= total;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: award['color'].withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (isCompleted)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: award['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Award Icon/Emoji
                    Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: award['color'].withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              award['emoji'],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        if (isCompleted)
                          const Positioned(
                            right: 0,
                            top: 0,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Award Title
                    Text(
                      award['title'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    // Award Description
                    Text(
                      award['description'],
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(award['color']),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Progress Text
                    Text(
                      '$progress/$total',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            isCompleted ? Colors.green : Colors.grey.shade600,
                        fontWeight:
                            isCompleted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
