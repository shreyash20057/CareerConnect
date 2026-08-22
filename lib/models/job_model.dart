import 'package:cloud_firestore/cloud_firestore.dart';

enum OpportunityType { job, internship }

enum WorkMode { remote, onsite, hybrid }

class JobModel {
  final String id;
  final String title;
  final String companyId;
  final String companyName;
  final String? companyLogoUrl;
  final String location;
  final WorkMode workMode;
  final OpportunityType type;
  final String? salary;
  final String? stipend;
  final List<String> requiredSkills;
  final List<String> eligibility;
  final String shortDescription;
  final String fullDescription;
  final List<String> responsibilities;
  final String? experience;
  final String? education;
  final DateTime deadline;
  final bool isActive;
  final String category;
  final DateTime postedAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.companyId,
    required this.companyName,
    this.companyLogoUrl,
    required this.location,
    required this.workMode,
    required this.type,
    this.salary,
    this.stipend,
    required this.requiredSkills,
    required this.eligibility,
    required this.shortDescription,
    required this.fullDescription,
    required this.responsibilities,
    this.experience,
    this.education,
    required this.deadline,
    required this.isActive,
    required this.category,
    required this.postedAt,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      id: doc.id,
      title: data['title'] ?? '',
      companyId: data['companyId'] ?? '',
      companyName: data['companyName'] ?? '',
      companyLogoUrl: data['companyLogoUrl'],
      location: data['location'] ?? '',
      workMode: WorkMode.values.firstWhere(
        (m) => m.name == data['workMode'],
        orElse: () => WorkMode.onsite,
      ),
      type: OpportunityType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => OpportunityType.job,
      ),
      salary: data['salary'],
      stipend: data['stipend'],
      requiredSkills: List<String>.from(data['requiredSkills'] ?? []),
      eligibility: List<String>.from(data['eligibility'] ?? []),
      shortDescription: data['shortDescription'] ?? '',
      fullDescription: data['fullDescription'] ?? '',
      responsibilities: List<String>.from(data['responsibilities'] ?? []),
      experience: data['experience'],
      education: data['education'],
      deadline: (data['deadline'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      category: data['category'] ?? '',
      postedAt: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get workModeLabel {
    switch (workMode) {
      case WorkMode.remote:
        return 'Remote';
      case WorkMode.onsite:
        return 'On-site';
      case WorkMode.hybrid:
        return 'Hybrid';
    }
  }

  String get typeLabel =>
      type == OpportunityType.job ? 'Full-time' : 'Internship';

  String get compensation => type == OpportunityType.job
      ? (salary ?? 'Not disclosed')
      : (stipend ?? 'Not disclosed');

  bool get isDeadlinePassed => deadline.isBefore(DateTime.now());

  int get daysUntilDeadline => deadline.difference(DateTime.now()).inDays;
}

class CompanyModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String description;
  final String industry;
  final String? website;
  final String location;
  final String about;
  final int? employeeCount;
  final DateTime? foundedYear;

  const CompanyModel({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.description,
    required this.industry,
    this.website,
    required this.location,
    required this.about,
    this.employeeCount,
    this.foundedYear,
  });

  factory CompanyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CompanyModel(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'],
      description: data['description'] ?? '',
      industry: data['industry'] ?? '',
      website: data['website'],
      location: data['location'] ?? '',
      about: data['about'] ?? '',
      employeeCount: data['employeeCount'],
      foundedYear: (data['foundedYear'] as Timestamp?)?.toDate(),
    );
  }
}