import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';

ThemeData dark({Color color = AppColors.primaryOrange}) => ThemeData(
  fontFamily: GoogleFonts.notoSansArabic().fontFamily,
  scaffoldBackgroundColor: Color(0xff212224),
  primaryColor: color,
  secondaryHeaderColor: AppColors.primaryBlue,
  disabledColor: const Color(0xffa2a7ad),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: const Color(0xFF30313C),
  shadowColor: Colors.white,
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: color),
  ),
  colorScheme: ColorScheme.dark(primary: color, secondary: color)
      .copyWith(surface: const Color(0xFF191A26))
      .copyWith(error: const Color(0xFFdd3135)),
  popupMenuTheme: const PopupMenuThemeData(
    color: Color(0xFF29292D),
    surfaceTintColor: Color(0xFF29292D),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    surfaceTintColor: Colors.black,
    height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    color: Color(0xFFA0A4A8),
  ),
);
