import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/app_appbar.dart';
import 'package:talknep/provider/menu/about_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(title: "About"),
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
                  shrinkWrap: true,
                  data: provider.aboutData,
                  style: {
                    "h2": Style(
                      fontSize: FontSize.xLarge,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      color: context.colorsScheme.onSecondaryContainer,
                    ),
                    "p": Style(
                      fontSize: FontSize.medium,
                      lineHeight: LineHeight.number(1.5),
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      color: context.colorsScheme.onSecondaryContainer,
                    ),
                  },
                ),
              );
        },
      ),
    );
  }
}
