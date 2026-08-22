import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/profile_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';

class ProfilePhotoWidget extends StatefulWidget {
  final double radius;
  const ProfilePhotoWidget({super.key, this.radius = 40});

  @override
  State<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  final _service = ProfileService();
  bool _uploading = false;
  double _progress = 0;

  Future<void> _pickAndUpload() async {
    setState(() {
      _uploading = true;
      _progress = 0;
    });

    final url = await _service.uploadProfilePhoto(
      onProgress: (p) => setState(() => _progress = p),
    );

    if (url != null) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        await context.read<ProfileProvider>().loadProfile(uid);
      }
      if (mounted) context.showSnackBar('Photo updated!');
    } else if (mounted) {
      context.showSnackBar('Failed to update photo', isError: true);
    }

    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>().user;
    final auth = context.read<AuthProvider>();
    final photoUrl = user?.photoUrl;
    final initial = (user?.fullName.isNotEmpty == true
            ? user!.fullName[0]
            : auth.user?.email?[0] ?? 'U')
        .toUpperCase();

    return GestureDetector(
      onTap: _uploading ? null : _pickAndUpload,
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: AppTheme.primaryLight,
            backgroundImage:
                photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(
                    initial,
                    style: TextStyle(
                      fontSize: widget.radius * 0.7,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  )
                : null,
          ),
          if (_uploading)
            Positioned.fill(
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                radius: widget.radius,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}