import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../models/job_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cc_button.dart';

class JobPrepScreen extends StatefulWidget {
  final JobModel job;
  const JobPrepScreen({super.key, required this.job});

  @override
  State<JobPrepScreen> createState() => _JobPrepScreenState();
}

class _JobPrepScreenState extends State<JobPrepScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _aiService = AIService();

  PrepPlan? _plan;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _generatePlan();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = context.read<ProfileProvider>().user;
    final prompt = _buildPrompt(user);

    try {
      final reply = await _aiService.chat(
        userMessage: prompt,
        history: [],
        userProfile: user,
        selectedJob: widget.job,
      );
      final plan = _parsePlan(reply, widget.job);
      setState(() {
        _plan = plan;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _plan = _fallbackPlan(widget.job);
        _loading = false;
      });
    }
  }

  String _buildPrompt(user) {
    final skills = user?.skills.join(', ') ?? 'not specified';
    final missing = widget.job.requiredSkills
        .where((s) =>
            !(user?.skills
                    .map((us) => us.toLowerCase())
                    .contains(s.toLowerCase()) ??
                false))
        .join(', ');
    return '''
Create a detailed interview preparation plan for this job:
Title: ${widget.job.title}
Company: ${widget.job.companyName}
Required skills: ${widget.job.requiredSkills.join(', ')}
My skills: $skills
Skills I need to develop: ${missing.isEmpty ? 'none' : missing}

Give me:
1. TECHNICAL section: 5 specific technical topics to study, each with 2-3 sub-topics
2. HR section: 5 behavioral questions with brief answer strategies
3. APTITUDE section: 3 areas to practise with specific resources
4. TIMELINE section: A 2-week study plan, day by day in week 1 and week 2

Be specific to this role and company. Format clearly.
''';
  }

  PrepPlan _parsePlan(String raw, JobModel job) {
    // Use AI response as the technical section raw text
    // and provide structured fallback for other sections
    return PrepPlan(
      technicalRaw: raw,
      hrQuestions: [
        HRQuestion(
          question: 'Tell me about yourself.',
          strategy:
              'Open with your degree and branch, mention 2–3 relevant projects, then state why you want this role at ${job.companyName}.',
        ),
        HRQuestion(
          question: 'Why do you want to work at ${job.companyName}?',
          strategy:
              'Research ${job.companyName}\'s products and culture. Align your career goals with their mission.',
        ),
        HRQuestion(
          question:
              'Describe a challenging project you worked on.',
          strategy:
              'Use the STAR format. Focus on the technical problem, your approach, and measurable outcome.',
        ),
        HRQuestion(
          question: 'What are your strengths and weaknesses?',
          strategy:
              'Choose a strength that\'s directly relevant to this role. For weakness, pick a real one with a genuine improvement plan.',
        ),
        HRQuestion(
          question: 'Where do you see yourself in 3 years?',
          strategy:
              'Show ambition aligned with growth at ${job.companyName}. Mention skill development and leadership.',
        ),
      ],
      aptitudeTopics: [
        AptitudeTopic(
          title: 'Logical Reasoning',
          resource: 'IndiaBix — Logical Reasoning section',
          daily: '20 questions / day',
        ),
        AptitudeTopic(
          title: 'Quantitative Aptitude',
          resource: 'R.S. Aggarwal or Arun Sharma',
          daily: 'Chapters: Time & Work, Percentages, Profit & Loss',
        ),
        AptitudeTopic(
          title: 'Verbal Ability',
          resource: 'Magoosh Vocabulary + GRE wordlists',
          daily: '15 mins reading + 10 new words',
        ),
      ],
      timeline: _buildTimeline(job),
    );
  }

  PrepPlan _fallbackPlan(JobModel job) => _parsePlan('', job);

  List<TimelineDay> _buildTimeline(JobModel job) {
    final skills = job.requiredSkills;
    return [
      TimelineDay(
          label: 'Day 1–2',
          tasks: [
            'Review core concepts of ${skills.isNotEmpty ? skills[0] : 'primary skill'}',
            'Solve 10 easy LeetCode problems',
            'Research ${job.companyName} — products, culture, recent news',
          ]),
      TimelineDay(
          label: 'Day 3–4',
          tasks: [
            'Deep dive into ${skills.length > 1 ? skills[1] : 'secondary skill'}',
            'Practice 10 medium LeetCode problems',
            'Prepare STAR stories for 3 experiences',
          ]),
      TimelineDay(
          label: 'Day 5–6',
          tasks: [
            'System design fundamentals (if applicable)',
            'Review your projects — prepare 2-min walkthroughs',
            'Practice aptitude: 30 questions',
          ]),
      TimelineDay(
          label: 'Day 7',
          tasks: [
            'Mock interview with a friend or Pramp.com',
            'Review weak areas from mock',
            'Rest and light revision',
          ]),
      TimelineDay(
          label: 'Week 2 (Days 8–13)',
          tasks: [
            'Advanced ${skills.isNotEmpty ? skills[0] : 'skill'} — build a mini project',
            '2 mock interviews per day (technical + HR)',
            'Refine resume and LinkedIn',
            'Prepare 5 questions to ask the interviewer',
            'Review all notes',
            'Final mock + mental prep',
          ]),
      TimelineDay(
          label: 'Day of interview',
          tasks: [
            'Light review of key concepts only',
            'Prepare documents, verify meeting link',
            'Arrive/login 10 minutes early',
            'Stay calm — you\'ve prepared well',
          ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Interview Prep',
                style: TextStyle(fontSize: 16)),
            Text(
              widget.job.title,
              style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Technical'),
            Tab(text: 'HR'),
            Tab(text: 'Aptitude'),
            Tab(text: 'Timeline'),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabAlignment: TabAlignment.start,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      body: _loading
          ? _LoadingPrep()
          : TabBarView(
              controller: _tab,
              children: [
                _TechnicalTab(
                    raw: _plan?.technicalRaw ?? '',
                    job: widget.job),
                _HRTab(questions: _plan?.hrQuestions ?? []),
                _AptitudeTab(
                    topics: _plan?.aptitudeTopics ?? []),
                _TimelineTab(
                    days: _plan?.timeline ?? []),
              ],
            ),
    );
  }
}

// ── Data models ─────────────────────────────────────────────────────────

class PrepPlan {
  final String technicalRaw;
  final List<HRQuestion> hrQuestions;
  final List<AptitudeTopic> aptitudeTopics;
  final List<TimelineDay> timeline;

  const PrepPlan({
    required this.technicalRaw,
    required this.hrQuestions,
    required this.aptitudeTopics,
    required this.timeline,
  });
}

class HRQuestion {
  final String question;
  final String strategy;
  const HRQuestion(
      {required this.question, required this.strategy});
}

class AptitudeTopic {
  final String title;
  final String resource;
  final String daily;
  const AptitudeTopic(
      {required this.title,
      required this.resource,
      required this.daily});
}

class TimelineDay {
  final String label;
  final List<String> tasks;
  const TimelineDay({required this.label, required this.tasks});
}

// ── Tab widgets ──────────────────────────────────────────────────────────

class _LoadingPrep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppTheme.purpleGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 32),
          )
              .animate(
                  onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                  begin: 0.95,
                  end: 1.05,
                  duration: 1000.ms),
          const SizedBox(height: 20),
          const Text(
            'Generating your prep plan...',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Personalised for your profile and this role',
            style: TextStyle(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TechnicalTab extends StatelessWidget {
  final String raw;
  final JobModel job;

  const _TechnicalTab({required this.raw, required this.job});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Required skills grid
        _SectionCard(
          title: 'Skills to master for this role',
          icon: Icons.code_rounded,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.requiredSkills.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s,
                    style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // AI-generated raw advice
        if (raw.isNotEmpty)
          _SectionCard(
            title: 'AI preparation guide',
            icon: Icons.auto_awesome_rounded,
            child: Text(
              raw,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                height: 1.7,
              ),
            ),
          )
        else
          ..._defaultTechnicalTopics(job, scheme),

        const SizedBox(height: 12),
        _SectionCard(
          title: 'Recommended resources',
          icon: Icons.menu_book_rounded,
          child: Column(
            children: [
              _ResourceRow(
                icon: Icons.code_rounded,
                title: 'LeetCode',
                desc: 'DSA practice — start with Easy, then Medium',
                color: const Color(0xFFFFA116),
              ),
              _ResourceRow(
                icon: Icons.school_rounded,
                title: 'GeeksForGeeks',
                desc: 'Concept articles for every CS topic',
                color: AppTheme.secondary,
              ),
              _ResourceRow(
                icon: Icons.play_circle_rounded,
                title: 'YouTube / freeCodeCamp',
                desc: 'Free video courses for your required skills',
                color: AppTheme.error,
              ),
              _ResourceRow(
                icon: Icons.people_rounded,
                title: 'Pramp',
                desc: 'Free mock interviews with peers',
                color: const Color(0xFF6366F1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _defaultTechnicalTopics(
      JobModel job, ColorScheme scheme) {
    final topics = [
      (job.requiredSkills.isNotEmpty
          ? '${job.requiredSkills[0]} core concepts'
          : 'Core skill fundamentals'),
      'Data Structures & Algorithms',
      'System design basics (scalability, databases)',
      'REST APIs and HTTP fundamentals',
      'Version control with Git',
    ];
    return [
      _SectionCard(
        title: 'Key topics to study',
        icon: Icons.list_alt_rounded,
        child: Column(
          children: topics
              .map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.circle,
                            size: 6, color: scheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(t,
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant,
                              )),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    ];
  }
}

class _HRTab extends StatelessWidget {
  final List<HRQuestion> questions;
  const _HRTab({required this.questions});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'How to answer HR questions',
          icon: Icons.lightbulb_outline_rounded,
          child: Text(
            'Use the STAR method: Situation → Task → Action → Result. Keep answers under 2 minutes. Be specific with outcomes.',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...questions.asMap().entries.map((entry) {
          final i = entry.key;
          final q = entry.value;
          return _HRCard(question: q, index: i + 1)
              .animate()
              .fadeIn(
                  duration: 300.ms, delay: (i * 80).ms)
              .slideY(begin: 0.05, end: 0);
        }),
      ],
    );
  }
}

class _HRCard extends StatefulWidget {
  final HRQuestion question;
  final int index;
  const _HRCard({required this.question, required this.index});

  @override
  State<_HRCard> createState() => _HRCardState();
}

class _HRCardState extends State<_HRCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color:
                          scheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.question.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded,
                          size: 14, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text('Strategy',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.question.strategy,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
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

class _AptitudeTab extends StatelessWidget {
  final List<AptitudeTopic> topics;
  const _AptitudeTab({required this.topics});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [
      AppTheme.primary,
      AppTheme.warning,
      const Color(0xFF6366F1),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Why aptitude matters',
          icon: Icons.psychology_outlined,
          child: Text(
            'Most tech companies include aptitude rounds. 30 minutes of daily practice for 2 weeks is enough to clear most company cutoffs.',
            style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                height: 1.6),
          ),
        ),
        const SizedBox(height: 12),
        ...topics.asMap().entries.map((entry) {
          final i = entry.key;
          final t = entry.value;
          final color = colors[i % colors.length];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 90,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface)),
                        const SizedBox(height: 4),
                        Text('📚 ${t.resource}',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    scheme.onSurfaceVariant)),
                        const SizedBox(height: 2),
                        Text('⏱ ${t.daily}',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          )
              .animate()
              .fadeIn(
                  duration: 280.ms, delay: (i * 80).ms)
              .slideX(begin: 0.04, end: 0);
        }),
      ],
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final List<TimelineDay> days;
  const _TimelineTab({required this.days});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: '2-week preparation plan',
          icon: Icons.calendar_month_rounded,
          child: Text(
            'Follow this plan consistently. Adjust based on your current level — the goal is confidence, not perfection.',
            style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                height: 1.6),
          ),
        ),
        const SizedBox(height: 16),
        ...days.asMap().entries.map((entry) {
          final i = entry.key;
          final day = entry.value;
          final isLast = i == days.length - 1;
          return _TimelineRow(
            day: day,
            isLast: isLast,
            index: i,
          )
              .animate()
              .fadeIn(
                  duration: 280.ms, delay: (i * 60).ms)
              .slideX(begin: 0.04, end: 0);
        }),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineDay day;
  final bool isLast;
  final int index;

  const _TimelineRow(
      {required this.day,
      required this.isLast,
      required this.index});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color:
                            scheme.outline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outline),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    day.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...day.tasks.map((task) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_box_outline_blank_rounded,
                              size: 15,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task,
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      scheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard(
      {required this.title,
      required this.icon,
      required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: scheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _ResourceRow(
      {required this.icon,
      required this.title,
      required this.desc,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface)),
                Text(desc,
                    style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}