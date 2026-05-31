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
import 'student_detail_screen.dart';
import 'profile_screen.dart';

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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.enrollStudent,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext)),
                  ],
                ),
                const SizedBox(height: 20),
                Text(AppLocalizations.of(context)!.studentInfo,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.firstName,
                    prefixIcon: const Icon(Icons.person_outline,
                        color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.lastName,
                    prefixIcon: const Icon(Icons.person_outline,
                        color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: sheetStateContext,
                      initialDate: DateTime.now()
                          .subtract(const Duration(days: 365 * 4)),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null)
                      setSheetState(() => selectedBirthday = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.birthday,
                      prefixIcon:
                          const Icon(Icons.cake, color: AppColors.primary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(selectedBirthday == null
                        ? AppLocalizations.of(context)!.notSet
                        : "${selectedBirthday!.month}/${selectedBirthday!.day}/${selectedBirthday!.year}"),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lrnController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.lRN,
                    helperText: AppLocalizations.of(context)!.password,
                    prefixIcon: const Icon(Icons.badge_outlined,
                        color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.genderLabel,
                    prefixIcon: const Icon(Icons.wc, color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'Male',
                        child: Text(AppLocalizations.of(context)!.male)),
                    DropdownMenuItem(
                        value: 'Female',
                        child: Text(AppLocalizations.of(context)!.female)),
                  ],
                  onChanged: (v) => setSheetState(() => selectedGender = v!),
                ),
                const SizedBox(height: 24),
                Text(AppLocalizations.of(context)!.parentsInfo,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                TextField(
                  controller: parentNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.parentNameLabel,
                    prefixIcon: const Icon(Icons.family_restroom,
                        color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: parentContactController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.parentContactLabel,
                    hintText: "09XXXXXXXXX",
                    prefixIcon:
                        const Icon(Icons.phone, color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
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
                      if (parentContactController.text.trim().length != 11) {
                        _showStatusDialog(
                          AppLocalizations.of(context)!.contactLengthError,
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
                        parentContact: parentContactController.text.trim(),
                      );
                      if (!context.mounted) return;
                      if (result['status'] == 'Success') {
                        _showEnrollmentSuccess(usernameController.text,
                            lrnController.text.trim(), fullName);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: Text(AppLocalizations.of(context)!.enroll,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetStateContext, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(nameController.text,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                            overflow: TextOverflow.ellipsis)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext)),
                  ],
                ),
                const SizedBox(height: 20),
                Text(AppLocalizations.of(context)!.studentInfo,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fullName,
                    prefixIcon:
                        const Icon(Icons.badge, color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lrnController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.lRNPassword,
                    prefixIcon:
                        const Icon(Icons.password, color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.birthday,
                      prefixIcon:
                          const Icon(Icons.cake, color: AppColors.primary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(selectedBirthday == null
                        ? AppLocalizations.of(context)!.notSet
                        : "${selectedBirthday!.month}/${selectedBirthday!.day}/${selectedBirthday!.year}"),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildChoiceChip(
                            label: AppLocalizations.of(context)!.male,
                            isSelected: selectedGender == 'Male',
                            onSelected: (s) =>
                                setSheetState(() => selectedGender = 'Male'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildChoiceChip(
                            label: AppLocalizations.of(context)!.female,
                            isSelected: selectedGender == 'Female',
                            onSelected: (s) => setSheetState(
                                () => selectedGender = 'Female'))),
                  ],
                ),
                const SizedBox(height: 24),
                Text(AppLocalizations.of(context)!.parentsInfo,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                TextField(
                  controller: parentNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.parentNameLabel,
                    prefixIcon: const Icon(Icons.family_restroom,
                        color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: parentContactController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.parentContactLabel,
                    hintText: "09XXXXXXXXX",
                    prefixIcon:
                        const Icon(Icons.phone, color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _buildCopyableRow(
                          context,
                          AppLocalizations.of(context)!.userLabel,
                          username,
                          AppColors.primary),
                      const Divider(),
                      _buildCopyableRow(
                          context,
                          AppLocalizations.of(context)!.passwordLabel,
                          lrnController.text,
                          Colors.black87),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final removeStudentTitle =
                              AppLocalizations.of(context)!.removeStudent;
                          final confirmRemoveMsg = AppLocalizations.of(context)!
                              .confirmRemoveStudent;
                          final cancelLabel =
                              AppLocalizations.of(context)!.cancel;
                          final removeLabel =
                              AppLocalizations.of(context)!.remove;

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text(removeStudentTitle),
                              content: Text(confirmRemoveMsg),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: Text(cancelLabel)),
                                TextButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: Text(removeLabel,
                                        style: const TextStyle(
                                            color: Colors.red))),
                              ],
                            ),
                          );
                          if (!mounted) return;
                          if (confirm == true) {
                            await _authService.deleteStudent(studentId);
                            if (!mounted) return;
                            Navigator.of(context).pop();
                            _showStatusDialog(
                              removeLabel,
                              Icons.delete_outline,
                              Colors.red,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: Text(AppLocalizations.of(context)!.remove,
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => StudentDetailScreen(
                                      studentName: nameController.text,
                                      studentData: studentData)));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: Text(AppLocalizations.of(context)!.progressLabel,
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                      if (parentContactController.text.trim().length != 11) {
                        _showStatusDialog(
                          AppLocalizations.of(context)!.contactLengthError,
                          Icons.warning_amber_rounded,
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
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: Text(AppLocalizations.of(context)!.update,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCopyableRow(
      BuildContext context, String label, String value, Color valueColor) {
    return Row(
      children: [
        SizedBox(
          width: 45,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: valueColor)),
        ),
        IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            _showStatusDialog(
              AppLocalizations.of(context)!.copied,
              Icons.copy,
              AppColors.primary,
            );
          },
          icon: const Icon(Icons.copy, size: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.teacherDashboard,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        actions: [
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
                    const Icon(Icons.delete_forever, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.resetAllStudents),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.logout),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEnrollSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.enrollStudent,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _authService.getStudentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noStudentsEnrolled,
                    style: const TextStyle(
                        fontSize: 18, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.tapToEnroll,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textLight),
                  ),
                ],
              ),
            );
          }

          final studentDocs = snapshot.data!.docs;

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.swipe_left,
                        size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.swipeToDeleteGuide,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
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

                    final overallProgress = progress != null
                        ? (progress['overallProgress'] ?? 0.0).toDouble()
                        : 0.0;
                    final stars = profile != null ? (profile['stars'] ?? 0) : 0;

                    return Dismissible(
                      key: Key(studentId),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
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
                        final removeMsg = AppLocalizations.of(context)!.remove;
                        await _authService.deleteStudent(studentId);
                        if (!mounted) return;
                        _showStatusDialog(
                          removeMsg,
                          Icons.delete_outline,
                          Colors.red,
                        );
                      },
                      background: Container(
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: GestureDetector(
                            // Wrapped CircleAvatar with GestureDetector
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              radius: 25,
                              child: const Icon(Icons.person,
                                  color: AppColors.primary),
                            ),
                          ),
                          title: Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                  '${AppLocalizations.of(context)!.usernameHeader} $username',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight)),
                              const SizedBox(height: 8),
                              Text(
                                  '${AppLocalizations.of(context)!.progressLabel}: ${(overallProgress * 100).toInt()}%'),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: overallProgress.toDouble(),
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.success),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text('$stars',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          onTap: () => _showStudentInfoSheet(
                              studentId: studentId, studentData: studentData),
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

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
