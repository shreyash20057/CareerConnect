import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _Section(
            title: 'Account',
            children: [
              _SettingsItem(
                icon: Icons.person_outline_rounded,
                label: 'Edit profile',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.lock_outline_rounded,
                label: 'Change password',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.email_outlined,
                label: 'Email preferences',
                onTap: () {},
              ),
            ],
          ),
          _Section(
            title: 'Notifications',
            children: [
              _SettingsToggle(
                icon: Icons.notifications_outlined,
                label: 'Push notifications',
                value: true,
                onChanged: (_) {},
              ),
              _SettingsToggle(
                icon: Icons.work_outline_rounded,
                label: 'New job matches',
                value: true,
                onChanged: (_) {},
              ),
              _SettingsToggle(
                icon: Icons.assignment_outlined,
                label: 'Application updates',
                value: true,
                onChanged: (_) {},
              ),
              _SettingsToggle(
                icon: Icons.schedule_rounded,
                label: 'Deadline reminders',
                value: false,
                onChanged: (_) {},
              ),
            ],
          ),
          _Section(
            title: 'Privacy',
            children: [
              _SettingsItem(
                icon: Icons.visibility_outlined,
                label: 'Profile visibility',
                trailing: const Text(
                  'Public',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.download_outlined,
                label: 'Download my data',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.delete_outline_rounded,
                label: 'Delete account',
                textColor: AppTheme.error,
                onTap: () => _confirmDelete(context),
              ),
            ],
          ),
          _Section(
            title: 'Appearance',
            children: [
              const _ThemeSelector(),
            ],
          ),
          _Section(
            title: 'App',
            children: [
              _SettingsItem(
                icon: Icons.info_outline_rounded,
                label: 'About CareerConnect',
                trailing: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy policy',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.article_outlined,
                label: 'Terms of service',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.star_outline_rounded,
                label: 'Rate the app',
                onTap: () {},
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
              },
              icon: const Icon(
                Icons.logout_rounded,
                color: AppTheme.error,
                size: 18,
              ),
              label: const Text(
                'Sign out',
                style: TextStyle(color: AppTheme.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This will permanently delete your account and all data. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          color: AppTheme.surface,
          child: Column(
            children: children
                .expand(
                  (w) => [
                    w,
                    if (w != children.last)
                      const Divider(
                        height: 1,
                        indent: 56,
                      ),
                  ],
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? textColor;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: textColor ?? AppTheme.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppTheme.textPrimary,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: AppTheme.textTertiary,
          ),
      onTap: onTap,
    );
  }
}

class _SettingsToggle extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_SettingsToggle> createState() => _SettingsToggleState();
}

class _SettingsToggleState extends State<_SettingsToggle> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        widget.icon,
        size: 20,
        color: AppTheme.textSecondary,
      ),
      title: Text(
        widget.label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: Switch(
        value: _value,
        onChanged: (v) {
          setState(() => _value = v);
          widget.onChanged(v);
        },
        activeColor: AppTheme.primary,
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final options = [
      (
        AppThemeMode.system,
        'System default',
        Icons.brightness_auto_rounded,
      ),
      (
        AppThemeMode.light,
        'Light',
        Icons.light_mode_rounded,
      ),
      (
        AppThemeMode.dark,
        'Dark',
        Icons.dark_mode_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: options.map((opt) {
              final selected = themeProvider.mode == opt.$1;

              return Expanded(
                child: GestureDetector(
                  onTap: () => themeProvider.setMode(opt.$1),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: opt == options.last ? 0 : 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryLight
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          opt.$3,
                          size: 20,
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          opt.$2,
                          style: TextStyle(
                            fontSize: 10,
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
            }).toList(),
          ),
        ],
      ),
    );
  }
}