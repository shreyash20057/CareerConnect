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

class AddCertificationScreen extends StatefulWidget {
  final CertificationModel? existing;
  final int? existingIndex;

  const AddCertificationScreen(
      {super.key, this.existing, this.existingIndex});

  @override
  State<AddCertificationScreen> createState() =>
      _AddCertificationScreenState();
}

class _AddCertificationScreenState
    extends State<AddCertificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProfileService();

  final _nameC = TextEditingController();
  final _orgC = TextEditingController();
  final _dateC = TextEditingController();
  final _linkC = TextEditingController();
  bool _saving = false;

  // Popular issuers
  static const _popularOrgs = [
    'Google', 'AWS', 'Microsoft', 'Coursera', 'Udemy',
    'NPTEL', 'LinkedIn Learning', 'HackerRank', 'Infosys Springboard',
    'IBM', 'Oracle', 'Cisco', 'Meta',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final c = widget.existing!;
      _nameC.text = c.name;
      _orgC.text = c.organization;
      _dateC.text = c.date;
      _linkC.text = c.credentialLink ?? '';
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _orgC.dispose();
    _dateC.dispose();
    _linkC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final cert = CertificationModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameC.text.trim(),
      organization: _orgC.text.trim(),
      date: _dateC.text.trim(),
      credentialLink:
          _linkC.text.trim().isNotEmpty ? _linkC.text.trim() : null,
    );

    final success = await _service.addCertification(cert);

    if (success) {
      final uid =
          context.read<ProfileProvider>().user?.uid;
      if (uid != null) {
        await context.read<ProfileProvider>().loadProfile(uid);
      }
      if (mounted) {
        context.showSnackBar('Certification added!');
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
            ? 'Edit certification'
            : 'Add certification'),
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
                label: 'Certification name',
                hint:
                    'e.g., AWS Solutions Architect, Google UX Design',
                prefixIcon: Icons.verified_outlined,
                validator: (v) => v == null || v.isEmpty
                    ? 'Certification name is required'
                    : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _orgC,
                label: 'Issuing organization',
                hint: 'e.g., Google, AWS, Coursera',
                prefixIcon: Icons.business_outlined,
                validator: (v) => v == null || v.isEmpty
                    ? 'Organization is required'
                    : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 10),
              // Quick org suggestions
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _popularOrgs
                    .map(
                      (org) => GestureDetector(
                        onTap: () {
                          _orgC.text = org;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            org,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _dateC,
                label: 'Date issued',
                hint: 'e.g., Dec 2024 or 2024',
                prefixIcon: Icons.calendar_today_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Date is required' : null,
              ),
              const SizedBox(height: 14),
              CCTextField(
                controller: _linkC,
                label: 'Credential link (optional)',
                hint: 'https://...',
                prefixIcon: Icons.link_rounded,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),
              CCButton(
                label: 'Save certification',
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