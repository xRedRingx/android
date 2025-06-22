import 'package:flutter/material.dart';

class AppTheme {
  // --- DARK THEME COLORS ---
  static const Color darkPrimaryColor = Color(0xFF0A0A0A);
  static const Color darkAccentColor = Color(0xFFC62828);
  static const Color darkSurfaceColor = Color(0xFF1C1C1E);
  static const Color darkCtaColor = Color(0xFF2962FF);
  static const Color darkSubtleColor = Color(0xFFC0C0C0);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkTextSecondaryColor = Color(0xFFC0C0C0);
  static const Color darkTextBodyColor = Color(0xFFE0E0E0);

  // --- LIGHT THEME COLORS ---
  static const Color lightPrimaryColor = Color(0xFFFFFFFF);
  static const Color lightAccentColor = Color(0xFFC62828);
  static const Color lightSurfaceColor = Color(0xFFF5F5F5);
  static const Color lightCtaColor = Color(0xFF2962FF);
  static const Color lightSubtleColor = Color(0xFF8A8A8E);
  static const Color lightTextColor = Color(0xFF0A0A0A);
  static const Color lightTextSecondaryColor = Color(0xFF3C3C43);
  static const Color lightTextBodyColor = Color(0xFF4A4A4A);

  // --- DYNAMIC THEME GETTERS REMOVED ---
  // Widgets should use Theme.of(context) for dynamic theme properties.
  // Example: Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary, etc.

