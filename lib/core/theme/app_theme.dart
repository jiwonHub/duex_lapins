import 'package:duex_lapins/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const background = Color(0xFFF3F0E9);
  static const surface = Color(0xFFF8F5EF);
  static const text = Color(0xFF171511);
  static const muted = Color(0xFF6B665E);
  static const line = Color(0xFFCBC5BA);
  static const soft = Color(0xFFE8E3DA);
  static const darkBrown = Color(0xFF2B241E);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: text,
        brightness: Brightness.light,
        surface: surface,
      ),
    );

    final textTheme = base.textTheme.copyWith(
      displayLarge: AppTypography.serif(
        fontSize: 72,
        height: 0.92,
        fontWeight: FontWeight.w500,
      ),
      displayMedium: AppTypography.serif(
        fontSize: 56,
        height: 0.95,
        fontWeight: FontWeight.w500,
      ),
      displaySmall: AppTypography.serif(
        fontSize: 44,
        height: 0.98,
        fontWeight: FontWeight.w500,
      ),
      headlineLarge: AppTypography.serif(
        fontSize: 38,
        height: 1,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: AppTypography.serif(
        fontSize: 32,
        height: 1.02,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: AppTypography.serif(
        fontSize: 26,
        height: 1.05,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: const TextStyle(
        color: text,
        fontSize: 15,
        height: 1.65,
      ),
      bodyMedium: const TextStyle(
        color: text,
        fontSize: 13,
        height: 1.65,
      ),
      bodySmall: const TextStyle(
        color: muted,
        fontSize: 11,
        height: 1.5,
      ),
      labelLarge: const TextStyle(
        color: text,
        fontSize: 11,
        letterSpacing: 1.25,
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      dividerColor: line,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        labelStyle: TextStyle(
          color: muted,
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: muted,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: text, width: 1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: text,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          textStyle: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.35,
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: const BorderSide(color: text, width: 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: text,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w600,
          ),
          shape: const RoundedRectangleBorder(),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: text,
          shape: const RoundedRectangleBorder(),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.transparent,
        selectedColor: soft,
        labelStyle: const TextStyle(
          color: text,
          fontSize: 10,
          letterSpacing: 0.7,
        ),
        side: const BorderSide(color: line, width: 0.8),
        shape: const RoundedRectangleBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: background,
        shape: RoundedRectangleBorder(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: background,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: text,
            fontSize: 9,
            letterSpacing: 0.7,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w400,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: text,
        contentTextStyle: TextStyle(
          color: background,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
