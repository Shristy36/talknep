// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:lottie/lottie.dart' as _lottie;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetIconGen {
  const $AssetIconGen();

  /// File path: asset/icon/comment.svg
  SvgGenImage get comment => const SvgGenImage('asset/icon/comment.svg');

  /// File path: asset/icon/google_icon.svg
  SvgGenImage get googleIcon => const SvgGenImage('asset/icon/google_icon.svg');

  /// File path: asset/icon/homeIcon.png
  AssetGenImage get homeIcon => const AssetGenImage('asset/icon/homeIcon.png');

  /// File path: asset/icon/ic_blog.png
  AssetGenImage get icBlog => const AssetGenImage('asset/icon/ic_blog.png');

  /// File path: asset/icon/ic_events.png
  AssetGenImage get icEvents => const AssetGenImage('asset/icon/ic_events.png');

  /// File path: asset/icon/ic_flag.png
  AssetGenImage get icFlag => const AssetGenImage('asset/icon/ic_flag.png');

  /// File path: asset/icon/ic_groups.png
  AssetGenImage get icGroups => const AssetGenImage('asset/icon/ic_groups.png');

  /// File path: asset/icon/ic_market.png
  AssetGenImage get icMarket => const AssetGenImage('asset/icon/ic_market.png');

  /// File path: asset/icon/ic_media.png
  AssetGenImage get icMedia => const AssetGenImage('asset/icon/ic_media.png');

  /// File path: asset/icon/ic_timeline.png
  AssetGenImage get icTimeline =>
      const AssetGenImage('asset/icon/ic_timeline.png');

  /// File path: asset/icon/ic_user.png
  AssetGenImage get icUser => const AssetGenImage('asset/icon/ic_user.png');

  /// File path: asset/icon/marketplaceIcon.png
  AssetGenImage get marketplaceIcon =>
      const AssetGenImage('asset/icon/marketplaceIcon.png');

  /// File path: asset/icon/menuIcon.png
  AssetGenImage get menuIcon => const AssetGenImage('asset/icon/menuIcon.png');

  /// File path: asset/icon/messageIcon.png
  AssetGenImage get messageIcon =>
      const AssetGenImage('asset/icon/messageIcon.png');

  /// File path: asset/icon/notificationIcon.png
  AssetGenImage get notificationIcon =>
      const AssetGenImage('asset/icon/notificationIcon.png');

  /// File path: asset/icon/reelIcon.png
  AssetGenImage get reelIcon => const AssetGenImage('asset/icon/reelIcon.png');

  /// File path: asset/icon/sparkIcon.png
  AssetGenImage get sparkIcon =>
      const AssetGenImage('asset/icon/sparkIcon.png');

  /// File path: asset/icon/story_camera.svg
  SvgGenImage get storyCamera =>
      const SvgGenImage('asset/icon/story_camera.svg');

  /// File path: asset/icon/story_photo1.png
  AssetGenImage get storyPhoto1 =>
      const AssetGenImage('asset/icon/story_photo1.png');

  /// File path: asset/icon/story_text.svg
  SvgGenImage get storyText => const SvgGenImage('asset/icon/story_text.svg');

  /// File path: asset/icon/story_video1.png
  AssetGenImage get storyVideo1 =>
      const AssetGenImage('asset/icon/story_video1.png');

  /// File path: asset/icon/userIcon.png
  AssetGenImage get userIcon => const AssetGenImage('asset/icon/userIcon.png');

  /// List of all assets
  List<dynamic> get values => [
    comment,
    googleIcon,
    homeIcon,
    icBlog,
    icEvents,
    icFlag,
    icGroups,
    icMarket,
    icMedia,
    icTimeline,
    icUser,
    marketplaceIcon,
    menuIcon,
    messageIcon,
    notificationIcon,
    reelIcon,
    sparkIcon,
    storyCamera,
    storyPhoto1,
    storyText,
    storyVideo1,
    userIcon,
  ];
}

class $AssetImageGen {
  const $AssetImageGen();

  /// Directory path: asset/image/png
  $AssetImagePngGen get png => const $AssetImagePngGen();

  /// Directory path: asset/image/svg
  $AssetImageSvgGen get svg => const $AssetImageSvgGen();
}

class $AssetLottieGen {
  const $AssetLottieGen();

  /// File path: asset/lottie/no_net.json
  LottieGenImage get noNet => const LottieGenImage('asset/lottie/no_net.json');

  /// File path: asset/lottie/upload.json
  LottieGenImage get upload => const LottieGenImage('asset/lottie/upload.json');

  /// List of all assets
  List<LottieGenImage> get values => [noNet, upload];
}

class $AssetImagePngGen {
  const $AssetImagePngGen();

  /// File path: asset/image/png/app_icon.png
  AssetGenImage get appIcon =>
      const AssetGenImage('asset/image/png/app_icon.png');

  /// File path: asset/image/png/backgroundImage.png
  AssetGenImage get backgroundImage =>
      const AssetGenImage('asset/image/png/backgroundImage.png');

  /// File path: asset/image/png/profile.png
  AssetGenImage get profile =>
      const AssetGenImage('asset/image/png/profile.png');

  /// List of all assets
  List<AssetGenImage> get values => [appIcon, backgroundImage, profile];
}

class $AssetImageSvgGen {
  const $AssetImageSvgGen();

  /// File path: asset/image/svg/likePost.svg
  SvgGenImage get likePost => const SvgGenImage('asset/image/svg/likePost.svg');

  /// List of all assets
  List<SvgGenImage> get values => [likePost];
}

class Assets {
  const Assets._();

  static const $AssetIconGen icon = $AssetIconGen();
  static const $AssetImageGen image = $AssetImageGen();
  static const $AssetLottieGen lottie = $AssetLottieGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class LottieGenImage {
  const LottieGenImage(this._assetName, {this.flavors = const {}});

  final String _assetName;
  final Set<String> flavors;

  _lottie.LottieBuilder lottie({
    Animation<double>? controller,
    bool? animate,
    _lottie.FrameRate? frameRate,
    bool? repeat,
    bool? reverse,
    _lottie.LottieDelegates? delegates,
    _lottie.LottieOptions? options,
    void Function(_lottie.LottieComposition)? onLoaded,
    _lottie.LottieImageProviderFactory? imageProviderFactory,
    Key? key,
    AssetBundle? bundle,
    Widget Function(BuildContext, Widget, _lottie.LottieComposition?)?
    frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    String? package,
    bool? addRepaintBoundary,
    FilterQuality? filterQuality,
    void Function(String)? onWarning,
    _lottie.LottieDecoder? decoder,
    _lottie.RenderCache? renderCache,
    bool? backgroundLoading,
  }) {
    return _lottie.Lottie.asset(
      _assetName,
      controller: controller,
      animate: animate,
      frameRate: frameRate,
      repeat: repeat,
      reverse: reverse,
      delegates: delegates,
      options: options,
      onLoaded: onLoaded,
      imageProviderFactory: imageProviderFactory,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      package: package,
      addRepaintBoundary: addRepaintBoundary,
      filterQuality: filterQuality,
      onWarning: onWarning,
      decoder: decoder,
      renderCache: renderCache,
      backgroundLoading: backgroundLoading,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
