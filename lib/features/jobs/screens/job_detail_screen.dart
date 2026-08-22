import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../../applications/providers/applications_provider.dart';
import '../../saved/providers/saved_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../models/job_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cc_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/constants/app_constants.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;

  const JobDetailScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  JobModel? _job;
  bool _loadingJob = true;
  bool _applying = false;
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final job =
        await context.read<JobsProvider>().getJobById(widget.jobId);

    final alreadyApplied =
        await context.read<ApplicationsProvider>().isApplied(widget.jobId);

    if (mounted) {
      setState(() {
        _job = job;
        _applied = alreadyApplied;
        _loadingJob = false;
      });
    }
  }

  Future<void> _apply() async {
    if (_job == null) return;

    setState(() => _applying = true);

    final success =
        await context.read<ApplicationsProvider>().apply(_job!);

    if (mounted) {
      if (success) {
        setState(() => _applied = true);
        context.showSnackBar(
          'Application submitted successfully!',
        );
      } else {
        context.showSnackBar(
          'Already applied or an error occurred.',
          isError: true,
        );
      }

      setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingJob) {
      return const Scaffold(
        body: LoadingWidget(
          message: 'Loading opportunity...',
        ),
      );
    }

    if (_job == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Opportunity not found'),
        ),
      );
    }

    final job = _job!;
    final jobsProvider = context.read<JobsProvider>();
    final savedProvider = context.watch<SavedProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final breakdown = jobsProvider.getMatchBreakdown(job);
    final isSaved = savedProvider.isSaved(job.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              job.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? AppTheme.primary : null,
                ),
                onPressed: () => savedProvider.toggle(job),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _JobHeader(job: job),
                const SizedBox(height: 8),

                if (breakdown.total > 0)
                  _MatchBreakdownCard(
                    breakdown: breakdown,
                  ),

                if (breakdown.missingSkills.isNotEmpty)
                  _SkillGapCard(
                    matched: breakdown.matchedSkills,
                    missing: breakdown.missingSkills,
                  ),

                _Section(
                  title: 'About the role',
                  child: Text(
                    job.fullDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.7,
                    ),
                  ),
                ),

                if (job.responsibilities.isNotEmpty)
                  _Section(
                    title: 'Responsibilities',
                    child: Column(
                      children: job.responsibilities
                          .map((r) => _BulletRow(text: r))
                          .toList(),
                    ),
                  ),

                _Section(
                  title: 'Required skills',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.requiredSkills.map((s) {
                      final userHas = profileProvider.user?.skills
                              .map((us) => us.toLowerCase())
                              .contains(s.toLowerCase()) ??
                          false;

                      return _SkillChip(
                        skill: s,
                        userHas: userHas,
                      );
                    }).toList(),
                  ),
                ),

                if (job.eligibility.isNotEmpty)
                  _Section(
                    title: 'Eligibility',
                    child: Column(
                      children: job.eligibility
                          .map((e) => _CheckRow(text: e))
                          .toList(),
                    ),
                  ),

                _Section(
                  title: 'Job details',
                  child: _DetailsGrid(job: job),
                ),

                _CompanyMiniCard(job: job),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ApplyBar(
        applied: _applied,
        applying: _applying,
        onApply: _apply,
        onAskAI: () => context.push('/chat'),
        jobId: job.id,
      ),
    );
  }
}

class _JobHeader extends StatelessWidget {
  final JobModel job;

