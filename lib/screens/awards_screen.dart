import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';

class AwardsScreen extends StatelessWidget {
  const AwardsScreen({super.key});

  String _t(BuildContext context, String en, String il, String tl) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return lang.translate(en, il, tl);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final achievements = userProvider.userProfile?.achievements ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t(context, 'Awards', 'Dagiti Premio', 'Mga Gantimpala'),
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
            _t(context, 'No Awards Yet', 'Awan pay ti Premio',
                'Wala pang Gantimpala'),
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
              _t(
                  context,
                  'Complete activities to earn awards!',
                  'Lpasen dagiti aktibidad tapno makapremio!',
                  'Kumpletuhin ang mga aktibidad para makakuha ng gantimpala!'),
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
        'title':
            _t(context, 'First Steps', 'Umuna nga Addang', 'Unang Hakbang'),
        'description': _t(context, 'Complete your first activity',
            'Lpasen ti umuna nga aktibidad', 'Kumpletuhin ang unang aktibidad'),
        'icon': Icons.directions_walk,
        'color': AppColors.primary,
        'progress': achievements['firstSteps'] ?? 0,
        'total': 1,
        'emoji': '👣',
      },
      {
        'id': 'math_wizard',
        'title':
            _t(context, 'Math Whiz', 'Nalaing iti Math', 'Magaling sa Math'),
        'description': _t(
            context,
            'Complete 10 math games',
            'Lpasen ti 10 nga ay-ayam iti math',
            'Kumpletuhin ang 10 laro sa math'),
        'icon': Icons.calculate,
        'color': AppColors.numbers,
        'progress': achievements['mathWizard'] ?? 0,
        'total': 10,
        'emoji': '🔢',
      },
      {
        'id': 'reading_star',
        'title': _t(context, 'Bookworm', 'Nalaing Agbasa', 'Mahilig Magbasa'),
        'description': _t(context, 'Read 5 stories', 'Basaen ti 5 nga sarita',
            'Magbasa ng 5 kwento'),
        'icon': Icons.menu_book,
        'color': AppColors.alphabet,
        'progress': achievements['readingStar'] ?? 0,
        'total': 5,
        'emoji': '📚',
      },
      {
        'id': 'color_artist',
        'title':
            _t(context, 'Color Artist', 'Nalaing Agkolor', 'Mahusay Magkulay'),
        'description': _t(
            context,
            'Complete 4 coloring activities',
            'Lpasen ti 4 nga aktibidad ti panagkolor',
            'Kumpletuhin ang 4 na aktibidad sa pagkulay'),
        'icon': Icons.palette,
        'color': AppColors.colors,
        'progress': achievements['colorArtist'] ?? 0,
        'total': 4,
        'emoji': '🎨',
      },
      {
        'id': 'family_hero',
        'title':
            _t(context, 'Family Hero', 'Bida ti Pamilia', 'Bida ng Pamilya'),
        'description': _t(context, 'Complete all family levels',
            'Lpasen amin a family level', 'Kumpletuhin lahat ng family levels'),
        'icon': Icons.family_restroom,
        'color': AppColors.family,
        'progress': achievements['familyHero'] ?? 0,
        'total': 5,
        'emoji': '👨‍👩‍👧',
      },
      {
        'id': 'writing_star',
        'title':
            _t(context, 'Writing Star', 'Nalaing Agsurat', 'Magaling Magsulat'),
        'description': _t(
            context,
            'Trace all letters and numbers',
            'Suroten amin a letra ken numero',
            'Sundan lahat ng titik at numero'),
        'icon': Icons.edit,
        'color': Colors.orange,
        'progress': achievements['writingStar'] ?? 0,
        'total': 26,
        'emoji': '✏️',
      },
      {
        'id': 'songbird',
        'title': _t(context, 'Songbird', 'Nalaing Agkanta', 'Mahusay Kumanta'),
        'description': _t(context, 'Learn all 13 songs',
            'Adalen amin a 13 a kanta', 'Matutunan lahat ng 13 kanta'),
        'icon': Icons.music_note,
        'color': AppColors.animals,
        'progress': achievements['songbird'] ?? 0,
        'total': 13,
        'emoji': '🎵',
      },
      {
        'id': 'perfect_score',
        'title': _t(context, 'Perfect Score', 'Perpekto nga Puntos',
            'Perpektong Puntos'),
        'description': _t(context, 'Get perfect score in 3 games',
            'Agperpekto iti 3 nga ay-ayam', 'Mag-perpekto sa 3 laro'),
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