  // --- THEMES ---
  // The static _isDarkMode and setThemeMode are removed.
  // Widgets should use Theme.of(context) to get theme properties.

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true, // Enable Material 3
      brightness: Brightness.dark,
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkPrimaryColor,
      colorScheme: ColorScheme.dark(
        brightness: Brightness.dark,
        primary: darkAccentColor,
        onPrimary: darkTextColor,
        secondary: darkCtaColor,
        onSecondary: darkTextColor,
        tertiary: darkSubtleColor,
        surface: darkSurfaceColor,
        onSurface: darkTextColor,
        background: darkPrimaryColor,
        onBackground: darkTextColor,
        error: Colors.redAccent.shade700,
        onError: darkTextColor,
        outline: darkSubtleColor.withOpacity(0.5),
        outlineVariant: darkSubtleColor.withOpacity(0.3),
        surfaceVariant: darkSurfaceColor,
        onSurfaceVariant: darkTextSecondaryColor,
      ),
      splashColor: darkCtaColor.withOpacity(0.2),
      highlightColor: darkAccentColor.withOpacity(0.1),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 57, fontWeight: FontWeight.w400, color: darkTextColor),
        displayMedium: TextStyle(fontFamily: 'Montserrat', fontSize: 45, fontWeight: FontWeight.w400, color: darkTextColor),
        displaySmall: TextStyle(fontFamily: 'Montserrat', fontSize: 36, fontWeight: FontWeight.w400, color: darkTextColor),
        headlineLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 32, fontWeight: FontWeight.bold, color: darkTextColor),
        headlineMedium: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.bold, color: darkTextColor),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w600, color: darkTextColor),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w500, color: darkTextColor),
        titleMedium: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500, color: darkTextColor),
        titleSmall: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: darkTextSecondaryColor),
        bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w400, color: darkTextBodyColor),
        bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w400, color: darkTextSecondaryColor),
        bodySmall: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w400, color: darkTextSecondaryColor),
        labelLarge: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: darkTextColor),
        labelMedium: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: darkTextSecondaryColor),
        labelSmall: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w500, color: darkTextSecondaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkAccentColor,
          foregroundColor: darkTextColor,
          disabledBackgroundColor: darkSubtleColor.withOpacity(0.3),
          disabledForegroundColor: darkTextSecondaryColor.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.7),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkCtaColor,
          disabledForegroundColor: darkSubtleColor.withOpacity(0.5),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkCtaColor,
          side: BorderSide(color: darkCtaColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: darkSubtleColor.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: darkCtaColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.redAccent.shade700, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.redAccent.shade700, width: 2),
        ),
        hintStyle: TextStyle(color: darkTextSecondaryColor.withOpacity(0.6)),
        labelStyle: TextStyle(color: darkTextSecondaryColor),
        errorStyle: TextStyle(color: Colors.redAccent.shade700),
        prefixIconColor: darkSubtleColor,
        suffixIconColor: darkSubtleColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      iconTheme: IconThemeData(color: darkSubtleColor, size: 24),
      primaryIconTheme: IconThemeData(color: darkTextColor, size: 24),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkAccentColor,
        foregroundColor: darkTextColor,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(darkCtaColor.withOpacity(0.8)),
        trackColor: WidgetStateProperty.all(darkSubtleColor.withOpacity(0.2)),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkCtaColor;
          }
          return darkSubtleColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkCtaColor.withOpacity(0.5);
          }
          return darkSubtleColor.withOpacity(0.3);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkCtaColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(darkTextColor),
        side: BorderSide(color: darkSubtleColor, width: 2),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkCtaColor;
          }
          return darkSubtleColor;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceColor,
        selectedColor: darkAccentColor,
        disabledColor: darkSubtleColor.withOpacity(0.3),
        labelStyle: TextStyle(color: darkTextColor),
        secondaryLabelStyle: TextStyle(color: darkTextColor),
        brightness: Brightness.dark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 24,
        titleTextStyle: TextStyle(
          color: darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: darkTextBodyColor,
          fontSize: 16,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceColor,
        contentTextStyle: TextStyle(color: darkTextColor),
        actionTextColor: darkCtaColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: darkAccentColor,
        unselectedItemColor: darkSubtleColor,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: darkTextColor),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // Enable Material 3
      brightness: Brightness.light,
      primaryColor: lightPrimaryColor,
      scaffoldBackgroundColor: lightPrimaryColor,
      colorScheme: ColorScheme.light(
        brightness: Brightness.light,
        primary: lightAccentColor,
        onPrimary: Colors.white,
        secondary: lightCtaColor,
        onSecondary: Colors.white,
        tertiary: lightSubtleColor,
        surface: lightSurfaceColor,
        onSurface: lightTextColor,
        background: lightPrimaryColor,
        onBackground: lightTextColor,
        error: Colors.red.shade900,
        onError: Colors.white,
        outline: lightSubtleColor.withOpacity(0.5),
        outlineVariant: lightSubtleColor.withOpacity(0.3),
        surfaceVariant: lightSurfaceColor,
        onSurfaceVariant: lightTextSecondaryColor,
      ),
      splashColor: lightCtaColor.withOpacity(0.1),
      highlightColor: lightAccentColor.withOpacity(0.1),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 57, fontWeight: FontWeight.w400, color: lightTextColor),
        displayMedium: TextStyle(fontFamily: 'Montserrat', fontSize: 45, fontWeight: FontWeight.w400, color: lightTextColor),
        displaySmall: TextStyle(fontFamily: 'Montserrat', fontSize: 36, fontWeight: FontWeight.w400, color: lightTextColor),
        headlineLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 32, fontWeight: FontWeight.bold, color: lightTextColor),
        headlineMedium: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.bold, color: lightTextColor),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w600, color: lightTextColor),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w500, color: lightTextColor),
        titleMedium: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500, color: lightTextColor),
        titleSmall: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: lightTextSecondaryColor),
        bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w400, color: lightTextBodyColor),
        bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w400, color: lightTextSecondaryColor),
        bodySmall: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w400, color: lightTextSecondaryColor),
        labelLarge: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: lightTextColor),
        labelMedium: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: lightTextSecondaryColor),
        labelSmall: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w500, color: lightTextSecondaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightAccentColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: lightSubtleColor.withOpacity(0.3),
          disabledForegroundColor: lightTextSecondaryColor.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 4,
          shadowColor: lightAccentColor.withOpacity(0.3),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightCtaColor,
          disabledForegroundColor: lightSubtleColor.withOpacity(0.5),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightCtaColor,
          side: BorderSide(color: lightCtaColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: lightSubtleColor.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: lightCtaColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade900, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade900, width: 2),
        ),
        hintStyle: TextStyle(color: lightTextSecondaryColor.withOpacity(0.6)),
        labelStyle: TextStyle(color: lightTextSecondaryColor),
        errorStyle: TextStyle(color: Colors.red.shade900),
        prefixIconColor: lightSubtleColor,
        suffixIconColor: lightSubtleColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: lightSurfaceColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      iconTheme: IconThemeData(color: lightSubtleColor, size: 24),
      primaryIconTheme: IconThemeData(color: lightTextColor, size: 24),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightAccentColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(lightCtaColor.withOpacity(0.8)),
        trackColor: WidgetStateProperty.all(lightSubtleColor.withOpacity(0.2)),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightCtaColor;
          }
          return lightSubtleColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightCtaColor.withOpacity(0.5);
          }
          return lightSubtleColor.withOpacity(0.3);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightCtaColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: lightSubtleColor, width: 2),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightCtaColor;
          }
          return lightSubtleColor;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightSurfaceColor,
        selectedColor: lightAccentColor,
        disabledColor: lightSubtleColor.withOpacity(0.3),
        labelStyle: TextStyle(color: lightTextColor),
        secondaryLabelStyle: TextStyle(color: Colors.white),
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 24,
        titleTextStyle: TextStyle(
          color: lightTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: lightTextBodyColor,
          fontSize: 16,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightTextColor,
        contentTextStyle: TextStyle(color: lightPrimaryColor),
        actionTextColor: lightCtaColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightSurfaceColor,
        selectedItemColor: lightAccentColor,
        unselectedItemColor: lightSubtleColor,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightPrimaryColor,
        foregroundColor: lightTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: lightTextColor),
      ),
    );
  }
}