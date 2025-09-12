import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/provider/menu/about_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  String cleanHtml(String html) {
    html = html.replaceAll(
      RegExp(r'<style[^>]*>.*?</style>', dotAll: true),
      '',
    );
    html = html.replaceAll(RegExp(r'font-feature-settings\s*:\s*[^;"]+;?'), '');
    return html;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(title: "Privacy Policy"),
      backgroundColor: context.scaffoldBackgroundColor,
      body: Consumer<AboutProvider>(
        builder: (context, provider, child) {
          return provider.isLoading
              ? Center(
                child: CommonLoader(
                  fullScreen: true,
                  color: context.colorsScheme.primary,
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Sizer.w(3)),
                child: Html(
                  data: cleanHtml(provider.privacyPolicyData ?? ""),
                  style: {
                    "h1": Style(
                      color: context.colorsScheme.onSurface,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                    "h3": Style(
                      color: context.colorsScheme.onSurface,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                    "h4": Style(
                      color: context.colorsScheme.onSurface,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                    "p": Style(
                      color: context.colorsScheme.onSurface,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                    "li": Style(
                      color: context.colorsScheme.onSurface,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  },
                ),
              );
        },
      ),
    );
  }
}
