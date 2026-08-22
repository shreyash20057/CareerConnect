import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../services/jobs_service.dart';
import '../../profile/services/profile_service.dart';
import '../widgets/job_card.dart';
import '../../../models/job_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_widget.dart';

class CompanyDetailScreen extends StatefulWidget {
  final String companyId;
  const CompanyDetailScreen({super.key, required this.companyId});

  @override
  State<CompanyDetailScreen> createState() =>
      _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  final _service = JobsService();
  final _profileService = ProfileService();

  CompanyModel? _company;
  List<JobModel> _companyJobs = [];
  bool _loading = true;
  Stream<bool>? _followStream;

  static final _sampleCompanies = {
    'c1': CompanyModel(
      id: 'c1',
      name: 'TechCorp India',
      description: 'Building next-generation software products',
      industry: 'Software / Technology',
      website: 'https://techcorp.in',
      location: 'Bangalore, Karnataka',
      about:
          'TechCorp India is a fast-growing technology company building enterprise and consumer software products. Founded in 2015, we have grown to 500+ employees across 3 offices. We believe in building products that make a real difference in people\'s lives.',
      employeeCount: 500,
    ),
    'c2': CompanyModel(
      id: 'c2',
      name: 'StartupHub',
      description: 'Powering the next generation of startups',
      industry: 'SaaS / Cloud',
      website: 'https://startuphub.io',
      location: 'Hyderabad, Telangana',
      about:
          'StartupHub provides cloud infrastructure and developer tools for high-growth startups. We obsess over developer experience and reliability. Our platform powers over 10,000 applications globally.',
      employeeCount: 120,
    ),
    'c3': CompanyModel(
      id: 'c3',
      name: 'Analytics Pro',
      description: 'Data intelligence for modern businesses',
      industry: 'Data Science / AI',
      website: 'https://analyticspro.ai',
      location: 'Mumbai, Maharashtra',
      about:
          'Analytics Pro builds AI-powered analytics solutions for enterprise clients. Our ML platform processes billions of data points daily, helping businesses make smarter decisions faster.',
      employeeCount: 80,
    ),
  };

  @override
  void initState() {
    super.initState();
    _followStream =
        _profileService.isFollowingCompany(widget.companyId);
    _load();
  }

  Future<void> _load() async {
    CompanyModel? company =
        await _service.getCompany(widget.companyId);
    company ??= _sampleCompanies[widget.companyId];

    List<JobModel> jobs =
        await _service.getJobsByCompany(widget.companyId);
    if (jobs.isEmpty) {
      final provider = context.read<JobsProvider>();
      jobs = [...provider.jobs, ...provider.internships]
          .where((j) => j.companyId == widget.companyId)
          .toList();
    }

    if (mounted) {
      setState(() {
        _company = company;
        _companyJobs = jobs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: LoadingWidget());
    }

    if (_company == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Company')),
        body: const Center(child: Text('Company not found')),
      );
    }

    final company = _company!;
    final jobs = _companyJobs
        .where((j) => j.type == OpportunityType.job)
        .toList();
    final internships = _companyJobs
        .where((j) => j.type == OpportunityType.internship)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            actions: [
              StreamBuilder<bool>(
                stream: _followStream,
                builder: (context, snap) {
                  final following = snap.data ?? false;
                  return TextButton.icon(
                    onPressed: () => _profileService
                        .toggleFollowCompany(widget.companyId),
                    icon: Icon(
                      following
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      size: 18,
                      color: following
                          ? Colors.white
                          : Colors.white70,
                    ),
                    label: Text(
                      following ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: following
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.cardGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 56, 20, 20),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              company.name.isNotEmpty
                                  ? company.name[0]
                                      .toUpperCase()
                                  : 'C',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                company.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                company.industry,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Company Stats ─────────────────────────────
                Container(
                  color: AppTheme.surface,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      _CompanyStat(
                        icon: Icons.people_rounded,
                        label: 'Employees',
                        value: company.employeeCount != null
                            ? '${company.employeeCount}'
                            : 'N/A',
                      ),
                      const SizedBox(width: 1),
                      _CompanyStat(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: company.location.split(',').first,
                      ),
                      const SizedBox(width: 1),
                      _CompanyStat(
                        icon: Icons.work_outline_rounded,
                        label: 'Open roles',
                        value: '${_companyJobs.length}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── About ─────────────────────────────────────
                Container(
                  color: AppTheme.surface,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        company.about,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.7,
                        ),
                      ),
                      if (company.website != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(
                              Icons.language_rounded,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              company.website!,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Open Jobs ─────────────────────────────────
                if (jobs.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 10),
                    child: Text(
                      'Open positions (${jobs.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  ...jobs.map(
                    (job) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: JobCard(
                        job: job,
                        onTap: () =>
                            context.push('/job/${job.id}'),
                        matchPercentage: context
                            .read<JobsProvider>()
                            .getMatchPercentage(job),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // ── Internships ───────────────────────────────
                if (internships.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 8, 16, 10),
                    child: Text(
                      'Internships (${internships.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  ...internships.map(
                    (job) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: JobCard(
                        job: job,
                        onTap: () =>
                            context.push('/job/${job.id}'),
                        matchPercentage: context
                            .read<JobsProvider>()
                            .getMatchPercentage(job),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CompanyStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}