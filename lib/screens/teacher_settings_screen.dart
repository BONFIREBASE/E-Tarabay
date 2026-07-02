import 'package:e_tarabay/l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../login_screen.dart';
import '../main.dart';
import '../utils/page_transitions.dart';
import '../utils/constants.dart';
import '../widgets/custom_header_app_bar.dart';
import '../widgets/staggered_entrance.dart';


class TeacherSettingsScreen extends StatefulWidget {
  const TeacherSettingsScreen({super.key});

  @override
  State<TeacherSettingsScreen> createState() => _TeacherSettingsScreenState();
}

class _TeacherSettingsScreenState extends State<TeacherSettingsScreen> {
  final AuthService _authService = AuthService();
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _notificationsEnabled = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadBiometric();
  }

  Future<void> _loadBiometric() async {
    final available = await BiometricService.isAvailable();
    final enabled =
        await BiometricService.isEnabled(BiometricService.teacherKey);
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometricEnabled = enabled && available;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _musicEnabled = prefs.getBool('music_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleMusic(bool value) async {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    setState(() => _musicEnabled = value);
    await audioManager.setMusicEnabled(value);
  }

  Future<void> _setLanguage(String code) async {
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    await provider.setLanguage(code);
    setState(() {});
  }

  void _showSnack(String message, IconData icon, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Account: change credentials + biometric ───────────────────────────────

  /// Prompt for the current password, then let the teacher set a new username
  /// and/or password. Writes only the hash to Firestore.
  Future<void> _changeCredentialsDialog() async {
    final currentCtrl = TextEditingController();
    final newUserCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure = true;
    String? error;
    bool busy = false;

    final currentUsername = await _authService.getTeacherUsername();
    if (currentUsername != null) newUserCtrl.text = currentUsername;

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            InputDecoration deco(String label, IconData icon,
                    {Widget? suffix}) =>
                InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon, size: 20),
                  suffixIcon: suffix,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                );

            Future<void> save() async {
              final current = currentCtrl.text.trim();
              final newUser = newUserCtrl.text.trim();
              final newPass = newPassCtrl.text.trim();
              final confirm = confirmCtrl.text.trim();

              if (current.isEmpty) {
                setDialogState(() => error = 'Enter your current password.');
                return;
              }
              if (newPass.isNotEmpty && newPass != confirm) {
                setDialogState(() => error = 'New passwords do not match.');
                return;
              }
              if (newUser.isEmpty && newPass.isEmpty) {
                setDialogState(() => error = 'Nothing to change.');
                return;
              }

              setDialogState(() {
                busy = true;
                error = null;
              });

              final ok = await _authService.verifyTeacherPassword(current);
              if (!ok) {
                setDialogState(() {
                  busy = false;
                  error = 'Current password is incorrect.';
                });
                return;
              }

              final result = await _authService.updateTeacherCredentials(
                username: newUser,
                newPassword: newPass,
              );

              if (result['status'] != 'Success') {
                setDialogState(() {
                  busy = false;
                  error = result['message']?.toString() ??
                      'Could not save changes.';
                });
                return;
              }

              // Keep biometric in sync: if enabled, re-store the new password so
              // fingerprint login keeps working.
              if (_biometricEnabled) {
                await BiometricService.saveCredentials(
                  slot: BiometricService.teacherKey,
                  username: newUser.isNotEmpty
                      ? newUser
                      : (currentUsername ?? 'Daycare Teacher'),
                  password: newPass.isNotEmpty ? newPass : current,
                );
              }

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              _showSnack('Credentials updated.', LucideIcons.circle_check,
                  AppColors.success);
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Row(children: [
                Icon(LucideIcons.key_round, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Change Login', style: TextStyle(fontSize: 18)),
              ]),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                    controller: currentCtrl,
                    obscureText: true,
                    decoration:
                        deco('Current password', LucideIcons.lock),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newUserCtrl,
                    decoration: deco('Username', LucideIcons.user),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: obscure,
                    decoration: deco('New password', LucideIcons.lock_keyhole,
                        suffix: IconButton(
                          icon: Icon(
                              obscure ? LucideIcons.eye_off : LucideIcons.eye,
                              size: 18),
                          onPressed: () =>
                              setDialogState(() => obscure = !obscure),
                        )),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: obscure,
                    decoration:
                        deco('Confirm new password', LucideIcons.lock_keyhole),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Leave the password blank to change only the username.',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ]),
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: busy ? null : save,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Enable/disable biometric login. Turning ON requires the current password
  /// (to verify + store for future logins) plus a live biometric scan.
  Future<void> _toggleBiometric(bool value) async {
    if (!value) {
      await BiometricService.clearCredentials(BiometricService.teacherKey);
      if (!mounted) return;
      setState(() => _biometricEnabled = false);
      _showSnack('Fingerprint login turned off.',
          LucideIcons.fingerprint_pattern, AppColors.primary);
      return;
    }

    // Turning ON — ask for the current password.
    final passCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enable fingerprint login',
            style: TextStyle(fontSize: 18)),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm your password',
            prefixIcon: const Icon(LucideIcons.lock, size: 20),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final password = passCtrl.text.trim();
    final valid = await _authService.verifyTeacherPassword(password);
    if (!valid) {
      if (!mounted) return;
      _showSnack('Password is incorrect.', LucideIcons.circle_alert,
          Colors.red);
      return;
    }

    final scanned = await BiometricService.authenticate(
        'Scan to enable fingerprint login');
    if (!scanned) {
      if (!mounted) return;
      _showSnack('Biometric not confirmed.', LucideIcons.circle_alert,
          Colors.red);
      return;
    }

    final username =
        await _authService.getTeacherUsername() ?? 'Daycare Teacher';
    await BiometricService.saveCredentials(
      slot: BiometricService.teacherKey,
      username: username,
      password: password,
    );
    if (!mounted) return;
    setState(() => _biometricEnabled = true);
    _showSnack('Fingerprint login enabled.', LucideIcons.circle_check,
        AppColors.success);
  }

  Future<void> _confirmResetAllStudents() async {    final loc = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(LucideIcons.triangle_alert, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(loc.resetAllStudents,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(loc.confirmResetAllStudents),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel,
                style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.confirm,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _authService.deleteAllStudents();
      if (!mounted) return;
      final ok = result['status'] == 'Success';
      _showSnack(
        result['message'] as String,
        ok ? LucideIcons.circle_check : LucideIcons.circle_alert,
        ok ? AppColors.success : Colors.red,
      );
    }
  }

  Future<void> _logout() async {
    final loc = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.logout,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(loc.confirmLogout),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel,
                style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.logout,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await userProvider.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        PremiumPageRoute(child: const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBody: true,
      appBar: CustomHeaderAppBar(
        title: loc.settingsTitle,
        baseColor: AppColors.primary,
        showBackButton: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_settings.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              StaggeredEntrance(
                index: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(loc.language),
                    Card.filled(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _LanguageTile(
                            code: 'en',
                            label: 'English',
                            isSelected:
                                languageProvider.currentLanguageCode == 'en',
                            onTap: () => _setLanguage('en'),
                          ),
                          const Divider(height: 0, indent: 72),
                          _LanguageTile(
                            code: 'fil',
                            label: 'Filipino',
                            isSelected:
                                languageProvider.currentLanguageCode == 'fil',
                            onTap: () => _setLanguage('fil'),
                          ),
                          const Divider(height: 0, indent: 72),
                          _LanguageTile(
                            code: 'ilo',
                            label: 'Ilokano',
                            isSelected:
                                languageProvider.currentLanguageCode == 'ilo',
                            onTap: () => _setLanguage('ilo'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StaggeredEntrance(
                index: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Audio'),
                    Card.filled(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary:
                                const _IconBadge(icon: LucideIcons.volume_2),
                            title: Text(loc.sound),
                            value: _soundEnabled,
                            onChanged: (value) {
                              setState(() => _soundEnabled = value);
                              SharedPreferences.getInstance().then(
                                (prefs) =>
                                    prefs.setBool('sound_enabled', value),
                              );
                            },
                          ),
                          const Divider(height: 0, indent: 72),
                          SwitchListTile(
                            secondary:
                                const _IconBadge(icon: LucideIcons.music),
                            title: Text(loc.music),
                            value: _musicEnabled,
                            onChanged: _toggleMusic,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StaggeredEntrance(
                index: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(loc.notifications),
                    Card.filled(
                      clipBehavior: Clip.antiAlias,
                      child: SwitchListTile(
                        secondary: const _IconBadge(icon: LucideIcons.bell),
                        title: Text(loc.notifications),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                          SharedPreferences.getInstance().then(
                            (prefs) =>
                                prefs.setBool('notifications_enabled', value),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StaggeredEntrance(
                index: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Account'),
                    Card.filled(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          ListTile(
                            leading:
                                const _IconBadge(icon: LucideIcons.key_round),
                            title: const Text('Change Login'),
                            subtitle: const Text('Update username or password'),
                            trailing: Icon(LucideIcons.chevron_right,
                                color: Colors.grey.shade400, size: 18),
                            onTap: _changeCredentialsDialog,
                          ),
                          if (_biometricAvailable) ...[
                            const Divider(height: 0, indent: 72),
                            SwitchListTile(
                              secondary: const _IconBadge(
                                  icon: LucideIcons.fingerprint_pattern),
                              title: const Text('Fingerprint / Face login'),
                              subtitle: const Text(
                                  'Skip typing your password next time'),
                              value: _biometricEnabled,
                              onChanged: _toggleBiometric,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StaggeredEntrance(
                index: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Classroom'),
                    Card.filled(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const _IconBadge(
                                icon: LucideIcons.trash_2, danger: true),
                            title: Text(
                              AppLocalizations.of(context)!.resetAllStudents,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                            trailing: const Icon(LucideIcons.chevron_right,
                                color: Colors.red, size: 18),
                            onTap: _confirmResetAllStudents,
                          ),
                          const Divider(height: 0, indent: 72),
                          ListTile(
                            leading:
                                const _IconBadge(icon: LucideIcons.log_out),
                            title: Text(AppLocalizations.of(context)!.logout),
                            trailing: Icon(LucideIcons.chevron_right,
                                color: Colors.grey.shade400, size: 18),
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              StaggeredEntrance(
                index: 5,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'E-Tarabay',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.version} 1.0.4',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  ({String short, Color color}) get _meta {
    switch (code) {
      case 'fil':
        return (short: 'FIL', color: const Color(0xFFFF6584));
      case 'ilo':
        return (short: 'ILO', color: const Color(0xFFFFB347));
      default:
        return (short: 'EN', color: const Color(0xFF4A90D9));
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _meta;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [meta.color, meta.color.withValues(alpha: 0.75)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: meta.color.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            meta.short,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textDark,
        ),
      ),
      trailing: isSelected
          ? const Icon(LucideIcons.circle_check, color: AppColors.primary)
          : const SizedBox(width: 24),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final bool danger;
  const _IconBadge({required this.icon, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : AppColors.primary;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
