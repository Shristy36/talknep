import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/util/theme_extension.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final matrix = _transformationController.value;
        if (matrix.getMaxScaleOnAxis() == 1.0) {
          Get.back();
        }
      },
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: () {
        final position = _doubleTapDetails!.localPosition;
        final scale = _transformationController.value.getMaxScaleOnAxis();

        if (scale == 1.0) {
          // Zoom in
          _transformationController.value =
              Matrix4.identity()
                ..translate(-position.dx * 2, -position.dy * 2)
                ..scale(3.0);
        } else {
          // Reset (zoom out)
          _transformationController.value = Matrix4.identity();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: context.scaffoldBackgroundColor,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight:
              MediaQuery.of(context).size.height -
              (AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top),
        ),
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1.0,
          maxScale: 4.0,
          child: NetImage(imageUrl: widget.imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
