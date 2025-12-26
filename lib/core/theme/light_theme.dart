import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';

ThemeData light({Color color = AppColors.primaryOrange}) => ThemeData(
  fontFamily: GoogleFonts.notoSansArabic().fontFamily,
  scaffoldBackgroundColor: Color(0xffF5F5F5),
  primaryColor: color,
  secondaryHeaderColor: AppColors.primaryBlue,
  disabledColor: const Color(0xFFBABFC4),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  shadowColor: Colors.black,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: color),
  ),
  colorScheme: ColorScheme.light(primary: color, secondary: color)
      .copyWith(surface: const Color(0xFFFCFCFC))
      .copyWith(error: const Color(0xFFE84D4F)),
  popupMenuTheme: const PopupMenuThemeData(
    color: Colors.white,
    surfaceTintColor: Colors.white,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    surfaceTintColor: Colors.white,
    height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(
    thickness: 0.2,
    color: Color(0xFFA0A4A8),
  ),
);
