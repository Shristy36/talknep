import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_sizer.dart';

class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final List<Shadow>? shadows;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText({
    super.key,
    required this.text,
    this.fontSize,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.shadows,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: GoogleFonts.poppins(
        fontSize: fontSize ?? Sizer.sp(4),
        shadows: shadows,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
