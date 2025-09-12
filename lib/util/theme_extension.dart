import 'package:flutter/material.dart';

extension ThemeContextExtension on BuildContext {
  ColorScheme get colorsScheme => Theme.of(this).colorScheme;

  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;
}
