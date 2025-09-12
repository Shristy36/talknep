import 'package:flutter/material.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

enum SnackbarType { success, error, info }

void showCustomSnackbar(
  BuildContext context,
  String message, {
  SnackbarType type = SnackbarType.info,
}) {
  final overlay = Overlay.of(context);

  final icon =
      {
        SnackbarType.success: Icons.check_circle,
        SnackbarType.error: Icons.error,
        SnackbarType.info: Icons.info_outline,
      }[type]!;

  final color =
      {
        SnackbarType.success: Colors.green,
        SnackbarType.error: Colors.redAccent,
        SnackbarType.info: Colors.blueAccent,
      }[type]!;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      return Positioned(
        bottom: keyboardHeight + 20,
        left: 20,
        right: 20,
        child: _AnimatedSnackbarWidget(
          icon: icon,
          color: color,
          message: message,
        ),
      );
    },
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 3), () {
    entry.remove();
  });
}

class _AnimatedSnackbarWidget extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _AnimatedSnackbarWidget({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  State<_AnimatedSnackbarWidget> createState() =>
      _AnimatedSnackbarWidgetState();
}

class _AnimatedSnackbarWidgetState extends State<_AnimatedSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2), // Start below screen
      end: const Offset(0, 0), // Slide to original position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(14),
        color: widget.color,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: AppColors.whiteColor, size: 22),
              SizedBox(width: Sizer.w(5)),
              Expanded(
                child: AppText(
                  text: widget.message,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
