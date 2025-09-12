import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/provider/menu/theme/theme_provider.dart';
import 'package:talknep/util/theme_extension.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final selectedTheme = provider.currentAppTheme;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: const AppAppbar(title: "Theme"),
      body: Column(
        children: [
          RadioListTile<AppTheme>(
            title: const Text("System Default"),
            value: AppTheme.system,
            groupValue: selectedTheme,
            onChanged: (theme) {
              if (theme != null) provider.setTheme(theme);
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text("Light Theme"),
            value: AppTheme.light,
            groupValue: selectedTheme,
            onChanged: (theme) {
              if (theme != null) provider.setTheme(theme);
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text("Dark Theme"),
            value: AppTheme.dark,
            groupValue: selectedTheme,
            onChanged: (theme) {
              if (theme != null) provider.setTheme(theme);
            },
          ),
        ],
      ),
    );
  }
}
