import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/image_helper_picker.dart';

void showImagePickerBottomSheet({
  String titleCamera = 'Camera',
  required BuildContext context,
  String titleGallery = 'Gallery',
  required Function(File image) onImageSelected,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: context.theme.dividerColor),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: AppText(text: titleCamera),
            leading: Icon(CupertinoIcons.camera_circle),
            onTap: () async {
              Navigator.of(context).pop();
              File? image = await ImagePickerHelper.pickImageFromCamera();
              if (image != null) {
                onImageSelected(image);
              }
            },
          ),
          Divider(color: context.theme.dividerColor),
          ListTile(
            title: AppText(text: titleGallery),
            leading: Icon(CupertinoIcons.photo),
            onTap: () async {
              Navigator.of(context).pop();
              File? image = await ImagePickerHelper.pickImageFromGallery();
              if (image != null) {
                onImageSelected(image);
              }
            },
          ),
          SizedBox(height: Sizer.h(1)),
        ],
      );
    },
  );
}
