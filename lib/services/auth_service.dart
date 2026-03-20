import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Login a student/parent using credentials enrolled by the teacher.
  /// Looks up `students` collection in Firestore.
  /// Matches username and LRN (password).
  Future<Map<String, dynamic>> loginStudent(
      String username, String password) async {
    try {
      // Smart Cache + Strict Timeout to prevent indefinite loading freezes
      final querySnapshot = await _db
          .collection('students')
          .where('username', isEqualTo: username.trim())
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));

      if (querySnapshot.docs.isEmpty) {
        // Check if they are trying to login as teacher on student screen
        if (username.toLowerCase().trim() == 'daycare teacher') {
          return {
            'status': 'Error',
            'message': 'This is the Student Login. Please use the "Continue as Teacher" button at the bottom of the screen.',
          };
        }
        return {
          'status': 'Error',
          'message': 'This username does not exist. Please check your spelling or ask your teacher if you are enrolled.',
        };
      }

      final doc = querySnapshot.docs.first;
      final studentData = doc.data();
      final storedLrn = (studentData['lrn'] ?? '').toString().trim();

      if (storedLrn == password.trim()) {
        return {
          'status': 'Success',
          'studentId': doc.id,
          'studentData': studentData,
        };
      }

      return {
        'status': 'Error',
        'message': 'The LRN (password) you entered is incorrect. Please try again.',
      };
    } catch (e) {
      debugPrint('Login error: $e');
      return {
        'status': 'Error',
        'message': 'A connection error occurred. Please check your internet.',
      };
    }
  }

  /// Enroll a student — called by the teacher.
  /// Adds a new student record to `students` collection.
  Future<Map<String, dynamic>> enrollStudent({
    required String name,
    required String lrn,
    required String gender,
    required String username,
    DateTime? birthday,
    String parentName = '',
    String parentContact = '',
  }) async {
    try {
      // Check if LRN already exists to prevent duplicates
      final existingCheck = await _db
          .collection('students')
          .where('lrn', isEqualTo: lrn.trim())
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
        'lrn': lrn.trim(),
        'gender': gender,
        'username': username.trim(),
        'birthday': birthday?.toIso8601String(),
        'parentName': parentName,
        'parentContact': parentContact,
        'enrolledAt': FieldValue.serverTimestamp(),
        'progress': {
          'overallProgress': 0.0,
          'totalCompleted': 0,
          'totalActivities': 100,
        },
        'profile': {
          'name': name,
          'gender': gender,
          'birthday': birthday?.toIso8601String(),
          'parentName': parentName,
          'parentContact': parentContact,
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
    return _db.collection('students').orderBy('enrolledAt', descending: true).snapshots();
  }

  /// Update student details (name, LRN).
  Future<void> updateStudent({
    required String studentId,
    required String name,
    required String lrn,
    String? gender,
    DateTime? birthday,
    String? parentName,
    String? parentContact,
  }) async {
    try {
      final updates = <String, dynamic>{
        'name': name,
        'lrn': lrn,
      };
      
      final profileUpdates = <String, dynamic>{
        'profile.name': name,
      };

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
}