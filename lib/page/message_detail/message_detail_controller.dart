// ignore_for_file: prefer_is_not_empty, prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:freerse/page/message/message_controller.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';

class MessageDetailController extends GetxController {
  late String userId;
  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();
  // Initialise a scroll controller.
  ScrollController textScrollController = ScrollController();
  late final NostrService nostrService = Get.find();
  late final MessageController messageController = Get.find();

  var showBottomDialog = false.obs;
  var showSendBton = false.obs;
  var showGifDialog = false.obs;

  // var showName = "".obs;

  @override
  void onInit() {
    userId = Get.arguments.toString();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showGifDialog.value = false;
        showBottomDialog.value = false;
        Future.delayed(const Duration(milliseconds: 300), () {
          jumpToBottom();
        });
      }
    });
    textEditingController.addListener(() {
      if (textEditingController.text.isEmpty) {
        showSendBton.value = false;
      } else {
        showSendBton.value = true;
      }
    });
    Future.delayed(Duration(milliseconds: 100), () {
      jumpToBottom();
    });
    // loadUserName();
    super.onInit();
  }

  // void loadUserName(){
  //   var result = nostrService.userMetadataObj.getUserInfo(userId);
  //   var name = ViewUtils.userShowName(result, userId: userId);
  //   showName.value = name;
  // }
  void jumpToBottom() {
    //scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  // gif picture
  void showGif() {
    showBottomDialog.value = false;

    showGifDialog.value = true;
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      jumpToBottom();
    });
  }

  void hideGif() {
    showGifDialog.value = false;
  }

  void showBottom() {
    showGifDialog.value = false;

    showBottomDialog.value = true;
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      jumpToBottom();
    });
  }

  void closeBootom() {
    showGifDialog.value = false;

    showBottomDialog.value = false;
  }

  void sendMessage() {
    var content = nostrService.userMessageObj
        .encodeContent(userId, textEditingController.text);
    var result = nostrService.writeEvent(content, 4, [
      ["p", userId]
    ]);
    if (StringUtils.isBlank(result)) {
      sendFail();
      return;
    }
    textEditingController.text = "";
    //messageController.initUserMsg(100);
    Future.delayed(Duration(milliseconds: 1000), () {
      jumpToBottom();
    });
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
      if (!imgSrc.isEmpty) {
        var content = nostrService.userMessageObj.encodeContent(userId, imgSrc);
        var result = nostrService.writeEvent(content, 4, [
          ["p", userId]
        ]);
        if (StringUtils.isBlank(result)) {
          sendFail();
          return;
        }
        Future.delayed(Duration(milliseconds: 1000), () {
          Get.back();
          jumpToBottom();
        });
      } else {
        Get.back();
      }
    } else {
      // User canceled the picker
      return;
    }
  }

  Future<String> uploadGifImg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      // type: FileType.custom,
      // allowedExtensions: ['gif'], // 只允许选择GIF文件
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String imgSrc = await nostrService.uploadImage(file);

      print("get gif url ---> $imgSrc");
      return Future.value(imgSrc);
    }

    return Future.value("");
  }

  void sendGifImg(imgSrc) async {
    var content = nostrService.userMessageObj.encodeContent(userId, imgSrc);
    var result = nostrService.writeEvent(content, 4, [
      ["p", userId]
    ]);
    if (StringUtils.isBlank(result)) {
      sendFail();
      return;
    }
    Future.delayed(Duration(milliseconds: 1000), () {
      // Get.back();
      jumpToBottom();
    });
  }

  void sendFail() {
    Get.snackbar(
      "TI_SHI".tr,
      "FAILED_TO_SEND".tr,
      duration: Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    focusNode.dispose();
    textEditingController.dispose();
    super.onClose();
  }
}
