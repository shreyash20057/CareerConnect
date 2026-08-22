import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  applied,
  underReview,
  shortlisted,
  interview,
  selected,
  rejected,
  withdrawn,
}

class ApplicationModel {
  final String id;
  final String userId;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String? companyLogoUrl;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final String? notes;

  const ApplicationModel({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogoUrl,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
    this.notes,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      jobId: data['jobId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      companyName: data['companyName'] ?? '',
      companyLogoUrl: data['companyLogoUrl'],
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ApplicationStatus.applied,
      ),
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'companyLogoUrl': companyLogoUrl,
        'status': status.name,
        'appliedAt': Timestamp.fromDate(appliedAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'notes': notes,
      };

  String get statusLabel {
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.selected:
        return 'Selected';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}