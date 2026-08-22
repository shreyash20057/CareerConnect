import 'package:flutter/material.dart';
import '../../../models/job_model.dart';
import '../../../core/theme/app_theme.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;
  final int matchPercentage;
  final bool isCompact;
  final bool isSaved;
  final VoidCallback? onSave;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.matchPercentage = 0,
    this.isCompact = false,
    this.isSaved = false,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return isCompact ? _CompactCard(job: job, onTap: onTap, matchPercentage: matchPercentage) : _FullCard(job: job, onTap: onTap, matchPercentage: matchPercentage, isSaved: isSaved, onSave: onSave);
  }
}

class _FullCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;
  final int matchPercentage;
  final bool isSaved;
  final VoidCallback? onSave;

  const _FullCard({
    required this.job,
    this.onTap,
    required this.matchPercentage,
    required this.isSaved,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Company logo placeholder
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        job.companyName.isNotEmpty
                            ? job.companyName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.companyName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (matchPercentage > 0) ...[
                    const SizedBox(width: 8),
                    _MatchBadge(percentage: matchPercentage),
                  ],
                  if (onSave != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onSave,
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isSaved
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: job.location,
                  ),
                  _InfoChip(
                    icon: Icons.work_outline_rounded,
                    label: job.workModeLabel,
                  ),
                  _InfoChip(
                    icon: Icons.attach_money_rounded,
                    label: job.compensation,
                  ),
                ],
              ),
              if (job.requiredSkills.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: job.requiredSkills.take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: job.daysUntilDeadline < 7
                        ? AppTheme.error
                        : AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.daysUntilDeadline > 0
                        ? 'Closes in ${job.daysUntilDeadline} days'
                        : 'Deadline passed',
                    style: TextStyle(
                      fontSize: 11,
                      color: job.daysUntilDeadline < 7
                          ? AppTheme.error
                          : AppTheme.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: job.type == OpportunityType.job
                          ? AppTheme.primaryLight
                          : AppTheme.secondaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job.typeLabel,
                      style: TextStyle(
                        color: job.type == OpportunityType.job
                            ? AppTheme.primary
                            : AppTheme.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;
  final int matchPercentage;

  const _CompactCard({
    required this.job,
    this.onTap,
    required this.matchPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      job.companyName.isNotEmpty
                          ? job.companyName[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (matchPercentage > 0) _MatchBadge(percentage: matchPercentage),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              job.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              job.companyName,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: AppTheme.textTertiary),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    job.location,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final int percentage;
  const _MatchBadge({required this.percentage});

  Color get _color {
    if (percentage >= 75) return AppTheme.success;
    if (percentage >= 50) return AppTheme.warning;
    return AppTheme.textSecondary;
  }

  Color get _bgColor {
    if (percentage >= 75) return AppTheme.successLight;
    if (percentage >= 50) return AppTheme.warningLight;
    return AppTheme.surfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}