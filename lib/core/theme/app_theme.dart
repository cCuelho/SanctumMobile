import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sanctum_colors.dart';

/// Sanctum Mobile theme — light + dark, aligned with web `src/index.css`.
abstract final class AppTheme {
  static ThemeData light() => _build(SanctumPalette.light);

  static ThemeData dark() => _build(SanctumPalette.dark);

  static ThemeData _build(SanctumPalette p) {
    final scheme = (p.isDark ? ColorScheme.dark : ColorScheme.light)(
      primary: p.isDark ? SanctumDark.accent : SanctumBrand.indigo,
      onPrimary: p.isDark ? const Color(0xFF1E1B4B) : Colors.white,
      primaryContainer: p.isDark ? const Color(0xFF312E81) : const Color(0xFFECEAF8),
      onPrimaryContainer: p.isDark ? SanctumDark.accent : SanctumBrand.indigo,
      secondary: p.emeraldFocus,
      onSecondary: p.isDark ? const Color(0xFF064E3B) : Colors.white,
      tertiary: SanctumBrand.goldSoft,
      surface: p.surface,
      onSurface: p.text,
      onSurfaceVariant: p.textMuted,
      outline: p.borderStrong,
      outlineVariant: p.border,
    ).copyWith(
      surfaceTint: Colors.transparent,
      surfaceContainerHighest: p.creamDeep,
      surfaceContainerHigh: p.surfaceElevated,
      surfaceContainer: p.surfaceElevated,
      surfaceContainerLow: p.bg,
      surfaceContainerLowest: p.bg,
    );

    final textTheme = TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: p.text,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: p.text,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: p.text,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: p.text,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        height: 1.5,
        color: p.text,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.55,
        color: p.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.45,
        color: p.textMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: p.text,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.isDark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: p.headerBg,
        foregroundColor: p.text,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle:
            p.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SanctumBrand.radius),
          side: BorderSide(color: p.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.border,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SanctumBrand.indigoSoft,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SanctumBrand.radiusSm),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          backgroundColor: p.surface,
          minimumSize: const Size(0, 44),
          side: BorderSide(color: p.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SanctumBrand.radiusSm),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SanctumBrand.indigoSoft,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: selected ? p.accent : p.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? p.accent : p.textMuted,
            size: 22,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SanctumBrand.radius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.creamDeep,
        selectedColor: p.chipSelected,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: p.text,
        ),
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SanctumBrand.radiusSm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(color: p.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.emeraldFocus, width: 1.5),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surfaceElevated,
        contentTextStyle: TextStyle(color: p.text),
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.border),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.text,
      ),
      extensions: [p],
    );
  }
}

extension SanctumTheme on BuildContext {
  SanctumPalette get sanctumPalette =>
      Theme.of(this).extension<SanctumPalette>() ?? SanctumPalette.light;
}
