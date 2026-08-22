import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cc_button.dart';
import '../../../core/widgets/cc_text_field.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/validators.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Step 1: Personal
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  // Step 2: Education
  final _degreeController = TextEditingController();
  final _collegeController = TextEditingController();
  final _branchController = TextEditingController();
  final _cgpaController = TextEditingController();
  final _gradYearController = TextEditingController();

  // Step 3: Skills
  final _skillInput = TextEditingController();
  final List<String> _selectedSkills = [];
  final _popularSkills = [
    'Python', 'Java', 'JavaScript', 'React', 'Flutter',
    'Node.js', 'SQL', 'MongoDB', 'Machine Learning', 'AWS',
    'Docker', 'Git', 'HTML', 'CSS', 'TypeScript',
  ];

  // Step 4: Preferences
  String _workMode = 'hybrid';
  String _opportunityType = 'both';
  final _roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController.text = auth.user?.displayName ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _degreeController.dispose();
    _collegeController.dispose();
    _branchController.dispose();
    _cgpaController.dispose();
    _gradYearController.dispose();
    _skillInput.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _completeSetup();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _completeSetup() async {
    final profile = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();

    final success = await profile.completeProfile({
      'fullName': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'graduation': {
        'degree': _degreeController.text.trim(),
        'college': _collegeController.text.trim(),
        'branch': _branchController.text.trim(),
        'cgpa': _cgpaController.text.trim(),
        'passingYear': _gradYearController.text.trim(),
        'currentYear': '',
      },
      'skills': _selectedSkills,
      'preferences': {
        'desiredRoles': _roleController.text.trim().isNotEmpty
            ? [_roleController.text.trim()]
            : [],
        'workMode': _workMode,
        'opportunityType': _opportunityType,
        'preferredLocations': [],
      },
    });

    if (success && mounted) {
      auth.setProfileComplete();
    } else if (mounted) {
      context.showSnackBar(
          profile.error ?? 'Failed to save profile',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          onPressed: _prevPage,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${_currentPage + 1} of $_totalPages',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _stepTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _totalPages,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primary),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _PersonalInfoPage(
                    nameController: _nameController,
                    phoneController: _phoneController,
                    cityController: _cityController,
                    stateController: _stateController,
                  ),
                  _EducationPage(
                    degreeController: _degreeController,
                    collegeController: _collegeController,
                    branchController: _branchController,
                    cgpaController: _cgpaController,
                    gradYearController: _gradYearController,
                  ),
                  _SkillsPage(
                    skillInput: _skillInput,
                    selectedSkills: _selectedSkills,
                    popularSkills: _popularSkills,
                    onSkillToggle: (skill) {
                      setState(() {
                        if (_selectedSkills.contains(skill)) {
                          _selectedSkills.remove(skill);
                        } else {
                          _selectedSkills.add(skill);
                        }
                      });
                    },
                    onAddCustom: () {
                      final skill = _skillInput.text.trim();
                      if (skill.isNotEmpty &&
                          !_selectedSkills.contains(skill)) {
                        setState(() => _selectedSkills.add(skill));
                        _skillInput.clear();
                      }
                    },
                  ),
                  _PreferencesPage(
                    workMode: _workMode,
                    opportunityType: _opportunityType,
                    roleController: _roleController,
                    onWorkModeChanged: (v) => setState(() => _workMode = v),
                    onOpportunityTypeChanged: (v) =>
                        setState(() => _opportunityType = v),
                  ),
                ],
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: CCButton(
                label: _currentPage == _totalPages - 1
                    ? 'Complete setup'
                    : 'Continue',
                onPressed: profile.isLoading ? null : _nextPage,
                isLoading: profile.isLoading,
                icon: _currentPage == _totalPages - 1
                    ? Icons.check_rounded
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _stepTitle {
    switch (_currentPage) {
      case 0:
        return 'Personal info';
      case 1:
        return 'Education';
      case 2:
        return 'Your skills';
      case 3:
        return 'Preferences';
      default:
        return '';
    }
  }
}

class _PersonalInfoPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController stateController;

  const _PersonalInfoPage({
    required this.nameController,
    required this.phoneController,
    required this.cityController,
    required this.stateController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          CCTextField(
            controller: nameController,
            label: 'Full name',
            prefixIcon: Icons.person_outline_rounded,
            validator: Validators.name,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          CCTextField(
            controller: phoneController,
            label: 'Phone number',
            hint: 'Optional',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          CCTextField(
            controller: cityController,
            label: 'City',
            prefixIcon: Icons.location_city_outlined,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          CCTextField(
            controller: stateController,
            label: 'State',
            prefixIcon: Icons.map_outlined,
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }
}

class _EducationPage extends StatelessWidget {
  final TextEditingController degreeController;
  final TextEditingController collegeController;
  final TextEditingController branchController;
  final TextEditingController cgpaController;
  final TextEditingController gradYearController;

  const _EducationPage({
    required this.degreeController,
    required this.collegeController,
    required this.branchController,
    required this.cgpaController,
    required this.gradYearController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your graduation details',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          CCTextField(
            controller: degreeController,
            label: 'Degree',
            hint: 'e.g., B.Tech, B.E., BCA',
            prefixIcon: Icons.school_outlined,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          CCTextField(
            controller: collegeController,
            label: 'College / University',
            prefixIcon: Icons.account_balance_outlined,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          CCTextField(
            controller: branchController,
            label: 'Branch / Specialization',
            hint: 'e.g., Computer Science, IT',
            prefixIcon: Icons.category_outlined,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CCTextField(
                  controller: cgpaController,
                  label: 'CGPA / %',
                  hint: 'e.g., 8.5',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.grade_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CCTextField(
                  controller: gradYearController,
                  label: 'Passing year',
                  hint: 'e.g., 2025',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillsPage extends StatelessWidget {
  final TextEditingController skillInput;
  final List<String> selectedSkills;
  final List<String> popularSkills;
  final void Function(String) onSkillToggle;
  final VoidCallback onAddCustom;

  const _SkillsPage({
    required this.skillInput,
    required this.selectedSkills,
    required this.popularSkills,
    required this.onSkillToggle,
    required this.onAddCustom,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select skills you have (tap to add)',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          // Custom skill input
          Row(
            children: [
              Expanded(
                child: CCTextField(
                  controller: skillInput,
                  label: 'Add custom skill',
                  prefixIcon: Icons.add_circle_outline_rounded,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAddCustom(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onAddCustom,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(56, 52),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add_rounded, size: 22),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (selectedSkills.isNotEmpty) ...[
            const Text(
              'Selected',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedSkills
                  .map(
                    (skill) => GestureDetector(
                      onTap: () => onSkillToggle(skill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              skill,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.close_rounded,
                                size: 14, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          const Text(
            'Popular skills',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularSkills
                .where((s) => !selectedSkills.contains(s))
                .map(
                  (skill) => GestureDetector(
                    onTap: () => onSkillToggle(skill),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PreferencesPage extends StatelessWidget {
  final String workMode;
  final String opportunityType;
  final TextEditingController roleController;
  final void Function(String) onWorkModeChanged;
  final void Function(String) onOpportunityTypeChanged;

  const _PreferencesPage({
    required this.workMode,
    required this.opportunityType,
    required this.roleController,
    required this.onWorkModeChanged,
    required this.onOpportunityTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are you looking for?',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          CCTextField(
            controller: roleController,
            label: 'Desired role',
            hint: 'e.g., Flutter Developer, Data Analyst',
            prefixIcon: Icons.work_outline_rounded,
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 24),

          const Text(
            'Work mode preference',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _OptionGroup(
            options: const [
              ('remote', 'Remote', Icons.home_work_outlined),
              ('onsite', 'On-site', Icons.business_outlined),
              ('hybrid', 'Hybrid', Icons.swap_horiz_rounded),
            ],
            selected: workMode,
            onSelected: onWorkModeChanged,
          ),

          const SizedBox(height: 24),

          const Text(
            'Opportunity type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _OptionGroup(
            options: const [
              ('internship', 'Internship', Icons.school_outlined),
              ('fulltime', 'Full-time', Icons.work_outline_rounded),
              ('both', 'Both', Icons.all_inclusive_rounded),
            ],
            selected: opportunityType,
            onSelected: onOpportunityTypeChanged,
          ),
        ],
      ),
    );
  }
}

class _OptionGroup extends StatelessWidget {
  final List<(String, String, IconData)> options;
  final String selected;
  final void Function(String) onSelected;

  const _OptionGroup({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((opt) {
        final isSelected = selected == opt.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: opt == options.last ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => onSelected(opt.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryLight : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      opt.$3,
                      size: 22,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      opt.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}