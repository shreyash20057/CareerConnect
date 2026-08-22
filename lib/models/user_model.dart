import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? photoUrl;
  final String? phone;
  final String? city;
  final String? state;
  final String? country;
  final DateTime? dateOfBirth;
  final String? preferredWorkLocation;
  final Education10th? education10th;
  final Education12th? education12th;
  final EducationGraduation? graduation;
  final EducationPostGraduation? postGraduation;
  final List<String> skills;
  final List<ProjectModel> projects;
  final List<CertificationModel> certifications;
  final List<ExperienceModel> experiences;
  final List<String> achievements;
  final String? resumeUrl;
  final UserPreferences preferences;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.photoUrl,
    this.phone,
    this.city,
    this.state,
    this.country,
    this.dateOfBirth,
    this.preferredWorkLocation,
    this.education10th,
    this.education12th,
    this.graduation,
    this.postGraduation,
    this.skills = const [],
    this.projects = const [],
    this.certifications = const [],
    this.experiences = const [],
    this.achievements = const [],
    this.resumeUrl,
    this.preferences = const UserPreferences(),
    this.isProfileComplete = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      photoUrl: data['photoUrl'],
      phone: data['phone'],
      city: data['city'],
      state: data['state'],
      country: data['country'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      preferredWorkLocation: data['preferredWorkLocation'],
      education10th: data['education10th'] != null
          ? Education10th.fromMap(data['education10th'])
          : null,
      education12th: data['education12th'] != null
          ? Education12th.fromMap(data['education12th'])
          : null,
      graduation: data['graduation'] != null
          ? EducationGraduation.fromMap(data['graduation'])
          : null,
      postGraduation: data['postGraduation'] != null
          ? EducationPostGraduation.fromMap(data['postGraduation'])
          : null,
      skills: List<String>.from(data['skills'] ?? []),
      projects: (data['projects'] as List<dynamic>? ?? [])
          .map((p) => ProjectModel.fromMap(p))
          .toList(),
      certifications: (data['certifications'] as List<dynamic>? ?? [])
          .map((c) => CertificationModel.fromMap(c))
          .toList(),
      experiences: (data['experiences'] as List<dynamic>? ?? [])
          .map((e) => ExperienceModel.fromMap(e))
          .toList(),
      achievements: List<String>.from(data['achievements'] ?? []),
      resumeUrl: data['resumeUrl'],
      preferences: data['preferences'] != null
          ? UserPreferences.fromMap(data['preferences'])
          : const UserPreferences(),
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'phone': phone,
      'city': city,
      'state': state,
      'country': country,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'preferredWorkLocation': preferredWorkLocation,
      'education10th': education10th?.toMap(),
      'education12th': education12th?.toMap(),
      'graduation': graduation?.toMap(),
      'postGraduation': postGraduation?.toMap(),
      'skills': skills,
      'projects': projects.map((p) => p.toMap()).toList(),
      'certifications': certifications.map((c) => c.toMap()).toList(),
      'experiences': experiences.map((e) => e.toMap()).toList(),
      'achievements': achievements,
      'resumeUrl': resumeUrl,
      'preferences': preferences.toMap(),
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? photoUrl,
    String? phone,
    String? city,
    String? state,
    String? country,
    DateTime? dateOfBirth,
    String? preferredWorkLocation,
    Education10th? education10th,
    Education12th? education12th,
    EducationGraduation? graduation,
    EducationPostGraduation? postGraduation,
    List<String>? skills,
    List<ProjectModel>? projects,
    List<CertificationModel>? certifications,
    List<ExperienceModel>? experiences,
    List<String>? achievements,
    String? resumeUrl,
    UserPreferences? preferences,
    bool? isProfileComplete,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      preferredWorkLocation:
          preferredWorkLocation ?? this.preferredWorkLocation,
      education10th: education10th ?? this.education10th,
      education12th: education12th ?? this.education12th,
      graduation: graduation ?? this.graduation,
      postGraduation: postGraduation ?? this.postGraduation,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      experiences: experiences ?? this.experiences,
      achievements: achievements ?? this.achievements,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      preferences: preferences ?? this.preferences,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class Education10th {
  final String board;
  final String school;
  final String passingYear;
  final String percentage;

  const Education10th({
    required this.board,
    required this.school,
    required this.passingYear,
    required this.percentage,
  });

  factory Education10th.fromMap(Map<String, dynamic> map) => Education10th(
        board: map['board'] ?? '',
        school: map['school'] ?? '',
        passingYear: map['passingYear'] ?? '',
        percentage: map['percentage'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'board': board,
        'school': school,
        'passingYear': passingYear,
        'percentage': percentage,
      };
}

class Education12th {
  final String board;
  final String school;
  final String stream;
  final String passingYear;
  final String percentage;

  const Education12th({
    required this.board,
    required this.school,
    required this.stream,
    required this.passingYear,
    required this.percentage,
  });

  factory Education12th.fromMap(Map<String, dynamic> map) => Education12th(
        board: map['board'] ?? '',
        school: map['school'] ?? '',
        stream: map['stream'] ?? '',
        passingYear: map['passingYear'] ?? '',
        percentage: map['percentage'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'board': board,
        'school': school,
        'stream': stream,
        'passingYear': passingYear,
        'percentage': percentage,
      };
}

class EducationGraduation {
  final String degree;
  final String college;
  final String branch;
  final String currentYear;
  final String passingYear;
  final String cgpa;

  const EducationGraduation({
    required this.degree,
    required this.college,
    required this.branch,
    required this.currentYear,
    required this.passingYear,
    required this.cgpa,
  });

  factory EducationGraduation.fromMap(Map<String, dynamic> map) =>
      EducationGraduation(
        degree: map['degree'] ?? '',
        college: map['college'] ?? '',
        branch: map['branch'] ?? '',
        currentYear: map['currentYear'] ?? '',
        passingYear: map['passingYear'] ?? '',
        cgpa: map['cgpa'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'degree': degree,
        'college': college,
        'branch': branch,
        'currentYear': currentYear,
        'passingYear': passingYear,
        'cgpa': cgpa,
      };
}

class EducationPostGraduation {
  final String degree;
  final String university;
  final String specialization;
  final String year;
  final String cgpa;

  const EducationPostGraduation({
    required this.degree,
    required this.university,
    required this.specialization,
    required this.year,
    required this.cgpa,
  });

  factory EducationPostGraduation.fromMap(Map<String, dynamic> map) =>
      EducationPostGraduation(
        degree: map['degree'] ?? '',
        university: map['university'] ?? '',
        specialization: map['specialization'] ?? '',
        year: map['year'] ?? '',
        cgpa: map['cgpa'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'degree': degree,
        'university': university,
        'specialization': specialization,
        'year': year,
        'cgpa': cgpa,
      };
}

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final List<String> technologies;
  final String role;
  final String? projectLink;
  final String? githubLink;
  final String year;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.technologies,
    required this.role,
    this.projectLink,
    this.githubLink,
    required this.year,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        technologies: List<String>.from(map['technologies'] ?? []),
        role: map['role'] ?? '',
        projectLink: map['projectLink'],
        githubLink: map['githubLink'],
        year: map['year'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'technologies': technologies,
        'role': role,
        'projectLink': projectLink,
        'githubLink': githubLink,
        'year': year,
      };
}

class CertificationModel {
  final String id;
  final String name;
  final String organization;
  final String date;
  final String? credentialLink;

  const CertificationModel({
    required this.id,
    required this.name,
    required this.organization,
    required this.date,
    this.credentialLink,
  });

  factory CertificationModel.fromMap(Map<String, dynamic> map) =>
      CertificationModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        organization: map['organization'] ?? '',
        date: map['date'] ?? '',
        credentialLink: map['credentialLink'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'organization': organization,
        'date': date,
        'credentialLink': credentialLink,
      };
}

class ExperienceModel {
  final String id;
  final String type; // 'internship' or 'job'
  final String organization;
  final String position;
  final String duration;
  final String responsibilities;

  const ExperienceModel({
    required this.id,
    required this.type,
    required this.organization,
    required this.position,
    required this.duration,
    required this.responsibilities,
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> map) => ExperienceModel(
        id: map['id'] ?? '',
        type: map['type'] ?? 'internship',
        organization: map['organization'] ?? '',
        position: map['position'] ?? '',
        duration: map['duration'] ?? '',
        responsibilities: map['responsibilities'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'organization': organization,
        'position': position,
        'duration': duration,
        'responsibilities': responsibilities,
      };
}

class UserPreferences {
  final List<String> desiredRoles;
  final List<String> preferredLocations;
  final String workMode; // remote, onsite, hybrid
  final String opportunityType; // internship, fulltime, both
  final String? expectedSalary;

  const UserPreferences({
    this.desiredRoles = const [],
    this.preferredLocations = const [],
    this.workMode = 'hybrid',
    this.opportunityType = 'both',
    this.expectedSalary,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) => UserPreferences(
        desiredRoles: List<String>.from(map['desiredRoles'] ?? []),
        preferredLocations: List<String>.from(map['preferredLocations'] ?? []),
        workMode: map['workMode'] ?? 'hybrid',
        opportunityType: map['opportunityType'] ?? 'both',
        expectedSalary: map['expectedSalary'],
      );

  Map<String, dynamic> toMap() => {
        'desiredRoles': desiredRoles,
        'preferredLocations': preferredLocations,
        'workMode': workMode,
        'opportunityType': opportunityType,
        'expectedSalary': expectedSalary,
      };
}