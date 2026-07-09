import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Vibrant modern indigo — bright enough to stand out, not so dark it feels heavy.
  static const _primary = Color(0xFF4F46E5);
  static const _secondary = Color(0xFF10B981);
  static const _tertiary = Color(0xFF8B5CF6);

  static ColorScheme _colorScheme({required Brightness brightness}) {
    final isLight = brightness == Brightness.light;
    return ColorScheme(
      brightness: brightness,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Colors.white,
      tertiary: _tertiary,
      onTertiary: Colors.white,
      surface: isLight ? const Color(0xFFFAFAFE) : const Color(0xFF111318),
      onSurface: isLight ? const Color(0xFF1C1B1F) : const Color(0xFFE8E9ED),
      surfaceContainerHighest: isLight
          ? const Color(0xFFEFF0F6)
          : const Color(0xFF2A2D35),
      surfaceContainerLowest: isLight
          ? const Color(0xFFFEFEFF)
          : const Color(0xFF1E2028),
      surfaceContainerLow: isLight
          ? const Color(0xFFF4F4FA)
          : const Color(0xFF24272F),
      surfaceContainer: isLight
          ? const Color(0xFFECECF4)
          : const Color(0xFF2E3139),
      surfaceContainerHigh: isLight
          ? const Color(0xFFE2E2EC)
          : const Color(0xFF383B43),
      outlineVariant: isLight
          ? const Color(0xFFCAC4D0)
          : const Color(0xFF45484F),
      outline: isLight ? const Color(0xFF8A8D9C) : const Color(0xFF8A8D9C),
      error: isLight ? const Color(0xFFDC2626) : const Color(0xFFEF9A9A),
      onError: Colors.white,
      primaryContainer: isLight
          ? const Color(0xFFE0E7FF)
          : const Color(0xFF312E81),
      onPrimaryContainer: isLight
          ? const Color(0xFF1E1B4B)
          : const Color(0xFFE0E7FF),
      secondaryContainer: isLight
          ? const Color(0xFFD1FAE5)
          : const Color(0xFF064E3B),
      onSecondaryContainer: isLight
          ? const Color(0xFF064E3B)
          : const Color(0xFFD1FAE5),
      tertiaryContainer: isLight
          ? const Color(0xFFEDE9FE)
          : const Color(0xFF4C1D95),
      onTertiaryContainer: isLight
          ? const Color(0xFF2E1065)
          : const Color(0xFFEDE9FE),
    );
  }

  static ThemeData lightTheme = _buildTheme(Brightness.light);
  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = _colorScheme(brightness: brightness);
    final textTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLowest.withAlpha(200),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerLowest.withAlpha(220),
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(size: 24, color: colorScheme.primary);
          }
          return IconThemeData(size: 22, color: colorScheme.onSurfaceVariant);
        }),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(120),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.primary.withAlpha(150),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        labelStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
        hintStyle: GoogleFonts.inter(color: colorScheme.outline),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withAlpha(60),
        thickness: 1,
      ),

      scaffoldBackgroundColor: colorScheme.surface,

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static BoxDecoration glassDecoration(BuildContext context, {Color? accent}) {
    final theme = Theme.of(context);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surfaceContainerLowest.withAlpha(220),
          theme.colorScheme.surfaceContainerLow.withAlpha(180),
        ],
      ),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withAlpha(50),
      ),
      boxShadow: [
        BoxShadow(
          color: (accent ?? theme.colorScheme.primary).withAlpha(20),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static LinearGradient primaryGradient(BuildContext context) {
    final theme = Theme.of(context);
    return LinearGradient(
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.primary.withAlpha(190),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient successGradient(BuildContext context) {
    final theme = Theme.of(context);
    return LinearGradient(
      colors: [
        theme.colorScheme.secondary,
        theme.colorScheme.secondary.withAlpha(180),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient surfaceGradient(BuildContext context) {
    final theme = Theme.of(context);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.colorScheme.surface,
        theme.colorScheme.surfaceContainerLowest,
      ],
    );
  }
}
