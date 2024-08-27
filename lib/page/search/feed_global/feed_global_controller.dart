import 'package:flutter/material.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:get/get.dart';

import '../../../services/nostr/nostr_service.dart';

class FeedGlobalController extends GetxController {

  late final NostrService nostrService = Get.find();
  late final ScrollController scrollControllerUserFeedReplyOriginal = ScrollController();

  @override
  void onInit() {
    initData();
    super.onInit();
  }

  void initData(){
    nostrService.globalFeedObj.requestGlobalFeed();
  }

  void close() {
    nostrService.closeSubscription("gfeed-${nostrService.globalFeedObj.requestId}");
  }

  refreshData() {
    close();
    nostrService.globalFeedObj.markNewRequest();
    nostrService.globalFeedObj.markClear();
    initData();
  }

}
