
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:scan/scan.dart';

class ZapConnectScannerView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _ZapConnectScannerView();
  }

}

class _ZapConnectScannerView extends State<ZapConnectScannerView> {

  CameraController? cameraController;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (cameraController != null) {
      cameraController!.resumePreview();
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaData = MediaQuery.of(context);
    var paddingTop = mediaData.padding.top;

    return Scaffold(
      body: Stack(
        children: [
          ReaderWidget(
            onScan: onScan,
            onControllerCreated: (c) {
              cameraController = c;
            },
            actionButtonsAlignment: Alignment(-1.0, 0.9),
            showGallery: false,
            showToggleCamera: false,
            // actionButtonsAlignment: Alignment.bottomRight,
          ),
          // Positioned(child: GestureDetector(
          //   onTap: openAlbum,
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.image, size: 30, color: Colors.white,),
          //       Text("IMAGE".tr, style: TextStyle(
          //         color: Colors.white,
          //       ),),
          //     ],
          //   ),
          // ), right: 30, bottom: 30,),
          Positioned(child: GestureDetector(
            onTap: openAlbum,
            behavior: HitTestBehavior.translucent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.black.withOpacity(0.5),
                child: Icon(Icons.image, size: 30, color: Colors.white,),
              ),
            ),
          ), right: 30, bottom: 44,),
          Positioned(child: GestureDetector(
            onTap: () {
              Get.back();
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15)
              ),
              child: Icon(Icons.chevron_left),
            ),
          ), left: 30, top: paddingTop + 30,)
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (cameraController != null) {
      cameraController!.dispose();
    }
    super.dispose();
  }

  Future<void> openAlbum() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && StringUtils.isNotBlank(result.paths[0])) {
      String? scanResult = await Scan.parse(result.paths[0]!);
      if (StringUtils.isNotBlank(scanResult)) {
        Get.back(result: scanResult);
      }
    }
  }

  onScan(Code code) {
    var text = code.text;
    print("scanText $text");
    if (StringUtils.isNotBlank(text) && text!.indexOf("nostr+walletconnect") == 0) {
      Get.back(result: text);
    }
  }
}