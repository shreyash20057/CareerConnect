import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/extensions.dart';
import '../../../models/user_model.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ProfileProvider>().loadProfile(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final user = profileProv.user;
    final completion = profileProv.profileCompletionPercent;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: profileProv,
                  child: const EditProfileScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: profileProv.isLoading
          ? const LoadingWidget()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Profile Header Card ───────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          (user?.fullName.isNotEmpty == true
                                  ? user!.fullName[0]
                                  : auth.user?.email?[0] ?? 'U')
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.fullName ??
                            auth.user?.displayName ??
                            'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      if (user?.city != null || user?.state != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 13, color: Colors.white60),
                            const SizedBox(width: 4),
                            Text(
                              [user?.city, user?.state]
                                  .where((s) => s != null && s.isNotEmpty)
                                  .join(', '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Progress
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Profile strength',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '$completion%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: completion / 100,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Skills ────────────────────────────────────
                if (user?.skills.isNotEmpty == true)
                  _ProfileSection(
                    title: 'Skills',
                    icon: Icons.code_rounded,
                    onEdit: () {},
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user!.skills
                          .map((s) => _SkillBadge(skill: s))
                          .toList(),
                    ),
                  )
                else
                  _AddSection(
                    title: 'Add skills',
                    subtitle: 'Let employers know what you can do',
                    icon: Icons.code_rounded,
                    onTap: () {},
                  ),

                const SizedBox(height: 12),

                // ── Education ─────────────────────────────────
                if (user?.graduation != null)
                  _ProfileSection(
                    title: 'Education',
                    icon: Icons.school_outlined,
                    onEdit: () {},
                    child: _EducationEntry(graduation: user!.graduation!),
                  )
                else
                  _AddSection(
                    title: 'Add education',
                    subtitle: 'Degree, college, branch',
                    icon: Icons.school_outlined,
                    onTap: () {},
                  ),

                const SizedBox(height: 12),

                // ── Experience ────────────────────────────────
                if (user?.experiences.isNotEmpty == true)
                  _ProfileSection(
                    title: 'Experience',
                    icon: Icons.work_history_outlined,
                    onEdit: () {},
                    child: Column(
                      children: user!.experiences
                          .map((e) => _ExperienceEntry(exp: e))
                          .toList(),
                    ),
                  )
                else
                  _AddSection(
                    title: 'Add experience',
                    subtitle: 'Internships and work history',
                    icon: Icons.work_history_outlined,
                    onTap: () {},
                  ),

                const SizedBox(height: 12),

                // ── Projects ──────────────────────────────────
                if (user?.projects.isNotEmpty == true)
                  _ProfileSection(
                    title: 'Projects',
                    icon: Icons.rocket_launch_outlined,
                    onEdit: () {},
                    child: Column(
                      children: user!.projects
                          .map((p) => _ProjectEntry(project: p))
                          .toList(),
                    ),
                  )
                else
                  _AddSection(
                    title: 'Add projects',
                    subtitle: 'Showcase your work',
                    icon: Icons.rocket_launch_outlined,
                    onTap: () {},
                  ),

                const SizedBox(height: 12),

                // ── Certifications ────────────────────────────
                if (user?.certifications.isNotEmpty == true)
                  _ProfileSection(
                    title: 'Certifications',
                    icon: Icons.verified_outlined,
                    onEdit: () {},
                    child: Column(
                      children: user!.certifications
                          .map((c) => _CertEntry(cert: c))
                          .toList(),
                    ),
                  )
                else
                  _AddSection(
                    title: 'Add certifications',
                    subtitle: 'Courses, badges, and credentials',
                    icon: Icons.verified_outlined,
                    onTap: () {},
                  ),

                const SizedBox(height: 12),

                // ── Resume ────────────────────────────────────
                _ProfileSection(
                  title: 'Resume',
                  icon: Icons.description_outlined,
                  onEdit: () {},
                  child: user?.resumeUrl != null
                      ? Row(
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded,
                                color: AppTheme.error, size: 32),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Resume uploaded',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View'),
                            ),
                          ],
                        )
                      : _UploadResumeCTA(onTap: () {}),
                ),

                const SizedBox(height: 12),

                // ── Account Actions ───────────────────────────
                _ProfileSection(
                  title: 'Account',
                  icon: Icons.manage_accounts_outlined,
                  child: Column(
                    children: [
                      _ActionItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notification preferences',
                        onTap: () {},
                      ),
                      _ActionItem(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy settings',
                        onTap: () {},
                      ),
                      _ActionItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () {},
                      ),
                      _ActionItem(
                        icon: Icons.logout_rounded,
                        label: 'Sign out',
                        isDestructive: true,
                        onTap: () async {
                          await context.read<AuthProvider>().signOut();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

// ── Profile section widgets ────────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onEdit;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.child,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(Icons.edit_outlined,
                      size: 18, color: AppTheme.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AddSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AddSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.border, style: BorderStyle.solid),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline_rounded,
                color: AppTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SkillBadge extends StatelessWidget {
  final String skill;
  const _SkillBadge({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EducationEntry extends StatelessWidget {
  final EducationGraduation graduation;
  const _EducationEntry({required this.graduation});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school_rounded,
              color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${graduation.degree} — ${graduation.branch}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                graduation.college,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (graduation.cgpa.isNotEmpty) ...[
                    const Icon(Icons.grade_outlined,
                        size: 12, color: AppTheme.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      'CGPA: ${graduation.cgpa}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  if (graduation.passingYear.isNotEmpty) ...[
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppTheme.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      graduation.passingYear,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExperienceEntry extends StatelessWidget {
  final ExperienceModel exp;
  const _ExperienceEntry({required this.exp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.secondaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              exp.type == 'internship'
                  ? Icons.school_outlined
                  : Icons.business_outlined,
              color: AppTheme.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp.position,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  exp.organization,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: exp.type == 'internship'
                            ? AppTheme.secondaryLight
                            : AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        exp.type == 'internship' ? 'Internship' : 'Job',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: exp.type == 'internship'
                              ? AppTheme.secondary
                              : AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      exp.duration,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectEntry extends StatelessWidget {
  final ProjectModel project;
  const _ProjectEntry({required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                project.year,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            project.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: project.technologies.take(4).map((t) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  t,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CertEntry extends StatelessWidget {
  final CertificationModel cert;
  const _CertEntry({required this.cert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded,
              color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${cert.organization} • ${cert.date}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadResumeCTA extends StatelessWidget {
  final VoidCallback onTap;
  const _UploadResumeCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.border,
              style: BorderStyle.solid),
        ),
        child: const Column(
          children: [
            Icon(Icons.upload_file_rounded,
                color: AppTheme.textSecondary, size: 32),
            SizedBox(height: 8),
            Text(
              'Upload your resume',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'PDF, DOC up to 5MB',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        size: 20,
        color:
            isDestructive ? AppTheme.error : AppTheme.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color:
              isDestructive ? AppTheme.error : AppTheme.textPrimary,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppTheme.textTertiary),
      onTap: onTap,
    );
  }
}