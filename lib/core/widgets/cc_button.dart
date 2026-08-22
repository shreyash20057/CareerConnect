import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CCButtonVariant { primary, secondary, outlined, ghost, danger }

class CCButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CCButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsets? padding;

  const CCButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CCButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;

    switch (variant) {
      case CCButtonVariant.primary:
        backgroundColor =
            isDisabled ? AppTheme.primary.withOpacity(0.5) : AppTheme.primary;
        foregroundColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case CCButtonVariant.secondary:
        backgroundColor = AppTheme.primaryLight;
        foregroundColor = AppTheme.primary;
        borderColor = Colors.transparent;
        break;
      case CCButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = AppTheme.primary;
        borderColor = AppTheme.primary;
        break;
      case CCButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppTheme.textSecondary;
        borderColor = AppTheme.border;
        break;
      case CCButtonVariant.danger:
        backgroundColor = AppTheme.error;
        foregroundColor = Colors.white;
        borderColor = Colors.transparent;
        break;
    }

    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foregroundColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: variant == CCButtonVariant.outlined ? 1.5 : 0,
              ),
            ),
            alignment: Alignment.center,
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}