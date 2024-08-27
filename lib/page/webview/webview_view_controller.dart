
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:status_bar_control/status_bar_control.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/ColorConstants.dart';

class WebviewViewController extends GetxController {

  WebViewController webVeiwController = WebViewController();

  String? initUrl;

  @override
  Future<void> onInit() async {
    initUrl = Get.arguments;
    log("onInit initUrl $initUrl");
    webVeiwController.setJavaScriptMode(JavaScriptMode.unrestricted);
    webVeiwController.setNavigationDelegate(NavigationDelegate(
      onUrlChange: (urlChange) async {
        var url = urlChange.url;
        print("urlChange $url");
        if (url != null && url.indexOf("nostr+walletconnect://") == 0) {
          //  nostr wallet connect
          Get.back(result: url.toString());
        }
      }
    ));

    // await StatusBarControl.setColor(Colors.white, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);

    super.onInit();
  }

  @override
  void onReady() {
    if (initUrl != null) {
      webVeiwController.loadRequest(Uri.parse(initUrl!));
    }
    super.onReady();
  }

  @override
  Future<void> onClose() async {
    // await StatusBarControl.setColor(ColorConstants.zapSettingViewBG, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
    super.onClose();
  }

}