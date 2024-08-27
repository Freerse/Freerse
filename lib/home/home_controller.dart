import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:freerse/main.dart';
import 'package:freerse/page/message/message_view.dart';
import 'package:freerse/page/mine/mine_view.dart';
import 'package:freerse/page/notify/notify_view.dart';
import 'package:freerse/page/search/search_view.dart';
import 'package:freerse/services/nostr/nips/zap_service.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:get/get.dart';

import '../page/feed/feed_view.dart';

class HomeController extends GetxController {
  StreamSubscription? _purchaseUpdatedSubscription;

  late final NostrService nostrService = Get.find();
  late PageController pageController;

  var zapService = Get.put(ZapService());

  List<Widget> pages = [
    MessagePage(),
    SearchPage(),
    FeedPage(),
    NotifyPage(),
    MinePage(),
  ];

  var currentPage = 0.obs;
  var unreadMsgTotal = false.obs;

  @override
  Future<void> onInit() async {
    pageController = PageController(initialPage: 0);
    super.onInit();

    await setDefaultStatusBar();
    // nostrService.clearCacheReset();
    // nostrService.init(true);

    // 注释影响运行
    // asyncInitState();
  }

  void asyncInitState() async {
    await FlutterInappPurchase.instance.initialize();
    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
      if (productItem == null) {
        return;
      }

      try {
        if (donateLoadingController != null) {
          donateLoadingController!.close();
          donateLoadingController = null;
        }
      } catch (e) {}

      try {
        if (Platform.isAndroid) {
          await FlutterInappPurchase.instance.finishTransaction(productItem);
        } else if (Platform.isIOS) {
          await FlutterInappPurchase.instance
              .finishTransactionIOS(productItem.transactionId!);
        }

        Get.snackbar(
          "TI_SHI".tr,
          "THANKS_DONATE".tr,
          duration: Duration(seconds: 3),
        );
      } catch (e) {
        print(e);
      }
      print('purchase-updated: $productItem');
    });
  }

  Future<void> setDefaultStatusBar() async {
    // await StatusBarControl.setColor(ColorConstants.statuabarColor, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
  }

  Future<void> goToTab(int page) async {
    if (page == 4) {
      // await StatusBarControl.setColor(Colors.white, animated:false);
      // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
    } else {
      await setDefaultStatusBar();
    }

    if (currentPage.value == 1) {
      nostrService
          .closeSubscription("gfeed-${nostrService.globalFeedObj.requestId}");
    }

    currentPage.value = page;
    pageController.jumpToPage(page);

    int lastReadTime =
        await nostrService.userMessageObj.getReadLastMessage("MESSAGE_");

    print('lastReadTime=' +
        lastReadTime.toString() +
        ', lastUnReadMessgeTime=' +
        nostrService.lastUnReadMessgeTime.toString());
    unreadMsgTotal.value = nostrService.lastUnReadMessgeTime > lastReadTime;

    if (page == 1) {
      nostrService.userMessageObj.saveReadLastMessage("MESSAGE_");
    }
  }

  @override
  Future<void> dispose() async {
    pageController.dispose();
    super.dispose();

    if (_purchaseUpdatedSubscription != null) {
      _purchaseUpdatedSubscription!.cancel();
      _purchaseUpdatedSubscription = null;
    }
    await FlutterInappPurchase.instance.finalize();
  }
}
