import 'package:flutter/material.dart';
import 'package:talknep/widget/app_loader.dart';

showLoadingDialog({required BuildContext context, Widget? widgets}) {
  showAdaptiveDialog(
    context: context,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async => false,
        child: Dialog(
          child: widgets ?? CommonLoader(),
          backgroundColor: Colors.transparent,
        ),
      );
    },
  );
}
