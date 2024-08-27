
import 'package:flutter/material.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';
import 'package:status_bar_control/status_bar_control.dart';

import '../../config/ColorConstants.dart';
import '../../home/home_controller.dart';

class ZapSettingController extends GetxController {

  HomeController homeController = Get.find();

  @override
  Future<void> onInit() async {
    // await StatusBarControl.setColor(ColorConstants.zapSettingViewBG, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
    super.onInit();
  }

  @override
  Future<void> onClose() async {
    if (homeController.currentPage.value == 4) {
      // await StatusBarControl.setColor(Colors.white, animated:false);
      // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
    }else{
      // await StatusBarControl.setColor(ColorConstants.statuabarColor, animated:false);
      // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
    }
    super.onClose();
  }

}