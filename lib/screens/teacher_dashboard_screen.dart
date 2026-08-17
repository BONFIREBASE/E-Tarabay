import 'package:e_tarabay/l10n/app_localizations.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/staggered_entrance.dart';
import '../widgets/cached_avatar.dart';
import '../widgets/birthday_celebration.dart';
import '../login_screen.dart';
import '../utils/page_transitions.dart';
import 'student_detail_screen.dart';
import 'teacher_settings_screen.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final AuthService _authService = AuthService();
  bool _birthdayCelebrationShown = false;
  bool _notificationsEnabled = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  /// Back button on the dashboard prompts to log out (there is no previous
  /// route since the dashboard replaced the login screen).
  String _formatDateWord(BuildContext context, DateTime date) {
    const en = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const fil = [
      'Enero',
      'Pebrero',
      'Marso',
      'Abril',
      'Mayo',
      'Hunyo',
      'Hulyo',
      'Agosto',
      'Setyembre',
      'Oktubre',
      'Nobyembre',
      'Disyembre'
    ];
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    final mName = (date.month >= 1 && date.month <= 12)
        ? ((lang == 'fil' || lang == 'ilo')
            ? fil[date.month - 1]
            : en[date.month - 1])
        : 'Month ${date.month}';
    return '$mName ${date.day}, ${date.year}';
  }

  Future<void> _confirmLogout() async {
    final loc = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(LucideIcons.log_out, color: Colors.red),
            const SizedBox(width: 8),
            Text(loc.logout,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(loc.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(loc.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStatusDialog(String message, IconData icon, Color color) {
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
                        fontWeight: FontWeight.bold, color: Colors.white))),
          ],
        ),
        backgroundColor: color == Colors.transparent ? Colors.black87 : color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showEnrollSheet() {
    final firstNameController = TextEditingController();
    final middleNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final lrnController = TextEditingController();
    final usernameController = TextEditingController();
    final parentNameController = TextEditingController();
    final parentContactController = TextEditingController();
    DateTime? selectedBirthday;
    String selectedGender = 'Male';
    String selectedAvatar = 'boy1';
    bool avatarExplicitlySelected = false;
    int currentStep = 0;
    const stepLabels = ['Profile', 'Parent', 'Account'];

    String? randomSuffix;
    void updateUsername() {
      final first =
          firstNameController.text.trim().toLowerCase().replaceAll(' ', '');
      if (first.isNotEmpty) {
        randomSuffix ??= (Random().nextInt(9000) + 1000).toString();
        usernameController.text = '$first$randomSuffix';
      } else {
        randomSuffix = null;
        usernameController.text = '';
      }
    }

    firstNameController.addListener(updateUsername);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetStateContext, setSheetState) {
          // Per-step content.
          Widget stepContent() {
            switch (currentStep) {
              case 0:
                return Column(
                  key: const ValueKey(0),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Avatar'),
                    _buildAvatarPicker(
                      selectedAvatar: selectedAvatar,
                      onSelect: (preset) {
                        setSheetState(() {
                          selectedAvatar = preset;
                          avatarExplicitlySelected = true;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Student Information'),
                    _buildCard([
                      _buildTextField(
                        controller: firstNameController,
                        label: AppLocalizations.of(context)!.firstName,
                        icon: LucideIcons.user,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: middleNameController,
                        label: 'Middle Name',
                        icon: LucideIcons.user,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: lastNameController,
                        label: AppLocalizations.of(context)!.lastName,
                        icon: LucideIcons.user,
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () async {
                          final initialToUse = (selectedBirthday != null &&
                                  !selectedBirthday!.isBefore(DateTime(1900)) &&
                                  !selectedBirthday!.isAfter(DateTime.now()))
                              ? selectedBirthday!
                              : DateTime.now()
                                  .subtract(const Duration(days: 365 * 4));
                          final picked = await showDatePicker(
                            context: sheetStateContext,
                            initialDate: initialToUse,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedBirthday = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            label: AppLocalizations.of(context)!.birthday,
                            icon: LucideIcons.cake,
                          ),
                          child: Text(
                            selectedBirthday == null
                                ? AppLocalizations.of(context)!.notSet
                                : _formatDateWord(context, selectedBirthday!),
                            style: TextStyle(
                              color: selectedBirthday == null
                                  ? Colors.grey.shade500
                                  : AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernChoiceChip(
                              label: AppLocalizations.of(context)!.male,
                              isSelected: selectedGender == 'Male',
                              onSelected: (s) => setSheetState(() {
                                selectedGender = 'Male';
                                if (!avatarExplicitlySelected) {
                                  selectedAvatar = 'boy1';
                                }
                              }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildModernChoiceChip(
                              label: AppLocalizations.of(context)!.female,
                              isSelected: selectedGender == 'Female',
                              onSelected: (s) => setSheetState(() {
                                selectedGender = 'Female';
                                if (!avatarExplicitlySelected) {
                                  selectedAvatar = 'girl1';
                                }
                              }),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ],
                );
              case 1:
                return Column(
                  key: const ValueKey(1),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Parent Information'),
                    _buildCard([
                      _buildTextField(
                        controller: parentNameController,
                        label: AppLocalizations.of(context)!.parentNameLabel,
                        icon: LucideIcons.users,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: parentContactController,
                        label: AppLocalizations.of(context)!.parentContactLabel,
                        icon: LucideIcons.phone,
                        hintText: '09XXXXXXXXX',
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ]),
                  ],
                );
              default:
                return Column(
                  key: const ValueKey(2),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Login Credentials'),
                    _buildCard([
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: lrnController,
                              label: 'Student ID (Format: DC-2026-0001)',
                              icon: LucideIcons.badge,
                              hintText: 'DC-2026-0001',
                              onChanged: (_) => setSheetState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            icon: const Icon(LucideIcons.sparkles),
                            tooltip: 'Auto-generate Student ID',
                            onPressed: () {
                              setSheetState(() {
                                final year = DateTime.now().year;
                                final rand =
                                    (Random().nextInt(9000) + 1000).toString();
                                lrnController.text = 'DC-$year-$rand';
                              });
                            },
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Account Preview'),
                    _buildCard([
                      _buildCredentialRow(
                        label: AppLocalizations.of(context)!.userLabel,
                        value: usernameController.text.isEmpty
                            ? 'Auto-generated'
                            : usernameController.text,
                        icon: LucideIcons.user,
                        color: AppColors.primary,
                      ),
                      Divider(
                        height: 24,
                        indent: 40,
                        color: Colors.grey.shade200,
                      ),
                      _buildCredentialRow(
                        label: AppLocalizations.of(context)!.passwordLabel,
                        value: lrnController.text.isEmpty
                            ? 'Enter DC-2026-0001 format above'
                            : lrnController.text,
                        icon: LucideIcons.lock,
                        color: AppColors.textDark,
                      ),
                    ]),
                  ],
                );
            }
          }

          Future<void> submit() async {
            final passValidation = AuthService.validateDcPasswordFormat(lrnController.text.trim());
            if (!passValidation['isValid']) {
              _showStatusDialog(
                passValidation['message'] ?? AppLocalizations.of(context)!.fillAllFields,
                LucideIcons.triangle_alert,
                Colors.orange,
              );
              return;
            }
            Navigator.pop(sheetContext);
            final mid = middleNameController.text.trim();
            final fullName = mid.isNotEmpty
                ? '${firstNameController.text.trim()} $mid ${lastNameController.text.trim()}'
                : '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
            final result = await _authService.enrollStudent(
              name: fullName,
              middleName: mid,
              lrn: lrnController.text.trim(),
              gender: selectedGender,
              username: usernameController.text,
              birthday: selectedBirthday,
              parentName: parentNameController.text.trim(),
              parentContact: parentContactController.text.trim(),
              avatar: selectedAvatar,
            );
            if (!context.mounted) return;
            if (result['status'] == 'Success') {
              _showEnrollmentSuccess(
                usernameController.text,
                lrnController.text.trim(),
                fullName,
              );
            }
          }

          void goNext() {
            // Validate the current step before advancing.
            if (currentStep == 0) {
              if (firstNameController.text.trim().isEmpty ||
                  lastNameController.text.trim().isEmpty) {
                _showStatusDialog(
                  AppLocalizations.of(context)!.fillAllFields,
                  LucideIcons.triangle_alert,
                  Colors.orange,
                );
                return;
              }
            } else if (currentStep == 1) {
              if (parentNameController.text.trim().isEmpty ||
                  parentContactController.text.trim().isEmpty) {
                _showStatusDialog(
                  AppLocalizations.of(context)!.fillAllFields,
                  LucideIcons.triangle_alert,
                  Colors.orange,
                );
                return;
              }
              if (parentContactController.text.trim().length != 11) {
                _showStatusDialog(
                  AppLocalizations.of(context)!.contactLengthError,
                  LucideIcons.triangle_alert,
                  Colors.orange,
                );
                return;
              }
              if (lrnController.text.trim().isEmpty) {
                final year = DateTime.now().year;
                final rand = (Random().nextInt(9000) + 1000).toString();
                lrnController.text = 'DC-$year-$rand';
              }
            }
            FocusScope.of(sheetStateContext).unfocus();
            setSheetState(() => currentStep++);
          }

          final isLast = currentStep == stepLabels.length - 1;

          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.enrollStudent,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Step ${currentStep + 1} of ${stepLabels.length} · ${stepLabels[currentStep]}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                _buildStepBreadcrumb(
                  labels: stepLabels,
                  current: currentStep,
                  onTap: (i) {
                    // Only allow jumping to already-visited steps.
                    if (i <= currentStep) {
                      FocusScope.of(sheetStateContext).unfocus();
                      setSheetState(() => currentStep = i);
                    }
                  },
                ),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: stepContent(),
                    ),
                  ),
                ),
                _buildWizardFooter(
                  showBack: currentStep > 0,
                  onBack: () {
                    FocusScope.of(sheetStateContext).unfocus();
                    setSheetState(() => currentStep--);
                  },
                  primary: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLast ? submit : goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        isLast
                            ? AppLocalizations.of(context)!.enroll
                            : 'Next',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEnrollmentSuccess(String username, String lrn, String studentName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(LucideIcons.circle_check,
                  color: AppColors.success, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.studentEnrolled,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!
                      .studentEnrolledSuccessfully(studentName),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.loginCredentials,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontSize: 14,
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(LucideIcons.user,
                              size: 16, color: AppColors.textLight),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 65,
                            child: Text(AppLocalizations.of(context)!.userLabel,
                                style: const TextStyle(
                                    color: AppColors.textLight, fontSize: 13)),
                          ),
                          Expanded(
                            child: Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(LucideIcons.copy,
                                size: 16, color: AppColors.primary),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: username));
                              _showStatusDialog(
                                AppLocalizations.of(context)!.usernameCopied,
                                LucideIcons.copy,
                                AppColors.primary,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(LucideIcons.lock,
                              size: 16, color: AppColors.textLight),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 65,
                            child: Text(
                                AppLocalizations.of(context)!.passwordLabel,
                                style: const TextStyle(
                                    color: AppColors.textLight, fontSize: 13)),
                          ),
                          Expanded(
                            child: Text(
                              lrn,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(LucideIcons.copy,
                                size: 16, color: AppColors.primary),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: lrn));
                              _showStatusDialog(
                                AppLocalizations.of(context)!.passwordCopied,
                                LucideIcons.copy,
                                AppColors.primary,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.done,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showStudentInfoSheet(
      {required String studentId, required Map<String, dynamic> studentData}) {
    final nameController = TextEditingController(text: studentData['name']);
    final lrnController = TextEditingController(text: studentData['lrn']);
    final parentNameController = TextEditingController(
        text: studentData['parentName'] ??
            (studentData['profile']?['parentName'] ?? ''));
    final parentContactController = TextEditingController(
        text: studentData['parentContact'] ??
            (studentData['profile']?['parentContact'] ?? ''));
    DateTime? selectedBirthday;
    if (studentData['birthday'] != null) {
      selectedBirthday = DateTime.tryParse(studentData['birthday']);
    }
    final username = studentData['username'] ?? '';
    String selectedGender =
        studentData['gender'] ?? (studentData['profile']?['gender'] ?? 'Male');
    String selectedAvatar =
        studentData['avatar'] ?? (studentData['profile']?['avatar'] ?? '');
    if (selectedAvatar.isEmpty) {
      selectedAvatar =
          selectedGender.toLowerCase() == 'female' ? 'girl1' : 'boy1';
    }
    int currentStep = 0;
    const stepLabels = ['Profile', 'Parent', 'Account'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetStateContext, setSheetState) {
          Widget stepContent() {
            switch (currentStep) {
              case 0:
                return Column(
                  key: const ValueKey(0),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Avatar'),
                    _buildAvatarPicker(
                      selectedAvatar: selectedAvatar,
                      onSelect: (preset) {
                        setSheetState(() => selectedAvatar = preset);
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Student Information'),
                    _buildCard([
                      _buildTextField(
                        controller: nameController,
                        label: AppLocalizations.of(context)!.fullName,
                        icon: LucideIcons.badge,
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () async {
                          final initialToUse = (selectedBirthday != null &&
                                  !selectedBirthday!.isBefore(DateTime(1900)) &&
                                  !selectedBirthday!.isAfter(DateTime.now()))
                              ? selectedBirthday!
                              : DateTime.now()
                                  .subtract(const Duration(days: 365 * 4));
                          final picked = await showDatePicker(
                            context: sheetStateContext,
                            initialDate: initialToUse,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedBirthday = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            label: AppLocalizations.of(context)!.birthday,
                            icon: LucideIcons.cake,
                          ),
                          child: Text(
                            selectedBirthday == null
                                ? AppLocalizations.of(context)!.notSet
                                : "${selectedBirthday!.month}/${selectedBirthday!.day}/${selectedBirthday!.year}",
                            style: TextStyle(
                              color: selectedBirthday == null
                                  ? Colors.grey.shade500
                                  : AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernChoiceChip(
                              label: AppLocalizations.of(context)!.male,
                              isSelected: selectedGender == 'Male',
                              onSelected: (s) => setSheetState(
                                  () => selectedGender = 'Male'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildModernChoiceChip(
                              label: AppLocalizations.of(context)!.female,
                              isSelected: selectedGender == 'Female',
                              onSelected: (s) => setSheetState(
                                  () => selectedGender = 'Female'),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ],
                );
              case 1:
                return Column(
                  key: const ValueKey(1),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Parent Information'),
                    _buildCard([
                      _buildTextField(
                        controller: parentNameController,
                        label: AppLocalizations.of(context)!.parentNameLabel,
                        icon: LucideIcons.users,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: parentContactController,
                        label: AppLocalizations.of(context)!.parentContactLabel,
                        icon: LucideIcons.phone,
                        hintText: '09XXXXXXXXX',
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ]),
                  ],
                );
              default:
                return Column(
                  key: const ValueKey(2),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Login Credentials'),
                    _buildCard([
                      _buildTextField(
                        controller: lrnController,
                        label: AppLocalizations.of(context)!.lRNPassword,
                        icon: LucideIcons.key_round,
                        hintText: lrnController.text.isEmpty
                            ? 'Enter Student Number to set/show the password'
                            : null,
                        onChanged: (_) => setSheetState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _buildCredentialRow(
                        label: AppLocalizations.of(context)!.userLabel,
                        value: username,
                        icon: LucideIcons.user,
                        color: AppColors.primary,
                      ),
                      Divider(
                        height: 24,
                        indent: 40,
                        color: Colors.grey.shade200,
                      ),
                      _buildCredentialRow(
                        label: AppLocalizations.of(context)!.passwordLabel,
                        value: lrnController.text.isEmpty
                            ? 'Not saved yet — type a Student Number above to set it'
                            : lrnController.text,
                        icon: LucideIcons.lock,
                        color: AppColors.textDark,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionHeader('More'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: AppLocalizations.of(context)!.remove,
                            icon: LucideIcons.trash_2,
                            color: Colors.red,
                            isFilled: false,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  title: Text(AppLocalizations.of(context)!
                                      .removeStudent),
                                  content: Text(AppLocalizations.of(context)!
                                      .confirmRemoveStudent),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: Text(AppLocalizations.of(context)!
                                            .cancel)),
                                    TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: Text(
                                          AppLocalizations.of(context)!.remove,
                                          style: const TextStyle(
                                              color: Colors.red),
                                        )),
                                  ],
                                ),
                              );
                              if (!mounted) return;
                              if (confirm == true) {
                                await _authService.deleteStudent(studentId);
                                if (!mounted) return;
                                Navigator.of(context).pop();
                                _showStatusDialog(
                                  AppLocalizations.of(context)!.remove,
                                  LucideIcons.trash_2,
                                  Colors.red,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: 'Progress',
                            icon: LucideIcons.chart_column,
                            color: AppColors.secondary,
                            isFilled: true,
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              context.pushPremium(
                                StudentDetailScreen(
                                  studentName: nameController.text,
                                  studentData: {
                                    'id': studentId,
                                    'studentId': studentId,
                                    ...studentData,
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
            }
          }

          Future<void> saveUpdate() async {
            if (nameController.text.trim().isEmpty ||
                lrnController.text.trim().isEmpty ||
                parentNameController.text.trim().isEmpty ||
                parentContactController.text.trim().isEmpty) {
              _showStatusDialog(
                AppLocalizations.of(context)!.fillAllFields,
                LucideIcons.triangle_alert,
                Colors.orange,
              );
              return;
            }
            if (parentContactController.text.trim().length != 11) {
              _showStatusDialog(
                AppLocalizations.of(context)!.contactLengthError,
                LucideIcons.triangle_alert,
                Colors.orange,
              );
              return;
            }
            try {
              final updateMsg = AppLocalizations.of(context)!.update;
              await _authService.updateStudent(
                studentId: studentId,
                name: nameController.text.trim(),
                lrn: lrnController.text.trim(),
                gender: selectedGender,
                birthday: selectedBirthday,
                parentName: parentNameController.text.trim(),
                parentContact: parentContactController.text.trim(),
                avatar: selectedAvatar,
              );
              if (!mounted) return;
              Navigator.of(context).pop();
              _showStatusDialog(
                updateMsg,
                LucideIcons.circle_check,
                AppColors.success,
              );
            } catch (e) {
              if (!mounted) return;
              _showStatusDialog(
                "${AppLocalizations.of(context)!.error}: ${e.toString()}",
                LucideIcons.circle_alert,
                Colors.red,
              );
            }
          }

          void goNext() {
            if (currentStep == 0) {
              if (nameController.text.trim().isEmpty) {
                _showStatusDialog(
                  AppLocalizations.of(context)!.fillAllFields,
                  LucideIcons.triangle_alert,
                  Colors.orange,
                );
                return;
              }
            } else if (currentStep == 1) {
              if (parentNameController.text.trim().isEmpty ||
                  parentContactController.text.trim().isEmpty) {
                _showStatusDialog(
                  AppLocalizations.of(context)!.fillAllFields,
                  LucideIcons.triangle_alert,
                  Colors.orange,
                );
                return;
              }
              if (parentContactController.text.trim().length != 11) {
                _showStatusDialog(
                  AppLocalizations.of(context)!.contactLengthError,
                  LucideIcons.triangle_alert,
                  Colors.orange,
                );
                return;
              }
            }
            FocusScope.of(sheetStateContext).unfocus();
            setSheetState(() => currentStep++);
          }

          final isLast = currentStep == stepLabels.length - 1;

          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      _buildPresetAvatar(selectedAvatar,
                          size: 56, iconSize: 30),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameController.text,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@$username',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                _buildStepBreadcrumb(
                  labels: stepLabels,
                  current: currentStep,
                  onTap: (i) {
                    if (i <= currentStep) {
                      FocusScope.of(sheetStateContext).unfocus();
                      setSheetState(() => currentStep = i);
                    }
                  },
                ),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: stepContent(),
                    ),
                  ),
                ),
                _buildWizardFooter(
                  showBack: currentStep > 0,
                  onBack: () {
                    FocusScope.of(sheetStateContext).unfocus();
                    setSheetState(() => currentStep--);
                  },
                  primary: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isLast ? saveUpdate : goNext,
                      icon: Icon(
                          isLast ? LucideIcons.save : LucideIcons.arrow_right,
                          size: 20),
                      label: Text(
                        isLast ? AppLocalizations.of(context)!.update : 'Next',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Breadcrumb step indicator for the enroll/edit wizards. Numbered circles
  /// connected by lines, with a label under each. Tapping a step jumps to it.
  Widget _buildStepBreadcrumb({
    required List<String> labels,
    required int current,
    required ValueChanged<int> onTap,
  }) {
    final items = <Widget>[];
    for (int i = 0; i < labels.length; i++) {
      final isActive = i == current;
      final isDone = i < current;
      final circleColor =
          (isActive || isDone) ? AppColors.primary : Colors.grey.shade300;
      items.add(
        GestureDetector(
          onTap: () => onTap(i),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 68,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration:
                      BoxDecoration(color: circleColor, shape: BoxShape.circle),
                  child: Center(
                    child: isDone
                        ? const Icon(LucideIcons.check,
                            size: 16, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.1,
                    color: isActive ? AppColors.primary : Colors.grey.shade500,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (i < labels.length - 1) {
        items.add(
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(top: 14, left: 2, right: 2),
              color: i < current ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }

  /// Sticky footer with an optional Back button and a primary action that
  /// stays above the keyboard so the user never has to scroll to reach it.
  Widget _buildWizardFooter({
    required bool showBack,
    required VoidCallback onBack,
    required Widget primary,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBack) ...[
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(LucideIcons.arrow_left, size: 18),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(child: primary),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: _inputDecoration(label: label, icon: icon).copyWith(
        hintText: hintText,
        counterText: maxLength != null ? '' : null,
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 15),
    );
  }

  Widget _buildCredentialRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              _showStatusDialog(
                AppLocalizations.of(context)!.copied,
                LucideIcons.copy,
                AppColors.primary,
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.copy, size: 16, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return Container(
      height: 44,
      child: ChoiceChip(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label.toLowerCase() == 'male' ? LucideIcons.smile : LucideIcons.smile,
              size: 18,
              color: isSelected ? AppColors.primary : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: AppColors.primary.withOpacity(0.1),
        backgroundColor: const Color(0xFFF8F9FA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isFilled,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      child: isFilled
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18, color: color),
              label: Text(label, style: TextStyle(color: color)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
    );
  }

  Widget _buildPresetAvatar(String preset,
      {required double size, required double iconSize}) {
    // If it's a network URL, show the cached image
    if (preset.startsWith('http')) {
      return CachedAvatar(imageUrl: preset, size: size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarTintForPreset(preset),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        avatarAssetForPreset(preset),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
    );
  }

  Widget _buildAvatarPicker({
    required String selectedAvatar,
    required Function(String) onSelect,
  }) {
    final options = [
      {'key': 'boy1', 'label': 'Male'},
      {'key': 'girl1', 'label': 'Female'},
    ];

    return Row(
      children: List.generate(options.length, (i) {
        final preset = options[i]['key']!;
        final label = options[i]['label']!;
        final isSelected = _isSameGenderAvatar(selectedAvatar, preset);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 6,
              right: i == options.length - 1 ? 0 : 6,
            ),
            child: GestureDetector(
              onTap: () => onSelect(preset),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildPresetAvatar(preset, size: 64, iconSize: 32),
                        if (isSelected)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(LucideIcons.check,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Treats any boy*/girl* avatar as the same gender selection.
  bool _isSameGenderAvatar(String selected, String preset) {
    final s = selected.toLowerCase();
    if (preset.startsWith('girl')) {
      return s.startsWith('girl') || s == 'female';
    }
    return !(s.startsWith('girl') || s == 'female');
  }

  Widget _buildBirthdayBanner(List<String> names) {
    final label = names.length == 1
        ? names.first
        : '${names.take(2).join(', ')}${names.length > 2 ? ' +${names.length - 2}' : ''}';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF99C8), Color(0xFFFFB347)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF99C8).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🎂', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  names.length == 1
                      ? 'Birthday today!'
                      : '${names.length} birthdays today!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '🎉 $label',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                showBirthdayCelebration(context, name: names.first),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFFF6584),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Celebrate',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _confirmLogout,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(LucideIcons.arrow_left,
                            color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.teacherDashboard,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Manage your classroom',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconButton(
                      icon: LucideIcons.settings,
                      tooltip: AppLocalizations.of(context)!.settingsTitle,
                      onTap: () => context.pushPremium(
                        const TeacherSettingsScreen(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEnrollSheet,
        elevation: 4,
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.user_plus, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.enrollStudent,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF3FF), Color(0xFFFDEFF5)],
          ),
        ),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _authService.getStudentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final studentDocs = snapshot.data!.docs;

          // Detect students celebrating their birthday today.
          final now = DateTime.now();
          final birthdayStudents = <String>[];
          for (final doc in studentDocs) {
            final data = doc.data();
            final bdayRaw = data['birthday'] ??
                (data['profile'] as Map<String, dynamic>?)?['birthday'];
            if (bdayRaw is String && bdayRaw.isNotEmpty) {
              final bday = DateTime.tryParse(bdayRaw);
              if (bday != null &&
                  bday.month == now.month &&
                  bday.day == now.day) {
                final name = data['name']?.toString();
                if (name != null && name.isNotEmpty) birthdayStudents.add(name);
              }
            }
          }

          // Auto-show the celebration once when a student has a birthday today.
          if (birthdayStudents.isNotEmpty &&
              !_birthdayCelebrationShown &&
              _notificationsEnabled) {
            _birthdayCelebrationShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showBirthdayCelebration(context, name: birthdayStudents.first);
              }
            });
          }

          // Calculate stats
          double totalProgress = 0;
          int totalStars = 0;
          for (final doc in studentDocs) {
            final data = doc.data();
            final progress = data['progress'] as Map<String, dynamic>?;
            final profile = data['profile'] as Map<String, dynamic>?;
            totalProgress += (progress?['overallProgress'] ?? 0.0).toDouble();
            totalStars += (profile?['stars'] ?? 0) as int;
          }
          final avgProgress =
              studentDocs.isNotEmpty ? totalProgress / studentDocs.length : 0.0;

          final q = _searchQuery.trim().toLowerCase();
          final filteredDocs = q.isEmpty
              ? studentDocs
              : studentDocs.where((d) {
                  final data = d.data();
                  final n = (data['name'] ?? '').toString().toLowerCase();
                  final u = (data['username'] ?? '').toString().toLowerCase();
                  return n.contains(q) || u.contains(q);
                }).toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: _buildSearchBar(),
              ),

              // Stats Summary Cards
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: LucideIcons.users,
                        value: '${studentDocs.length}',
                        label: 'Students',
                        color: AppColors.primary,
                        index: 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: LucideIcons.trending_up,
                        value: '${(avgProgress * 100).toInt()}%',
                        label: 'Avg Progress',
                        color: AppColors.success,
                        index: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.star_rounded,
                        value: '$totalStars',
                        label: 'Stars',
                        color: Colors.amber,
                        index: 2,
                      ),
                    ),
                  ],
                ),
              ),

              // Birthday notification banner
              if (birthdayStudents.isNotEmpty)
                _buildBirthdayBanner(birthdayStudents),

              // Swipe hint
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Icon(LucideIcons.pointer,
                        size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.swipeToDeleteGuide,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),

              // Student List
              Expanded(
                child: filteredDocs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.search,
                                size: 40, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            Text(
                              'No students match "$_searchQuery"',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final studentDoc = filteredDocs[index];
                    final studentId = studentDoc.id;
                    final studentData = studentDoc.data();
                    final name = studentData['name'] ??
                        AppLocalizations.of(context)!.unknownStudent;
                    final username = studentData['username'] ?? '';
                    final progress =
                        studentData['progress'] as Map<String, dynamic>?;
                    final profile =
                        studentData['profile'] as Map<String, dynamic>?;
                    final gender = profile?['gender']?.toString() ?? '';
                    final avatar = studentData['avatar'] ??
                        (profile?['avatar']?.toString() ?? '');
                    final resolvedAvatar = avatar.isNotEmpty
                        ? avatar
                        : (gender.toLowerCase() == 'female' ? 'girl1' : 'boy1');

                    final overallProgress = progress != null
                        ? (progress['overallProgress'] ?? 0.0).toDouble()
                        : 0.0;
                    final stars = profile != null ? (profile['stars'] ?? 0) : 0;

                    return StaggeredEntrance(
                      index: index,
                      delayMs: 60,
                      child: Dismissible(
                        key: Key(studentId),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: Text(
                                  AppLocalizations.of(context)!.removeStudent),
                              content: Text(AppLocalizations.of(context)!
                                  .confirmRemoveStudent),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: Text(
                                        AppLocalizations.of(context)!.cancel)),
                                TextButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: Text(
                                        AppLocalizations.of(context)!.remove,
                                        style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          final removeMsg =
                              AppLocalizations.of(context)!.remove;
                          await _authService.deleteStudent(studentId);
                          if (!mounted) return;
                          _showStatusDialog(
                            removeMsg,
                            LucideIcons.trash_2,
                            Colors.red,
                          );
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade300,
                                Colors.red,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.trash_2,
                                  color: Colors.white, size: 28),
                              SizedBox(height: 4),
                              Text(
                                'Remove',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: _buildStudentCard(
                          name: name,
                          username: username,
                          overallProgress: overallProgress,
                          stars: stars,
                          avatar: resolvedAvatar,
                          onTap: () => _showStudentInfoSheet(
                            studentId: studentId,
                            studentData: studentData,
                          ),
                          onAvatarTap: () {
                            context.pushPremium(
                              StudentDetailScreen(
                                studentName: name,
                                studentData: {
                                  'id': studentId,
                                  'studentId': studentId,
                                  ...studentData,
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: StaggeredEntrance(
        index: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.users,
                size: 48,
                color: AppColors.primary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noStudentsEnrolled,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tapToEnroll,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search students...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon:
              Icon(LucideIcons.search, size: 20, color: Colors.grey.shade400),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: Icon(LucideIcons.x, size: 18, color: Colors.grey.shade500),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    FocusScope.of(context).unfocus();
                  },
                ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required int index,
  }) {
    return StaggeredEntrance(
      index: index,
      delayMs: 40,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard({
    required String name,
    required String username,
    required double overallProgress,
    required int stars,
    required String avatar,
    required VoidCallback onTap,
    required VoidCallback onAvatarTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                    child: _buildPresetAvatar(avatar, size: 48, iconSize: 24),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@$username',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(end: overallProgress),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    backgroundColor: Colors.grey.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      overallProgress >= 0.7
                                          ? AppColors.success
                                          : overallProgress >= 0.4
                                              ? Colors.orange
                                              : AppColors.primary,
                                    ),
                                    minHeight: 6,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(overallProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: overallProgress >= 0.7
                                  ? AppColors.success
                                  : overallProgress >= 0.4
                                      ? Colors.orange
                                      : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stars
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFB800), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$stars',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(LucideIcons.chevron_right,
                    color: Colors.grey.shade300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HEADER ICON BUTTON (glassy, for the dashboard top bar)
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.2),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
