import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:talknep/widget/app_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class DescriptionText extends StatefulWidget {
  final String htmlDescription;
  final Color? textColor;
  final Color? linkColor;

  const DescriptionText({
    super.key,
    this.textColor,
    this.linkColor,
    required this.htmlDescription,
  });

  @override
  State<DescriptionText> createState() => _DescriptionTextState();
}

class _DescriptionTextState extends State<DescriptionText> {
  bool isExpanded = false;
  static const int trimLength = 150;

  @override
  Widget build(BuildContext context) {
    String parsedText = parseHtmlString(widget.htmlDescription);

    final displayText =
        isExpanded
            ? parsedText
            : (parsedText.length > trimLength
                ? parsedText.substring(0, trimLength) + "..."
                : parsedText);

    final spans = _buildTextSpans(displayText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: Sizer.sp(3.5),
              fontWeight: FontWeight.w500,
              color: widget.textColor,
            ),
            children: spans,
          ),
        ),
        if (parsedText.length > trimLength)
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                isExpanded ? "See less" : "... See more",
                style: TextStyle(
                  fontSize: Sizer.sp(3.5),
                  color: widget.linkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<TextSpan> _buildTextSpans(String text) {
    final spans = <TextSpan>[];
    final hashtagRegex = RegExp(r'(?<!\w)#(\w+)', multiLine: true);
    final matches = hashtagRegex.allMatches(text);

    int currentIndex = 0;

    for (final match in matches) {
      final matchStart = match.start;
      final matchEnd = match.end;

      if (currentIndex < matchStart) {
        spans.add(TextSpan(text: text.substring(currentIndex, matchStart)));
      }

      final hashtag = text.substring(matchStart, matchEnd);
      final tag = hashtag.substring(1);

      spans.add(
        TextSpan(
          text: hashtag,
          style: TextStyle(
            color: widget.linkColor,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
          recognizer:
              TapGestureRecognizer()
                ..onTap = () {
                  final url = 'https://www.google.com/search?q=%23$tag';

                  launchUrl(Uri.parse(url));
                },
        ),
      );

      currentIndex = matchEnd;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  String parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? "";
  }
}
