import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';

class MineProfileController extends GetxController {
  late final NostrService nostrService = Get.find();
  var lud06 = "".obs;
  var website = "".obs;
  var nip05 = "".obs;
  var picture = "".obs;
  var banner = "".obs;
  var displayName = "".obs;
  var about = "".obs;
  var name = "".obs;
  var nip05valid = true.obs;
  var lud16 = "".obs;
  // var images = ''.obs;

  TextEditingController lud06Controller = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController nip05Controller = TextEditingController();
  TextEditingController pictureController = TextEditingController();
  TextEditingController bannerController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lud16Controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();

  @override
  void onInit() {
    var result =
        nostrService.userMetadataObj.getUserInfo(nostrService.myKeys.publicKey);
    picture.value = result['picture'] ?? '';
    lud06.value = result['lud06'] ?? '';
    lud06Controller.text = result['lud06'] ?? '';
    website.value = result['website'] ?? '';
    websiteController.text = result['website'] ?? '';
    nip05.value = result['nip05'] ?? '';
    nip05Controller.text = result['nip05'] ?? '';
    banner.value = result['banner'] ?? '';
    bannerController.text = result['banner'] ?? '';
    displayName.value = result['display_name'] ?? '';
    displayNameController.text = result['display_name'] ?? '';
    about.value = result['about'] ?? '';
    aboutController.text = result['about'] ?? '';
    name.value = result['name'] ?? '';
    nameController.text = result['name'] ?? '';
    lud16.value = result['lud16'] ?? '';
    lud16Controller.text = result['lud16'] ?? '';
    nip05valid.value = result['nip05valid'] ?? false;
    super.onInit();
  }

  void onSave() {
    var content = {
      'picture': picture.value,
      'lud06': lud06Controller.text,
      'website': websiteController.text,
      'nip05': nip05Controller.text,
      'banner': banner.value,
      'display_name': displayNameController.text,
      'about': aboutController.text,
      'name': nameController.text,
      'lud16': lud16Controller.text
    };
    nostrService.userMetadataObj
        .setUserInfo(nostrService.myKeys.publicKey, content);
    nostrService.writeEvent(jsonEncode(content), 0, []);
  }

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

  Future<void> sendImgTitle() async {
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
      if (!imgSrc.isEmpty) {
        banner.value = imgSrc;
        Get.back();
      } else {
        Get.back();
      }
    } else {
      return;
    }
  }
}
