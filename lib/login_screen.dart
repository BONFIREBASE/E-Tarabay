import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/teacher_login_screen.dart';
import 'utils/constants.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

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
          lrn: profile?['lrn'] ?? studentData['lrn'],
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
            const Icon(LucideIcons.circle_alert, color: Colors.white),
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

  InputDecoration _modernInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
                        child: Column(
                          children: [
                            // Top decorative header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                top: 48,
                                bottom: 80,
                                left: 32,
                                right: 32,
                              ),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary,
                                    Color(0xFF5B8DEF),
                                  ],
                                ),
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(40),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Logo
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      'assets/images/splash_logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'E-Tarabay',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!.welcome,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Form card overlapping the header
                            Transform.translate(
                              offset: const Offset(0, -48),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .loginPrompt,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Username field
                                      TextField(
                                        controller: _usernameController,
                                        decoration: _modernInputDecoration(
                                          label: AppLocalizations.of(context)!
                                              .username,
                                          icon: LucideIcons.user,
                                        ),
                                        textInputAction: TextInputAction.next,
                                        style: const TextStyle(fontSize: 15),
                                      ),

                                      const SizedBox(height: 16),

                                      // Password field (LRN)
                                      TextField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: _modernInputDecoration(
                                          label:
                                              '${AppLocalizations.of(context)!.password} (LRN)',
                                          icon: LucideIcons.lock,
                                          suffix: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? LucideIcons.eye_off
                                                  : LucideIcons.eye,
                                              color: Colors.grey.shade400,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) => _loginStudent(),
                                        style: const TextStyle(fontSize: 15),
                                      ),

                                      const SizedBox(height: 28),

                                      // Login Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: _loginStudent,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .loginButton,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Continue as Teacher
                            Transform.translate(
                              offset: const Offset(0, -24),
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherLoginScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  LucideIcons.graduation_cap,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                label: Text(
                                  AppLocalizations.of(context)!
                                      .teacherLoginButton,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
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
