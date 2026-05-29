import 'package:e_tarabay/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'for_parents_screen.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class ParentsLockScreen extends StatefulWidget {
  const ParentsLockScreen({super.key});

  @override
  State<ParentsLockScreen> createState() => _ParentsLockScreenState();
}

class _ParentsLockScreenState extends State<ParentsLockScreen> {
  final TextEditingController _lrnController = TextEditingController();
  bool _isLoading = false;
  bool _showError = false;

  @override
  void dispose() {
    _lrnController.dispose();
    super.dispose();
  }

  Future<void> _verifyLRN() async {
    final lrn = _lrnController.text.trim();
    if (lrn.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studentId = userProvider.currentStudentId;

      if (studentId == null) {
        setState(() {
          _isLoading = false;
          _showError = true;
        });
        return;
      }

      // Verify LRN against Firestore
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      if (doc.exists) {
        final storedLrn = (doc.data()?['lrn'] ?? '').toString().trim();
        if (storedLrn == lrn) {
          HapticFeedback.heavyImpact();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ForParentsScreen()),
          );
          return;
        }
      }

      // If we reach here, LRN is incorrect
      HapticFeedback.vibrate();
      setState(() {
        _showError = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error verifying LRN: $e');
      setState(() {
        _isLoading = false;
        _showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.parents,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.enterLRN,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _lrnController,
                keyboardType: TextInputType.number,
                obscureText: true,
                style: const TextStyle(letterSpacing: 8, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.lRN,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: '••••••••••••',
                  hintStyle: const TextStyle(letterSpacing: 2),
                  errorText: _showError
                      ? AppLocalizations.of(context)!.invalidLRN
                      : null,
                  prefixIcon: const Icon(Icons.key_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyLRN,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          AppLocalizations.of(context)!.verifyLRN,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
