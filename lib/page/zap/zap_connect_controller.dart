
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freerse/services/nostr/nips/nip47/wallet_connection_info.dart';
import 'package:freerse/services/nostr/nips/zap_service.dart';
import 'package:get/get.dart';
import 'package:status_bar_control/status_bar_control.dart';

import '../../config/ColorConstants.dart';

class ZapConnectController extends GetxController {

  ZapService zapService = Get.find();

  TextEditingController textEditingController = TextEditingController();

  @override
  Future<void> onInit() async {
    // await StatusBarControl.setColor(Colors.white, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);

    super.onInit();
  }

  @override
  Future<void> onClose() async {
    // await StatusBarControl.setColor(ColorConstants.zapSettingViewBG, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
    super.onClose();
  }

  Future<void> paste() async {
    var clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    var text = clipboardData?.text ?? '';
    textEditingController.text = text;
  }

  void clear() {
    textEditingController.text = "";
  }

  Future<bool> connect() async {
    var text = textEditingController.text;
    var info = WalletConnectionInfo.validAndParse(text);
    if (info == null) {
      Get.snackbar(
        "TI_SHI".tr,
        "NO_WALLET_WAS_FOUND".tr,
        duration: Duration(seconds: 3),
      );
      // Get.showSnackbar(GetSnackBar(
      //   message: "Connect parse error",
      //   duration: Duration(seconds: 3),
      // ));
      return false;
    }

    var zapConfig = zapService.zapConfig;
    zapConfig!.wallConnectUrl = text;
    await zapService.updateSetting();
    zapService.reconect();

    return true;
  }

}