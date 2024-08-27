import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/model/UserItem.dart';
import 'package:freerse/nostr/nips/nip_019_hrps.dart';
import 'package:freerse/page/write_show/write_show_view.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';

import '../../model/Tweet.dart';
import '../../services/nostr/nostr_service.dart';

class WritePageController extends GetxController {
  FocusNode focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  late final NostrService nostrService = Get.find();

  var isArticle = false.obs;
  Tweet? replyTweet;
  var isReply = false.obs;
  var images = ''.obs;
  var atUserList = <UserItem>[].obs;

  var showGifDialog = false.obs;

  @override
  void onResumed() {
    final params = Get.arguments;
    print(params);
  }

  void closeBootom() {
    showGifDialog.value = false;
  }

  @override
  void onInit() {
    final params = Get.arguments;
    replyTweet = params['replyTweet'];
    if (replyTweet != null) {
      isReply.value = true;
    }
    if (params['eventId'] != null) {
      textEditingController.text = textEditingController.text +
          "\nnostr:" +
          Nip019.encodeNoteId(params['eventId']);
      textEditingController.selection =
          TextSelection(baseOffset: 0, extentOffset: 0);
    }
    super.onInit();
  }

  void addAtUser(UserItem userItem) {
    atUserList.add(userItem);
    var userText = '[@' + userItem.name + ']';
    var text = textEditingController.text;
    var textSelection = textEditingController.selection;

    var preIndex = textSelection.baseOffset - 1;
    var nextIndex = textSelection.end + 1;
    if (preIndex > 0 && text.substring(preIndex, preIndex + 1) != " ") {
      userText = " $userText";
    }
    if (nextIndex <= text.length &&
        text.substring(nextIndex, nextIndex + 1) != " ") {
      userText = "$userText ";
    }

    text = text.replaceRange(textSelection.start, textSelection.end, userText);

    textEditingController.text = text;
    textEditingController.selection = TextSelection(
        baseOffset: textSelection.start + text.length, extentOffset: 1);
    // textEditingController.text = textEditingController.text + '[@' + userItem.name + ']';
  }

  bool sending = false;

  Future<void> sendMsg() async {
    if (sending) {
      return;
    }
    try {
      sending = true;
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      _doSendMsg();
    } finally {
      sending = false;
    }
  }

  Future<void> _doSendMsg() async {
    if (!isArticle.value) {
      List tags = [];
      int atIndex = 0;
      var msgText = textEditingController.text;

      if (isReply.value) {
        if (replyTweet!.isReply) {
          tags.add(['e', replyTweet!.getRootId()]);
          atIndex = atIndex + 1;
        }
        tags.add(["e", replyTweet!.id]);
        atIndex = atIndex + 1;
        if (replyTweet!.isReply) {
          var rootPubkey = replyTweet!.getRootPubkey();
          if (StringUtils.isNotBlank(rootPubkey)) {
            tags.add(['p', rootPubkey]);
            atIndex = atIndex + 1;
          }
        }
        tags.add(["p", replyTweet!.pubkey]);
        atIndex = atIndex + 1;

        for (var userItem in atUserList) {
          String tagKey = '[@' + userItem.name + ']';
          if (msgText.contains(tagKey)) {
            print('contains' + tagKey);
            String toValue = "#[" + atIndex.toString() + "]";
            msgText = msgText.replaceFirst(tagKey, toValue);
            tags.add(["p", userItem.userId]);
            atIndex++;
          }
        }
        print(msgText);
        var result = nostrService.writeEvent(msgText, 1, tags);
        if (StringUtils.isBlank(result)) {
          sendFail();
          return;
        }
        try {
          nostrService.refreshFeedReply();
          nostrService.refreshFeedReplyReply();
        } catch (e) {
          print("refresh error");
          print(e);
        }
        Get.back();
      } else {
        for (var userItem in atUserList) {
          String tagKey = '[@' + userItem.name + ']';
          if (msgText.contains(tagKey)) {
            print('contains' + tagKey);
            String toValue = "#[" + atIndex.toString() + "]";
            msgText = msgText.replaceFirst(tagKey, toValue);
            tags.add(["p", userItem.userId]);
            atIndex++;
          }
        }
        print(msgText);
        var result = nostrService.writeEvent(msgText, 1, tags);
        if (StringUtils.isBlank(result)) {
          sendFail();
          return;
        }
        try {
          nostrService.refreshHomeFeed();
        } catch (e) {
          print("refresh error");
          print(e);
        }
        Get.back();
      }
    } else {
      List tags = [
        ['title', titleController.text],
        ['image', images.value]
      ];
      var result =
          nostrService.writeEvent(textEditingController.text, 30023, tags);
      if (StringUtils.isBlank(result)) {
        sendFail();
        return;
      }
      Get.back();
    }
  }

  Future<String> uploadGifImg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      // type: FileType.custom,
      // allowedExtensions: ['gif'], //
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String imgSrc = await nostrService.uploadImage(file);

      print("get gif url ---> $imgSrc");
      return Future.value(imgSrc);
    }

    return Future.value("");
  }

  Future<void> sendGifImg(imgUrl) async {
    if (!imgUrl.isEmpty) {
      textEditingController.text = '${textEditingController.text}\n$imgUrl';
    }
  }

  Future<void> sendImgVedio(isVedio) async {
    // final picker = ImagePicker();
    // final pickedFile = await picker.pickVideo(
    //     source: img,
    //     preferredCameraDevice: CameraDevice.front,
    //     maxDuration: const Duration(minutes: 10));

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: isVedio ? FileType.video : FileType.image,
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
        textEditingController.text = textEditingController.text + '\n' + imgSrc;
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
        images.value = imgSrc;
        Get.back();
      } else {
        Get.back();
      }
    } else {
      return;
    }
  }

  void goToShow() {
    if (isArticle.value) {
      List tags = [
        ['title', titleController.text],
        ['image', images.value]
      ];
      var eventMap = nostrService.writeEventForShow(
          textEditingController.text, 30023, tags);
      Tweet tweet = Tweet.fromNostrEvent(eventMap);
      Get.to(() => WriteShowPage(
            data: tweet,
          ));
    } else {
      var eventMap =
          nostrService.writeEventForShow(textEditingController.text, 1, []);
      Tweet tweet = Tweet.fromNostrEvent(eventMap);
      Get.to(() => WriteShowPage(
            data: tweet,
          ));
    }
  }

  void sendFail() {
    Get.snackbar("TI_SHI".tr, "FAILED_TO_SEND".tr,
        duration: Duration(seconds: 3));
  }
}
