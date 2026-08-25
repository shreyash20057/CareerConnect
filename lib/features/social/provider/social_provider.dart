import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../models/social_post_model.dart';

class SocialProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SocialPostModel> _posts = [];
  bool _loading = true;
  bool _submitting = false;
  StreamSubscription? _sub;
  String? _error;

  List<SocialPostModel> get posts => _posts;
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;

  String? get _uid => _auth.currentUser?.uid;

  void startListening() {
    _sub?.cancel();
    _sub = _db
        .collection('social_posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snap) {
        if (snap.docs.isEmpty) {
          _posts = _samplePosts();
        } else {
          _posts = snap.docs
              .map((d) => SocialPostModel.fromFirestore(d))
              .toList();
        }
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _posts = _samplePosts();
        _loading = false;
        notifyListeners();
      },
    );
  }

  bool isLikedByMe(SocialPostModel post) {
    if (_uid == null) return false;
    return post.likedBy.contains(_uid);
  }

  Future<void> toggleLike(SocialPostModel post) async {
    if (_uid == null) return;
    final liked = isLikedByMe(post);

    // Optimistic update
    final idx = _posts.indexWhere((p) => p.id == post.id);
    if (idx != -1) {
      final newLikes = List<String>.from(post.likedBy);
      if (liked) {
        newLikes.remove(_uid);
      } else {
        newLikes.add(_uid!);
      }
      _posts[idx] = post.copyWith(likedBy: newLikes);
      notifyListeners();
    }

    // Firestore update
    try {
      await _db.collection('social_posts').doc(post.id).update({
        'likedBy': liked
            ? FieldValue.arrayRemove([_uid])
            : FieldValue.arrayUnion([_uid]),
      });
    } catch (_) {
      // revert on error
      if (idx != -1) {
        _posts[idx] = post;
        notifyListeners();
      }
    }
  }

  Future<bool> createPost({
    required String content,
    required PostType postType,
    String? jobTitle,
    String? jobId,
    List<String> tags = const [],
  }) async {
    if (_uid == null || content.trim().isEmpty) return false;
    _submitting = true;
    notifyListeners();

    try {
      final user = _auth.currentUser!;
      await _db.collection('social_posts').add({
        'authorId': _uid,
        'authorName': user.displayName ?? 'User',
        'authorPhotoUrl': user.photoURL,
        'authorType': PostAuthorType.student.name,
        'content': content.trim(),
        'postType': postType.name,
        'jobTitle': jobTitle,
        'jobId': jobId,
        'tags': tags,
        'likedBy': [],
        'commentCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to post. Try again.';
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final snap = await _db
          .collection('social_posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();
      return snap.docs
          .map((d) => CommentModel.fromFirestore(d))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> addComment(
      String postId, String content) async {
    if (_uid == null || content.trim().isEmpty) return false;
    try {
      final user = _auth.currentUser!;
      await _db
          .collection('social_posts')
          .doc(postId)
          .collection('comments')
          .add({
        'authorId': _uid,
        'authorName': user.displayName ?? 'User',
        'authorPhotoUrl': user.photoURL,
        'authorType': PostAuthorType.student.name,
        'content': content.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _db
          .collection('social_posts')
          .doc(postId)
          .update({
        'commentCount': FieldValue.increment(1),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  List<SocialPostModel> _samplePosts() {
    final now = DateTime.now();
    return [
      SocialPostModel(
        id: 'sp1',
        authorId: 'company_c1',
        authorName: 'TechCorp India',
        authorType: PostAuthorType.company,
        companyName: 'TechCorp India',
        content:
            '🚀 We are hiring Flutter Developers!\n\nLooking for passionate mobile developers to join our growing team in Bangalore.\n\n✅ 0–2 years experience\n✅ Hybrid work model\n✅ ₹6–10 LPA\n\nApply now through CareerConnect! #Flutter #Hiring #MobileDev',
        postType: PostType.jobPosting,
        jobTitle: 'Flutter Developer',
        jobId: 'j1',
        tags: ['Flutter', 'Hiring', 'MobileDev'],
        likedBy: ['u1', 'u2', 'u3'],
        commentCount: 8,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      SocialPostModel(
        id: 'sp2',
        authorId: 'student_u1',
        authorName: 'Rahul Sharma',
        authorType: PostAuthorType.student,
        content:
            '🎉 Excited to share that I just got selected for the ML Research Internship at Analytics Pro!\n\nThank you CareerConnect for the skill gap analysis that showed me exactly what to study. Prepared for 3 weeks and cleared the interview! 💪\n\n#Internship #MachineLearning #CareerWin',
        postType: PostType.achievement,
        tags: ['Internship', 'MachineLearning', 'CareerWin'],
        likedBy: ['u2', 'u3', 'c1', 'u4', 'u5'],
        commentCount: 12,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      SocialPostModel(
        id: 'sp3',
        authorId: 'company_c3',
        authorName: 'Analytics Pro',
        authorType: PostAuthorType.company,
        companyName: 'Analytics Pro',
        content:
            '💡 Interview tip from our hiring team:\n\nWe receive hundreds of applications. What makes a candidate stand out?\n\n1️⃣ A GitHub profile with real projects\n2️⃣ Quantified achievements ("improved model accuracy by 12%")\n3️⃣ Knowledge of our product before the interview\n4️⃣ Asking thoughtful questions\n\nGood luck to all applicants! #InterviewTips #Hiring',
        postType: PostType.tip,
        tags: ['InterviewTips', 'Hiring'],
        likedBy: ['u1', 'u2', 'u3', 'u4'],
        commentCount: 6,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      SocialPostModel(
        id: 'sp4',
        authorId: 'student_u2',
        authorName: 'Priya Patel',
        authorType: PostAuthorType.student,
        content:
            'Does anyone have tips for the TechCorp India technical interview?\n\nI applied for the Flutter Developer role and got a call. Nervous but excited! Any advice from people who have been through it? 🙏\n\n#TechInterview #Flutter #JobSearch',
        postType: PostType.general,
        tags: ['TechInterview', 'Flutter', 'JobSearch'],
        likedBy: ['u1', 'u3'],
        commentCount: 4,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      SocialPostModel(
        id: 'sp5',
        authorId: 'company_c2',
        authorName: 'StartupHub',
        authorType: PostAuthorType.company,
        companyName: 'StartupHub',
        content:
            '🌐 We are going fully remote!\n\nStartupHub is now hiring Backend Engineers and DevOps Engineers with a 100% remote work policy.\n\n📍 Work from anywhere in India\n💰 ₹8–15 LPA\n🚀 Fast-growing team\n\nCheck our open roles on CareerConnect. Link in bio!\n\n#Remote #BackendDev #DevOps #NowHiring',
        postType: PostType.jobPosting,
        jobTitle: 'Backend Engineer',
        jobId: 'j2',
        tags: ['Remote', 'BackendDev', 'DevOps', 'NowHiring'],
        likedBy: ['u1', 'u2', 'u3', 'u4', 'u5', 'u6'],
        commentCount: 15,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      SocialPostModel(
        id: 'sp6',
        authorId: 'student_u3',
        authorName: 'Aditya Kumar',
        authorType: PostAuthorType.student,
        content:
            '📚 Study tip for freshers preparing for placements:\n\nSpend 30 days like this:\n• Week 1–2: DSA basics (arrays, strings, linked lists)\n• Week 3: SQL + DBMS fundamentals\n• Week 4: 2 mock interviews + resume polish\n\nConsistency beats cramming every time! 💡\n\n#PlacementPrep #DSA #FresherTips',
        postType: PostType.tip,
        tags: ['PlacementPrep', 'DSA', 'FresherTips'],
        likedBy: ['u1', 'u4', 'u5'],
        commentCount: 9,
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
    ];
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}