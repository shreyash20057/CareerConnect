import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  newMatch,
  applicationUpdate,
  deadline,
  profileTip,
  interview,
  general,
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final String? actionId; // jobId, applicationId, etc.
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.actionId,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == d['type'],
        orElse: () => NotificationType.general,
      ),
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      isRead: d['isRead'] ?? false,
      actionId: d['actionId'],
      createdAt:
          (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'type': type.name,
        'title': title,
        'body': body,
        'isRead': isRead,
        'actionId': actionId,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}