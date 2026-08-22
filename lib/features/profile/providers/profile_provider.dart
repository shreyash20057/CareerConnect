import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/app_constants.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      _error = 'Failed to load profile';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await loadProfile(uid);
      return true;
    } catch (e) {
      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeProfile(Map<String, dynamic> data) async {
    return updateProfile({...data, 'isProfileComplete': true});
  }

  int get profileCompletionPercent {
    if (_user == null) return 0;
    int score = 0;
    const total = 10;
    if (_user!.fullName.isNotEmpty) score++;
    if (_user!.phone != null) score++;
    if (_user!.city != null) score++;
    if (_user!.graduation != null) score++;
    if (_user!.skills.isNotEmpty) score++;
    if (_user!.projects.isNotEmpty) score++;
    if (_user!.certifications.isNotEmpty) score++;
    if (_user!.experiences.isNotEmpty) score++;
    if (_user!.resumeUrl != null) score++;
    if (_user!.preferences.desiredRoles.isNotEmpty) score++;
    return ((score / total) * 100).round();
  }
}