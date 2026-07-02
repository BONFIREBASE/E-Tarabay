import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../utils/constants.dart';
import '../utils/page_transitions.dart';
import '../widgets/custom_back_button.dart';
import 'teacher_dashboard_screen.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Teacher credentials live in Firestore (`config/teacher`) — the password is
/// stored only as a one-way SHA-256 hash, never in the app source. The username
/// is not secret, so it's kept here just to pre-fill the field.
class TeacherCredentials {
  static const String username = 'Daycare Teacher';
}

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final TextEditingController _usernameController =
      TextEditingController(text: TeacherCredentials.username);
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _initBiometric();
  }

  Future<void> _initBiometric() async {
    final enabled = await BiometricService.isEnabled(BiometricService.teacherKey);
    final available = await BiometricService.isAvailable();
    if (!mounted) return;
    setState(() => _biometricEnabled = enabled && available);
    // Auto-offer biometric on open for a smoother return experience.
    if (_biometricEnabled) {
      _biometricLogin();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _enterDashboard() {
    Provider.of<UserProvider>(context, listen: false).setCurrentRole('teacher');
    Navigator.pushReplacement(
      context,
      PremiumPageRoute(child: const TeacherDashboardScreen()),
    );
  }

  Future<void> _biometricLogin() async {
    final ok = await BiometricService.authenticate(
        'Log in to your teacher account');
    if (!ok || !mounted) return;

    final creds = await BiometricService.getCredentials(BiometricService.teacherKey);
    if (creds == null) return;

    setState(() => _isLoading = true);
    // Re-verify the saved password against the current cloud hash in case it
    // was changed on another device. If it no longer matches, drop the saved
    // credential and make them sign in with the new password.
    final valid = await _authService.verifyTeacherPassword(creds['password']!);
    if (!mounted) return;
    if (valid) {
      _enterDashboard();
    } else {
      await BiometricService.clearCredentials(BiometricService.teacherKey);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _biometricEnabled = false;
      });
      _showErrorDialog(
          'Your password changed. Please sign in with your password once.');
    }
  }

  void _loginTeacher() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context)!.enterUsernamePassword);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Fetch the teacher credentials from Firestore. Uses serverAndCache so it
      // works offline AFTER the first successful online load (smart caching).
      final snap = await FirebaseFirestore.instance
          .collection('config')
          .doc('teacher')
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      final data = snap.data();
      if (data == null) {
        setState(() => _isLoading = false);
        _showErrorDialog(
            'Teacher account not set up yet. Please connect to the internet once to finish setup.');
        return;
      }

      final storedUsername = (data['username'] ?? '').toString();
      final storedHash = (data['passwordHash'] ?? '').toString();

      final usernameOk = username.toLowerCase().trim() ==
          storedUsername.toLowerCase().trim();
      final passwordOk =
          storedHash.isNotEmpty && storedHash == AuthService.hashLrn(password);

      setState(() => _isLoading = false);

      if (usernameOk && passwordOk) {
        _enterDashboard();
      } else {
        _showErrorDialog(
            AppLocalizations.of(context)!.invalidTeacherCredentials);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog(
          'Could not verify credentials. If this is your first login, please connect to the internet once.');
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
    bool disabled = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: disabled ? Colors.grey.shade400 : Colors.grey.shade500,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: disabled ? Colors.grey.shade400 : AppColors.primary,
        size: 20,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: disabled ? const Color(0xFFF0F1F2) : const Color(0xFFF8F9FA),
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
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
                            // Back button row
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, top: 8, right: 16),
                              child: Row(
                                children: [
                                  CustomBackButton(
                                    iconColor: AppColors.primary,
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),

                            // Top header
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: 16,
                              ),
                              padding: const EdgeInsets.only(
                                top: 24,
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
                                    AppColors.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(40),
                                  top: Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Teacher icon
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      LucideIcons.graduation_cap,
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .teacherLoginTitle,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .teacherLoginPrompt,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            // Form card overlapping header
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
                                        'Sign in to your teacher account',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Username field (pre-filled, disabled)
                                      TextField(
                                        controller: _usernameController,
                                        enabled: false,
                                        decoration: _modernInputDecoration(
                                          label: AppLocalizations.of(context)!
                                              .username,
                                          icon: LucideIcons.user,
                                          disabled: true,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Password field
                                      TextField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: _modernInputDecoration(
                                          label: AppLocalizations.of(context)!
                                              .password,
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
                                        onSubmitted: (_) => _loginTeacher(),
                                        style: const TextStyle(fontSize: 15),
                                      ),

                                      const SizedBox(height: 28),

                                      // Login Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: _loginTeacher,
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
                                                .teacherLoginButtonLabel,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
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
                                            label: const Text(
                                              'Use fingerprint / face',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

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
