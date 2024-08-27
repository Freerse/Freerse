import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:get/get.dart';

import '../../../config/Cons.dart';
import '../../../model/Tweet.dart';
import '../../../services/nostr/nostr_service.dart';

class SearchListController extends GetxController with GetSingleTickerProviderStateMixin{
  String keyword = '';
  String searchId = Helpers().getRandomString(4);
  var feed = <Tweet>[].obs;
  var userIdList = <String>[].obs;

  late final NostrService nostrService = Get.find();
  late StreamSubscription _streamSubscription;

  final StreamController<Tweet> replyStreamController = StreamController<Tweet>.broadcast();
  final StreamController<dynamic> replyUserStreamController = StreamController<dynamic>.broadcast();

  // final List<Tab> myTabs = <Tab>[
  //   Tab(text: "TUI_WEN".tr),
  //   Tab(text: "YONG_HU".tr),
  // ];
  final List<Tab> myTabs = <Tab>[
    Tab(child: Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(Cons.APPBAR_TAB_BOTTOM)),
      child: Text("Freerse"),
    ), height: ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT),),
    Tab(child: Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(Cons.APPBAR_TAB_BOTTOM)),
      child: Text("YONG_HU".tr),
    ), height: ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT),),
  ];

  late TabController controller;

  @override
  void onInit() {
    searchId = Helpers().getRandomString(4);

    final params = Get.arguments;
    keyword = params['keyword'];
    _streamSubscription = replyStreamController.stream.listen((event) {
      onEvent(event);
    });

    _streamSubscription = replyUserStreamController.stream.listen((event) {
      onUserEvent(event);
    });

    controller = TabController(vsync: this, length: myTabs.length);

    initData();
    super.onInit();
  }

  @override
  void onClose() {
    nostrService.searchFeedObj.stopSearch(requestId: searchId);
    _streamSubscription.cancel();
    replyStreamController.close();
    replyUserStreamController.close();
    super.onClose();

    userIdList.clear();
    nostrService.closeSubscription("search-$searchId");
    nostrService.closeSubscription("finduser-$searchId");
  }

  void initData(){
    nostrService.searchFeedObj.requestSeach(
        keyword: keyword,
        requestId: searchId,
        streamController: replyStreamController
    );
    if(keyword.startsWith('npub')){
      var idList = Helpers().decodeBech32(keyword);
      userIdList.add(idList[0]);
    }else{
      var searchText = keyword.replaceFirst("#", "");
      nostrService.searchFeedObj.requestUserSeach(
          keyword: searchText,
          requestId: searchId,
          streamController: replyUserStreamController
      );
    }
  }

  void onEvent(Tweet item){
    if (feed.any((element) => element.id == item.id)) {
      return;
    }

    feed.add(item);

    feed.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
  }

  void onUserEvent(dynamic item){
    // print(item);
    userIdList.add(item['pubkey']);
  }
}
