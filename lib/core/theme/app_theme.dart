import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF1A56DB);
  static const primaryDark = Color(0xFF1341B0);
  static const primaryLight = Color(0xFFE8EFFE);
  static const secondary = Color(0xFF0E9F6E);
  static const secondaryLight = Color(0xFFDEF7EC);
  static const accent = Color(0xFFF05252);
  static const accentLight = Color(0xFFFDE8E8);
  static const warning = Color(0xFFFF8A00);
  static const warningLight = Color(0xFFFFF3CD);

  // Semantic
  static const success = Color(0xFF0E9F6E);
  static const successLight = Color(0xFFDEF7EC);
  static const error = Color(0xFFF05252);
  static const errorLight = Color(0xFFFDE8E8);

  // Light neutrals
  static const backgroundLight = Color(0xFFF9FAFB);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFF3F4F6);
  static const borderLight = Color(0xFFE5E7EB);
  static const borderLightAlt = Color(0xFFF3F4F6);
  static const textPrimaryLight = Color(0xFF111827);
  static const textSecondaryLight = Color(0xFF6B7280);
  static const textTertiaryLight = Color(0xFF9CA3AF);

  // Dark neutrals
  static const backgroundDark = Color(0xFF0F1117);
  static const surfaceDark = Color(0xFF1A1D27);
  static const surfaceVariantDark = Color(0xFF252836);
  static const borderDark = Color(0xFF2D3142);
  static const borderDarkAlt = Color(0xFF363A50);
  static const textPrimaryDark = Color(0xFFF1F2F6);
  static const textSecondaryDark = Color(0xFF8B91A8);
  static const textTertiaryDark = Color(0xFF5C6280);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const cardGradient = LinearGradient(
    colors: [Color(0xFF1A56DB), Color(0xFF1341B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const purpleGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  // Expose static colors for convenience (light defaults)
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color secondary = AppColors.secondary;
  static const Color secondaryLight = AppColors.secondaryLight;
  static const Color accent = AppColors.accent;
  static const Color accentLight = AppColors.accentLight;
  static const Color warning = AppColors.warning;
  static const Color warningLight = AppColors.warningLight;
  static const Color success = AppColors.success;
  static const Color successLight = AppColors.successLight;
  static const Color error = AppColors.error;
  static const Color errorLight = AppColors.errorLight;
  static const LinearGradient cardGradient = AppColors.cardGradient;
  static const LinearGradient purpleGradient = AppColors.purpleGradient;

  // Light contextual
  static const Color background = AppColors.backgroundLight;
  static const Color surface = AppColors.surfaceLight;
  static const Color surfaceVariant = AppColors.surfaceVariantLight;
  static const Color border = AppColors.borderLight;
  static const Color textPrimary = AppColors.textPrimaryLight;
  static const Color textSecondary = AppColors.textSecondaryLight;
  static const Color textTertiary = AppColors.textTertiaryLight;
  static const Color textDisabled = Color(0xFFD1D5DB);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surf = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surfVar =
        isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    final brd = isDark ? AppColors.borderDark : AppColors.borderLight;
    final txtPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final txtSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final txtTertiary =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: isDark
          ? AppColors.primary.withOpacity(0.15)
          : AppColors.primaryLight,
      onPrimaryContainer:
          isDark ? const Color(0xFF93C5FD) : AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: isDark
          ? AppColors.secondary.withOpacity(0.15)
          : AppColors.secondaryLight,
      onSecondaryContainer:
          isDark ? const Color(0xFF6EE7B7) : const Color(0xFF064E3B),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: isDark
          ? AppColors.error.withOpacity(0.15)
          : AppColors.errorLight,
      onErrorContainer:
          isDark ? const Color(0xFFFCA5A5) : const Color(0xFF7F1D1D),
      surface: surf,
      onSurface: txtPrimary,
      surfaceContainerHighest: surfVar,
      onSurfaceVariant: txtSecondary,
      outline: brd,
      outlineVariant: isDark ? AppColors.borderDarkAlt : AppColors.borderLightAlt,
      shadow: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
      inverseSurface: txtPrimary,
      onInverseSurface: surf,
      inversePrimary: const Color(0xFF93C5FD),
      surfaceTint: AppColors.primary.withOpacity(0.05),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Roboto',

      appBarTheme: AppBarTheme(
        backgroundColor: surf,
        foregroundColor: txtPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: txtPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: txtPrimary, size: 22),
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: brd, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surf,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: TextStyle(
            color: txtSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: txtTertiary, fontSize: 14),
        errorStyle: const TextStyle(
            color: AppColors.error,
            fontSize: 12,
            fontWeight: FontWeight.w500),
        prefixIconColor: txtSecondary,
        suffixIconColor: txtSecondary,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfVar,
        selectedColor: isDark
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.primaryLight,
        labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: txtSecondary),
        side: BorderSide(color: brd),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      dividerTheme: DividerThemeData(
          color: brd, thickness: 1, space: 1),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surf,
        indicatorColor: isDark
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.primaryLight,
        labelTextStyle:
            WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary);
          }
          return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: txtSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
                color: AppColors.primary, size: 22);
          }
          return IconThemeData(color: txtSecondary, size: 22);
        }),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.15),
        surfaceTintColor: Colors.transparent,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.textPrimaryLight,
        contentTextStyle: TextStyle(
            color: isDark ? txtPrimary : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        elevation: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: txtPrimary,
            letterSpacing: -0.5),
        displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: txtPrimary,
            letterSpacing: -0.4),
        displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: txtPrimary,
            letterSpacing: -0.3),
        headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: txtPrimary,
            letterSpacing: -0.2),
        headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: txtPrimary,
            letterSpacing: -0.2),
        headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: txtPrimary,
            letterSpacing: -0.1),
        titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: txtPrimary),
        titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: txtPrimary),
        titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: txtPrimary),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: txtPrimary),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: txtPrimary),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: txtSecondary),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: txtPrimary,
            letterSpacing: 0.1),
        labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: txtSecondary,
            letterSpacing: 0.1),
        labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: txtTertiary,
            letterSpacing: 0.2),
      ),
    );
  }
}