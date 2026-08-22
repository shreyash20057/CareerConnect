import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cc_button.dart';

class ResumeFeedbackScreen extends StatefulWidget {
  const ResumeFeedbackScreen({super.key});

  @override
  State<ResumeFeedbackScreen> createState() =>
      _ResumeFeedbackScreenState();
}

class _ResumeFeedbackScreenState
    extends State<ResumeFeedbackScreen> {
  final _aiService = AIService();
  List<ResumeTip>? _tips;
  bool _loading = false;
  int _overallScore = 0;

  Future<void> _analyse() async {
    setState(() => _loading = true);

    final user = context.read<ProfileProvider>().user;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final prompt = '''
Analyse this student's profile and give resume feedback:

Name: ${user.fullName}
Education: ${user.graduation?.degree ?? 'N/A'} from ${user.graduation?.college ?? 'N/A'}, CGPA: ${user.graduation?.cgpa ?? 'N/A'}
Skills: ${user.skills.join(', ')}
Projects: ${user.projects.map((p) => p.name).join(', ')}
Certifications: ${user.certifications.map((c) => c.name).join(', ')}
Experience: ${user.experiences.map((e) => '${e.position} at ${e.organization}').join(', ')}

Give:
1. Overall score out of 100
2. 3 STRENGTHS of their profile
3. 4 specific IMPROVEMENTS with action steps
4. 2 MISSING sections that would strengthen the resume

Be specific and actionable.
''';

    try {
      final reply = await _aiService.chat(
        userMessage: prompt,
        history: [],
        userProfile: user,
      );
      final parsed = _parseResponse(reply, user);
      setState(() {
        _tips = parsed;
        _overallScore =
            _computeScore(user);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _tips = _fallbackTips(user);
        _overallScore = _computeScore(user);
        _loading = false;
      });
    }
  }

  int _computeScore(user) {
    int score = 40;
    if ((user.fullName?.isNotEmpty ?? false)) score += 5;
    if (user.graduation != null) score += 10;
    if (user.skills.length >= 5) score += 10;
    if (user.projects.isNotEmpty) score += 10;
    if (user.certifications.isNotEmpty) score += 8;
    if (user.experiences.isNotEmpty) score += 12;
    if (user.resumeUrl != null) score += 5;
    return score.clamp(0, 100);
  }

  List<ResumeTip> _parseResponse(String raw, user) =>
      _fallbackTips(user);

  List<ResumeTip> _fallbackTips(user) {
    final tips = <ResumeTip>[];
    final u = user;

    if (u.experiences.isEmpty) {
      tips.add(ResumeTip(
        type: TipType.improvement,
        title: 'Add work experience',
        body:
            'Even a short internship significantly boosts resume credibility. Look for virtual/remote internships on Internshala or LinkedIn.',
        priority: 1,
      ));
    }

    if (u.projects.isEmpty) {
      tips.add(ResumeTip(
        type: TipType.improvement,
        title: 'Showcase projects',
        body:
            'Build 2–3 projects using your key skills. Host them on GitHub and deploy them. Projects are proof of capability.',
        priority: 1,
      ));
    }

    if (u.certifications.isEmpty) {
      tips.add(ResumeTip(
        type: TipType.missing,
        title: 'Certifications section missing',
        body:
            'Google, AWS, and NPTEL offer free certifications. Even one certification signals initiative to recruiters.',
        priority: 2,
      ));
    }

    if (u.skills.length < 5) {
      tips.add(ResumeTip(
        type: TipType.improvement,
        title: 'Expand your skills list',
        body:
            'List at least 8–10 relevant skills. Include tools, frameworks, and soft skills relevant to your target role.',
        priority: 2,
      ));
    }

    if (u.graduation != null) {
      tips.add(ResumeTip(
        type: TipType.strength,
        title: 'Education is well-structured',
        body:
            'Your degree information is clear. Make sure to highlight CGPA if above 7.5, and mention relevant coursework.',
        priority: 3,
      ));
    }

    if (u.skills.length >= 5) {
      tips.add(ResumeTip(
        type: TipType.strength,
        title: 'Good technical skill breadth',
        body:
            'You have a solid range of technical skills. Organise them by category (Languages, Frameworks, Tools) on your resume.',
        priority: 3,
      ));
    }

    tips.add(ResumeTip(
      type: TipType.improvement,
      title: 'Quantify your achievements',
      body:
          'Replace vague descriptions with numbers. "Improved app load time by 35%" is far more compelling than "improved performance".',
      priority: 2,
    ));

    tips.add(ResumeTip(
      type: TipType.missing,
      title: 'Add a LinkedIn / GitHub link',
      body:
          'Put your LinkedIn and GitHub URLs at the top of your resume. Recruiters check these immediately.',
      priority: 2,
    ));

    return tips;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = context.watch<ProfileProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Resume AI feedback')),
      body: user == null
          ? const Center(
              child: Text('Please complete your profile first'))
          : _tips == null
              ? _InitialView(onAnalyse: _analyse, loading: _loading)
              : _ResultView(
                  tips: _tips!,
                  score: _overallScore,
                  onRedo: _analyse,
                  loading: _loading,
                ),
    );
  }
}

