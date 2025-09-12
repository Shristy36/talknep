import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';

class NetImage extends StatelessWidget {
  final BoxFit fit;
  final double? width;
  final double? height;
  final String imageUrl;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const NetImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      fit: fit,
      width: width,
      height: height,
      imageUrl: imageUrl,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
      errorWidget:
          (context, url, error) => errorWidget ?? _defaultErrorWidget(),
    );

    if (borderRadius != null) {
      return ClipRRect(
        child: image,
        borderRadius: borderRadius ?? BorderRadius.zero,
      );
    } else {
      return image;
    }
  }

  Widget _defaultPlaceholder() {
    return Container(width: width, height: Sizer.h(30), child: CommonLoader());
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: Icon(
        Icons.broken_image,
        color: Colors.grey.shade700,
        size: width != null && height != null ? (width! * 0.5) : 40,
      ),
    );
  }
}
