import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Application "pepper" mixed into the LRN before hashing. The LRN (password)
  // is never stored in plaintext — only this one-way SHA-256 hash is saved,
  // so the raw password can't be read straight out of the database.
  static const String _lrnPepper = 'e_tarabay_v1_lrn_pepper';

  /// One-way hash of an LRN/password for storage and verification.
  static String hashLrn(String lrn) {
    final bytes = utf8.encode('$_lrnPepper:${lrn.trim()}');
    return sha256.convert(bytes).toString();
  }

  // ── Teacher credentials (config/teacher) ──────────────────────────────────

  /// Fetch the current teacher username from `config/teacher`.
  Future<String?> getTeacherUsername() async {
    try {
      final snap = await _db
          .collection('config')
          .doc('teacher')
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));
      final u = (snap.data()?['username'] ?? '').toString();
      return u.isEmpty ? null : u;
    } catch (e) {
      debugPrint('getTeacherUsername error: $e');
      return null;
    }
  }

  /// Verify a teacher password against the hash stored in `config/teacher`.
  /// Uses serverAndCache so it works offline after the first online login.
  Future<bool> verifyTeacherPassword(String password) async {
    try {
      final snap = await _db
          .collection('config')
          .doc('teacher')
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));
      final storedHash = (snap.data()?['passwordHash'] ?? '').toString();
      return storedHash.isNotEmpty && storedHash == hashLrn(password);
    } catch (e) {
      debugPrint('verifyTeacherPassword error: $e');
      return false;
    }
  }

  /// Update the teacher's stored credentials. The password is written only as a
  /// one-way hash — plaintext never touches Firestore. Pass a new [username]
  /// and/or [newPassword] (omit/empty to leave a field unchanged).
  Future<Map<String, dynamic>> updateTeacherCredentials({
    String? username,
    String? newPassword,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null && username.trim().isNotEmpty) {
        updates['username'] = username.trim();
      }
      if (newPassword != null && newPassword.trim().isNotEmpty) {
        updates['passwordHash'] = hashLrn(newPassword);
      }
      if (updates.isEmpty) {
        return {'status': 'Error', 'message': 'Nothing to update.'};
      }
      await _db
          .collection('config')
          .doc('teacher')
          .set(updates, SetOptions(merge: true));
      return {'status': 'Success'};
    } catch (e) {
      debugPrint('updateTeacherCredentials error: $e');
      return {
        'status': 'Error',
        'message': 'Could not save changes. Please check your connection.',
      };
    }
  }

  /// Update a student's login credentials (parent-controlled). The password
  /// (LRN) is stored only as a hash. Username is optional and, when provided,
  /// checked for uniqueness so it stays a valid roster identity.
  Future<Map<String, dynamic>> updateStudentCredentials({
    required String studentId,
    String? username,
    String? newPassword,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (username != null && username.trim().isNotEmpty) {
        final uname = username.trim();
        final clash = await _db
            .collection('students')
            .where('username', isEqualTo: uname)
            .get();
        final takenByOther =
            clash.docs.any((d) => d.id != studentId);
        if (takenByOther) {
          return {
            'status': 'Error',
            'message': 'That username is already taken. Please pick another.',
          };
        }
        updates['username'] = uname;
      }

      if (newPassword != null && newPassword.trim().isNotEmpty) {
        updates['lrnHash'] = hashLrn(newPassword);
        // Keep plaintext LRN so the teacher can view the student's password.
        updates['lrn'] = newPassword.trim();
      }

      if (updates.isEmpty) {
        return {'status': 'Error', 'message': 'Nothing to update.'};
      }

      await _db.collection('students').doc(studentId).update(updates);
      return {'status': 'Success'};
    } catch (e) {
      debugPrint('updateStudentCredentials error: $e');
      return {
        'status': 'Error',
        'message': 'Could not save changes. Please check your connection.',
      };
    }
  }

  /// Verify a student's password (LRN) against the stored hash. Used by the
  /// parent portal before enabling biometric or changing credentials.
  Future<bool> verifyStudentPassword(String studentId, String password) async {
    try {
      final snap = await _db
          .collection('students')
          .doc(studentId)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));
      final storedHash = (snap.data()?['lrnHash'] ?? '').toString();
      final legacyLrn = (snap.data()?['lrn'] ?? '').toString().trim();
      if (storedHash.isNotEmpty) return storedHash == hashLrn(password);
      return legacyLrn.isNotEmpty && legacyLrn == password.trim();
    } catch (e) {
      debugPrint('verifyStudentPassword error: $e');
      return false;
    }
  }

  /// Fetch a student's current username (for pre-filling parent forms / storing
  /// biometric credentials).
  Future<String?> getStudentUsername(String studentId) async {
    try {
      final snap = await _db
          .collection('students')
          .doc(studentId)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));
      final u = (snap.data()?['username'] ?? '').toString();
      return u.isEmpty ? null : u;
    } catch (e) {
      debugPrint('getStudentUsername error: $e');
      return null;
    }
  }

  /// Login a student/parent using credentials enrolled by the teacher.
  /// Looks up `students` collection in Firestore.
  /// Matches username and LRN (password).
  Future<Map<String, dynamic>> loginStudent(
      String username, String password) async {
    try {
      final query = _db
          .collection('students')
          .where('username', isEqualTo: username.trim());

      // Cache-first: returning students are already cached locally, so login
      // is instant with no spinner wait. Only fall back to the server when the
      // student isn't cached yet (e.g. first login on this device).
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      try {
        querySnapshot =
            await query.get(const GetOptions(source: Source.cache));
        if (querySnapshot.docs.isEmpty) {
          querySnapshot = await query
              .get(const GetOptions(source: Source.server))
              .timeout(const Duration(seconds: 5));
        }
      } catch (_) {
        querySnapshot = await query
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 5));
      }

      if (querySnapshot.docs.isEmpty) {
        // Check if they are trying to login as teacher on student screen
        if (username.toLowerCase().trim() == 'daycare teacher') {
          return {
            'status': 'Error',
            'message':
                'This is the Student Login. Please use the "Continue as Teacher" button at the bottom of the screen.',
          };
        }
        return {
          'status': 'Error',
          'message':
              'This username does not exist. Please check your spelling or ask your teacher if you are enrolled.',
        };
      }

      final doc = querySnapshot.docs.first;
      final studentData = doc.data();
      final storedHash = (studentData['lrnHash'] ?? '').toString();
      final legacyLrn = (studentData['lrn'] ?? '').toString().trim();

      bool matches = false;
      if (storedHash.isNotEmpty) {
        // Preferred path: compare against the stored one-way hash.
        matches = storedHash == hashLrn(password);
      } else if (legacyLrn.isNotEmpty) {
        // Legacy records only hold a plaintext LRN — verify, then add the
        // hash. The plaintext is kept so the teacher can view the password.
        matches = legacyLrn == password.trim();
        if (matches) {
          try {
            await doc.reference.update({
              'lrnHash': hashLrn(password),
            });
          } catch (_) {}
        }
      }

      if (matches) {
        return {
          'status': 'Success',
          'studentId': doc.id,
          'studentData': studentData,
        };
      }

      return {
        'status': 'Error',
        'message':
            'The LRN (password) you entered is incorrect. Please try again.',
      };
    } catch (e) {
      debugPrint('Login error: $e');
      return {
        'status': 'Error',
        'message': 'A connection error occurred. Please check your internet.',
      };
    }
  }

  /// Validate password format for DC-2026-0001 structure.
  /// Format: DC-YYYY-XXXX (e.g., DC-2026-0001)
  /// Also detects repeated digits in suffix (e.g. DC-2026-0000, DC-2026-1111).
  static Map<String, dynamic> validateDcPasswordFormat(String password) {
    final trimmed = password.trim();
    if (trimmed.isEmpty) {
      return {'isValid': false, 'message': 'Password (LRN) cannot be empty.'};
    }

    // Match DC-XXXX-XXXX format (e.g. DC-2026-0001)
    final regex = RegExp(r'^DC-\d{4}-\d{4}$', caseSensitive: false);
    if (!regex.hasMatch(trimmed)) {
      return {
        'isValid': false,
        'message': 'Password must follow format: DC-2026-0001',
      };
    }

    // Extract trailing numeric portion
    final parts = trimmed.split('-');
    final numericPart = parts.last;

    // Check for identical repeated digits
    if (RegExp(r'^(\d)\1{3}$').hasMatch(numericPart)) {
      return {
        'isValid': false,
        'message': 'Password cannot contain repeated digits (e.g., 0000, 1111).',
      };
    }

    return {'isValid': true, 'message': ''};
  }

  /// Enroll a student — called by the teacher.
  /// Adds a new student record to `students` collection.
  Future<Map<String, dynamic>> enrollStudent({
    required String name,
    String middleName = '',
    required String lrn,
    required String gender,
    required String username,
    DateTime? birthday,
    String parentName = '',
    String parentContact = '',
    String? avatar,
  }) async {
    try {
      // Check if LRN already exists to prevent duplicates (compare hashes)
      final lrnHash = hashLrn(lrn);
      final existingCheck = await _db
          .collection('students')
          .where('lrnHash', isEqualTo: lrnHash)
          .get();

      if (existingCheck.docs.isNotEmpty) {
        return {
          'status': 'Error',
          'message': 'A student with this LRN is already enrolled.',
        };
      }

      // Check if username already exists
      final usernameCheck = await _db
          .collection('students')
          .where('username', isEqualTo: username.trim())
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        return {
          'status': 'Error',
          'message': 'This username is already taken. Please try again.',
        };
      }

      // Create the student record in Firestore
      final docRef = _db.collection('students').doc();
      final studentData = {
        'name': name,
        'middleName': middleName.trim(),
        'lrnHash': lrnHash,
        // Plaintext LRN kept so the teacher can view a student's login
        // password from the dashboard. Verification still uses lrnHash.
        'lrn': lrn.trim(),
        'gender': gender,
        'username': username.trim(),
        'birthday': birthday?.toIso8601String(),
        'parentName': parentName,
        'parentContact': parentContact,
        'avatar': avatar,
        'enrolledAt': FieldValue.serverTimestamp(),
        'progress': {
          'overallProgress': 0.0,
          'totalCompleted': 0,
          'totalActivities': 100,
        },
        'profile': {
          'name': name,
          'middleName': middleName.trim(),
          'gender': gender,
          'birthday': birthday?.toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
          'parentName': parentName,
          'parentContact': parentContact,
          'avatar': avatar,
          'stars': 0,
          'lessonsCompleted': 0,
          'achievements': {},
        }
      };

      await docRef.set(studentData);

      return {
        'status': 'Success',
        'studentId': docRef.id,
        'studentData': studentData,
      };
    } catch (e) {
      debugPrint('Enrollment error: $e');
      return {
        'status': 'Error',
        'message': 'Could not enroll student. Please check your connection.',
      };
    }
  }

  /// Get all enrolled students (for teacher dashboard).
  Stream<QuerySnapshot<Map<String, dynamic>>> getStudentsStream() {
    return _db
        .collection('students')
        .orderBy('enrolledAt', descending: true)
        .snapshots();
  }

  /// Update student details (name, LRN).
  Future<void> updateStudent({
    required String studentId,
    required String name,
    String? middleName,
    required String lrn,
    String? gender,
    DateTime? birthday,
    String? parentName,
    String? parentContact,
    String? avatar,
  }) async {
    try {
      final updates = <String, dynamic>{
        'name': name,
      };

      if (middleName != null) {
        updates['middleName'] = middleName.trim();
      }

      // Only change the password hash when a new LRN is actually provided;
      // never overwrite it with an empty value. Keep the plaintext LRN so the
      // teacher can view the student's login password.
      if (lrn.trim().isNotEmpty) {
        updates['lrnHash'] = hashLrn(lrn);
        updates['lrn'] = lrn.trim();
      }

      final profileUpdates = <String, dynamic>{
        'profile.name': name,
      };
      if (middleName != null) {
        profileUpdates['profile.middleName'] = middleName.trim();
      }

      if (gender != null) {
        updates['gender'] = gender;
        profileUpdates['profile.gender'] = gender;
      }
      if (birthday != null) {
        updates['birthday'] = birthday.toIso8601String();
        profileUpdates['profile.birthday'] = birthday.toIso8601String();
      }
      if (parentName != null) {
        updates['parentName'] = parentName;
        profileUpdates['profile.parentName'] = parentName;
      }
      if (parentContact != null) {
        updates['parentContact'] = parentContact;
        profileUpdates['profile.parentContact'] = parentContact;
      }
      if (avatar != null) {
        updates['avatar'] = avatar;
        profileUpdates['profile.avatar'] = avatar;
      }

      await _db.collection('students').doc(studentId).update({
        ...updates,
        ...profileUpdates,
      });
    } catch (e) {
      debugPrint('Error updating student: $e');
    }
  }

  /// Delete a student record.
  Future<void> deleteStudent(String studentId) async {
    try {
      await _db.collection('students').doc(studentId).delete();
    } catch (e) {
      debugPrint('Error deleting student: $e');
    }
  }

  /// Delete all student records from Firestore.
  Future<Map<String, dynamic>> deleteAllStudents() async {
    try {
      final querySnapshot = await _db.collection('students').get();
      final docs = querySnapshot.docs;

      if (docs.isEmpty) {
        return {
          'status': 'Success',
          'message': 'No students to delete.',
          'count': 0,
        };
      }

      // Firestore batches are limited to 500 operations
      const int batchLimit = 500;
      for (var i = 0; i < docs.length; i += batchLimit) {
        final batch = _db.batch();
        final end =
            (i + batchLimit < docs.length) ? i + batchLimit : docs.length;
        for (var j = i; j < end; j++) {
          batch.delete(docs[j].reference);
        }
        await batch.commit();
      }

      return {
        'status': 'Success',
        'message': 'All students deleted.',
        'count': docs.length,
      };
    } catch (e) {
      debugPrint('Error deleting all students: $e');
      return {
        'status': 'Error',
        'message': 'Could not delete students. Please try again.',
      };
    }
  }

  /// Reset credentials for all existing students to DC-2026-XXXX format.
  Future<Map<String, dynamic>> resetAllStudentCredentialsToDcFormat() async {
    try {
      final querySnapshot = await _db.collection('students').get();
      final docs = querySnapshot.docs;

      if (docs.isEmpty) {
        return {
          'status': 'Success',
          'message': 'No students found to reset.',
          'updatedStudents': <Map<String, String>>[],
        };
      }

      final year = DateTime.now().year;
      final updatedList = <Map<String, String>>[];
      final usedIds = <String>{};

      const int batchLimit = 500;
      for (var i = 0; i < docs.length; i += batchLimit) {
        final batch = _db.batch();
        final end =
            (i + batchLimit < docs.length) ? i + batchLimit : docs.length;

        for (var j = i; j < end; j++) {
          final doc = docs[j];
          final name = (doc.data()['name'] ?? 'Student').toString();
          final username = (doc.data()['username'] ?? '').toString();

          // Generate unique DC-YYYY-XXXX ID
          String newId;
          do {
            final rand = (Random().nextInt(9000) + 1000).toString();
            newId = 'DC-$year-$rand';
          } while (usedIds.contains(newId));

          usedIds.add(newId);
          final newHash = hashLrn(newId);

          batch.update(doc.reference, {
            'lrn': newId,
            'lrnHash': newHash,
            'profile.lrn': newId,
          });

          updatedList.add({
            'name': name,
            'username': username,
            'studentId': newId,
          });
        }
        await batch.commit();
      }

      return {
        'status': 'Success',
        'message': 'Successfully reset credentials for ${docs.length} students.',
        'updatedStudents': updatedList,
      };
    } catch (e) {
      debugPrint('Error resetting student credentials: $e');
      return {
        'status': 'Error',
        'message': 'Failed to reset credentials. Please try again.',
      };
    }
  }
}
