import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:freerse/services/SpUtils.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';

import '../../services/nostr/nostr_service.dart';
import '../message/message_controller.dart';
import '../message_detail/message_detail_controller.dart';

class SetNickNameController extends GetxController {
  late final NostrService nostrService = Get.find();
  var name = "".obs;
  late String userId;

  TextEditingController nameController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void onInit() {
    userId = Get.arguments.toString();
    getData();
    super.onInit();
  }

  void getData() async {
    var result = nostrService.userMetadataObj.getUserInfo(userId);
    var nickName =  ViewUtils.userShowName(result, userId: userId);
    name.value = nickName;
    nameController.text = nickName;
  }

  void onSave(){
    nostrService.userMetadataObj.setUserRemark(userId,  nameController.text);
    // MessageDetailController messageDetailController = Get.find();
    // print('messageDetailController=');
    // print(messageDetailController);
    // messageDetailController.loadUserName();
    nostrService.userMetadataObj.usersMetadata.refresh();
    nostrService.userMessageObj.userMessages.refresh();

    // MessageController messageController = Get.find();
    // messageController.refresh();
  }

}
