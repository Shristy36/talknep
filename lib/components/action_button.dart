import 'package:flutter/material.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class ActionButton extends StatefulWidget {
  final String title;
  final Color? color;
  final bool isActive;
  final Widget? svgIcon;
  final VoidCallback? onTap;
  final IconData? activeIcon;
  final IconData? inactiveIcon;

  const ActionButton({
    super.key,
    this.color,
    this.onTap,
    this.svgIcon,
    this.activeIcon,
    this.inactiveIcon,
    required this.title,
    this.isActive = false,
  }) : assert(
         inactiveIcon != null || svgIcon != null,
         'Provide either inactiveIcon or svgIcon',
       );

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? context.colorsScheme.primary;

    return InkWell(
      onTap: _handleTap,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child:
                widget.svgIcon != null
                    ? SizedBox(width: 20, height: 20, child: widget.svgIcon)
                    : Icon(
                      widget.isActive && widget.activeIcon != null
                          ? widget.activeIcon
                          : widget.inactiveIcon,
                      size: 20,
                      color: buttonColor,
                    ),
          ),
          SizedBox(width: Sizer.w(2)),
          AppText(
            text: widget.title,
            fontSize: Sizer.sp(3.5),
            color: buttonColor,
          ),
        ],
      ),
    );
  }
}
