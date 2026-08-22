import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../jobs/providers/jobs_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../jobs/widgets/job_card.dart';
import '../../jobs/widgets/skill_recommendations_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().loadJobs();
      context.read<NotificationsProvider>().startListening();
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ProfileProvider>().loadProfile(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobs = context.watch<JobsProvider>();
    final profile = context.watch<ProfileProvider>();
    final notifs = context.watch<NotificationsProvider>();
    final name =
        profile.user?.fullName.split(' ').first ??
            auth.user?.displayName?.split(' ').first ??
            'there';
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest
          .withOpacity(0.3),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<JobsProvider>().loadJobs(),
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────
            SliverToBoxAdapter(
              child: _HomeHeader(
                name: name,
                unreadCount: notifs.unreadCount,
              ).animate().fadeIn(duration: 400.ms),
            ),

            // ── Quick actions ───────────────────────────
            SliverToBoxAdapter(
              child: _QuickActions()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms),
            ),

            // ── Profile completeness ────────────────────
            SliverToBoxAdapter(
              child: _ProfileCompletenessCard(
                      profile: profile)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms),
            ),

            // ── Recommended jobs ────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Recommended for you',
                onSeeAll: () => context.go('/jobs'),
              ),
            ),

            jobs.isLoading
                ? const SliverToBoxAdapter(
                    child: _JobsShimmer())
                : jobs.jobs.isEmpty
                    ? const SliverToBoxAdapter(
                        child: _EmptyJobs())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final job = jobs.jobs[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16),
                              child: JobCard(
                                job: job,
                                onTap: () => context
                                    .push('/job/${job.id}'),
                                matchPercentage: jobs
                                    .getMatchPercentage(job),
                                isSaved: context
                                    .read<JobsProvider>()
                                    .isSaved(job.id),
                              ),
                            ).animate().fadeIn(
                                duration: 300.ms,
                                delay: (index * 60).ms);
                          },
                          childCount:
                              jobs.jobs.take(4).length,
                        ),
                      ),

            // ── Skill recommendations ───────────────────
            const SliverToBoxAdapter(
              child: SkillRecommendationsWidget(),
            ),

            // ── Latest internships ──────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Latest internships',
                onSeeAll: () => context.go('/jobs'),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 190,
                child: jobs.isLoading
                    ? const _HorizontalShimmer()
                    : jobs.internships.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16),
                            itemCount: jobs.internships
                                .take(6)
                                .length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final job =
                                  jobs.internships[index];
                              return JobCard(
                                job: job,
                                isCompact: true,
                                onTap: () => context
                                    .push('/job/${job.id}'),
                                matchPercentage: jobs
                                    .getMatchPercentage(job),
                              );
                            },
                          ),
              ),
            ),

            // ── AI + Interview CTAs ─────────────────────
            SliverToBoxAdapter(
              child: _CTAGrid()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String name;
  final int unreadCount;

  const _HomeHeader(
      {required this.name, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: AppColors.cardGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text('Hello, $name 👋',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            )),
                        const SizedBox(height: 4),
                        const Text('Find your dream role',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            )),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.push('/notifications'),
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 9
                                      ? '9+'
                                      : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () =>
                        context.push('/saved'),
                    icon: const Icon(
                      Icons.bookmark_border_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => context.push('/search'),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: AppTheme.textSecondary,
                          size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Search jobs, skills, companies...',
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final actions = [
      _QA('Jobs', Icons.work_rounded, AppTheme.primary,
          () => context.go('/jobs')),
      _QA('Internships', Icons.school_rounded, AppTheme.secondary,
          () => context.go('/jobs')),
      _QA('AI Chat', Icons.auto_awesome_rounded,
          const Color(0xFF6366F1), () => context.push('/chat')),
      _QA('Calendar', Icons.calendar_month_rounded,
          AppTheme.warning,
          () => context.push('/deadline-calendar')),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: actions.map((a) {
          return Expanded(
            child: GestureDetector(
              onTap: a.onTap,
              child: Container(
                margin:
                    EdgeInsets.only(right: a == actions.last ? 0 : 8),
                padding: const EdgeInsets.symmetric(
                    vertical: 12),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outline),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: a.color.withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Icon(a.icon,
                          size: 18, color: a.color),
                    ),
                    const SizedBox(height: 6),
                    Text(a.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QA {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QA(this.label, this.icon, this.color, this.onTap);
}

class _ProfileCompletenessCard extends StatelessWidget {
  final ProfileProvider profile;

  const _ProfileCompletenessCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final pct = profile.profileCompletionPercent;
    if (pct >= 100) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: () => context.push('/profile-completeness'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outline),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: pct / 100,
                      strokeWidth: 4,
                      backgroundColor: scheme.outline,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                              scheme.primary),
                    ),
                    Text('$pct%',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text('Complete your profile',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        )),
                    Text('Get 3× more recruiter views',
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _CTAGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          _CTACard(
            gradient: AppTheme.purpleGradient,
            icon: Icons.auto_awesome_rounded,
            title: 'AI Career Assistant',
            subtitle:
                'Personalized guidance, interview prep, and career advice',
            onTap: () => context.push('/chat'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SmallCTA(
                  color: AppTheme.warning,
                  icon: Icons.psychology_rounded,
                  title: 'Interview Prep',
                  onTap: () =>
                      context.push('/interview-prep'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallCTA(
                  color: AppTheme.secondary,
                  icon: Icons.description_rounded,
                  title: 'Resume Review',
                  onTap: () =>
                      context.push('/resume-feedback'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CTACard extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CTACard(
      {required this.gradient,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallCTA extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SmallCTA(
      {required this.color,
      required this.icon,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: color.withOpacity(0.25), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleMedium),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
              ),
              child: const Row(
                children: [
                  Text('See all',
                      style: TextStyle(fontSize: 13)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 11),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _JobsShimmer extends StatelessWidget {
  const _JobsShimmer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 120,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms),
        ),
      ),
    );
  }
}

class _HorizontalShimmer extends StatelessWidget {
  const _HorizontalShimmer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Container(
        width: 200,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1200.ms),
    );
  }
}

class _EmptyJobs extends StatelessWidget {
  const _EmptyJobs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          'No opportunities yet.\nPull down to refresh.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}