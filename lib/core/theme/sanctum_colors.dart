import 'package:flutter/material.dart';

/// Shared Sanctum brand colors.
abstract final class SanctumBrand {
  static const indigo = Color(0xFF2E2A6E);
  static const indigoSoft = Color(0xFF4338CA);
  static const emerald = Color(0xFF047857);
  static const emeraldSoft = Color(0xFF059669);
  static const gold = Color(0xFF9A7348);
  static const goldSoft = Color(0xFFC4A574);
  static const radius = 18.0;
  static const radiusSm = 14.0;
}

/// Web `:root` light tokens.
abstract final class SanctumLight {
  static const bg = Color(0xFFF4F2EE);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFFFDFA);
  static const creamDeep = Color(0xFFF0ECE6);
  static const text = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF334155);
  static const textMuted = Color(0xFF64748B);
  static const accent = SanctumBrand.indigo;
  static const border = Color(0x140F172A);
  static const borderStrong = Color(0x1F0F172A);
  static const headerBg = Color(0xF2F4F2EE);
}

/// Web `.dark` tokens.
abstract final class SanctumDark {
  static const bg = Color(0xFF0B1120);
  static const surface = Color(0xFF151D2E);
  static const surfaceElevated = Color(0xFF1A2438);
  static const creamDeep = Color(0xFF0B1120);
  static const text = Color(0xFFE2E8F0);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);
  static const accent = Color(0xFFC7D2FE);
  static const emeraldSoft = Color(0xFF34D399);
  static const border = Color(0x12FFFFFF);
  static const borderStrong = Color(0x1FFFFFFF);
  static const headerBg = Color(0xE00B1120);
}

class SanctumPalette extends ThemeExtension<SanctumPalette> {
  const SanctumPalette({
    required this.bg,
    required this.surface,
    required this.surfaceElevated,
    required this.creamDeep,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.border,
    required this.borderStrong,
    required this.headerBg,
    required this.emeraldFocus,
    required this.chipSelected,
    required this.isDark,
  });

  final Color bg;
  final Color surface;
  final Color surfaceElevated;
  final Color creamDeep;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color border;
  final Color borderStrong;
  final Color headerBg;
  final Color emeraldFocus;
  final Color chipSelected;
  final bool isDark;

  static const light = SanctumPalette(
    bg: SanctumLight.bg,
    surface: SanctumLight.surface,
    surfaceElevated: SanctumLight.surfaceElevated,
    creamDeep: SanctumLight.creamDeep,
    text: SanctumLight.text,
    textSecondary: SanctumLight.textSecondary,
    textMuted: SanctumLight.textMuted,
    accent: SanctumLight.accent,
    border: SanctumLight.border,
    borderStrong: SanctumLight.borderStrong,
    headerBg: SanctumLight.headerBg,
    emeraldFocus: SanctumBrand.emeraldSoft,
    chipSelected: Color(0x142E2A6E),
    isDark: false,
  );

  static const dark = SanctumPalette(
    bg: SanctumDark.bg,
    surface: SanctumDark.surface,
    surfaceElevated: SanctumDark.surfaceElevated,
    creamDeep: SanctumDark.creamDeep,
    text: SanctumDark.text,
    textSecondary: SanctumDark.textSecondary,
    textMuted: SanctumDark.textMuted,
    accent: SanctumDark.accent,
    border: SanctumDark.border,
    borderStrong: SanctumDark.borderStrong,
    headerBg: SanctumDark.headerBg,
    emeraldFocus: SanctumDark.emeraldSoft,
    chipSelected: Color(0x24C7D2FE),
    isDark: true,
  );

  @override
  SanctumPalette copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceElevated,
    Color? creamDeep,
    Color? text,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? border,
    Color? borderStrong,
    Color? headerBg,
    Color? emeraldFocus,
    Color? chipSelected,
    bool? isDark,
  }) {
    return SanctumPalette(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      creamDeep: creamDeep ?? this.creamDeep,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      headerBg: headerBg ?? this.headerBg,
      emeraldFocus: emeraldFocus ?? this.emeraldFocus,
      chipSelected: chipSelected ?? this.chipSelected,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  SanctumPalette lerp(ThemeExtension<SanctumPalette>? other, double t) {
    if (other is! SanctumPalette) return this;
    return t < 0.5 ? this : other;
  }
}
