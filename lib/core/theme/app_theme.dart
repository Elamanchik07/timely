import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Dark-Blue Palette ───
  static const Color primaryDark = Color(0xFF0D1B2A);    // Rich Black
  static const Color primaryMid = Color(0xFF1B263B);      // Oxford Blue
  static const Color primaryLight = Color(0xFF415A77);    // Slate
  static const Color accent = Color(0xFF3A86FF);          // Vivid Blue
  static const Color accentLight = Color(0xFF5EA1FF);     // Light Vivid Blue
  static const Color surfaceColor = Color(0xFF1E2D42);    // Card Surface
  static const Color backgroundColor = Color(0xFF0D1B2A); // Background
  static const Color errorColor = Color(0xFFFF6B6B);      // Soft Red
  static const Color successColor = Color(0xFF00D68F);    // Minted Green
  static const Color warningColor = Color(0xFFFFBE0B);    // Amber
  static const Color textPrimary = Color(0xFFE0E6ED);     // Off-White
  static const Color textSecondary = Color(0xFF8899A8);   // Muted
  static const Color dividerColor = Color(0xFF2A3A50);    // Subtle divider
  static const Color primaryColor = accent;               // Backward compatibility

  static const double borderRadius = 16.0;
  static const double borderRadiusLarge = 20.0;

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: accent,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentLight,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // Typography
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700, fontSize: 32, color: textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600, fontSize: 24, color: textPrimary,
        ),
        displaySmall: GoogleFonts.inter(
          fontWeight: FontWeight.w600, fontSize: 20, color: textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600, fontSize: 18, color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600, fontSize: 18, color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w500, fontSize: 16, color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w400, fontSize: 16, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w400, fontSize: 14, color: textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontWeight: FontWeight.w400, fontSize: 12, color: textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryMid,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600, fontSize: 18, color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: dividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
        floatingLabelStyle: const TextStyle(color: accent),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: accent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Page Transitions (Smooth)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // NavigationBar (bottom)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: primaryMid,
        indicatorColor: accent.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: accent,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary,
          );
        }),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 70,
      ),

      // TabBar
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: textSecondary,
        indicatorColor: accent,
        labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        dividerColor: dividerColor,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14, color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: primaryMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14, color: textSecondary,
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: accent.withOpacity(0.2),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: textPrimary),
        side: const BorderSide(color: dividerColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: textSecondary, size: 24),

      // Dropdown
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: dividerColor),
          ),
        ),
      ),

      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: primaryMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(fontSize: 14, color: textPrimary),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: primaryMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
    );
  }

  // Keep a light theme getter for compatibility, but default to dark
  static ThemeData get lightTheme => darkTheme;
}
