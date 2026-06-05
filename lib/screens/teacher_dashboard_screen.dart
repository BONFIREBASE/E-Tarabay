import 'package:e_tarabay/l10n/app_localizations.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../login_screen.dart';
import '../utils/constants.dart';
import '../widgets/staggered_entrance.dart';
import '../widgets/cached_avatar.dart';
import 'student_detail_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final AuthService _authService = AuthService();

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

  void _logout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(AppLocalizations.of(context)!.confirmLogout),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.logout,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await userProvider.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _confirmResetAllStudents() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.resetAllStudents,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(AppLocalizations.of(context)!.confirmResetAllStudents),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.confirm,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _authService.deleteAllStudents();
      if (!mounted) return;
      if (result['status'] == 'Success') {
        _showStatusDialog(
          result['message'] as String,
          Icons.check_circle,
          AppColors.success,
        );
      } else {
        _showStatusDialog(
          result['message'] as String,
          Icons.error,
          Colors.red,
        );
      }
    }
  }

  void _showEnrollSheet() {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final lrnController = TextEditingController();
    final usernameController = TextEditingController();
    final parentNameController = TextEditingController();
    final parentContactController = TextEditingController();
    DateTime? selectedBirthday;
    String selectedGender = 'Male';
    String selectedAvatar = 'boy1';
    bool avatarExplicitlySelected = false;

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
        builder: (sheetStateContext, setSheetState) => Container(
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
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
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
                            'Create a new student account',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar ──
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

                      // ── Student Information ──
                      _buildSectionHeader('Student Information'),
                      _buildCard([
                        _buildTextField(
                          controller: firstNameController,
                          label: AppLocalizations.of(context)!.firstName,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: lastNameController,
                          label: AppLocalizations.of(context)!.lastName,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: sheetStateContext,
                              initialDate: DateTime.now()
                                  .subtract(const Duration(days: 365 * 4)),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setSheetState(() => selectedBirthday = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              label: AppLocalizations.of(context)!.birthday,
                              icon: Icons.cake_outlined,
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
                        _buildTextField(
                          controller: lrnController,
                          label: AppLocalizations.of(context)!.lRN,
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
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

                      const SizedBox(height: 20),

                      // ── Parent Information ──
                      _buildSectionHeader('Parent Information'),
                      _buildCard([
                        _buildTextField(
                          controller: parentNameController,
                          label: AppLocalizations.of(context)!.parentNameLabel,
                          icon: Icons.family_restroom_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: parentContactController,
                          label:
                              AppLocalizations.of(context)!.parentContactLabel,
                          icon: Icons.phone_outlined,
                          hintText: '09XXXXXXXXX',
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── Account Credentials ──
                      _buildSectionHeader('Account Credentials'),
                      _buildCard([
                        _buildCredentialRow(
                          label: AppLocalizations.of(context)!.userLabel,
                          value: usernameController.text.isEmpty
                              ? 'Auto-generated'
                              : usernameController.text,
                          icon: Icons.person_outline,
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
                              ? 'Enter LRN above'
                              : lrnController.text,
                          icon: Icons.lock_outline,
                          color: AppColors.textDark,
                        ),
                      ]),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (firstNameController.text.trim().isEmpty ||
                                lastNameController.text.trim().isEmpty ||
                                lrnController.text.trim().isEmpty ||
                                parentNameController.text.trim().isEmpty ||
                                parentContactController.text.trim().isEmpty) {
                              _showStatusDialog(
                                AppLocalizations.of(context)!.fillAllFields,
                                Icons.warning_amber_rounded,
                                Colors.orange,
                              );
                              return;
                            }
                            if (parentContactController.text.trim().length !=
                                11) {
                              _showStatusDialog(
                                AppLocalizations.of(context)!
                                    .contactLengthError,
                                Icons.warning_amber_rounded,
                                Colors.orange,
                              );
                              return;
                            }
                            Navigator.pop(sheetContext);
                            final fullName =
                                '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
                            final result = await _authService.enrollStudent(
                              name: fullName,
                              lrn: lrnController.text.trim(),
                              gender: selectedGender,
                              username: usernameController.text,
                              birthday: selectedBirthday,
                              parentName: parentNameController.text.trim(),
                              parentContact:
                                  parentContactController.text.trim(),
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.enroll,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
              const Icon(Icons.check_circle,
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
                          const Icon(Icons.person,
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
                            icon: const Icon(Icons.copy,
                                size: 16, color: AppColors.primary),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: username));
                              _showStatusDialog(
                                AppLocalizations.of(context)!.usernameCopied,
                                Icons.copy,
                                AppColors.primary,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.lock,
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
                            icon: const Icon(Icons.copy,
                                size: 16, color: AppColors.primary),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: lrn));
                              _showStatusDialog(
                                AppLocalizations.of(context)!.passwordCopied,
                                Icons.copy,
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
    if (studentData['birthday'] != null)
      selectedBirthday = DateTime.tryParse(studentData['birthday']);
    final username = studentData['username'] ?? '';
    String selectedGender =
        studentData['gender'] ?? (studentData['profile']?['gender'] ?? 'Male');
    String selectedAvatar =
        studentData['avatar'] ?? (studentData['profile']?['avatar'] ?? '');
    if (selectedAvatar.isEmpty) {
      selectedAvatar =
          selectedGender.toLowerCase() == 'female' ? 'girl1' : 'boy1';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetStateContext, setSheetState) => Container(
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
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with avatar and name
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    _buildPresetAvatar(selectedAvatar, size: 56, iconSize: 30),
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
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar ──
                      _buildSectionHeader('Avatar'),
                      _buildAvatarPicker(
                        selectedAvatar: selectedAvatar,
                        onSelect: (preset) {
                          setSheetState(() => selectedAvatar = preset);
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Student Information ──
                      _buildSectionHeader('Student Information'),
                      _buildCard([
                        _buildTextField(
                          controller: nameController,
                          label: AppLocalizations.of(context)!.fullName,
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: lrnController,
                          label: AppLocalizations.of(context)!.lRNPassword,
                          icon: Icons.password_outlined,
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: sheetStateContext,
                              initialDate: selectedBirthday ??
                                  DateTime.now()
                                      .subtract(const Duration(days: 365 * 4)),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null)
                              setSheetState(() => selectedBirthday = picked);
                          },
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              label: AppLocalizations.of(context)!.birthday,
                              icon: Icons.cake_outlined,
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

                      const SizedBox(height: 20),

                      // ── Parent Information ──
                      _buildSectionHeader('Parent Information'),
                      _buildCard([
                        _buildTextField(
                          controller: parentNameController,
                          label: AppLocalizations.of(context)!.parentNameLabel,
                          icon: Icons.family_restroom_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: parentContactController,
                          label:
                              AppLocalizations.of(context)!.parentContactLabel,
                          icon: Icons.phone_outlined,
                          hintText: '09XXXXXXXXX',
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── Login Credentials ──
                      _buildSectionHeader('Login Credentials'),
                      _buildCard([
                        _buildCredentialRow(
                          label: AppLocalizations.of(context)!.userLabel,
                          value: username,
                          icon: Icons.person_outline,
                          color: AppColors.primary,
                        ),
                        Divider(
                          height: 24,
                          indent: 40,
                          color: Colors.grey.shade200,
                        ),
                        _buildCredentialRow(
                          label: AppLocalizations.of(context)!.passwordLabel,
                          value: lrnController.text,
                          icon: Icons.lock_outline,
                          color: AppColors.textDark,
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // ── Actions ──
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              label: AppLocalizations.of(context)!.remove,
                              icon: Icons.delete_outline,
                              color: Colors.red,
                              isFilled: false,
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    title: Text(AppLocalizations.of(context)!
                                        .removeStudent),
                                    content: Text(AppLocalizations.of(context)!
                                        .confirmRemoveStudent),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, false),
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .cancel)),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, true),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .remove,
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
                                    Icons.delete_outline,
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
                              icon: Icons.bar_chart_outlined,
                              color: AppColors.secondary,
                              isFilled: true,
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudentDetailScreen(
                                      studentName: nameController.text,
                                      studentData: studentData,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty ||
                                lrnController.text.trim().isEmpty ||
                                parentNameController.text.trim().isEmpty ||
                                parentContactController.text.trim().isEmpty) {
                              _showStatusDialog(
                                AppLocalizations.of(context)!.fillAllFields,
                                Icons.warning_amber_rounded,
                                Colors.orange,
                              );
                              return;
                            }
                            if (parentContactController.text.trim().length !=
                                11) {
                              _showStatusDialog(
                                AppLocalizations.of(context)!
                                    .contactLengthError,
                                Icons.warning_amber_rounded,
                                Colors.orange,
                              );
                              return;
                            }
                            try {
                              final updateMsg =
                                  AppLocalizations.of(context)!.update;
                              await _authService.updateStudent(
                                studentId: studentId,
                                name: nameController.text.trim(),
                                lrn: lrnController.text.trim(),
                                gender: selectedGender,
                                birthday: selectedBirthday,
                                parentName: parentNameController.text.trim(),
                                parentContact:
                                    parentContactController.text.trim(),
                                avatar: selectedAvatar,
                              );
                              if (!mounted) return;
                              Navigator.of(context).pop();
                              _showStatusDialog(
                                updateMsg,
                                Icons.check_circle_outline,
                                AppColors.success,
                              );
                            } catch (e) {
                              if (!mounted) return;
                              _showStatusDialog(
                                "${AppLocalizations.of(context)!.error}: ${e.toString()}",
                                Icons.error_outline,
                                Colors.red,
                              );
                            }
                          },
                          icon: const Icon(Icons.save_outlined, size: 20),
                          label: Text(
                            AppLocalizations.of(context)!.update,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
  }) {
    return TextField(
      controller: controller,
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
                Icons.copy,
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
              child: const Icon(Icons.copy, size: 16, color: AppColors.primary),
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
              label.toLowerCase() == 'male' ? Icons.face : Icons.face_2,
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

    final Map<String, Map<String, dynamic>> presets = {
      'boy1': {'icon': Icons.face, 'color': const Color(0xFF4A90D9)},
      'boy2': {
        'icon': Icons.sentiment_satisfied,
        'color': const Color(0xFF26A69A)
      },
      'boy3': {'icon': Icons.child_care, 'color': const Color(0xFFEF6C00)},
      'girl1': {'icon': Icons.face_2, 'color': const Color(0xFFE91E63)},
      'girl2': {'icon': Icons.face_3, 'color': const Color(0xFF9C27B0)},
      'girl3': {'icon': Icons.face_4, 'color': const Color(0xFF00BCD4)},
      'neutral1': {'icon': Icons.person, 'color': const Color(0xFF607D8B)},
      'neutral2': {
        'icon': Icons.sentiment_very_satisfied,
        'color': const Color(0xFF8BC34A)
      },
    };

    final config = presets[preset] ?? presets['boy1']!;
    final color = config['color'] as Color;
    final icon = config['icon'] as IconData;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }

  Widget _buildAvatarPicker({
    required String selectedAvatar,
    required Function(String) onSelect,
  }) {
    final presets = [
      'boy1',
      'boy2',
      'boy3',
      'girl1',
      'girl2',
      'girl3',
      'neutral1',
      'neutral2',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: presets.map((preset) {
          final isSelected = selectedAvatar == preset;
          return GestureDetector(
            onTap: () => onSelect(preset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2.5,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: _buildPresetAvatar(preset, size: 48, iconSize: 26),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 16,
            20,
            20,
          ),
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
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.teacherDashboard,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'reset') {
                          _confirmResetAllStudents();
                        } else if (value == 'logout') {
                          _logout();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'reset',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_forever,
                                  color: Colors.red),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!
                                  .resetAllStudents),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              const Icon(Icons.logout,
                                  color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.logout),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your classroom',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
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
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.enrollStudent,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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

          return Column(
            children: [
              // Space below gradient header
              const SizedBox(height: 140),

              // Stats Summary Cards
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_rounded,
                        value: '${studentDocs.length}',
                        label: 'Students',
                        color: AppColors.primary,
                        index: 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up_rounded,
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

              // Swipe hint
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.swipe_left,
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
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: studentDocs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final studentDoc = studentDocs[index];
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
                            Icons.delete_outline,
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
                              Icon(Icons.delete_outline,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentDetailScreen(
                                  studentName: name,
                                  studentData: studentData,
                                ),
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
                Icons.people_outline,
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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
                  child: _buildPresetAvatar(avatar, size: 52, iconSize: 26),
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
                          color: Colors.amber, size: 16),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
