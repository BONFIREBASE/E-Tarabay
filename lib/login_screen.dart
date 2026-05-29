import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/teacher_login_screen.dart';
import 'utils/constants.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginStudent() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context)!.enterUsernamePassword);
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.loginStudent(username, password);

    if (!mounted) return;

    if (result['status'] == 'Success') {
      // Store the student data locally for session
      final studentData = result['studentData'] as Map<String, dynamic>;
      final studentId = result['studentId'] as String;

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Set session data
      userProvider.setCurrentStudentId(studentId);
      userProvider.setCurrentRole('student');

      // 1. Sync EVERYTHING from Firebase FIRST.
      // This restores their profile and all progress keys to local Hive/SharedPreferences.
      try {
        await userProvider
            .syncFromFirebase()
            .timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('Firebase sync failed or timed out: $e');
      }

      // 2. If for some reason we still don't have a profile (e.g. sync failed or Firestore doc is empty),
      // then we create one from the studentData we got during login.
      if (userProvider.userProfile == null) {
        final profile = studentData['profile'] as Map<String, dynamic>?;
        DateTime? bday;
        if (profile?['birthday'] != null) {
          bday = DateTime.tryParse(profile!['birthday']);
        }

        await userProvider.createUserProfile(
          profile?['name'] ?? studentData['name'] ?? username,
          profile?['gender'] ?? studentData['gender'] ?? 'Male',
          birthday: bday,
          parentName: profile?['parentName'],
          parentContact: profile?['parentContact'],
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _isLoading = false);
      _showErrorDialog(
          result['message'] ?? AppLocalizations.of(context)!.loginError);
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
                child: Text(message,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              const SizedBox(height: 60),

                              // App Logo Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.auto_stories,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'E-Tarabay',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),

                              // Welcome text
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.welcome,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(context)!.loginPrompt,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textLight,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Username field
                              TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.username,
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                              ),

                              const SizedBox(height: 16),

                              // Password field (LRN)
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText:
                                      '${AppLocalizations.of(context)!.password} (LRN)',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.primary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textLight,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _loginStudent(),
                              ),

                              const SizedBox(height: 32),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _loginStudent,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.loginButton,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // Continue as Teacher button
                              Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TeacherLoginScreen(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppColors.primary, width: 2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.school_outlined,
                                    color: AppColors.primary,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!.teacherLoginButton,
                                    style: const TextStyle(
                                      color: AppColors.primary,
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
                },
              ),
      ),
    );
  }
}
