import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cc_button.dart';
import '../../../core/widgets/cc_text_field.dart';
import '../../../core/utils/extensions.dart';
import '../../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // Personal
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _cityC = TextEditingController();
  final _stateC = TextEditingController();
  final _countryC = TextEditingController();

  // Education
  final _degreeC = TextEditingController();
  final _collegeC = TextEditingController();
  final _branchC = TextEditingController();
  final _cgpaC = TextEditingController();
  final _gradYearC = TextEditingController();

  // Skills
  final _skillC = TextEditingController();
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    final user = context.read<ProfileProvider>().user;
    if (user != null) {
      _nameC.text = user.fullName;
      _phoneC.text = user.phone ?? '';
      _cityC.text = user.city ?? '';
      _stateC.text = user.state ?? '';
      _countryC.text = user.country ?? '';
      if (user.graduation != null) {
        _degreeC.text = user.graduation!.degree;
        _collegeC.text = user.graduation!.college;
        _branchC.text = user.graduation!.branch;
        _cgpaC.text = user.graduation!.cgpa;
        _gradYearC.text = user.graduation!.passingYear;
      }
      _skills = List.from(user.skills);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    _nameC.dispose();
    _phoneC.dispose();
    _cityC.dispose();
    _stateC.dispose();
    _countryC.dispose();
    _degreeC.dispose();
    _collegeC.dispose();
    _branchC.dispose();
    _cgpaC.dispose();
    _gradYearC.dispose();
    _skillC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<ProfileProvider>();
    final success = await provider.updateProfile({
      'fullName': _nameC.text.trim(),
      'phone': _phoneC.text.trim(),
      'city': _cityC.text.trim(),
      'state': _stateC.text.trim(),
      'country': _countryC.text.trim(),
      'graduation': {
        'degree': _degreeC.text.trim(),
        'college': _collegeC.text.trim(),
        'branch': _branchC.text.trim(),
        'cgpa': _cgpaC.text.trim(),
        'passingYear': _gradYearC.text.trim(),
        'currentYear': '',
      },
      'skills': _skills,
    });

    if (mounted) {
      if (success) {
        context.showSnackBar('Profile updated!');
        Navigator.pop(context);
      } else {
        context.showSnackBar(
            provider.error ?? 'Update failed',
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Edit profile'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Education'),
            Tab(text: 'Skills'),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // ── Personal ──────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CCTextField(
                    controller: _nameC,
                    label: 'Full name',
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words),
                const SizedBox(height: 14),
                CCTextField(
                    controller: _phoneC,
                    label: 'Phone',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                CCTextField(
                    controller: _cityC,
                    label: 'City',
                    prefixIcon: Icons.location_city_outlined,
                    textCapitalization: TextCapitalization.words),
                const SizedBox(height: 14),
                CCTextField(
                    controller: _stateC,
                    label: 'State',
                    prefixIcon: Icons.map_outlined,
                    textCapitalization: TextCapitalization.words),
                const SizedBox(height: 14),
                CCTextField(
                    controller: _countryC,
                    label: 'Country',
                    prefixIcon: Icons.public_outlined,
                    textCapitalization: TextCapitalization.words),
              ],
            ),
          ),

          // ── Education ─────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CCTextField(
                    controller: _degreeC,
                    label: 'Degree',
                    hint: 'B.Tech, BCA, MCA...',
                    prefixIcon: Icons.school_outlined,
                    textCapitalization: TextCapitalization.words),
                const SizedBox(height: 14),
                CCTextField(
                    controller: _collegeC,
                    label: 'College / University',
                    prefixIcon: Icons.account_balance_outlined,
                    textCapitalization: TextCapitalization.words),
                const SizedBox(height: 14),
                CCTextField(
                    controller: _branchC,
                    label: 'Branch / Specialization',
                    prefixIcon: Icons.category_outlined,
                    textCapitalization: TextCapitalization.words),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CCTextField(
                          controller: _cgpaC,
                          label: 'CGPA / %',
                          prefixIcon: Icons.grade_outlined,
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CCTextField(
                          controller: _gradYearC,
                          label: 'Passing year',
                          prefixIcon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Skills ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CCTextField(
                        controller: _skillC,
                        label: 'Add skill',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addSkill(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _addSkill,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(56, 52),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Icon(Icons.add_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills
                          .map(
                            (s) => GestureDetector(
                              onTap: () =>
                                  setState(() => _skills.remove(s)),
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
                                      s,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: CCButton(
          label: 'Save changes',
          onPressed: provider.isLoading ? null : _save,
          isLoading: provider.isLoading,
          icon: Icons.check_rounded,
        ),
      ),
    );
  }

  void _addSkill() {
    final skill = _skillC.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() => _skills.add(skill));
      _skillC.clear();
    }
  }
}