import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../core/theme/app_theme.dart';

class SkillRecommendationsWidget extends StatelessWidget {
  const SkillRecommendationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final jobs = context.watch<JobsProvider>();
    final user = profile.user;
    if (user == null) return const SizedBox.shrink();

    final recs = _buildRecommendations(
        user.skills, [...jobs.jobs, ...jobs.internships]);
    if (recs.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Icon(Icons.trending_up_rounded,
                  size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text('Skills to boost your matches',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/chat'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                ),
                child: const Text('Get plan',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recs.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final rec = recs[i];
              return _SkillRecCard(rec: rec, index: i);
            },
          ),
        ),
      ],
    );
  }

  List<_SkillRec> _buildRecommendations(
      List<String> userSkills, List allJobs) {
    final freq = <String, int>{};
    final userLower =
        userSkills.map((s) => s.toLowerCase()).toSet();

    for (final job in allJobs) {
      for (final skill in job.requiredSkills) {
        if (!userLower.contains(skill.toLowerCase())) {
          freq[skill] = (freq[skill] ?? 0) + 1;
        }
      }
    }

    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(8).map((e) {
      return _SkillRec(
        skill: e.key,
        jobCount: e.value,
        color: _colorForSkill(e.key),
      );
    }).toList();
  }

  Color _colorForSkill(String skill) {
    final s = skill.toLowerCase();
    if (s.contains('python') ||
        s.contains('ml') ||
        s.contains('ai')) return AppTheme.secondary;
    if (s.contains('react') ||
        s.contains('flutter') ||
        s.contains('vue')) return AppTheme.primary;
    if (s.contains('aws') ||
        s.contains('cloud') ||
        s.contains('docker')) return AppTheme.warning;
    if (s.contains('sql') ||
        s.contains('mongo') ||
        s.contains('database')) return const Color(0xFF6366F1);
    return AppTheme.textSecondary;
  }
}

class _SkillRec {
  final String skill;
  final int jobCount;
  final Color color;

  const _SkillRec(
      {required this.skill,
      required this.jobCount,
      required this.color});
}

class _SkillRecCard extends StatelessWidget {
  final _SkillRec rec;
  final int index;

  const _SkillRecCard(
      {required this.rec, required this.index});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push('/chat'),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: rec.color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rec.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_circle_outline_rounded,
                  size: 18, color: rec.color),
            ),
            const Spacer(),
            Text(rec.skill,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${rec.jobCount} jobs need this',
                style: TextStyle(
                  fontSize: 10,
                  color: rec.color,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      )
          .animate()
          .fadeIn(
              duration: 300.ms,
              delay: (index * 60).ms)
          .slideX(begin: 0.06, end: 0),
    );
  }
}