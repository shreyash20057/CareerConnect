import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/applications_provider.dart';
import '../../../models/application_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/extensions.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ApplicationsProvider>().startListening();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Applications'),
        automaticallyImplyLeading: false,
      ),
      body: provider.isLoading
          ? const LoadingWidget(message: 'Loading applications...')
          : provider.applications.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.assignment_outlined,
                  title: 'No applications yet',
                  subtitle:
                      'Start applying to jobs and internships. Your applications will appear here.',
                  actionLabel: 'Browse opportunities',
                  onAction: () => context.go('/jobs'),
                )
              : _ApplicationsList(applications: provider.applications),
    );
  }
}

class _ApplicationsList extends StatelessWidget {
  final List<ApplicationModel> applications;
  const _ApplicationsList({required this.applications});

  @override
  Widget build(BuildContext context) {
    // Group by status category
    final active = applications
        .where((a) =>
            a.status != ApplicationStatus.rejected &&
            a.status != ApplicationStatus.withdrawn)
        .toList();
    final closed = applications
        .where((a) =>
            a.status == ApplicationStatus.rejected ||
            a.status == ApplicationStatus.withdrawn)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats row
        _StatsRow(applications: applications),
        const SizedBox(height: 20),

        if (active.isNotEmpty) ...[
          _GroupHeader(
              label: 'Active (${active.length})',
              color: AppTheme.primary),
          const SizedBox(height: 10),
          ...active.map((a) => _ApplicationCard(application: a)),
          const SizedBox(height: 16),
        ],

        if (closed.isNotEmpty) ...[
          _GroupHeader(
              label: 'Closed (${closed.length})',
              color: AppTheme.textSecondary),
          const SizedBox(height: 10),
          ...closed.map((a) => _ApplicationCard(application: a)),
        ],
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<ApplicationModel> applications;
  const _StatsRow({required this.applications});

  @override
  Widget build(BuildContext context) {
    final total = applications.length;
    final interviews = applications
        .where((a) => a.status == ApplicationStatus.interview)
        .length;
    final shortlisted = applications
        .where((a) => a.status == ApplicationStatus.shortlisted)
        .length;
    final selected = applications
        .where((a) => a.status == ApplicationStatus.selected)
        .length;

    return Row(
      children: [
        _StatBox(label: 'Applied', value: total, color: AppTheme.primary),
        const SizedBox(width: 8),
        _StatBox(
            label: 'Shortlisted', value: shortlisted, color: AppTheme.warning),
        const SizedBox(width: 8),
        _StatBox(
            label: 'Interviews', value: interviews, color: const Color(0xFF6366F1)),
        const SizedBox(width: 8),
        _StatBox(label: 'Selected', value: selected, color: AppTheme.success),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _GroupHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(application.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      application.companyName.isNotEmpty
                          ? application.companyName[0].toUpperCase()
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
                        application.jobTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        application.companyName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusInfo.$2,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusInfo.$3, size: 12, color: statusInfo.$1),
                      const SizedBox(width: 4),
                      Text(
                        application.statusLabel,
                        style: TextStyle(
                          color: statusInfo.$1,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ApplicationTimeline(status: application.status),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 12, color: AppTheme.textTertiary),
                const SizedBox(width: 4),
                Text(
                  'Applied ${application.appliedAt.timeAgo}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const Spacer(),
                if (application.status != ApplicationStatus.withdrawn &&
                    application.status != ApplicationStatus.rejected)
                  TextButton(
                    onPressed: () async {
                      final confirm = await _confirmWithdraw(context);
                      if (confirm == true) {
                        await context
                            .read<ApplicationsProvider>()
                            .withdraw(application.id);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Withdraw',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmWithdraw(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: const Text(
            'This will withdraw your application. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) _statusInfo(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return (AppTheme.primary, AppTheme.primaryLight, Icons.send_rounded);
      case ApplicationStatus.underReview:
        return (AppTheme.warning, AppTheme.warningLight,
            Icons.hourglass_empty_rounded);
      case ApplicationStatus.shortlisted:
        return (AppTheme.secondary, AppTheme.secondaryLight,
            Icons.star_rounded);
      case ApplicationStatus.interview:
        return (const Color(0xFF6366F1), const Color(0xFFEEF2FF),
            Icons.videocam_rounded);
      case ApplicationStatus.selected:
        return (AppTheme.success, AppTheme.successLight,
            Icons.check_circle_rounded);
      case ApplicationStatus.rejected:
        return (AppTheme.error, AppTheme.errorLight, Icons.cancel_rounded);
      case ApplicationStatus.withdrawn:
        return (AppTheme.textSecondary, AppTheme.surfaceVariant,
            Icons.remove_circle_outline_rounded);
    }
  }
}

class _ApplicationTimeline extends StatelessWidget {
  final ApplicationStatus status;
  const _ApplicationTimeline({required this.status});

  static const _stages = [
    ApplicationStatus.applied,
    ApplicationStatus.underReview,
    ApplicationStatus.shortlisted,
    ApplicationStatus.interview,
    ApplicationStatus.selected,
  ];

  @override
  Widget build(BuildContext context) {
    if (status == ApplicationStatus.rejected ||
        status == ApplicationStatus.withdrawn) {
      return const SizedBox.shrink();
    }

    final currentIdx = _stages.indexOf(status);

    return Row(
      children: List.generate(_stages.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stageIdx = i ~/ 2;
          final isCompleted = stageIdx < currentIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? AppTheme.primary : AppTheme.border,
            ),
          );
        }
        // Stage dot
        final stageIdx = i ~/ 2;
        final isCompleted = stageIdx <= currentIdx;
        final isCurrent = stageIdx == currentIdx;

        return Container(
          width: isCurrent ? 12 : 8,
          height: isCurrent ? 12 : 8,
          decoration: BoxDecoration(
            color: isCompleted ? AppTheme.primary : AppTheme.border,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppTheme.primary, width: 2)
                : null,
          ),
        );
      }),
    );
  }
}