import 'package:flutter/widgets.dart';

class AppHorizontalPadding extends StatelessWidget {
  final Widget child;
  AppHorizontalPadding({required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).padding.left + 6,
        right: MediaQuery.of(context).padding.right + 6,
      ),
      child: child,
    );
  }
}
