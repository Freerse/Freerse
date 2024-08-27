
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:status_bar_control/status_bar_control.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nips/zap_service.dart';

class ZapNumberSettingController extends GetxController {

  ZapService zapService = Get.find();

  TextEditingController defaultTextController = TextEditingController();

  TextEditingController text1Controller = TextEditingController();

  TextEditingController text2Controller = TextEditingController();

  TextEditingController text3Controller = TextEditingController();

  TextEditingController text4Controller = TextEditingController();

  TextEditingController text5Controller = TextEditingController();

  TextEditingController text6Controller = TextEditingController();

  @override
  Future<void> onInit() async {
    var zapConfig = zapService.zapConfig;
    configToController(zapConfig!);

    super.onInit();

    // await StatusBarControl.setColor(Colors.white, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
  }

  @override
  Future<void> onClose() async {
    // await StatusBarControl.setColor(ColorConstants.zapSettingViewBG, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
    super.onClose();
  }

  void configToController(ZapConfig zapConfig) {
    defaultTextController.text = zapConfig.defaultNum!.toString();
    text1Controller.text = zapConfig.num1!.toString();
    text2Controller.text = zapConfig.num2!.toString();
    text3Controller.text = zapConfig.num3!.toString();
    text4Controller.text = zapConfig.num4!.toString();
    text5Controller.text = zapConfig.num5!.toString();
    text6Controller.text = zapConfig.num6!.toString();
  }

  void completeUpdate() {
    var zapConfig = zapService.zapConfig;
    zapConfig!.defaultNum = tryParseInt(zapConfig.defaultNum!, defaultTextController);
    zapConfig.num1 = tryParseInt(zapConfig.num1!, text1Controller);
    zapConfig.num2 = tryParseInt(zapConfig.num2!, text2Controller);
    zapConfig.num3 = tryParseInt(zapConfig.num3!, text3Controller);
    zapConfig.num4 = tryParseInt(zapConfig.num4!, text4Controller);
    zapConfig.num5 = tryParseInt(zapConfig.num5!, text5Controller);
    zapConfig.num6 = tryParseInt(zapConfig.num6!, text6Controller);

    zapService.updateSetting();
  }

  int tryParseInt(int num, TextEditingController textController) {
    try {
      return int.parse(textController.text);
    } catch (e) {
      return num;
    }
  }

  void resetNumber() {
    var zapConfig = zapService.zapConfig;

    zapConfig!.defaultNum = null;
    zapConfig.num1 = null;
    zapConfig.num2 = null;
    zapConfig.num3 = null;
    zapConfig.num4 = null;
    zapConfig.num5 = null;
    zapConfig.num6 = null;

    zapService.setDefault(zapConfig);
    configToController(zapConfig);
    zapService.updateSetting();

    print(zapConfig!.toJson());
  }

}