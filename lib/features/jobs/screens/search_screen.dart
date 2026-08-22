import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../widgets/job_card.dart';
import '../../../models/job_model.dart';
import '../../../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<JobModel> _results = [];
  bool _searched = false;

  // Filters
  String? _selectedType; // 'job' | 'internship' | null
  String? _selectedWorkMode; // 'remote' | 'onsite' | 'hybrid' | null
  String? _selectedLocation;
  final List<String> _locations = [
    'Bangalore', 'Hyderabad', 'Mumbai', 'Delhi', 'Pune',
    'Chennai', 'Remote',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search([String? query]) {
    final q = (query ?? _searchController.text).toLowerCase().trim();
    final provider = context.read<JobsProvider>();
    var all = [...provider.jobs, ...provider.internships];

    // Text filter
    if (q.isNotEmpty) {
      all = all.where((j) {
        return j.title.toLowerCase().contains(q) ||
            j.companyName.toLowerCase().contains(q) ||
            j.location.toLowerCase().contains(q) ||
            j.requiredSkills.any((s) => s.toLowerCase().contains(q)) ||
            j.category.toLowerCase().contains(q);
      }).toList();
    }

    // Type filter
    if (_selectedType != null) {
      all = all.where((j) => j.type.name == _selectedType).toList();
    }

    // Work mode filter
    if (_selectedWorkMode != null) {
      all = all
          .where((j) => j.workMode.name == _selectedWorkMode)
          .toList();
    }

    // Location filter
    if (_selectedLocation != null) {
      all = all.where((j) {
        if (_selectedLocation == 'Remote') {
          return j.workMode == WorkMode.remote;
        }
        return j.location
            .toLowerCase()
            .contains(_selectedLocation!.toLowerCase());
      }).toList();
    }

    setState(() {
      _results = all;
      _searched = true;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedWorkMode = null;
      _selectedLocation = null;
    });
    if (_searched) _search();
  }

  bool get _hasFilters =>
      _selectedType != null ||
      _selectedWorkMode != null ||
      _selectedLocation != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText:
                'Jobs, skills, companies, locations...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500),
          onChanged: (q) {
            if (q.length >= 2 || q.isEmpty) _search(q);
          },
          onSubmitted: (_) => _search(),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _results = [];
                  _searched = false;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter bar ─────────────────────────────────────
          Container(
            color: AppTheme.surface,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      // Type
                      _FilterChip(
                        label: _selectedType == null
                            ? 'Type'
                            : _selectedType == 'job'
                                ? 'Jobs'
                                : 'Internships',
                        icon: Icons.work_outline_rounded,
                        active: _selectedType != null,
                        onTap: () => _showTypeSheet(),
                      ),
                      const SizedBox(width: 8),
                      // Work mode
                      _FilterChip(
                        label: _selectedWorkMode == null
                            ? 'Work mode'
                            : _selectedWorkMode!.capitalize,
                        icon: Icons.laptop_mac_outlined,
                        active: _selectedWorkMode != null,
                        onTap: () => _showWorkModeSheet(),
                      ),
                      const SizedBox(width: 8),
                      // Location
                      _FilterChip(
                        label: _selectedLocation ?? 'Location',
                        icon: Icons.location_on_outlined,
                        active: _selectedLocation != null,
                        onTap: () => _showLocationSheet(),
                      ),
                      if (_hasFilters) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _clearFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.errorLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.close_rounded,
                                    size: 13,
                                    color: AppTheme.error),
                                SizedBox(width: 4),
                                Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: AppTheme.error,
                                    fontSize: 12,
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
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
              ],
            ),
          ),

          // ── Results ────────────────────────────────────────
          Expanded(
            child: !_searched
                ? _SearchSuggestions(
                    onTap: (q) {
                      _searchController.text = q;
                      _search(q);
                    },
                  )
                : _results.isEmpty
                    ? _NoResults(
                        hasFilters: _hasFilters,
                        onClear: _clearFilters)
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16, 12, 16, 8),
                            child: Row(
                              children: [
                                Text(
                                  '${_results.length} result${_results.length == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 0, 16, 16),
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final job = _results[index];
                                return JobCard(
                                  job: job,
                                  onTap: () =>
                                      context.push('/job/${job.id}'),
                                  matchPercentage: context
                                      .read<JobsProvider>()
                                      .getMatchPercentage(job),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  void _showTypeSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        title: 'Opportunity type',
        options: const [
          (null, 'All types'),
          ('job', 'Jobs only'),
          ('internship', 'Internships only'),
        ],
        selected: _selectedType,
        onSelect: (v) {
          setState(() => _selectedType = v);
          if (_searched) _search();
        },
      ),
    );
  }

  void _showWorkModeSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        title: 'Work mode',
        options: const [
          (null, 'Any mode'),
          ('remote', 'Remote'),
          ('onsite', 'On-site'),
          ('hybrid', 'Hybrid'),
        ],
        selected: _selectedWorkMode,
        onSelect: (v) {
          setState(() => _selectedWorkMode = v);
          if (_searched) _search();
        },
      ),
    );
  }

  void _showLocationSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        title: 'Location',
        options: [
          (null, 'Any location'),
          ..._locations.map((l) => (l, l)),
        ],
        selected: _selectedLocation,
        onSelect: (v) {
          setState(() => _selectedLocation = v);
          if (_searched) _search();
        },
      ),
    );
  }
}

// Extensions
extension _StringCap on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryLight : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppTheme.primary : AppTheme.border,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: active
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 13,
              color: active
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final String title;
  final List<(String?, String)> options;
  final String? selected;
  final void Function(String?) onSelect;

  const _FilterSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map(
            (opt) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                opt.$2,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected == opt.$1
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: selected == opt.$1
                      ? AppTheme.primary
                      : AppTheme.textPrimary,
                ),
              ),
              trailing: selected == opt.$1
                  ? const Icon(Icons.check_rounded,
                      color: AppTheme.primary, size: 20)
                  : null,
              onTap: () {
                onSelect(opt.$1);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final void Function(String) onTap;

  const _SearchSuggestions({required this.onTap});

  static const _categories = [
    ('Mobile Development', Icons.phone_android_rounded, AppTheme.primary),
    ('Web Development', Icons.language_rounded, Color(0xFF6366F1)),
    ('Data Science', Icons.analytics_rounded, AppTheme.secondary),
    ('DevOps / Cloud', Icons.cloud_rounded, AppTheme.warning),
    ('Machine Learning', Icons.psychology_rounded, AppTheme.error),
    ('Backend', Icons.storage_rounded, Color(0xFF0891B2)),
  ];

  static const _popular = [
    'Flutter Developer',
    'Python',
    'React',
    'Machine Learning',
    'Node.js',
    'AWS',
    'UI/UX Designer',
    'SQL',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Browse by category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: _categories
              .map(
                (cat) => GestureDetector(
                  onTap: () => onTap(cat.$1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (cat.$3 as Color).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: (cat.$3 as Color).withOpacity(0.2)),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(cat.$2,
                            size: 18, color: cat.$3 as Color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat.$1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cat.$3 as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Popular searches',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popular
              .map(
                (q) => GestureDetector(
                  onTap: () => onTap(q),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_rounded,
                            size: 13,
                            color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          q,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;

  const _NoResults({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters or using different keywords'
                  : 'Try different keywords or browse by category',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onClear,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 44)),
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}