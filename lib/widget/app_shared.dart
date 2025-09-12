import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

Future<void> shareReelFromUrl(String url) async {
  final share = SharePlus.instance;
  try {
    // 1. Download the video file
    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    // 2. Save temporarily
    final tempDir = await getTemporaryDirectory();

    final filePath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

    final file = File(filePath);

    await file.writeAsBytes(response.data);

    // 3. Share the video
    await share.share(
      ShareParams(files: [XFile(file.path)], text: "Check out this reel!"),
    );
  } catch (e) {
    print("Error sharing reel: $e");
  }
}

Future<void> shareImageFromUrl({String? imageUrl, String? title}) async {
  try {
    final extension = path.extension(imageUrl!).toLowerCase();
    final validImageExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

    if (!validImageExtensions.contains(extension)) {
      print("Not a valid image URL");
      return;
    }

    // Download image into memory (not storing permanently)
    final response = await Dio().get(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    // Save image temporarily in memory for sharing
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/shared_image$extension';
    final file = File(filePath);
    await file.writeAsBytes(response.data);

    final mimeType = lookupMimeType(filePath);
    if (mimeType != null && mimeType.startsWith('image/')) {
      await Share.shareXFiles([XFile(file.path)], text: title);
    } else {
      print("Downloaded content is not an image");
    }
  } catch (e) {
    print("Error sharing image: $e");
  }
}
