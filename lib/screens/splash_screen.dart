import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Import AudioManager
import '../login_screen.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startBackgroundMusic();
    _checkUserLoggedIn();
  }

  Future<void> _startBackgroundMusic() async {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    await audioManager.startBackgroundMusic('audio/tunog.mp3');
  }

  Future<void> _checkUserLoggedIn() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Smart Login: Ensure UserProvider is fully initialized before checking session
    int retryCount = 0;
    while (!userProvider.isInitialized && retryCount < 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      retryCount++;
    }

    if (!mounted) return;

    // Fallback: Manually check prefs if provider still hasn't loaded role
    String? role = userProvider.currentRole;
    String? studentId = userProvider.currentStudentId;

    if (role == null) {
      role = prefs.getString('session_role');
      studentId = prefs.getString('session_student_id');
      if (role != null) {
        if (role == 'student') {
          userProvider.setCurrentStudentId(studentId);
        }
        userProvider.setCurrentRole(role);
      }
    }

    if (!hasSeenOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (role == 'student' && studentId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (role == 'teacher') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TeacherDashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset(
            'assets/images/splash_logo.png',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(
                  begin: 1.0,
                  end: 1.05,
                  duration: 1500.ms,
                  curve: Curves.easeInOut),
        ),
      ),
    );
  }
}
