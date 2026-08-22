import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/profile/screens/profile_setup_screen.dart';
import '../../features/home/screens/main_shell_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/jobs/screens/jobs_screen.dart';
import '../../features/jobs/screens/job_detail_screen.dart';
import '../../features/jobs/screens/search_screen.dart';
import '../../features/applications/screens/applications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/jobs/screens/company_detail_screen.dart';
import '../../features/jobs/screens/saved_screen.dart';
import '../../features/interview/screens/interview_prep_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_completeness_screen.dart';
import '../../features/profile/screens/resume_screen.dart';
import '../../features/profile/screens/add_project_screen.dart';
import '../../features/profile/screens/add_experience_screen.dart';
import '../../features/profile/screens/add_certification_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

// Phase 4 additions
import '../../features/applications/screens/deadline_calendar_screen.dart';
import '../../features/chat/screens/job_prep_screen.dart';
import '../../features/chat/screens/resume_feedback_screen.dart';
import '../../features/jobs/providers/jobs_provider.dart';
import '../../core/widgets/loading_widget.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter({required this.authProvider});

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isProfileComplete = authProvider.isProfileComplete;
      final location = state.uri.toString();

      final authRoutes = [
        '/login',
        '/register',
        '/forgot-password',
        '/onboarding',
      ];

      if (location == '/splash') return null;

      if (!isLoggedIn) {
        if (authRoutes.contains(location)) return null;
        return '/onboarding';
      }

      if (isLoggedIn && !isProfileComplete) {
        if (location == '/profile-setup') return null;
        return '/profile-setup';
      }

      if (isLoggedIn &&
          isProfileComplete &&
          (authRoutes.contains(location) ||
              location == '/profile-setup')) {
        return '/home';
      }

      return null;
    },

    routes: [
      // ── Auth ─────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (c, s) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (c, s) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (c, s) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (c, s) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (c, s) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (c, s) => const ProfileSetupScreen(),
      ),

      // ── Shell (bottom nav) ───────────────────────────────
      ShellRoute(
        builder: (c, s, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (c, s) => const HomeScreen(),
          ),
          GoRoute(
            path: '/jobs',
            builder: (c, s) => const JobsScreen(),
          ),
          GoRoute(
            path: '/applications',
            builder: (c, s) => const ApplicationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (c, s) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Jobs ──────────────────────────────────────────────
      GoRoute(
        path: '/job/:id',
        builder: (c, s) => JobDetailScreen(
          jobId: s.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/company/:id',
        builder: (c, s) => CompanyDetailScreen(
          companyId: s.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (c, s) => const SearchScreen(),
      ),
      GoRoute(
        path: '/saved',
        builder: (c, s) => const SavedScreen(),
      ),

      // ── Features ──────────────────────────────────────────
      GoRoute(
        path: '/chat',
        builder: (c, s) => const ChatScreen(),
      ),
      GoRoute(
        path: '/interview-prep',
        builder: (c, s) => const InterviewPrepScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (c, s) => const NotificationsScreen(),
      ),

      // ── Phase 4 additions ────────────────────────────────
      GoRoute(
        path: '/deadline-calendar',
        builder: (c, s) => const DeadlineCalendarScreen(),
      ),
      GoRoute(
        path: '/resume-feedback',
        builder: (c, s) => const ResumeFeedbackScreen(),
      ),
      GoRoute(
        path: '/job-prep/:id',
        builder: (c, s) {
          return _JobPrepWrapper(
            jobId: s.pathParameters['id']!,
          );
        },
      ),

      // ── Profile ───────────────────────────────────────────
      GoRoute(
        path: '/profile-completeness',
        builder: (c, s) => const ProfileCompletenessScreen(),
      ),
      GoRoute(
        path: '/resume',
        builder: (c, s) => const ResumeScreen(),
      ),
      GoRoute(
        path: '/add-project',
        builder: (c, s) => const AddProjectScreen(),
      ),
      GoRoute(
        path: '/add-experience',
        builder: (c, s) => const AddExperienceScreen(),
      ),
      GoRoute(
        path: '/add-certification',
        builder: (c, s) => const AddCertificationScreen(),
      ),

      // ── Settings ──────────────────────────────────────────
      GoRoute(
        path: '/settings',
        builder: (c, s) => const SettingsScreen(),
      ),
    ],
  );
}

// ── Job Preparation Wrapper ────────────────────────────────
class _JobPrepWrapper extends StatefulWidget {
  final String jobId;

  const _JobPrepWrapper({
    required this.jobId,
  });

  @override
  State<_JobPrepWrapper> createState() => _JobPrepWrapperState();
}

class _JobPrepWrapperState extends State<_JobPrepWrapper> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await context.read<JobsProvider>().getJobById(widget.jobId);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsProvider>();

    final all = [
      ...jobs.jobs,
      ...jobs.internships,
    ];

    try {
      final job = all.firstWhere(
        (j) => j.id == widget.jobId,
      );

      return JobPrepScreen(job: job);
    } catch (_) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }
  }
}