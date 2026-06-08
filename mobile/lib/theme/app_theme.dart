import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MnColors extends ThemeExtension<MnColors> {
  const MnColors({
    required this.bgDeep,
    required this.bgElevated,
    required this.bgCard,
    required this.bgInset,
    required this.border,
    required this.borderSubtle,
    required this.textSoft,
    required this.textMuted,
    required this.textFaint,
    required this.accentDeep,
    required this.accentHover,
    required this.accentSoft,
    required this.accentGlow,
    required this.accentRing,
    required this.riskHigh,
    required this.riskHighSoft,
    required this.riskHighRing,
    required this.riskMid,
    required this.riskMidSoft,
    required this.riskMidRing,
    required this.riskSafe,
    required this.riskSafeSoft,
    required this.riskSafeRing,
    required this.logoFg,
  });

  final Color bgDeep;
  final Color bgElevated;
  final Color bgCard;
  final Color bgInset;
  final Color border;
  final Color borderSubtle;
  final Color textSoft;
  final Color textMuted;
  final Color textFaint;
  final Color accentDeep;
  final Color accentHover;
  final Color accentSoft;
  final Color accentGlow;
  final Color accentRing;
  final Color riskHigh;
  final Color riskHighSoft;
  final Color riskHighRing;
  final Color riskMid;
  final Color riskMidSoft;
  final Color riskMidRing;
  final Color riskSafe;
  final Color riskSafeSoft;
  final Color riskSafeRing;
  final Color logoFg;

  @override
  MnColors copyWith({
    Color? bgDeep, Color? bgElevated, Color? bgCard, Color? bgInset,
    Color? border, Color? borderSubtle, Color? textSoft, Color? textMuted,
    Color? textFaint, Color? accentDeep, Color? accentHover, Color? accentSoft,
    Color? accentGlow, Color? accentRing, Color? riskHigh, Color? riskHighSoft,
    Color? riskHighRing, Color? riskMid, Color? riskMidSoft, Color? riskMidRing,
    Color? riskSafe, Color? riskSafeSoft, Color? riskSafeRing, Color? logoFg,
  }) => MnColors(
    bgDeep: bgDeep ?? this.bgDeep,
    bgElevated: bgElevated ?? this.bgElevated,
    bgCard: bgCard ?? this.bgCard,
    bgInset: bgInset ?? this.bgInset,
    border: border ?? this.border,
    borderSubtle: borderSubtle ?? this.borderSubtle,
    textSoft: textSoft ?? this.textSoft,
    textMuted: textMuted ?? this.textMuted,
    textFaint: textFaint ?? this.textFaint,
    accentDeep: accentDeep ?? this.accentDeep,
    accentHover: accentHover ?? this.accentHover,
    accentSoft: accentSoft ?? this.accentSoft,
    accentGlow: accentGlow ?? this.accentGlow,
    accentRing: accentRing ?? this.accentRing,
    riskHigh: riskHigh ?? this.riskHigh,
    riskHighSoft: riskHighSoft ?? this.riskHighSoft,
    riskHighRing: riskHighRing ?? this.riskHighRing,
    riskMid: riskMid ?? this.riskMid,
    riskMidSoft: riskMidSoft ?? this.riskMidSoft,
    riskMidRing: riskMidRing ?? this.riskMidRing,
    riskSafe: riskSafe ?? this.riskSafe,
    riskSafeSoft: riskSafeSoft ?? this.riskSafeSoft,
    riskSafeRing: riskSafeRing ?? this.riskSafeRing,
    logoFg: logoFg ?? this.logoFg,
  );

  @override
  MnColors lerp(MnColors? other, double t) {
    if (other == null) return this;
    return MnColors(
      bgDeep: Color.lerp(bgDeep, other.bgDeep, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgInset: Color.lerp(bgInset, other.bgInset, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textSoft: Color.lerp(textSoft, other.textSoft, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      accentRing: Color.lerp(accentRing, other.accentRing, t)!,
      riskHigh: Color.lerp(riskHigh, other.riskHigh, t)!,
      riskHighSoft: Color.lerp(riskHighSoft, other.riskHighSoft, t)!,
      riskHighRing: Color.lerp(riskHighRing, other.riskHighRing, t)!,
      riskMid: Color.lerp(riskMid, other.riskMid, t)!,
      riskMidSoft: Color.lerp(riskMidSoft, other.riskMidSoft, t)!,
      riskMidRing: Color.lerp(riskMidRing, other.riskMidRing, t)!,
      riskSafe: Color.lerp(riskSafe, other.riskSafe, t)!,
      riskSafeSoft: Color.lerp(riskSafeSoft, other.riskSafeSoft, t)!,
      riskSafeRing: Color.lerp(riskSafeRing, other.riskSafeRing, t)!,
      logoFg: Color.lerp(logoFg, other.logoFg, t)!,
    );
  }

  static MnColors of(BuildContext context) =>
      Theme.of(context).extension<MnColors>()!;
}

class AppTheme {
  static TextTheme _textTheme(Color text, Color soft) => TextTheme(
    displayLarge: GoogleFonts.newsreader(fontWeight: FontWeight.w500, letterSpacing: -0.035, color: text),
    headlineLarge: GoogleFonts.newsreader(fontWeight: FontWeight.w500, letterSpacing: -0.025, color: text),
    headlineMedium: GoogleFonts.newsreader(fontWeight: FontWeight.w500, letterSpacing: -0.02, color: text),
    headlineSmall: GoogleFonts.newsreader(fontWeight: FontWeight.w500, letterSpacing: -0.015, color: text),
    titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: -0.01, color: text),
    titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, letterSpacing: -0.005, color: text),
    titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: text),
    bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, color: soft),
    bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: soft),
    bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12, color: soft),
    labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14.5, color: text),
    labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12, color: soft),
    labelSmall: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w500, fontSize: 10, letterSpacing: 0.08, color: soft),
  );

  static ThemeData dark() {
    const bg = Color(0xFF0B0B0E);
    const text = Color(0xFFECE8DE);
    const textSoft = Color(0xFFC2BDB1);
    const accent = Color(0xFFC89A5C);

    final mn = MnColors(
      bgDeep: const Color(0xFF060608),
      bgElevated: const Color(0xFF131318),
      bgCard: const Color(0xFF16161B),
      bgInset: const Color(0xFF101015),
      border: const Color(0xFF22222A),
      borderSubtle: const Color(0xFF1A1A20),
      textSoft: const Color(0xFFC2BDB1),
      textMuted: const Color(0xFF7F7A6E),
      textFaint: const Color(0xFF545048),
      accentDeep: const Color(0xFF9A6F3C),
      accentHover: const Color(0xFFD6AC72),
      accentSoft: const Color(0xFF2A2018),
      accentGlow: const Color(0x4CC89A5C),
      accentRing: const Color(0xFF4A3A24),
      riskHigh: const Color(0xFFC75D5D),
      riskHighSoft: const Color(0xFF2A1818),
      riskHighRing: const Color(0xFF4A2424),
      riskMid: const Color(0xFFC99B4B),
      riskMidSoft: const Color(0xFF2A2118),
      riskMidRing: const Color(0xFF4A3A24),
      riskSafe: const Color(0xFF6FA88A),
      riskSafeSoft: const Color(0xFF182521),
      riskSafeRing: const Color(0xFF244A3A),
      logoFg: const Color(0xFF1A1A1F),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        onPrimary: Color(0xFF1A1A1F),
        secondary: accent,
        surface: Color(0xFF16161B),
        onSurface: text,
        outline: Color(0xFF22222A),
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(text, textSoft),
      extensions: [mn],
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.015, color: text),
        iconTheme: const IconThemeData(color: Color(0xFFC2BDB1)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF131318),
        indicatorColor: const Color(0xFF2A2018),
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: s.contains(WidgetState.selected) ? accent : const Color(0xFF7F7A6E),
        )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? accent : const Color(0xFF7F7A6E),
          size: 22,
        )),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF101015),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF22222A))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF22222A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: accent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF545048), fontSize: 14.5),
      ),
      dividerColor: const Color(0xFF1A1A20),
    );
  }

  static ThemeData light() {
    const bg = Color(0xFFFAFAF6);
    const text = Color(0xFF1A1A1F);
    const textSoft = Color(0xFF46464F);
    const accent = Color(0xFF9A6F3C);

    final mn = MnColors(
      bgDeep: const Color(0xFFF2F0E8),
      bgElevated: const Color(0xFFFFFFFF),
      bgCard: const Color(0xFFFFFFFF),
      bgInset: const Color(0xFFF2F0E8),
      border: const Color(0xFFE5E2D6),
      borderSubtle: const Color(0xFFEFECE0),
      textSoft: const Color(0xFF46464F),
      textMuted: const Color(0xFF6E6E78),
      textFaint: const Color(0xFF9A9A9F),
      accentDeep: const Color(0xFF7A562C),
      accentHover: const Color(0xFFB58452),
      accentSoft: const Color(0xFFF6EFE2),
      accentGlow: const Color(0x389A6F3C),
      accentRing: const Color(0xFFE8DCC2),
      riskHigh: const Color(0xFFB14848),
      riskHighSoft: const Color(0xFFFBEFEF),
      riskHighRing: const Color(0xFFEFD0D0),
      riskMid: const Color(0xFFB07F2E),
      riskMidSoft: const Color(0xFFFBF4E5),
      riskMidRing: const Color(0xFFEFDEB5),
      riskSafe: const Color(0xFF4F8770),
      riskSafeSoft: const Color(0xFFECF4EF),
      riskSafeRing: const Color(0xFFC5DCD0),
      logoFg: const Color(0xFFFAFAF6),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: accent,
        onPrimary: Color(0xFFFAFAF6),
        secondary: accent,
        surface: Color(0xFFFFFFFF),
        onSurface: text,
        outline: Color(0xFFE5E2D6),
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(text, textSoft),
      extensions: [mn],
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.015, color: text),
        iconTheme: const IconThemeData(color: Color(0xFF46464F)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        indicatorColor: const Color(0xFFF6EFE2),
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: s.contains(WidgetState.selected) ? accent : const Color(0xFF6E6E78),
        )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? accent : const Color(0xFF6E6E78),
          size: 22,
        )),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF2F0E8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E2D6))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E2D6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: accent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF9A9A9F), fontSize: 14.5),
      ),
      dividerColor: const Color(0xFFEFECE0),
    );
  }
}