class _InitialView extends StatelessWidget {
  final VoidCallback onAnalyse;
  final bool loading;

  const _InitialView(
      {required this.onAnalyse, required this.loading});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppTheme.purpleGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 48),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scaleXY(begin: 0.8, end: 1.0),
          const SizedBox(height: 28),
          Text(
            'AI Resume Review',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Get personalised feedback on your profile — strengths, gaps, and exactly what to fix.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          CCButton(
            label: 'Analyse my profile',
            onPressed: loading ? null : onAnalyse,
            isLoading: loading,
            icon: Icons.auto_awesome_rounded,
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final List<ResumeTip> tips;
  final int score;
  final VoidCallback onRedo;
  final bool loading;

  const _ResultView(
      {required this.tips,
      required this.score,
      required this.onRedo,
      required this.loading});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strengths =
        tips.where((t) => t.type == TipType.strength).toList();
    final improvements =
        tips.where((t) => t.type == TipType.improvement).toList();
    final missing =
        tips.where((t) => t.type == TipType.missing).toList();

    final scoreColor = score >= 75
        ? AppTheme.success
        : score >= 50
            ? AppTheme.warning
            : AppTheme.error;
    final scoreLabel = score >= 75
        ? 'Strong'
        : score >= 50
            ? 'Good'
            : 'Needs work';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Score card
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outline),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor:
                          scoreColor.withOpacity(0.15),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                              scoreColor),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$score',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: scoreColor,
                            )),
                        Text('/100',
                            style: TextStyle(
                              fontSize: 9,
                              color: scheme.onSurfaceVariant,
                            )),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scaleXY(begin: 0.7, end: 1.0),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile score: $scoreLabel',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on your skills, education, projects, and experience.',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: loading ? null : onRedo,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded,
                              size: 14),
                          SizedBox(width: 4),
                          Text('Re-analyse',
                              style:
                                  TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        if (strengths.isNotEmpty) ...[
          _GroupHeader(
              label: 'Strengths (${strengths.length})',
              color: AppTheme.success,
              icon: Icons.thumb_up_rounded),
          const SizedBox(height: 10),
          ...strengths.asMap().entries.map((e) =>
              _TipCard(tip: e.value, index: e.key)),
          const SizedBox(height: 16),
        ],

        if (improvements.isNotEmpty) ...[
          _GroupHeader(
              label:
                  'Improvements (${improvements.length})',
              color: AppTheme.warning,
              icon: Icons.trending_up_rounded),
          const SizedBox(height: 10),
          ...improvements.asMap().entries.map((e) =>
              _TipCard(tip: e.value, index: e.key)),
          const SizedBox(height: 16),
        ],

        if (missing.isNotEmpty) ...[
          _GroupHeader(
              label: 'Missing (${missing.length})',
              color: AppTheme.error,
              icon: Icons.add_circle_outline_rounded),
          const SizedBox(height: 10),
          ...missing.asMap().entries.map(
              (e) => _TipCard(tip: e.value, index: e.key)),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _GroupHeader(
      {required this.label,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            )),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final ResumeTip tip;
  final int index;

  const _TipCard({required this.tip, required this.index});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = tip.type == TipType.strength
        ? AppTheme.success
        : tip.type == TipType.improvement
            ? AppTheme.warning
            : AppTheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(tip.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      )),
                  const SizedBox(height: 4),
                  Text(tip.body,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 280.ms, delay: (index * 70).ms)
        .slideX(begin: 0.04, end: 0);
  }
}

enum TipType { strength, improvement, missing }

class ResumeTip {
  final TipType type;
  final String title;
  final String body;
  final int priority;

  const ResumeTip(
      {required this.type,
      required this.title,
      required this.body,
      required this.priority});
}