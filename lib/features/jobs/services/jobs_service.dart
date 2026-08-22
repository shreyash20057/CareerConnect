import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/job_model.dart';
import '../../../models/application_model.dart';
import '../../../core/constants/app_constants.dart';

class JobsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ── Applications ──────────────────────────────────────────────
  Future<bool> applyToJob(JobModel job) async {
    if (_uid == null) return false;
    try {
      // Check if already applied
      final existing = await _db
          .collection(AppConstants.applicationsCollection)
          .where('userId', isEqualTo: _uid)
          .where('jobId', isEqualTo: job.id)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) return false;

      await _db.collection(AppConstants.applicationsCollection).add({
        'userId': _uid,
        'jobId': job.id,
        'jobTitle': job.title,
        'companyName': job.companyName,
        'companyLogoUrl': job.companyLogoUrl,
        'status': ApplicationStatus.applied.name,
        'appliedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<List<ApplicationModel>> applicationStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection(AppConstants.applicationsCollection)
        .where('userId', isEqualTo: _uid)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ApplicationModel.fromFirestore(d))
            .toList());
  }

  Future<bool> withdrawApplication(String applicationId) async {
    try {
      await _db
          .collection(AppConstants.applicationsCollection)
          .doc(applicationId)
          .update({
        'status': ApplicationStatus.withdrawn.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isApplied(String jobId) async {
    if (_uid == null) return false;
    try {
      final q = await _db
          .collection(AppConstants.applicationsCollection)
          .where('userId', isEqualTo: _uid)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();
      return q.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ── Saved / Bookmarks ─────────────────────────────────────────
  Future<void> toggleSaved(JobModel job) async {
    if (_uid == null) return;
    final docRef = _db
        .collection(AppConstants.usersCollection)
        .doc(_uid)
        .collection('saved')
        .doc(job.id);
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'jobId': job.id,
        'jobTitle': job.title,
        'companyName': job.companyName,
        'companyLogoUrl': job.companyLogoUrl,
        'type': job.type.name,
        'location': job.location,
        'salary': job.salary,
        'stipend': job.stipend,
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<Set<String>> savedIdsStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection(AppConstants.usersCollection)
        .doc(_uid)
        .collection('saved')
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toSet());
  }

  Stream<List<Map<String, dynamic>>> savedJobsStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection(AppConstants.usersCollection)
        .doc(_uid)
        .collection('saved')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  // ── Companies ─────────────────────────────────────────────────
  Future<CompanyModel?> getCompany(String id) async {
    try {
      final doc = await _db
          .collection(AppConstants.companiesCollection)
          .doc(id)
          .get();
      if (doc.exists) return CompanyModel.fromFirestore(doc);
    } catch (_) {}
    return null;
  }

  Future<List<JobModel>> getJobsByCompany(String companyId) async {
    try {
      final snap = await _db
          .collection(AppConstants.jobsCollection)
          .where('companyId', isEqualTo: companyId)
          .where('isActive', isEqualTo: true)
          .get();
      return snap.docs.map((d) => JobModel.fromFirestore(d)).toList();
    } catch (_) {
      return [];
    }
  }
}