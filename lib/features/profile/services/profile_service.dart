import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ── Photo Upload ───────────────────────────────────────────────
  Future<String?> uploadProfilePhoto({
    required void Function(double) onProgress,
  }) async {
    if (_uid == null) return null;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return null;

      final file = File(picked.path);
      final ref = _storage
          .ref()
          .child(AppConstants.profilePhotosPath)
          .child('$_uid.jpg');

      final task = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      task.snapshotEvents.listen((snap) {
        final progress =
            snap.bytesTransferred / snap.totalBytes;
        onProgress(progress);
      });

      await task;
      final url = await ref.getDownloadURL();

      await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .update({
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _auth.currentUser?.updatePhotoURL(url);
      return url;
    } catch (e) {
      return null;
    }
  }

  // ── Resume Upload ──────────────────────────────────────────────
  Future<ResumeUploadResult> uploadResume({
    required void Function(double) onProgress,
  }) async {
    if (_uid == null) {
      return ResumeUploadResult(success: false, error: 'Not authenticated');
    }
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );
      if (files.isEmpty) {
        return ResumeUploadResult(success: false, error: 'No file selected');
      }

      final file = File(files.first.path!);
      final fileName = files.first.name;
      final ext = fileName.split('.').last.toLowerCase();

      final ref = _storage
          .ref()
          .child(AppConstants.resumesPath)
          .child('${_uid}_resume.$ext');

      final task = ref.putFile(
        file,
        SettableMetadata(
          contentType: ext == 'pdf'
              ? 'application/pdf'
              : 'application/msword',
        ),
      );

      task.snapshotEvents.listen((snap) {
        final progress =
            snap.bytesTransferred / snap.totalBytes;
        onProgress(progress);
      });

      await task;
      final url = await ref.getDownloadURL();

      await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .update({
        'resumeUrl': url,
        'resumeFileName': fileName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return ResumeUploadResult(
          success: true, url: url, fileName: fileName);
    } catch (e) {
      return ResumeUploadResult(
          success: false, error: 'Upload failed: $e');
    }
  }

  // ── Projects ───────────────────────────────────────────────────
  Future<bool> addProject(ProjectModel project) async {
    if (_uid == null) return false;
    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .get();
      final data = doc.data() as Map<String, dynamic>;
      final projects = List<Map<String, dynamic>>.from(
          data['projects'] ?? []);
      projects.add(project.toMap());
      await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .update({
        'projects': projects,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProject(
      ProjectModel project, int index) async {
    if (_uid == null) return false;
    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .get();
      final data = doc.data() as Map<String, dynamic>;
      final projects = List<Map<String, dynamic>>.from(
          data['projects'] ?? []);
      if (index < projects.length) {
        projects[index] = project.toMap();
      }
      await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .update({
        'projects': projects,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProject(int index) async {
    if (_uid == null) return false;
    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .get();
      final data = doc.data() as Map<String, dynamic>;
      final projects = List<Map<String, dynamic>>.from(
          data['projects'] ?? []);
      if (index < projects.length) projects.removeAt(index);
      await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .update({
        'projects': projects,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Certifications ─────────────────────────────────────────────
  Future<bool> addCertification(CertificationModel cert) async {
    if (_uid == null) return false;
    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .get();
      final data = doc.data() as Map<String, dynamic>;
      final certs = List<Map<String, dynamic>>.from(
          data['certifications'] ?? []);
      certs.add(cert.toMap());
      await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .update({
        'certifications': certs,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCertification(int index) async {
    if (_uid == null) return false;
    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .get();
      final data = doc.data() as Map<String, dynamic>;
      final certs = List<Map<String, dynamic>>.from(
          data['certifications'] ?? []);
      if (index < certs.length) certs.removeAt(index);
      await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .update({
        'certifications': certs,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Experiences ────────────────────────────────────────────────
  Future<bool> addExperience(ExperienceModel exp) async {
    if (_uid == null) return false;
    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .get();
      final data = doc.data() as Map<String, dynamic>;
      final exps = List<Map<String, dynamic>>.from(
          data['experiences'] ?? []);
      exps.add(exp.toMap());
      await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .update({
        'experiences': exps,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteExperience(int index) async {
    if (_uid == null) return false;
    try {
      final doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .get();
      final data = doc.data() as Map<String, dynamic>;
      final exps = List<Map<String, dynamic>>.from(
          data['experiences'] ?? []);
      if (index < exps.length) exps.removeAt(index);
      await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .update({
        'experiences': exps,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Company Follow ─────────────────────────────────────────────
  Future<void> toggleFollowCompany(String companyId) async {
    if (_uid == null) return;
    final ref = _db
        .collection(AppConstants.usersCollection)
        .doc(_uid)
        .collection('following')
        .doc(companyId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'companyId': companyId,
        'followedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<bool> isFollowingCompany(String companyId) {
    if (_uid == null) return Stream.value(false);
    return _db
        .collection(AppConstants.usersCollection)
        .doc(_uid)
        .collection('following')
        .doc(companyId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}

class ResumeUploadResult {
  final bool success;
  final String? url;
  final String? fileName;
  final String? error;

  const ResumeUploadResult({
    required this.success,
    this.url,
    this.fileName,
    this.error,
  });
}