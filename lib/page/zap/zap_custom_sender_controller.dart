
import 'package:flutter/cupertino.dart';
import 'package:freerse/services/nostr/nips/zap_service.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';

class ZapCustomSenderController extends GetxController {

  String? eventId;

  String? pubkey;

  ZapService zapService = Get.find();

  TextEditingController othersController = TextEditingController();

  TextEditingController commentController = TextEditingController();

  var num = 0.obs;

  @override
  void onInit() {
    num.value = zapService.zapConfig!.num1!;

    othersController.addListener(() {
      if (StringUtils.isNotBlank(othersController.text)) {
        num.value = 0;
      }
    });
  }

  void onSelect(int _num) {
    num.value = _num;
  }

  void comfirm({Function(int amount, {String? noteId, String? pubkey})? onCompleted}) {
    if (StringUtils.isBlank(pubkey)) {
      return;
    }
    Get.back();

    var zapNum = num.value;
    if (StringUtils.isNotBlank(othersController.text)) {
      zapNum = int.parse(othersController.text);
    }

    if (zapNum <= 0) {
      return;
    }

    var comment = commentController.text;
    zapService.sendZap(pubkey!, sats: zapNum, comment: comment, eventId: eventId, onCompleted: onCompleted);
  }

}