  const _JobHeader({
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CompanyLogo(
                name: job.companyName,
                size: 60,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () =>
                          context.push('/company/${job.companyId}'),
                      child: Text(
                        job.companyName,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DetailPill(
                icon: Icons.location_on_outlined,
                label: job.location,
              ),
              _DetailPill(
                icon: Icons.work_outline_rounded,
                label: job.workModeLabel,
                color: AppTheme.primary,
                bg: AppTheme.primaryLight,
              ),
              _DetailPill(
                icon: Icons.attach_money_rounded,
                label: job.compensation,
                color: AppTheme.secondary,
                bg: AppTheme.secondaryLight,
              ),
              _DetailPill(
                icon: Icons.schedule_rounded,
                label: job.daysUntilDeadline > 0
                    ? 'Closes in ${job.daysUntilDeadline}d'
                    : 'Deadline passed',
                color: job.daysUntilDeadline < 7
                    ? AppTheme.error
                    : AppTheme.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String name;
  final double size;

  const _CompanyLogo({
    required this.name,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'C',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.43,
          ),
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final Color? bg;

  const _DetailPill({
    required this.icon,
    required this.label,
    this.color,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg ?? AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? AppTheme.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchBreakdownCard extends StatelessWidget {
  final MatchBreakdown breakdown;

  const _MatchBreakdownCard({
    required this.breakdown,
  });

  Color get _color {
    if (breakdown.total >= 75) return AppTheme.success;
    if (breakdown.total >= 50) return AppTheme.warning;
    return AppTheme.textSecondary;
  }

  String get _label {
    if (breakdown.total >= 75) return 'Strong match';
    if (breakdown.total >= 50) return 'Good match';
    return 'Partial match';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: _color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '$_label — ${breakdown.total}% overall',
                style: TextStyle(
                  color: _color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: breakdown.total / 100,
              backgroundColor: AppTheme.surfaceVariant,
              valueColor:
                  AlwaysStoppedAnimation<Color>(_color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ScoreBox(
                label: 'Skills',
                value: breakdown.skillScore,
                max: (AppConstants.skillWeight * 100).round(),
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              _ScoreBox(
                label: 'Education',
                value: breakdown.educationScore,
                max:
                    (AppConstants.educationWeight * 100).round(),
                color: AppTheme.secondary,
              ),
              const SizedBox(width: 8),
              _ScoreBox(
                label: 'Experience',
                value: breakdown.experienceScore,
                max:
                    (AppConstants.experienceWeight * 100).round(),
                color: AppTheme.warning,
              ),
              const SizedBox(width: 8),
              _ScoreBox(
                label: 'Location',
                value: breakdown.locationScore,
                max:
                    (AppConstants.locationWeight * 100).round(),
                color: const Color(0xFF6366F1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;

  const _ScoreBox({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$value/$max',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillGapCard extends StatelessWidget {
  final List<String> matched;
  final List<String> missing;

  const _SkillGapCard({
    required this.matched,
    required this.missing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 18,
                color: AppTheme.textPrimary,
              ),
              SizedBox(width: 8),
              Text(
                'Skill gap analysis',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (matched.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'You have',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: matched
                  .map(
                    (s) => _GapChip(
                      label: s,
                      hasIt: true,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (missing.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Skills to develop',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: missing
                  .map(
                    (s) => _GapChip(
                      label: s,
                      hasIt: false,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => context.push('/chat'),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: Color(0xFF6366F1),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Get a learning plan from AI',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GapChip extends StatelessWidget {
  final String label;
  final bool hasIt;

  const _GapChip({
    required this.label,
    required this.hasIt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: hasIt
            ? AppTheme.successLight
            : AppTheme.errorLight,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasIt
                ? Icons.check_rounded
                : Icons.add_rounded,
            size: 12,
            color:
                hasIt ? AppTheme.success : AppTheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  hasIt ? AppTheme.success : AppTheme.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;

  const _BulletRow({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 5,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;

  const _CheckRow({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: AppTheme.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String skill;
  final bool userHas;

  const _SkillChip({
    required this.skill,
    required this.userHas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: userHas
            ? AppTheme.successLight
            : AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: userHas
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (userHas) ...[
            const Icon(
              Icons.check_rounded,
              size: 12,
              color: AppTheme.success,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            skill,
            style: TextStyle(
              color: userHas
                  ? AppTheme.success
                  : AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  final JobModel job;

  const _DetailsGrid({
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (
        Icons.work_outline_rounded,
        'Type',
        job.typeLabel,
      ),
      (
        Icons.location_on_outlined,
        'Location',
        job.location,
      ),
      (
        Icons.laptop_mac_outlined,
        'Work mode',
        job.workModeLabel,
      ),
      (
        Icons.attach_money_rounded,
        'Compensation',
        job.compensation,
      ),
      if (job.experience != null)
        (
          Icons.timeline_rounded,
          'Experience',
          job.experience!,
        ),
      if (job.education != null)
        (
          Icons.school_outlined,
          'Education',
          job.education!,
        ),
      (
        Icons.calendar_today_outlined,
        'Deadline',
        '${job.deadline.day}/${job.deadline.month}/${job.deadline.year}',
      ),
      (
        Icons.category_outlined,
        'Category',
        job.category,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    item.$1,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          item.$2,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          item.$3,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CompanyMiniCard extends StatelessWidget {
  final JobModel job;

  const _CompanyMiniCard({
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About the company',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _CompanyLogo(
                name: job.companyName,
                size: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.companyName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      job.location,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.push('/company/${job.companyId}'),
                child: const Text('View'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplyBar extends StatelessWidget {
  final bool applied;
  final bool applying;
  final VoidCallback onApply;
  final VoidCallback onAskAI;
  final String jobId;

  const _ApplyBar({
    required this.applied,
    required this.applying,
    required this.onApply,
    required this.onAskAI,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        28,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: applied
            ? Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.success,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Application submitted',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: CCButton(
                      label: 'Apply now',
                      onPressed:
                          applying ? null : onApply,
                      isLoading: applying,
                      icon: Icons.send_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── AI Job Preparation ──────────────────
                  GestureDetector(
                    onTap: () =>
                        context.push('/job-prep/$jobId'),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.warningLight,
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.warning
                              .withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: AppTheme.warning,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── Ask AI ──────────────────────────────
                  GestureDetector(
                    onTap: onAskAI,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFEEF2FF),
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6366F1)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF6366F1),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}