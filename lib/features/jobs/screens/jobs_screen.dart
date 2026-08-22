import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../widgets/job_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedWorkMode = 'All';
  final _workModes = ['All', 'Remote', 'On-site', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().loadJobs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsProvider = context.watch<JobsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Opportunities'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Jobs'),
            Tab(text: 'Internships'),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _workModes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final mode = _workModes[index];
                final selected = _selectedWorkMode == mode;
                return FilterChip(
                  label: Text(mode),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedWorkMode = mode),
                  backgroundColor: AppTheme.surface,
                  selectedColor: AppTheme.primaryLight,
                  checkmarkColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: selected ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                      color: selected ? AppTheme.primary : AppTheme.border),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              },
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _JobsList(
                  jobs: jobsProvider.jobs,
                  isLoading: jobsProvider.isLoading,
                  provider: jobsProvider,
                ),
                _JobsList(
                  jobs: jobsProvider.internships,
                  isLoading: jobsProvider.isLoading,
                  provider: jobsProvider,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JobsList extends StatelessWidget {
  final List jobs;
  final bool isLoading;
  final JobsProvider provider;

  const _JobsList({
    required this.jobs,
    required this.isLoading,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const ShimmerList();

    if (jobs.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.work_off_rounded,
        title: 'No opportunities found',
        subtitle: 'Try adjusting your filters or check back later.',
        actionLabel: 'Refresh',
        onAction: () => provider.loadJobs(),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return JobCard(
          job: job,
          onTap: () => context.push('/job/${job.id}'),
          matchPercentage: provider.getMatchPercentage(job),
          onSave: () {},
        );
      },
    );
  }
}