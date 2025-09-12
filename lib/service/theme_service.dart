import 'package:flutter/material.dart';
import 'package:talknep/constant/app_color.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.whiteColor,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.textPrimaryColor),
    bodyMedium: TextStyle(color: AppColors.textSecondaryColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.whiteColor,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.whiteColor,
    selectedItemColor: AppColors.primaryColor,
    unselectedItemColor: AppColors.blackColor,
    selectedIconTheme: IconThemeData(color: AppColors.primaryColor),
    unselectedIconTheme: IconThemeData(color: AppColors.blackColor),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    modalBackgroundColor: AppColors.whiteColor,
  ),
  dividerColor: AppColors.blackColor.withValues(alpha: 0.3),
  datePickerTheme: DatePickerThemeData(
    dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.focused)) {
        return AppColors.primaryColor;
      }
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return null;
    }),
    dayOverlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return null;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryColor;
      }
      return null;
    }),
  ),
  timePickerTheme: TimePickerThemeData(
    dialHandColor: AppColors.primaryColor,
    dialTextColor: AppColors.blackColor,
    backgroundColor: AppColors.whiteColor,
    entryModeIconColor: AppColors.primaryColor,
    hourMinuteTextColor: AppColors.blackColor,
    hourMinuteColor: AppColors.primaryColor.withValues(alpha: 0.1),
    dialBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
    dayPeriodColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryColor;
      }
      return AppColors.primaryColor.withValues(alpha: 0.1);
    }),
    dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.whiteColor;
      }
      return AppColors.primaryColor;
    }),
  ),
  colorScheme: ColorScheme.light(
    error: AppColors.errorColor,
    surface: AppColors.whiteColor,
    primary: AppColors.primaryColor,
    onSurface: AppColors.blackColor,
    onPrimary: AppColors.whiteColor,
    secondary: AppColors.secondaryColor,
    secondaryContainer: AppColors.blackColor,
    shadow: AppColors.blackColor.withAlpha(15),
    onSecondary: AppColors.borderColor, //Border Color
    onSecondaryContainer: AppColors.textPrimaryColor,
  ),
);

final darkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    error: AppColors.errorColor,
    surface: AppColors.blackColor,
    primary: AppColors.primaryColor,
    onPrimary: AppColors.blackColor,
    onSurface: AppColors.whiteColor,
    secondary: AppColors.secondaryColor,
    secondaryContainer: AppColors.whiteColor,
    shadow: AppColors.whiteColor.withAlpha(15),
    onSecondaryContainer: AppColors.whiteColor,
    onSecondary: AppColors.whiteColor.withValues(alpha: 0.5), //Border Color
  ),
  datePickerTheme: DatePickerThemeData(
    dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.focused)) {
        return AppColors.primaryColor; // Color for today's date
      }
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryColor; // Text color for selected date
      }
      return null;
    }),
    dayOverlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent; // Prevent default overlay on selected date
      }
      return null;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.whiteColor; // Background color for selected date
      }
      return null;
    }),
  ),

  brightness: Brightness.dark,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.blackColor,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.whiteColor),
    bodyMedium: TextStyle(color: AppColors.textSecondaryColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.blackColor,
    ),
  ),
  dividerColor: AppColors.whiteColor.withValues(alpha: 0.3),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.blackColor,
    selectedItemColor: AppColors.primaryColor,
    unselectedItemColor: AppColors.whiteColor.withValues(alpha: 0.6),
    selectedIconTheme: IconThemeData(color: AppColors.primaryColor),
    unselectedIconTheme: IconThemeData(color: AppColors.whiteColor),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    modalBackgroundColor: AppColors.blackColor,
    backgroundColor: AppColors.greyColor,
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: AppColors.blackColor,
    hourMinuteColor: AppColors.primaryColor.withValues(alpha: 0.2),
    dialBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
    hourMinuteTextColor: AppColors.primaryColor,
    dialHandColor: AppColors.textSecondaryColor,
    dialTextColor: AppColors.whiteColor,
    entryModeIconColor: AppColors.primaryColor,
  ),
);
