import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/profile_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cc_button.dart';
import '../../../core/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  final _service = ProfileService();
  double? _uploadProgress;
  bool _uploading = false;

  Future<void> _upload() async {
    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });

    final result = await _service.uploadResume(
      onProgress: (p) => setState(() => _uploadProgress = p),
    );

    if (result.success) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        await context.read<ProfileProvider>().loadProfile(uid);
      }
      if (mounted) context.showSnackBar('Resume uploaded successfully!');
    } else if (mounted) {
      context.showSnackBar(
          result.error ?? 'Upload failed', isError: true);
    }

    setState(() {
      _uploading = false;
      _uploadProgress = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>().user;
    final hasResume = user?.resumeUrl != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Resume')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current resume card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: hasResume
                  ? Column(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: AppTheme.error,
                          size: 56,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Resume uploaded',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your resume is live on your profile',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final url = user!.resumeUrl!;
                                  if (await canLaunchUrl(
                                      Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  }
                                },
                                icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 16),
                                label: const Text('View'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _uploading ? null : _upload,
                                icon: const Icon(
                                    Icons.upload_file_rounded,
                                    size: 16),
                                label: const Text('Replace'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.upload_file_rounded,
                            color: AppTheme.textSecondary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No resume uploaded',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'PDF, DOC, or DOCX up to 5MB',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CCButton(
                          label: 'Upload resume',
                          onPressed: _uploading ? null : _upload,
                          isLoading: _uploading,
                          icon: Icons.upload_rounded,
                        ),
                      ],
                    ),
            ),

            // Upload progress
            if (_uploading && _uploadProgress != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Uploading...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${(_uploadProgress! * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: AppTheme.surfaceVariant,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Tips
            const Text(
              'Resume tips',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._tips.map((tip) => _TipRow(tip: tip)),
          ],
        ),
      ),
    );
  }

  static const _tips = [
    'Keep it to 1 page if you have less than 3 years of experience',
    'Use strong action verbs: Built, Optimised, Led, Reduced, Improved',
    'Quantify achievements — numbers make impact clear',
    'Include your GitHub and LinkedIn links',
    'Tailor your resume for each job description',
    'Use a clean, ATS-friendly format without heavy graphics',
  ];
}

class _TipRow extends StatelessWidget {
  final String tip;
  const _TipRow({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_rounded,
              size: 16, color: AppTheme.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}