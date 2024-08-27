import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:get/get.dart';

class RegViewController extends GetxController {
  TextEditingController nameController = TextEditingController();
  late final NostrService nostrService = Get.find();

  var acceptSlices = false.obs;
  var picture = "".obs;

  Future<void> sendImg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      Get.defaultDialog(
          title: 'Uploading...',
          content: CircularProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(ColorConstants.greenColor),
          ));
      String imgSrc = await nostrService.uploadImage(file);
      picture.value = result.files.single.path!;
      if (!imgSrc.isEmpty) {
        picture.value = imgSrc;
        Get.back();
      } else {
        Get.back();
      }
    } else {
      return;
    }
  }
}
