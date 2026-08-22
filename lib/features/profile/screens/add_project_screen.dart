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

class AddProjectScreen extends StatefulWidget {
  final ProjectModel? existing;
  final int? existingIndex;

  const AddProjectScreen({super.key, this.existing, this.existingIndex});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProfileService();

  final _nameC = TextEditingController();
  final _descC = TextEditingController();
  final _roleC = TextEditingController();
  final _projectLinkC = TextEditingController();
  final _githubC = TextEditingController();
  final _yearC = TextEditingController();
  final _techC = TextEditingController();

  List<String> _technologies = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final p = widget.existing!;
      _nameC.text = p.name;
      _descC.text = p.description;
      _roleC.text = p.role;
      _projectLinkC.text = p.projectLink ?? '';
      _githubC.text = p.githubLink ?? '';
      _yearC.text = p.year;
      _technologies = List.from(p.technologies);
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _descC.dispose();
    _roleC.dispose();
    _projectLinkC.dispose();
    _githubC.dispose();
    _yearC.dispose();
    _techC.dispose();
    super.dispose();
  }

  void _addTech() {
    final t = _techC.text.trim();
    if (t.isNotEmpty && !_technologies.contains(t)) {
      setState(() => _technologies.add(t));
      _techC.clear();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_technologies.isEmpty) {
      context.showSnackBar('Add at least one technology', isError: true);
      return;
    }

    setState(() => _saving = true);

    final project = ProjectModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameC.text.trim(),
      description: _descC.text.trim(),
      technologies: _technologies,
      role: _roleC.text.trim(),
      projectLink: _projectLinkC.text.trim().isNotEmpty
          ? _projectLinkC.text.trim()
          : null,
      githubLink: _githubC.text.trim().isNotEmpty
          ? _githubC.text.trim()
          : null,
      year: _yearC.text.trim(),
    );

    bool success;
    if (widget.existingIndex != null) {
      success =
          await _service.updateProject(project, widget.existingIndex!);
    } else {
      success = await _service.addProject(project);
    }

    if (success) {
      final uid = context
          .read<ProfileProvider>()
          .user
          ?.uid;
      if (uid != null) {
        await context.read<ProfileProvider>().loadProfile(uid);
      }
      if (mounted) {
        context.showSnackBar('Project saved!');
        Navigator.pop(context);
      }
    } else if (mounted) {
      context.showSnackBar('Failed to save project', isError: true);
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
            widget.existing != null ? 'Edit project' : 'Add project'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CCTextField(
                controller: _nameC,
                label: 'Project name',
                hint: 'e.g., CareerConnect App',
                prefixIcon: Icons.rocket_launch_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Project name is required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _descC,
                label: 'Description',
                hint: 'Briefly describe what this project does',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _roleC,
                label: 'Your role',
                hint: 'e.g., Full-stack Developer, Lead Designer',
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Role is required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _yearC,
                label: 'Year',
                hint: 'e.g., 2024',
                prefixIcon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Year is required' : null,
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _projectLinkC,
                label: 'Project link (optional)',
                hint: 'https://...',
                prefixIcon: Icons.link_rounded,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _githubC,
                label: 'GitHub link (optional)',
                hint: 'https://github.com/...',
                prefixIcon: Icons.code_rounded,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              const Text(
                'Technologies used',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CCTextField(
                      controller: _techC,
                      label: 'Add technology',
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addTech(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _addTech,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(52, 52),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.add_rounded),
                    ),
                  ),
                ],
              ),
              if (_technologies.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _technologies
                      .map(
                        (t) => GestureDetector(
                          onTap: () =>
                              setState(() => _technologies.remove(t)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.close_rounded,
                                    size: 13,
                                    color: Colors.white70),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 32),
              CCButton(
                label: 'Save project',
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