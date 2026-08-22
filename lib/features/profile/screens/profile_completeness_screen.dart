import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import 'add_project_screen.dart';
import 'add_experience_screen.dart';
import 'add_certification_screen.dart';
import 'resume_screen.dart';
import 'edit_profile_screen.dart';
import '../../../core/theme/app_theme.dart';

class ProfileCompletenessScreen extends StatelessWidget {
  const ProfileCompletenessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final user = profileProv.user;
    final completion = profileProv.profileCompletionPercent;

    final items = [
      _CompletenessItem(
        icon: Icons.person_rounded,
        label: 'Personal information',
        done: user?.fullName.isNotEmpty == true &&
            user?.city != null,
        description: 'Name, location, phone number',
        action: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: profileProv,
              child: const EditProfileScreen(),
            ),
          ),
        ),
      ),
      _CompletenessItem(
        icon: Icons.school_rounded,
        label: 'Education details',
        done: user?.graduation != null,
        description: 'Degree, college, branch, CGPA',
        action: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: profileProv,
              child: const EditProfileScreen(),
            ),
          ),
        ),
      ),
      _CompletenessItem(
        icon: Icons.code_rounded,
        label: 'Skills',
        done: (user?.skills.length ?? 0) >= 3,
        description: 'At least 3 relevant skills',
        action: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: profileProv,
              child: const EditProfileScreen(),
            ),
          ),
        ),
      ),
      _CompletenessItem(
        icon: Icons.rocket_launch_rounded,
        label: 'Projects',
        done: (user?.projects.length ?? 0) >= 1,
        description: 'At least 1 project',
        action: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: profileProv,
              child: const AddProjectScreen(),
            ),
          ),
        ),
      ),
      _CompletenessItem(
        icon: Icons.work_history_rounded,
        label: 'Experience',
        done: (user?.experiences.length ?? 0) >= 1,
        description: 'Internship or work experience',
        action: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: profileProv,
              child: const AddExperienceScreen(),
            ),
          ),
        ),
      ),
      _CompletenessItem(
        icon: Icons.verified_rounded,
        label: 'Certifications',
        done: (user?.certifications.length ?? 0) >= 1,
        description: 'At least 1 certification',
        action: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: profileProv,
              child: const AddCertificationScreen(),
            ),
          ),
        ),
      ),
      _CompletenessItem(
        icon: Icons.description_rounded,
        label: 'Resume',
        done: user?.resumeUrl != null,
        description: 'Upload your resume PDF',
        action: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: profileProv,
              child: const ResumeScreen(),
            ),
          ),
        ),
      ),
    ];

    final pending = items.where((i) => !i.done).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Profile strength')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Gauge ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1A56DB),
                  Color(0xFF3B82F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: completion / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '$completion%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'complete',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  pending == 0
                      ? 'Your profile is complete!'
                      : '$pending item${pending == 1 ? '' : 's'} remaining',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'A complete profile gets 3× more recruiter views',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Checklist',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          ...items.map((item) => _ChecklistCard(item: item)),
        ],
      ),
    );
  }
}

class _CompletenessItem {
  final IconData icon;
  final String label;
  final bool done;
  final String description;
  final VoidCallback action;

  const _CompletenessItem({
    required this.icon,
    required this.label,
    required this.done,
    required this.description,
    required this.action,
  });
}

class _ChecklistCard extends StatelessWidget {
  final _CompletenessItem item;
  const _ChecklistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.done ? null : item.action,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.done
                ? AppTheme.success.withOpacity(0.3)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.done
                    ? AppTheme.successLight
                    : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: item.done
                    ? AppTheme.success
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: item.done
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            item.done
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.success,
                    size: 22,
                  )
                : const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
          ],
        ),
      ),
    );
  }
}