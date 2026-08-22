import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/job_model.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../services/jobs_service.dart';

class JobsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final JobsService _service = JobsService();

  List<JobModel> _jobs = [];
  List<JobModel> _internships = [];
  Set<String> _savedIds = {};
  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;

  List<JobModel> get jobs => _jobs;
  List<JobModel> get internships => _internships;
  Set<String> get savedIds => _savedIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  JobsService get service => _service;

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  void listenSaved() {
    _service.savedIdsStream().listen((ids) {
      _savedIds = ids;
      notifyListeners();
    });
  }

  bool isSaved(String jobId) => _savedIds.contains(jobId);

  Future<void> toggleSaved(JobModel job) async {
    await _service.toggleSaved(job);
  }

  Future<void> loadJobs({String? query, Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Query q = _firestore
          .collection(AppConstants.jobsCollection)
          .where('isActive', isEqualTo: true)
          .limit(AppConstants.pageSize);

      if (filters != null) {
        if (filters['type'] != null) {
          q = q.where('type', isEqualTo: filters['type']);
        }
        if (filters['workMode'] != null) {
          q = q.where('workMode', isEqualTo: filters['workMode']);
        }
      }

      final snapshot = await q.get();
      final all =
          snapshot.docs.map((d) => JobModel.fromFirestore(d)).toList();

      _jobs = all.where((j) => j.type == OpportunityType.job).toList();
      _internships =
          all.where((j) => j.type == OpportunityType.internship).toList();
    } catch (_) {
      _loadSampleData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    _jobs = [
      JobModel(
        id: 'j1',
        title: 'Flutter Developer',
        companyId: 'c1',
        companyName: 'TechCorp India',
        location: 'Bangalore, Karnataka',
        workMode: WorkMode.hybrid,
        type: OpportunityType.job,
        salary: '₹6–10 LPA',
        requiredSkills: ['Flutter', 'Dart', 'Firebase', 'REST API'],
        eligibility: ['B.Tech / B.E.', 'Any branch'],
        shortDescription: 'Build world-class Flutter apps for millions of users.',
        fullDescription:
            'We are looking for a skilled Flutter developer to join our growing mobile team. You will work on consumer-facing applications used by millions of users daily, collaborating closely with product and design teams.',
        responsibilities: [
          'Build and maintain Flutter applications',
          'Integrate REST APIs and Firebase services',
          'Collaborate with UI/UX designers',
          'Write unit and widget tests',
          'Participate in code reviews',
        ],
        experience: '0–2 years',
        education: 'B.Tech / B.E.',
        deadline: now.add(const Duration(days: 30)),
        isActive: true,
        category: 'Mobile Development',
        postedAt: now.subtract(const Duration(days: 3)),
      ),
      JobModel(
        id: 'j2',
        title: 'Backend Engineer',
        companyId: 'c2',
        companyName: 'StartupHub',
        location: 'Hyderabad, Telangana',
        workMode: WorkMode.remote,
        type: OpportunityType.job,
        salary: '₹8–14 LPA',
        requiredSkills: ['Node.js', 'MongoDB', 'AWS', 'Docker'],
        eligibility: ['B.Tech / B.E.', 'CS / IT preferred'],
        shortDescription: 'Build scalable backend systems for our growing platform.',
        fullDescription:
            'We need a backend engineer to design and implement robust APIs, microservices, and data pipelines for our rapidly scaling platform.',
        responsibilities: [
          'Design and implement REST APIs',
          'Optimize MongoDB queries and schemas',
          'Deploy and manage services on AWS',
          'Monitor system performance',
        ],
        experience: '1–3 years',
        education: 'B.Tech / B.E.',
        deadline: now.add(const Duration(days: 20)),
        isActive: true,
        category: 'Backend',
        postedAt: now.subtract(const Duration(days: 1)),
      ),
      JobModel(
        id: 'j3',
        title: 'Data Scientist',
        companyId: 'c3',
        companyName: 'Analytics Pro',
        location: 'Mumbai, Maharashtra',
        workMode: WorkMode.onsite,
        type: OpportunityType.job,
        salary: '₹10–18 LPA',
        requiredSkills: ['Python', 'Machine Learning', 'SQL', 'TensorFlow'],
        eligibility: ['B.Tech / M.Tech', 'CS / IT / Statistics'],
        shortDescription: 'Drive data-driven decisions with production ML models.',
        fullDescription:
            'Join our data science team to build predictive models, extract business insights, and create intelligent features for our product.',
        responsibilities: [
          'Build and deploy ML models to production',
          'Analyze large-scale datasets',
          'Build dashboards and visualizations',
          'Work with cross-functional teams',
        ],
        experience: '0–2 years',
        education: 'B.Tech / M.Tech',
        deadline: now.add(const Duration(days: 15)),
        isActive: true,
        category: 'Data Science',
        postedAt: now.subtract(const Duration(days: 5)),
      ),
      JobModel(
        id: 'j4',
        title: 'DevOps Engineer',
        companyId: 'c2',
        companyName: 'StartupHub',
        location: 'Remote',
        workMode: WorkMode.remote,
        type: OpportunityType.job,
        salary: '₹9–15 LPA',
        requiredSkills: ['Docker', 'Kubernetes', 'CI/CD', 'AWS', 'Linux'],
        eligibility: ['B.Tech / B.E.', 'Any branch'],
        shortDescription: 'Own our cloud infrastructure and deployment pipelines.',
        fullDescription:
            'We are looking for a DevOps engineer to own our infrastructure, streamline deployments, and ensure high availability across our services.',
        responsibilities: [
          'Build and maintain CI/CD pipelines',
          'Manage Kubernetes clusters',
          'Monitor infrastructure and respond to incidents',
          'Automate operational tasks',
        ],
        experience: '1–3 years',
        education: 'B.Tech / B.E.',
        deadline: now.add(const Duration(days: 18)),
        isActive: true,
        category: 'DevOps',
        postedAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    _internships = [
      JobModel(
        id: 'i1',
        title: 'React Developer Intern',
        companyId: 'c1',
        companyName: 'TechCorp India',
        location: 'Bangalore, Karnataka',
        workMode: WorkMode.hybrid,
        type: OpportunityType.internship,
        stipend: '₹15,000/month',
        requiredSkills: ['React', 'JavaScript', 'HTML', 'CSS'],
        eligibility: ['Any graduation', 'CS / IT preferred'],
        shortDescription: 'Build real-world React features used by actual users.',
        fullDescription:
            'As a React intern, you will work directly on our production web application, implementing new features and fixing bugs alongside senior engineers.',
        responsibilities: [
          'Build React components from Figma designs',
          'Integrate REST APIs',
          'Write unit tests',
          'Participate in daily standups',
        ],
        experience: 'Fresher',
        education: 'Any graduation',
        deadline: now.add(const Duration(days: 10)),
        isActive: true,
        category: 'Web Development',
        postedAt: now.subtract(const Duration(days: 2)),
      ),
      JobModel(
        id: 'i2',
        title: 'ML Research Intern',
        companyId: 'c3',
        companyName: 'Analytics Pro',
        location: 'Remote',
        workMode: WorkMode.remote,
        type: OpportunityType.internship,
        stipend: '₹20,000/month',
        requiredSkills: ['Python', 'NumPy', 'Pandas', 'scikit-learn'],
        eligibility: ['B.Tech / M.Tech', 'CS / IT / Statistics'],
        shortDescription: 'Research and prototype ML algorithms with our science team.',
        fullDescription:
            'Work with our research team on novel machine learning problems. You will implement papers, run experiments, and report findings.',
        responsibilities: [
          'Implement and evaluate ML algorithms',
          'Run experiments on real datasets',
          'Write internal research reports',
          'Present findings to the team',
        ],
        experience: 'Fresher',
        education: 'B.Tech / M.Tech',
        deadline: now.add(const Duration(days: 25)),
        isActive: true,
        category: 'Data Science',
        postedAt: now.subtract(const Duration(days: 4)),
      ),
      JobModel(
        id: 'i3',
        title: 'Cloud Engineering Intern',
        companyId: 'c2',
        companyName: 'StartupHub',
        location: 'Hyderabad, Telangana',
        workMode: WorkMode.hybrid,
        type: OpportunityType.internship,
        stipend: '₹18,000/month',
        requiredSkills: ['AWS', 'Linux', 'Python', 'Git'],
        eligibility: ['B.Tech / B.E.', 'Any branch'],
        shortDescription: 'Get hands-on with real cloud infrastructure.',
        fullDescription:
            'Learn and contribute to our cloud infrastructure. You will work with AWS services, automate tasks, and support the DevOps team.',
        responsibilities: [
          'Set up and configure AWS services',
          'Write automation scripts in Python',
          'Monitor infrastructure dashboards',
          'Document cloud procedures',
        ],
        experience: 'Fresher',
        education: 'B.Tech / B.E.',
        deadline: now.add(const Duration(days: 12)),
        isActive: true,
        category: 'Cloud',
        postedAt: now.subtract(const Duration(days: 6)),
      ),
    ];
  }

  int getMatchPercentage(JobModel job) {
    if (_currentUser == null) return 0;
    return _calculateMatch(_currentUser!, job);
  }

  MatchBreakdown getMatchBreakdown(JobModel job) {
    if (_currentUser == null) {
      return MatchBreakdown(
          total: 0, skillScore: 0, educationScore: 0,
          experienceScore: 0, locationScore: 0,
          matchedSkills: [], missingSkills: []);
    }
    return _buildBreakdown(_currentUser!, job);
  }

  int _calculateMatch(UserModel user, JobModel job) {
    return _buildBreakdown(user, job).total;
  }

  MatchBreakdown _buildBreakdown(UserModel user, JobModel job) {
    final userSkillsLower = user.skills.map((s) => s.toLowerCase()).toSet();
    final requiredLower =
        job.requiredSkills.map((s) => s.toLowerCase()).toSet();

    final matched = userSkillsLower.intersection(requiredLower);
    final missing = requiredLower.difference(userSkillsLower);

    double skillScore = 0;
    if (requiredLower.isNotEmpty) {
      skillScore = (matched.length / requiredLower.length) *
          AppConstants.skillWeight *
          100;
    }

    double educationScore = user.graduation != null
        ? AppConstants.educationWeight * 100
        : 0;

    double experienceScore = user.experiences.isNotEmpty
        ? AppConstants.experienceWeight * 100
        : 0;

    double locationScore = 0;
    if (user.city != null &&
        job.location.toLowerCase().contains(user.city!.toLowerCase())) {
      locationScore = AppConstants.locationWeight * 100;
    }

    final total = (skillScore + educationScore + experienceScore + locationScore)
        .round()
        .clamp(0, 100);

    // Map back to display names
    final matchedDisplay = job.requiredSkills
        .where((s) => userSkillsLower.contains(s.toLowerCase()))
        .toList();
    final missingDisplay = job.requiredSkills
        .where((s) => !userSkillsLower.contains(s.toLowerCase()))
        .toList();

    return MatchBreakdown(
      total: total,
      skillScore: skillScore.round(),
      educationScore: educationScore.round(),
      experienceScore: experienceScore.round(),
      locationScore: locationScore.round(),
      matchedSkills: matchedDisplay,
      missingSkills: missingDisplay,
    );
  }

  List<String> getSkillGap(UserModel user, JobModel job) {
    final userSkillsLower = user.skills.map((s) => s.toLowerCase()).toSet();
    return job.requiredSkills
        .where((s) => !userSkillsLower.contains(s.toLowerCase()))
        .toList();
  }

  Future<JobModel?> getJobById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.jobsCollection)
          .doc(id)
          .get();
      if (doc.exists) return JobModel.fromFirestore(doc);
    } catch (_) {}
    final all = [..._jobs, ..._internships];
    try {
      return all.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }
}

class MatchBreakdown {
  final int total;
  final int skillScore;
  final int educationScore;
  final int experienceScore;
  final int locationScore;
  final List<String> matchedSkills;
  final List<String> missingSkills;

  const MatchBreakdown({
    required this.total,
    required this.skillScore,
    required this.educationScore,
    required this.experienceScore,
    required this.locationScore,
    required this.matchedSkills,
    required this.missingSkills,
  });
}