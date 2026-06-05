import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import '../widgets/staggered_entrance.dart';
import '../utils/page_transitions.dart';
import 'lessons_screen.dart';
import 'settings_screen.dart';

class AwardsScreen extends StatelessWidget {
  const AwardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final achievements = userProvider.userProfile?.achievements ?? {};
    final claimed = userProvider.userProfile?.claimedBadges ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      extendBody: true,
      bottomNavigationBar: FloatingBottomNavBar(
        selectedIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          switch (index) {
            case 0:
              Navigator.pop(context);
              break;
            case 1:
              context.pushReplacementPremium(const LessonsScreen());
              break;
            case 3:
              context.pushReplacementPremium(const SettingsScreen());
              break;
          }
        },
        items: const [
          NavItemData(icon: Icons.home_rounded, label: 'Home'),
          NavItemData(icon: Icons.auto_stories_rounded, label: 'Lessons'),
          NavItemData(icon: Icons.emoji_events_rounded, label: 'Awards'),
          NavItemData(icon: Icons.settings_rounded, label: 'Settings'),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: StaggeredEntrance(
              index: 0,
              child: _buildHeader(context, achievements.length, claimed.length),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final badge = _allBadges[index];
                  final isEarned = (achievements[badge['id']] ?? 0) >= 1;
                  final isClaimed = claimed.contains(badge['id']);
                  return StaggeredEntrance(
                    index: index + 1,
                    child: _buildBadgeCard(
                      context,
                      badge: badge,
                      isEarned: isEarned,
                      isClaimed: isClaimed,
                      userProvider: userProvider,
                    ),
                  );
                },
                childCount: _allBadges.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  static const List<Map<String, dynamic>> _allBadges = [
    {
      'id': 'firstSteps',
      'title': 'First Steps',
      'emoji': '👣',
      'color': 0xFF6C63FF,
      'stars': 5,
      'hint': 'Complete 1 activity'
    },
    {
      'id': 'alphabet',
      'title': 'Alphabet Master',
      'emoji': '🔤',
      'color': 0xFF6C63FF,
      'stars': 15,
      'hint': 'Complete 12 reading activities'
    },
    {
      'id': 'numbers',
      'title': 'Number Wizard',
      'emoji': '🔢',
      'color': 0xFFFF6B6B,
      'stars': 15,
      'hint': 'Play 20 math games'
    },
    {
      'id': 'colors',
      'title': 'Color Artist',
      'emoji': '🎨',
      'color': 0xFFFF9F43,
      'stars': 15,
      'hint': 'Complete 4 coloring activities'
    },
    {
      'id': 'shapes',
      'title': 'Shape Creator',
      'emoji': '⬛',
      'color': 0xFF4ECDC4,
      'stars': 15,
      'hint': 'Trace 26 uppercase letters'
    },
    {
      'id': 'animals',
      'title': 'Animal Friend',
      'emoji': '🐶',
      'color': 0xFF5F27CD,
      'stars': 15,
      'hint': 'Trace 26 lowercase letters'
    },
    {
      'id': 'bookworm',
      'title': 'Bookworm',
      'emoji': '📚',
      'color': 0xFF4ECDC4,
      'stars': 15,
      'hint': 'Read 4 stories'
    },
    {
      'id': 'starStudent',
      'title': 'Star Student',
      'emoji': '⭐',
      'color': 0xFFFFB800,
      'stars': 15,
      'hint': 'Play 20 family games'
    },
    {
      'id': 'mathWhiz',
      'title': 'Math Whiz',
      'emoji': '🧮',
      'color': 0xFFFF6B6B,
      'stars': 20,
      'hint': 'Complete 7 math levels'
    },
    {
      'id': 'familyHero',
      'title': 'Family Hero',
      'emoji': '👨‍👩‍👧',
      'color': 0xFF5F27CD,
      'stars': 20,
      'hint': 'Complete 5 family levels'
    },
    {
      'id': 'writingStar',
      'title': 'Writing Star',
      'emoji': '✏️',
      'color': 0xFFFF9F43,
      'stars': 15,
      'hint': 'Trace 10 numbers'
    },
    {
      'id': 'songbird',
      'title': 'Songbird',
      'emoji': '🎵',
      'color': 0xFFFF9F43,
      'stars': 15,
      'hint': 'Sing 10 songs'
    },
  ];

  Widget _buildHeader(BuildContext context, int earned, int claimed) {
    final headerContent = Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.success, AppColors.success.withOpacity(0.85)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Awards',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final progressSection = Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                const SizedBox(width: 10),
                Text(
                  '$claimed / ${_allBadges.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: claimed / _allBadges.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerContent,
        progressSection,
        if (earned > claimed)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 24),
            child: Text(
              '$earned earned, ${earned - claimed} waiting to claim!',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textDark.withOpacity(0.8)),
            ),
          ),
      ],
    );
  }

  Widget _buildBadgeCard(
    BuildContext context, {
    required Map<String, dynamic> badge,
    required bool isEarned,
    required bool isClaimed,
    required UserProvider userProvider,
  }) {
    final color = Color(badge['color'] as int);

    if (!isEarned) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.lock, color: Colors.grey, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge['title'] as String,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                badge['hint'] as String? ?? '???',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (isEarned && !isClaimed) {
      return GestureDetector(
        onTap: () => _showClaimDialog(context, badge, userProvider),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(badge['emoji'] as String,
                          style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.star, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                badge['title'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tap to Claim',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showViewBadgeModal(context, badge),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.85)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 3),
                    ),
                    child: Center(
                      child: Text(badge['emoji'] as String,
                          style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    badge['title'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+${badge['stars']}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClaimDialog(BuildContext context, Map<String, dynamic> badge,
      UserProvider userProvider) {
    final color = Color(badge['color'] as int);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actionsAlignment: MainAxisAlignment.center,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(badge['emoji'] as String,
                    style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Claim ${badge['title']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You earned this badge! Claim it to add it to your collection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '+${badge['stars']} Stars',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await userProvider.claimBadge(badge['id'] as String);
              if (context.mounted) {
                Navigator.pop(context);
                _showViewBadgeModal(context, badge);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Claim Badge'),
          ),
        ],
      ),
    );
  }

  void _showViewBadgeModal(BuildContext context, Map<String, dynamic> badge) {
    final color = Color(badge['color'] as int);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.85)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'BADGE CLAIMED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.25),
                    border: Border.all(color: Colors.amber, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(badge['emoji'] as String,
                        style: const TextStyle(fontSize: 56)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  badge['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '+${badge['stars']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Awesome!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
