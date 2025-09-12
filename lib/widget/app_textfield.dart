import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/util/theme_extension.dart';
import 'app_sizer.dart';

class CommonTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool enabled;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextInputAction? textInputAction;

  const CommonTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.textInputAction,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    _obscureText = widget.isPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        counterText: "", // Hide character counter
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : (widget.suffixIcon != null ? Icon(widget.suffixIcon) : null),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSecondaryContainer.withAlpha(50),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSecondaryContainer.withAlpha(50),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSecondaryContainer.withAlpha(50),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.errorColor),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.errorColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class CommonTextField2 extends StatelessWidget {
  final String text;
  final int? maxLines;
  final int? minLines;
  final bool? enabled;
  final bool? autofocus;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const CommonTextField2({
    super.key,
    this.enabled,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.autofocus,
    this.validator,
    this.suffixIcon,
    this.controller,
    this.prefixIcon,
    this.keyboardType,
    required this.text,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      controller: controller,
      keyboardType: keyboardType,
      autofocus: autofocus ?? false,
      textInputAction: textInputAction ?? TextInputAction.done,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        hintText: text,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        fillColor: context.colorsScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Sizer.w(3),
          vertical: Sizer.h(1.6),
        ),
        hintStyle: TextStyle(
          color: context.colorsScheme.onSecondaryContainer.withAlpha(150),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSecondaryContainer.withAlpha(50),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSecondaryContainer.withAlpha(50),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSecondaryContainer.withAlpha(50),
          ),
        ),
      ),
    );
  }
}
