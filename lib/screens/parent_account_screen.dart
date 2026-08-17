import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_back_button.dart';

/// Parent-controlled management of the child's login. The parent (not the
/// child) can change the child's password (LRN), optionally the username, and
/// enable fingerprint/face login on this device.
///
/// Design decision: the username stays the teacher-owned roster identity — if
/// the parent changes it, the change is written straight back to Firestore so
/// the teacher dashboard stays in sync.
class ParentAccountScreen extends StatefulWidget {
  const ParentAccountScreen({super.key});

  @override
  State<ParentAccountScreen> createState() => _ParentAccountScreenState();
}

class _ParentAccountScreenState extends State<ParentAccountScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  String? _studentId;
  bool _loading = true;
  bool _saving = false;
  bool _obscure = true;

  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _studentId = userProvider.currentStudentId;

    final available = await BiometricService.isAvailable();
    final enabled =
        await BiometricService.isEnabled(BiometricService.studentKey);

    String? username;
    if (_studentId != null) {
      username = await _authService.getStudentUsername(_studentId!);
    }

    if (!mounted) return;
    setState(() {
      _usernameCtrl.text = username ?? '';
      _biometricAvailable = available;
      _biometricEnabled = enabled && available;
      _loading = false;
    });
  }

  void _snack(String msg, IconData icon, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveCredentials() async {
    if (_studentId == null) return;
    final username = _usernameCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (username.isEmpty) {
      _snack('Username cannot be empty.', LucideIcons.circle_alert, Colors.red);
      return;
    }
    if (newPass.isNotEmpty && newPass != confirm) {
      _snack('Passwords do not match.', LucideIcons.circle_alert, Colors.red);
      return;
    }
    if (newPass.isNotEmpty && newPass.length < 4) {
      _snack('Password (LRN) is too short.', LucideIcons.circle_alert,
          Colors.red);
      return;
    }

    setState(() => _saving = true);
    final result = await _authService.updateStudentCredentials(
      studentId: _studentId!,
      username: username,
      newPassword: newPass,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (result['status'] != 'Success') {
      _snack(result['message']?.toString() ?? 'Could not save changes.',
          LucideIcons.circle_alert, Colors.red);
      return;
    }

    // Keep biometric in sync with any new credentials.
    if (_biometricEnabled) {
      await BiometricService.saveCredentials(
        slot: BiometricService.studentKey,
        username: username,
        password: newPass.isNotEmpty
            ? newPass
            : ((await BiometricService.getCredentials(
                    BiometricService.studentKey))?['password'] ??
                ''),
        extra: {'name': Provider.of<UserProvider>(context, listen: false)
                .userProfile
                ?.name ??
            ''},
      );
    }

    _newPassCtrl.clear();
    _confirmCtrl.clear();
    _snack('Login updated.', LucideIcons.circle_check, AppColors.success);
  }

  Future<void> _toggleBiometric(bool value) async {
    if (_studentId == null) return;

    if (!value) {
      await BiometricService.clearCredentials(BiometricService.studentKey);
      if (!mounted) return;
      setState(() => _biometricEnabled = false);
      _snack('Fingerprint login turned off.',
          LucideIcons.fingerprint_pattern, AppColors.primary);
      return;
    }

    // Enabling — confirm the child's current password (LRN) so we can store it.
    final passCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enable fingerprint login',
            style: TextStyle(fontSize: 18)),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Confirm child's Student Number",
            prefixIcon: const Icon(LucideIcons.key_round, size: 20),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
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
    final valid =
        await _authService.verifyStudentPassword(_studentId!, password);
    if (!valid) {
      if (!mounted) return;
      _snack('Student Number is incorrect.', LucideIcons.circle_alert, Colors.red);
      return;
    }

    final scanned = await BiometricService.authenticate(
        'Scan to enable fingerprint login');
    if (!scanned) {
      if (!mounted) return;
      _snack('Biometric not confirmed.', LucideIcons.circle_alert, Colors.red);
      return;
    }

    final username = _usernameCtrl.text.trim();
    final name =
        Provider.of<UserProvider>(context, listen: false).userProfile?.name ??
            '';
    await BiometricService.saveCredentials(
      slot: BiometricService.studentKey,
      username: username,
      password: password,
      extra: {'name': name},
    );
    if (!mounted) return;
    setState(() => _biometricEnabled = true);
    _snack('Fingerprint login enabled.', LucideIcons.circle_check,
        AppColors.success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomBackButton(
          iconColor: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Account & Security',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _studentId == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No student session found. Please log in first.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _card(
                      title: 'Change Login',
                      icon: LucideIcons.key_round,
                      children: [
                        TextField(
                          controller: _usernameCtrl,
                          decoration: _deco('Username', LucideIcons.user),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPassCtrl,
                          obscureText: _obscure,
                          keyboardType: TextInputType.number,
                          decoration: _deco(
                            'New password (Student Number)',
                            LucideIcons.lock,
                            suffix: IconButton(
                              icon: Icon(
                                  _obscure
                                      ? LucideIcons.eye_off
                                      : LucideIcons.eye,
                                  size: 18),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmCtrl,
                          obscureText: _obscure,
                          keyboardType: TextInputType.number,
                          decoration: _deco(
                              'Confirm new password', LucideIcons.lock),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Leave password blank to change only the username. '
                          'The username stays in sync with your teacher.',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _saveCredentials,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Save Changes',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_biometricAvailable)
                      _card(
                        title: 'Security',
                        icon: LucideIcons.shield,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            secondary: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.fingerprint_pattern,
                                  color: AppColors.primary, size: 20),
                            ),
                            title: const Text('Fingerprint / Face login'),
                            subtitle: const Text(
                                'Let your child sign in without typing the Student Number'),
                            value: _biometricEnabled,
                            onChanged: _toggleBiometric,
                          ),
                        ],
                      )
                    else
                      _card(
                        title: 'Security',
                        icon: LucideIcons.shield,
                        children: [
                          Row(children: [
                            Icon(LucideIcons.info,
                                size: 18, color: Colors.grey.shade500),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'No fingerprint or face is set up on this phone, '
                                'so biometric login is unavailable.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ]),
                        ],
                      ),
                  ],
                ),
    );
  }

  InputDecoration _deco(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      isDense: true,
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
              ]),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
