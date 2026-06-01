import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
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
  late ConfettiController _confettiController;
  bool _isLogginOut = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
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
          title: const Icon(Icons.warning_amber_rounded,
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
                  await userProvider.logout();
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
    _confettiController.dispose();
    super.dispose();
  }

  void _checkBirthday() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    if (profile == null || profile.birthday == null) return;

    final now = DateTime.now();
    if (profile.birthday!.month == now.month &&
        profile.birthday!.day == now.day) {
      _confettiController.play();
      showDialog(
        context: context,
        builder: (dialogContext) => Stack(
          alignment: Alignment.center,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
              numberOfParticles: 20,
              gravity: 0.1,
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cake, color: Colors.pink, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!
                        .birthdayGreeting(profile.name),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).then((_) => _confettiController.stop());
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
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LessonsScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AwardsScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
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

    // Get user name with null safety
    String userName = userProvider.userProfile?.name ?? 'Noel';
    String userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'N';
    int userAge = userProvider.userProfile?.age ?? 2;

    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                height: safeHeight * 0.22,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
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
                            child: Center(
                              child: Text(
                                userInitial,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CertificatesScreen(),
                              ),
                            );
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
                                  Icons.workspace_premium,
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

                        // For Parents Button
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ParentsLockScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.family_restroom,
                            color: AppColors.primary,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                AppColors.primary.withOpacity(0.08),
                            padding: const EdgeInsets.all(10),
                          ),
                        ),
                      ],
                    ),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          '${stats['lessons']}',
                          AppLocalizations.of(context)!.lessons,
                          Icons.menu_book,
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
                          Icons.star,
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
                          Icons.emoji_events,
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
                          // Row 1 - Matematika & Pamilya
                          SizedBox(
                            height: cardHeight,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildImageCard(
                                    title: AppLocalizations.of(context)!
                                        .matematika,
                                    subtitle: AppLocalizations.of(context)!
                                        .sundanMoKayaMo,
                                    imagePath: 'assets/images/card1.png',
                                    color: AppColors.numbers,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MatematikaScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildImageCard(
                                    title: AppLocalizations.of(context)!
                                        .angAkingSarili,
                                    subtitle: AppLocalizations.of(context)!
                                        .atAkingPamilya,
                                    imagePath: 'assets/images/card2.png',
                                    color: AppColors.family,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PamilyaScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Row 2 - Kulay & Trace It
                          SizedBox(
                            height: cardHeight,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildImageCard(
                                    title:
                                        AppLocalizations.of(context)!.kulaySaya,
                                    subtitle: AppLocalizations.of(context)!
                                        .magkulayTayo,
                                    imagePath: 'assets/images/card3.png',
                                    color: AppColors.colors,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const KulayScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildImageCard(
                                    title: AppLocalizations.of(context)!
                                        .traceItTitle,
                                    subtitle: AppLocalizations.of(context)!
                                        .traceItSubtitle,
                                    imagePath: 'assets/images/card4.png',
                                    color: AppColors.success,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TraceItScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Row 3 - Magbasa Tayo & Tandaan Mo
                          SizedBox(
                            height: cardHeight,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildImageCard(
                                    title: AppLocalizations.of(context)!
                                        .magbasaTitle,
                                    subtitle: AppLocalizations.of(context)!
                                        .alpabetoAtMgaSalita,
                                    imagePath: 'assets/images/card5.png',
                                    color: AppColors.alphabet,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MagbasaScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildGeneratedCard(
                                    title: AppLocalizations.of(context)!
                                        .tandaanTitle,
                                    subtitle: AppLocalizations.of(context)!
                                        .tandaanTitle,
                                    color: AppColors.shapes,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TandaanScreen(),
                                      ),
                                    ),
                                    child: _buildTandaanThumbnail(),
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
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.home_rounded,
                  AppLocalizations.of(context)!.home,
                  0,
                ),
                _buildNavItem(
                  Icons.auto_stories_rounded,
                  AppLocalizations.of(context)!.lessons,
                  1,
                ),
                _buildNavItem(
                  Icons.emoji_events_rounded,
                  AppLocalizations.of(context)!.awards,
                  2,
                ),
                _buildNavItem(
                  Icons.settings_rounded,
                  AppLocalizations.of(context)!.settings,
                  3,
                ),
              ],
            ),
          ),
        ),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2),
              BlendMode.darken,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, color.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    title.isNotEmpty ? title : '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black26)],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle.isNotEmpty ? subtitle : '',
                    style: TextStyle(
                      fontSize: 8,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, color.withOpacity(0.7)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          title.isNotEmpty ? title : '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 5, color: Colors.black26)
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subtitle.isNotEmpty ? subtitle : '',
                          style: TextStyle(
                            fontSize: 8,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                  const Icon(Icons.help_outline, color: Colors.white, size: 20),
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
              child: const Icon(Icons.question_mark_rounded,
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
    return Icon(Icons.auto_awesome_rounded,
        color: color.withOpacity(0.5), size: 14);
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label.isNotEmpty ? label : '',
              style: TextStyle(
                fontSize: 9,
                color: isActive ? AppColors.primary : Colors.grey.shade400,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
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
}
