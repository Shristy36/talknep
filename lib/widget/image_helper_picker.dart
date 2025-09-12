import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static ImagePicker? _picker;

  // Singleton pattern to avoid multiple instances
  static ImagePicker get picker {
    _picker ??= ImagePicker();
    return _picker!;
  }

  // Dispose method to clean up resources
  static void dispose() {
    _picker = null;
  }

  // Method with proper memory management
  static Future<File?> pickImageFromCamera({bool lowQuality = false}) async {
    try {
      // Clear any existing camera instances
      await SystemChannels.platform.invokeMethod('HapticFeedback.lightImpact');

      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: lowQuality ? 50 : 70,
        maxHeight: lowQuality ? 800 : 1200,
        maxWidth: lowQuality ? 600 : 900,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Verify file exists and is readable
        if (await file.exists()) {
          final fileSize = await file.length();
          print('Image captured: ${fileSize} bytes');
          return file;
        }
      }
      return null;
    } catch (e) {
      print('Camera error: $e');
      return null;
    }
  }

  static Future<File?> pickImageFromGallery({bool lowQuality = false}) async {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: lowQuality ? 50 : 70,
        maxHeight: lowQuality ? 800 : 1200,
        maxWidth: lowQuality ? 600 : 900,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.exists()) {
          return file;
        }
      }
      return null;
    } catch (e) {
      print('Gallery error: $e');
      return null;
    }
  }
}
