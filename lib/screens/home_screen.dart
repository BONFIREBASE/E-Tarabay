import 'package:e_tarabay/l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import '../widgets/staggered_entrance.dart';
import '../widgets/cached_avatar.dart';
import '../widgets/birthday_celebration.dart';
import '../utils/page_transitions.dart';
import 'matematika_screen.dart';
import 'pamilya_screen.dart';
import 'kulay_screen.dart';
import 'trace_it_screen.dart';
import 'magbasa_screen.dart';
import 'tandaan_screen.dart';
import 'lessons_screen.dart';
import 'awards_screen.dart';
import 'certificates_screen.dart';
import 'settings_screen.dart';
import 'parents_lock_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLogginOut = false;

  @override
  void initState() {
    super.initState();
    // Start background music safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioManager>(context, listen: false)
          .startBackgroundMusic('audio/tunog.mp3');
      _checkBirthday();
    });
  }

  void _showAccountDeletedDialog() {
    if (_isLogginOut) return;
    _isLogginOut = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(LucideIcons.triangle_alert,
              color: Colors.orange, size: 60),
          content: Text(
            AppLocalizations.of(context)!.accessExpired,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  // Account was deleted by the teacher — wipe all local data so
                  // no progress carries over to the next account on this device.
                  await userProvider.logoutAndClearData();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/', (Route<dynamic> route) => false);
                },
                child: Text(AppLocalizations.of(context)!.okButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkBirthday() async {
    final prefs = await SharedPreferences.getInstance();
    // Notifications toggle controls the birthday celebration alert.
    if (!(prefs.getBool('notifications_enabled') ?? true)) return;
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    if (profile == null || profile.birthday == null) return;

    final now = DateTime.now();
    if (profile.birthday!.month == now.month &&
        profile.birthday!.day == now.day) {
      if (!mounted) return;
      showBirthdayCelebration(context, name: profile.name);
    }
  }

  // Get real stats from UserProvider with null safety
  Map<String, dynamic> _getStats(UserProvider userProvider) {
    if (!userProvider.isInitialized) {
      return {'lessons': 0, 'stars': 0, 'awards': 0};
    }
    final progress = userProvider.getAllProgress();
    return {
      'lessons': progress['totalCompleted'] ?? 0,
      'stars': userProvider.userProfile?.stars ?? 0,
      'awards': userProvider.userProfile?.achievements.length ?? 0,
    };
  }

  void _onNavItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home - no navigation needed
        break;
      case 1:
        context
            .pushPremium(const LessonsScreen())
            .then((_) => setState(() => _selectedIndex = 0));
        break;
      case 2:
        context
            .pushPremium(const AwardsScreen())
            .then((_) => setState(() => _selectedIndex = 0));
        break;
      case 3:
        context
            .pushPremium(const SettingsScreen())
            .then((_) => setState(() => _selectedIndex = 0));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Listen for account deletion in real-time
    if (userProvider.isAccountDeleted && !_isLogginOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAccountDeletedDialog();
      });
    }

    final stats = _getStats(userProvider);
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final safeHeight = size.height - padding.top - padding.bottom;

    // Get user info with null safety
    final profile = userProvider.userProfile;
    String userName = profile?.name ?? 'Noel';
    int userAge = profile?.age ?? 2;
    final avatar = profile?.avatar ?? '';

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _PlayfulBackground()),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                height: safeHeight * 0.16,
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Row
                    Row(
                      children: [
                        // Profile Avatar
                        GestureDetector(
                          onTap: () {
                            context.pushPremium(const ProfileScreen());
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: _buildHomeAvatar(avatar, userName),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Name and Age
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .homeAge(userAge),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildPerformanceGrade(userProvider),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Certificates Button
                        GestureDetector(
                          onTap: () {
                            context.pushPremium(const CertificatesScreen());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.award,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${userProvider.earnedCertificates.length}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // For Parents moved to the center of the bottom nav bar.
                      ],
                    ),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          '${stats['lessons']}',
                          AppLocalizations.of(context)!.lessons,
                          LucideIcons.book_open,
                          AppColors.primary,
                        ),
                        Container(
                          height: 20,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        _buildStatItem(
                          '${stats['stars']}',
                          AppLocalizations.of(context)!.stars,
                          LucideIcons.star,
                          Colors.amber,
                        ),
                        Container(
                          height: 20,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        _buildStatItem(
                          '${stats['awards']}',
                          AppLocalizations.of(context)!.awards,
                          LucideIcons.trophy,
                          AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cards Grid Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardHeight = (constraints.maxHeight - 24) / 3;

                      return Column(
                        children: [
                          SizedBox(
                            height: cardHeight,
                            child: Row(
                              children: [
                                Expanded(
                                  child: StaggeredEntrance(
                                    index: 0,
                                    child: _buildImageCard(
                                      title: AppLocalizations.of(context)!
                                          .matematika,
                                      subtitle: AppLocalizations.of(context)!
                                          .sundanMoKayaMo,
                                      imagePath: 'assets/images/card1.png',
                                      color: AppColors.numbers,
                                      onTap: () => context.pushPremium(
                                        const MatematikaScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StaggeredEntrance(
                                    index: 1,
                                    child: _buildImageCard(
                                      title: AppLocalizations.of(context)!
                                          .angAkingSarili,
                                      subtitle: AppLocalizations.of(context)!
                                          .atAkingPamilya,
                                      imagePath: 'assets/images/card2.png',
                                      color: AppColors.family,
                                      onTap: () => context.pushPremium(
                                        const PamilyaScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: cardHeight,
                            child: Row(
                              children: [
                                Expanded(
                                  child: StaggeredEntrance(
                                    index: 2,
                                    child: _buildImageCard(
                                      title: AppLocalizations.of(context)!
                                          .kulaySaya,
                                      subtitle: AppLocalizations.of(context)!
                                          .magkulayTayo,
                                      imagePath: 'assets/images/card3.png',
                                      color: AppColors.colors,
                                      onTap: () => context.pushPremium(
                                        const KulayScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StaggeredEntrance(
                                    index: 3,
                                    child: _buildImageCard(
                                      title: AppLocalizations.of(context)!
                                          .traceItTitle,
                                      subtitle: AppLocalizations.of(context)!
                                          .traceItSubtitle,
                                      imagePath: 'assets/images/card4.png',
                                      color: AppColors.success,
                                      onTap: () => context.pushPremium(
                                        const TraceItScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: cardHeight,
                            child: Row(
                              children: [
                                Expanded(
                                  child: StaggeredEntrance(
                                    index: 4,
                                    child: _buildImageCard(
                                      title: AppLocalizations.of(context)!
                                          .magbasaTitle,
                                      subtitle: AppLocalizations.of(context)!
                                          .alpabetoAtMgaSalita,
                                      imagePath: 'assets/images/card5.png',
                                      color: AppColors.alphabet,
                                      onTap: () => context.pushPremium(
                                        const MagbasaScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StaggeredEntrance(
                                    index: 5,
                                    child: _buildGeneratedCard(
                                      title: AppLocalizations.of(context)!
                                          .tandaanTitle,
                                      subtitle: AppLocalizations.of(context)!
                                          .tandaanSubtitle,
                                      color: AppColors.shapes,
                                      onTap: () => context.pushPremium(
                                        const TandaanScreen(),
                                      ),
                                      child: _buildTandaanThumbnail(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        ],
      ),

      // Modern Bottom Navigation Bar
      bottomNavigationBar: FloatingBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        centerIcon: LucideIcons.users,
        centerLabel: AppLocalizations.of(context)!.forParents,
        onCenterTap: () {
          context.pushPremium(const ParentsLockScreen());
        },
        items: [
          NavItemData(
            icon: LucideIcons.house,
            label: AppLocalizations.of(context)!.home,
          ),
          NavItemData(
            icon: LucideIcons.book_open,
            label: AppLocalizations.of(context)!.lessons,
          ),
          NavItemData(
            icon: LucideIcons.trophy,
            label: AppLocalizations.of(context)!.awards,
          ),
          NavItemData(
            icon: LucideIcons.settings,
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label.isNotEmpty ? label : '',
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.6), width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: color.withOpacity(0.12)),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title.isNotEmpty ? title : '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _darken(color),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8.5,
                  color: _darken(color, 0.15),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedCard({
    required String title,
    required String subtitle,
    required Color color,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.6), width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: child,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title.isNotEmpty ? title : '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _darken(color),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8.5,
                  color: _darken(color, 0.15),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTandaanThumbnail() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Soft mint gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0F7FA), Color(0xFFB2DFDB)],
            ),
          ),
        ),
        // Decorative soft circles
        Positioned(
          top: -20,
          left: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.shapes.withOpacity(0.12),
            ),
          ),
        ),
        Positioned(
          bottom: -10,
          right: -10,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.animals.withOpacity(0.12),
            ),
          ),
        ),
        Positioned(
          top: 30,
          right: 20,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.colors.withOpacity(0.15),
            ),
          ),
        ),
        // Floating memory cards
        Center(
          child: Transform.rotate(
            angle: -0.15,
            child: _thumbCard(
              color: AppColors.shapes,
              child:
                  const Icon(LucideIcons.circle_question_mark, color: Colors.white, size: 20),
            ),
          ),
        ),
        Positioned(
          left: 38,
          top: 42,
          child: Transform.rotate(
            angle: 0.12,
            child: _thumbCard(
              color: AppColors.animals,
              child: const Text('🐶', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
        Positioned(
          right: 36,
          top: 38,
          child: Transform.rotate(
            angle: -0.08,
            child: _thumbCard(
              color: AppColors.colors,
              child: const Text('🍎', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
        Positioned(
          left: 52,
          bottom: 44,
          child: Transform.rotate(
            angle: 0.18,
            child: _thumbCard(
              color: AppColors.alphabet,
              child: const Text('Aa',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
            ),
          ),
        ),
        Positioned(
          right: 48,
          bottom: 40,
          child: Transform.rotate(
            angle: -0.1,
            child: _thumbCard(
              color: AppColors.primary.withOpacity(0.7),
              child: const Icon(LucideIcons.circle_question_mark,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
        // Sparkles
        Positioned(
          top: 50,
          left: 28,
          child: _sparkle(Colors.amber),
        ),
        Positioned(
          bottom: 55,
          right: 22,
          child: _sparkle(AppColors.shapes),
        ),
      ],
    );
  }

  Widget _thumbCard({required Color color, required Widget child}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  Widget _sparkle(Color color) {
    return Icon(LucideIcons.sparkles,
        color: color.withOpacity(0.5), size: 14);
  }

  Widget _buildPerformanceGrade(UserProvider userProvider) {
    final progress = userProvider.getAllProgress();
    final grade = progress['grade'] ?? 'Not Started';
    final percentage = (progress['percentage'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            grade,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 1),
          SizedBox(
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 3,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _darken(Color c, [double amount = 0.3]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.1).clamp(0.0, 1.0))
        .toColor();
  }

  Widget _buildHomeAvatar(String avatar, String userName) {
    if (avatar.startsWith('http')) {
      return CachedAvatar(imageUrl: avatar, size: 50);
    }
    if (avatar.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          avatarAssetForPreset(avatar),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      );
    }
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'N';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PLAYFUL BEACH-STYLE BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────
class _PlayfulBackground extends StatelessWidget {
  const _PlayfulBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/bg_home.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
