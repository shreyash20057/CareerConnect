import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { general, jobPosting, internshipPosting, achievement, tip }

enum PostAuthorType { student, company, admin }

class SocialPostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final PostAuthorType authorType;
  final String? companyName;
  final String content;
  final PostType postType;
  final String? jobTitle;
  final String? jobId;
  final List<String> tags;
  final List<String> likedBy;
  final int commentCount;
  final DateTime createdAt;
  final List<String>? imageUrls;

  const SocialPostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.authorType,
    this.companyName,
    required this.content,
    required this.postType,
    this.jobTitle,
    this.jobId,
    this.tags = const [],
    this.likedBy = const [],
    this.commentCount = 0,
    required this.createdAt,
    this.imageUrls,
  });

  bool get isLikedBy =>
      likedBy.isNotEmpty; // checked per user in provider

  factory SocialPostModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SocialPostModel(
      id: doc.id,
      authorId: d['authorId'] ?? '',
      authorName: d['authorName'] ?? '',
      authorPhotoUrl: d['authorPhotoUrl'],
      authorType: PostAuthorType.values.firstWhere(
        (t) => t.name == d['authorType'],
        orElse: () => PostAuthorType.student,
      ),
      companyName: d['companyName'],
      content: d['content'] ?? '',
      postType: PostType.values.firstWhere(
        (t) => t.name == d['postType'],
        orElse: () => PostType.general,
      ),
      jobTitle: d['jobTitle'],
      jobId: d['jobId'],
      tags: List<String>.from(d['tags'] ?? []),
      likedBy: List<String>.from(d['likedBy'] ?? []),
      commentCount: d['commentCount'] ?? 0,
      createdAt:
          (d['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      imageUrls: d['imageUrls'] != null
          ? List<String>.from(d['imageUrls'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'authorId': authorId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'authorType': authorType.name,
        'companyName': companyName,
        'content': content,
        'postType': postType.name,
        'jobTitle': jobTitle,
        'jobId': jobId,
        'tags': tags,
        'likedBy': likedBy,
        'commentCount': commentCount,
        'createdAt': Timestamp.fromDate(createdAt),
        'imageUrls': imageUrls,
      };

  SocialPostModel copyWith({List<String>? likedBy}) {
    return SocialPostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      authorType: authorType,
      companyName: companyName,
      content: content,
      postType: postType,
      jobTitle: jobTitle,
      jobId: jobId,
      tags: tags,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount,
      createdAt: createdAt,
      imageUrls: imageUrls,
    );
  }
}

class CommentModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final PostAuthorType authorType;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.authorType,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      authorId: d['authorId'] ?? '',
      authorName: d['authorName'] ?? '',
      authorPhotoUrl: d['authorPhotoUrl'],
      authorType: PostAuthorType.values.firstWhere(
        (t) => t.name == d['authorType'],
        orElse: () => PostAuthorType.student,
      ),
      content: d['content'] ?? '',
      createdAt:
          (d['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'authorId': authorId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'authorType': authorType.name,
        'content': content,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}