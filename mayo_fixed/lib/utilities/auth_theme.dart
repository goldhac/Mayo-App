import 'package:flutter/material.dart';

/// Authentication theme utility that provides consistent styling
/// for authentication screens while preserving the default system font
class AuthTheme {
  // Define the default font family for authentication screens
  static const String? _authFontFamily = null; // Uses system default
  
  /// Get a ThemeData specifically for authentication screens
  /// This preserves the original font while other screens use Lexend
  static ThemeData getAuthTheme(BuildContext context) {
    final baseTheme = Theme.of(context);
    
    return baseTheme.copyWith(
      // Override the font family to use system default instead of Lexend
      textTheme: baseTheme.textTheme.copyWith(
        displayLarge: baseTheme.textTheme.displayLarge?.copyWith(fontFamily: _authFontFamily),
        displayMedium: baseTheme.textTheme.displayMedium?.copyWith(fontFamily: _authFontFamily),
        displaySmall: baseTheme.textTheme.displaySmall?.copyWith(fontFamily: _authFontFamily),
        headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(fontFamily: _authFontFamily),
        headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(fontFamily: _authFontFamily),
        headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(fontFamily: _authFontFamily),
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(fontFamily: _authFontFamily),
        titleMedium: baseTheme.textTheme.titleMedium?.copyWith(fontFamily: _authFontFamily),
        titleSmall: baseTheme.textTheme.titleSmall?.copyWith(fontFamily: _authFontFamily),
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontFamily: _authFontFamily),
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontFamily: _authFontFamily),
        bodySmall: baseTheme.textTheme.bodySmall?.copyWith(fontFamily: _authFontFamily),
        labelLarge: baseTheme.textTheme.labelLarge?.copyWith(fontFamily: _authFontFamily),
        labelMedium: baseTheme.textTheme.labelMedium?.copyWith(fontFamily: _authFontFamily),
        labelSmall: baseTheme.textTheme.labelSmall?.copyWith(fontFamily: _authFontFamily),
      ),
    );
  }
  
  /// Get text style for authentication screens with system default font
  static TextStyle getAuthTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: _authFontFamily, // Uses system default
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}