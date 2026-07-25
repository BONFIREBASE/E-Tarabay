import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'services/auth_service.dart';
import 'services/biometric_service.dart';
import 'screens/home_screen.dart';
import 'screens/teacher_login_screen.dart';
import 'utils/constants.dart';
import 'utils/page_transitions.dart';
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
  bool _biometricEnabled = false;
  String _biometricName = '';

  @override
  void initState() {
    super.initState();
    _initBiometric();
  }

  Future<void> _initBiometric() async {
    final enabled =
        await BiometricService.isEnabled(BiometricService.studentKey);
    final available = await BiometricService.isAvailable();
    if (!mounted) return;
    final creds = enabled
        ? await BiometricService.getCredentials(BiometricService.studentKey)
        : null;
    if (!mounted) return;
    setState(() {
      _biometricEnabled = enabled && available;
      _biometricName = creds?['name'] ?? '';
    });
  }

  Future<void> _biometricLogin() async {
    final creds =
        await BiometricService.getCredentials(BiometricService.studentKey);
    if (creds == null) return;
    final ok = await BiometricService.authenticate('Log in to continue');
    if (!ok || !mounted) return;
    _usernameController.text = creds['username'] ?? '';
    _passwordController.text = creds['password'] ?? '';
    _loginStudent();
  }

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

      // Set session data. startStudentSession wipes any previous student's
      // local data if this is a different account (so a deleted-then-recreated
      // student, or a different student on this device, starts clean).
      await userProvider.startStudentSession(studentId);
      userProvider.setCurrentRole('student');
      if (!mounted) return;

      // Make sure a profile exists locally right away (fast, offline) using the
      // data the login already returned — so the home screen has something to
      // show immediately without waiting on the network.
      if (userProvider.userProfile == null) {
        final profile = studentData['profile'] as Map<String, dynamic>?;
        // Birthday might be at the top-level studentData or inside the profile
        // sub-map. Check both so newly enrolled students don't show "Not set".
        DateTime? bday;
        final bdayStr = profile?['birthday'] ?? studentData['birthday'];
        if (bdayStr != null) {
          bday = DateTime.tryParse(bdayStr.toString());
        }

        await userProvider.createUserProfile(
          profile?['name'] ?? studentData['name'] ?? username,
          profile?['gender'] ?? studentData['gender'] ?? 'Male',
          birthday: bday,
          parentName: profile?['parentName'] ?? studentData['parentName'],
          parentContact: profile?['parentContact'] ?? studentData['parentContact'],
          lrn: profile?['lrn'] ?? studentData['lrn'],
        );
      }

      if (!mounted) return;
      // Keep the typed LRN locally for certificate display (cloud stays hashed).
      await userProvider.setSessionLrn(password);
      if (!mounted) return;

      // Navigate to home immediately — no blocking spinner. The full progress
      // sync runs in the background and the UI updates silently once it lands
      // (UserProvider notifies listeners when the data arrives).
      Navigator.pushReplacement(
        context,
        PremiumPageRoute(child: const HomeScreen()),
      );

      userProvider
          .syncFromFirebase()
          .timeout(const Duration(seconds: 8))
          .catchError((e) => debugPrint('Background Firebase sync failed: $e'));
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),

                        // Centered Brand Logo & Title
                        Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/app_logo-transparent.png',
                                width: 130,
                                height: 130,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'E-Tarabay',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.welcome,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Login Form Prompt
                        Text(
                          AppLocalizations.of(context)!.loginPrompt,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Username field
                        TextField(
                          controller: _usernameController,
                          decoration: _modernInputDecoration(
                            label: AppLocalizations.of(context)!.username,
                            icon: LucideIcons.user,
                          ),
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(fontSize: 15),
                        ),

                        const SizedBox(height: 16),

                        // Password field (Student ID)
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _modernInputDecoration(
                            label: 'Student ID (Format: DC-2026-0001)',
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
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _loginStudent(),
                          style: const TextStyle(fontSize: 15),
                        ),

                        const SizedBox(height: 28),

                        // Gradient Login Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF5C52E5),
                                Color(0xFF4F46E5),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF5C52E5).withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _loginStudent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.loginButton,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        // Biometric quick-login
                        if (_biometricEnabled) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton.icon(
                              onPressed: _biometricLogin,
                              icon: const Icon(
                                LucideIcons.fingerprint_pattern,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              label: Text(
                                _biometricName.isNotEmpty
                                    ? 'Sign in as $_biometricName'
                                    : 'Use fingerprint / face',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const Spacer(),

                        // Continue as Teacher Pill Switch
                        Center(
                          child: InkWell(
                            onTap: () {
                              context.pushPremium(
                                const TeacherLoginScreen(),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.graduation_cap,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .teacherLoginButton,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
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
