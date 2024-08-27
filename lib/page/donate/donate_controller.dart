
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';
import 'package:status_bar_control/status_bar_control.dart';

import '../../config/ColorConstants.dart';
import '../../main.dart';

class DonateController extends GetxController {

  @override
  Future<void> onInit() async {
    print("donate init");
    // await StatusBarControl.setColor(ColorConstants.donateViewBG, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.LIGHT_CONTENT);
    super.onInit();

    updateIAPItems();
  }

  @override
  Future<void> onClose() async {
    // await StatusBarControl.setColor(Colors.white, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
    super.onClose();
  }

  void showDonateResult() {
    Get.snackbar("TI_SHI".tr, "THANKS_DONATE".tr, duration: Duration(seconds: 3),);
  }

  Future<void> buy(String id) async {
    donateLoadingController = Get.snackbar(
      "TI_SHI".tr,
      "",
      duration: Duration(seconds: 10),
      messageText: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Get.theme.colorScheme.secondary),
      ),
    );
    // Get.defaultDialog(title: 'Loading',content: CircularProgressIndicator(
    //   backgroundColor: Colors.grey[200],
    //   valueColor: AlwaysStoppedAnimation(ColorConstants.greenColor),
    // ));
    // try {
    var result = await FlutterInappPurchase.instance.requestPurchase(id);
    print(result);
    // } catch (e) {
    //   print(e);
    // } finally {
    //   Get.back();
    // }
    //
    // showDonateResult();
  }

  Future<void> updateIAPItems() async {
    var list =
    await FlutterInappPurchase.instance.getProducts([donateId1.value, donateId2.value, donateId3.value, donateId4.value]);
    print(list);
    for (var item in list) {
      print(item.toJson());
      if (StringUtils.isBlank(item.localizedPrice)) {
        continue;
      }

      if (item.productId == donateId1.value) {
        price1.value = item.localizedPrice!;
      } else if (item.productId == donateId2.value) {
        price2.value = item.localizedPrice!;
      } else if (item.productId == donateId3.value) {
        price3.value = item.localizedPrice!;
      } else if (item.productId == donateId4.value) {
        price4.value = item.localizedPrice!;
      }
    }
  }

  Future<void> resumePurchase() async {
    Get.defaultDialog(title: 'Loading',content: CircularProgressIndicator(
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation(ColorConstants.greenColor),
    ));
    var result = false;
    try {
      List<PurchasedItem>? list = await FlutterInappPurchase.instance.getPurchaseHistory();
      if (list != null && list.isNotEmpty) {
        result = true;
      }
    } finally {
      Get.back();
    }

    if (result) {
      showDonateResult();
    }
  }

  var donateId1 = "freerseDonateId1".obs;

  var donateId2 = "freerseDonateId2".obs;

  var donateId3 = "freerseDonateId3".obs;

  var donateId4 = "freerseDonateId4".obs;

  var price1 = "".obs;

  var price2 = "".obs;

  var price3 = "".obs;

  var price4 = "".obs;

}