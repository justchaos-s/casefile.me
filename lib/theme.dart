import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour tokens: charcoal workstation with one restrained red accent.
class C {
  static const bg = Color(0xFF111113);
  static const surface = Color(0xFF18181B);
  static const panel = Color(0xFF1E1E22);
  static const border = Color(0xFF2C2C32);
  static const red = Color(0xFFE5383B);
  static const text = Color(0xFFEDEDF0);
  static const muted = Color(0xFF8A8A94);
}

/// Monospace style used only for case IDs, CVEs and timestamps.
TextStyle mono([
  double size = 12,
  Color color = C.muted,
  FontWeight weight = FontWeight.w500,
]) => GoogleFonts.jetBrainsMono(
  fontSize: size,
  color: color,
  fontWeight: weight,
  letterSpacing: 0.3,
);

OutlineInputBorder _ob(Color c) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(6),
  borderSide: BorderSide(color: c),
);

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final interFamily = GoogleFonts.inter().fontFamily;
  final buildText = base.textTheme.apply(
    fontFamily: interFamily,
    bodyColor: C.text,
    displayColor: C.text,
  );

  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    colorScheme: const ColorScheme.dark(
      primary: C.red,
      onPrimary: Colors.white,
      secondary: C.red,
      surface: C.surface,
      onSurface: C.text,
      error: C.red,
    ),
    textTheme: buildText,
    dividerColor: C.border,
    appBarTheme: AppBarTheme(
      backgroundColor: C.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: C.text),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: C.text,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.panel,
      labelStyle: const TextStyle(color: C.muted),
      hintStyle: const TextStyle(color: C.muted),
      border: _ob(C.border),
      enabledBorder: _ob(C.border),
      focusedBorder: _ob(C.red),
      errorBorder: _ob(C.red),
      focusedErrorBorder: _ob(C.red),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.red,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.text,
        side: const BorderSide(color: C.border),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: C.red),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: C.red,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.surface,
      indicatorColor: C.red.withValues(alpha: .16),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? C.red : C.muted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          color: s.contains(WidgetState.selected) ? C.text : C.muted,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.panel,
      contentTextStyle: const TextStyle(color: C.text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: C.border),
      ),
    ),
  );
}
