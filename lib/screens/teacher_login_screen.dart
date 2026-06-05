import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_back_button.dart';
import 'teacher_dashboard_screen.dart';

/// Hardcoded teacher credentials — persists across installs.
/// Username: Daycare Teacher
/// Password: Tr@b4y2k
class TeacherCredentials {
  static const String username = 'Daycare Teacher';
  static const String password = 'Tr@b4y2k';
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
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginTeacher() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context)!.enterUsernamePassword);
      return;
    }

    setState(() => _isLoading = true);

    // Simulate brief delay for UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (username.toLowerCase().trim() ==
              TeacherCredentials.username.toLowerCase().trim() &&
          password.trim() == TeacherCredentials.password.trim()) {
        // Save session
        Provider.of<UserProvider>(context, listen: false)
            .setCurrentRole('teacher');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
        );
      } else {
        _showErrorDialog(
            AppLocalizations.of(context)!.invalidTeacherCredentials);
      }
    });
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
                                    iconColor: Colors.white,
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
                                    Color(0xFF2D3436),
                                    Color(0xFF636E72),
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
                                      Icons.school,
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
                                          icon: Icons.person_outline,
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
                                          icon: Icons.lock_outline,
                                          suffix: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
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
