import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/notification_model.dart';
import '../../../core/constants/app_constants.dart';

class NotificationsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<NotificationModel> _notifications = [];
  StreamSubscription? _sub;
  bool _loading = true;

  List<NotificationModel> get notifications => _notifications;
  bool get loading => _loading;
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  void startListening() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _sub?.cancel();
    _sub = _db
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snap) {
        if (snap.docs.isEmpty) {
          _notifications = _sampleNotifications(uid);
        } else {
          _notifications = snap.docs
              .map((d) => NotificationModel.fromFirestore(d))
              .toList();
        }
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        final uid2 = _auth.currentUser?.uid ?? '';
        _notifications = _sampleNotifications(uid2);
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markRead(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db
          .collection(AppConstants.notificationsCollection)
          .doc(id)
          .update({'isRead': true});
    } catch (_) {
      // offline — update locally
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = NotificationModel(
          id: _notifications[idx].id,
          userId: _notifications[idx].userId,
          type: _notifications[idx].type,
          title: _notifications[idx].title,
          body: _notifications[idx].body,
          isRead: true,
          actionId: _notifications[idx].actionId,
          createdAt: _notifications[idx].createdAt,
        );
        notifyListeners();
      }
    }
  }

  Future<void> markAllRead() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final unread =
        _notifications.where((n) => !n.isRead).toList();
    for (final n in unread) {
      await markRead(n.id);
    }
  }

  List<NotificationModel> _sampleNotifications(String uid) {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'n1',
        userId: uid,
        type: NotificationType.newMatch,
        title: '5 new jobs match your profile',
        body:
            'Flutter Developer, React Native Engineer and 3 more opportunities match your skills.',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'n2',
        userId: uid,
        type: NotificationType.applicationUpdate,
        title: 'Application shortlisted!',
        body:
            'TechCorp India moved your Flutter Developer application to Shortlisted.',
        isRead: false,
        actionId: 'j1',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 'n3',
        userId: uid,
        type: NotificationType.deadline,
        title: 'Deadline approaching',
        body:
            'React Developer Intern at TechCorp India closes in 2 days.',
        isRead: false,
        actionId: 'i1',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NotificationModel(
        id: 'n4',
        userId: uid,
        type: NotificationType.interview,
        title: 'Interview scheduled',
        body:
            'StartupHub has scheduled a technical interview for next Wednesday at 11 AM.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      NotificationModel(
        id: 'n5',
        userId: uid,
        type: NotificationType.profileTip,
        title: 'Boost your profile visibility',
        body:
            'Add at least one project to get 40% more recruiter views.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}