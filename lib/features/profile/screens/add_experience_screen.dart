import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/profile_provider.dart';
import '../services/profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cc_button.dart';
import '../../../core/widgets/cc_text_field.dart';
import '../../../core/utils/extensions.dart';
import '../../../models/user_model.dart';

class AddExperienceScreen extends StatefulWidget {
  final ExperienceModel? existing;
  final int? existingIndex;

  const AddExperienceScreen(
      {super.key, this.existing, this.existingIndex});

  @override
  State<AddExperienceScreen> createState() =>
      _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProfileService();

  final _orgC = TextEditingController();
  final _positionC = TextEditingController();
  final _durationC = TextEditingController();
  final _responsibilitiesC = TextEditingController();
  String _type = 'internship';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _type = e.type;
      _orgC.text = e.organization;
      _positionC.text = e.position;
      _durationC.text = e.duration;
      _responsibilitiesC.text = e.responsibilities;
    }
  }

  @override
  void dispose() {
    _orgC.dispose();
    _positionC.dispose();
    _durationC.dispose();
    _responsibilitiesC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final exp = ExperienceModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      type: _type,
      organization: _orgC.text.trim(),
      position: _positionC.text.trim(),
      duration: _durationC.text.trim(),
      responsibilities: _responsibilitiesC.text.trim(),
    );

    bool success;
    if (widget.existingIndex != null) {
      // update — re-add at index
      success = await _service.addExperience(exp);
    } else {
      success = await _service.addExperience(exp);
    }

    if (success) {
      final uid =
          context.read<ProfileProvider>().user?.uid;
      if (uid != null) {
        await context.read<ProfileProvider>().loadProfile(uid);
      }
      if (mounted) {
        context.showSnackBar('Experience saved!');
        Navigator.pop(context);
      }
    } else if (mounted) {
      context.showSnackBar('Failed to save', isError: true);
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.existing != null
            ? 'Edit experience'
            : 'Add experience'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type toggle
              const Text(
                'Experience type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _TypeButton(
                    label: 'Internship',
                    icon: Icons.school_outlined,
                    selected: _type == 'internship',
                    onTap: () => setState(() => _type = 'internship'),
                  ),
                  const SizedBox(width: 10),
                  _TypeButton(
                    label: 'Full-time job',
                    icon: Icons.business_outlined,
                    selected: _type == 'job',
                    onTap: () => setState(() => _type = 'job'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CCTextField(
                controller: _orgC,
                label: 'Organization / Company',
                prefixIcon: Icons.business_outlined,
                validator: (v) => v == null || v.isEmpty
                    ? 'Organization is required'
                    : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _positionC,
                label: 'Position / Role',
                hint: 'e.g., Flutter Developer Intern',
                prefixIcon: Icons.work_outline_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Position is required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _durationC,
                label: 'Duration',
                hint: 'e.g., June 2024 – Aug 2024 (3 months)',
                prefixIcon: Icons.calendar_today_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Duration is required' : null,
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _responsibilitiesC,
                label: 'Key responsibilities',
                hint:
                    'What did you build, learn, or achieve? Use bullet points.',
                prefixIcon: Icons.list_alt_rounded,
                maxLines: 5,
                validator: (v) => v == null || v.isEmpty
                    ? 'Please describe your responsibilities'
                    : null,
              ),
              const SizedBox(height: 32),
              CCButton(
                label: 'Save experience',
                onPressed: _saving ? null : _save,
                isLoading: _saving,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryLight : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22,
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.textSecondary),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}