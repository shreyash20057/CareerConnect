import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class InterviewPrepScreen extends StatelessWidget {
  const InterviewPrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _PrepCategory(
        title: 'Technical',
        subtitle: 'DSA, System Design, Core CS',
        icon: Icons.code_rounded,
        color: AppTheme.primary,
        bgColor: AppTheme.primaryLight,
        topics: ['Data Structures', 'Algorithms', 'System Design', 'DBMS', 'OS', 'Networking'],
      ),
      _PrepCategory(
        title: 'HR & Behavioral',
        subtitle: 'Introduction, Soft Skills',
        icon: Icons.people_outline_rounded,
        color: AppTheme.secondary,
        bgColor: AppTheme.secondaryLight,
        topics: ['Tell me about yourself', 'Strengths & Weaknesses', 'Career Goals', 'Teamwork', 'Conflict Resolution'],
      ),
      _PrepCategory(
        title: 'Aptitude',
        subtitle: 'Reasoning, Quant, Verbal',
        icon: Icons.psychology_outlined,
        color: AppTheme.warning,
        bgColor: AppTheme.warningLight,
        topics: ['Logical Reasoning', 'Quantitative Aptitude', 'Verbal Ability', 'Data Interpretation'],
      ),
      _PrepCategory(
        title: 'Domain Specific',
        subtitle: 'Based on your skills',
        icon: Icons.auto_awesome_outlined,
        color: const Color(0xFF6366F1),
        bgColor: const Color(0xFFEEF2FF),
        topics: ['Flutter', 'Python', 'React', 'Machine Learning', 'Cloud'],
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Interview Preparation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Ace your next interview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Comprehensive preparation for technical, HR, and aptitude rounds.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Preparation categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          ...categories.map((cat) => _CategoryCard(category: cat)),

          const SizedBox(height: 20),

          // Ask AI for prep
          GestureDetector(
            onTap: () => context.push('/chat'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.auto_awesome_rounded,
                      color: Color(0xFF6366F1), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Get personalized prep plan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ask the AI assistant to create a custom plan for your target role',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PrepCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final List<String> topics;

  const _PrepCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.topics,
  });
}

class _CategoryCard extends StatefulWidget {
  final _PrepCategory category;
  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.category.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.category.icon,
                      color: widget.category.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          widget.category.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.category.topics
                    .map(
                      (topic) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: widget.category.bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          topic,
                          style: TextStyle(
                            color: widget.category.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}