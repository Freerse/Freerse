import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:get/get.dart';

import '../../config/Cons.dart';
import '../../model/Tweet.dart';
import '../../nostr/utils.dart';
import '../../services/nostr/nostr_service.dart';

class FeedController extends GetxController  with GetSingleTickerProviderStateMixin {
  // final List<Tab> myTabs = <Tab>[
  //   AppBarTab(text: "TUI_WEN".tr, height: ScreenUtil().setHeight(34),),
  //   AppBarTab(text: "TUI_WYH_FU".tr, height: ScreenUtil().setHeight(34),),
  // ];

  final List<Tab> myTabs = <Tab>[
    Tab(child: Container(
        padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(Cons.APPBAR_TAB_BOTTOM)),
        child: Text("GUAN_ZHU".tr),
      ),
      height: ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT),
    ),
    Tab(child: Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(Cons.APPBAR_TAB_BOTTOM)),
      child: Text("TUI_WYH_FU".tr),
    ), height: ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT),),
    Tab(child: Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(Cons.APPBAR_TAB_BOTTOM)),
      child: Text("QU_SHI".tr),
    ),
      height: ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT),
    ),
  ];


  late TabController controller;
  late final NostrService _nostrService = Get.find();

  List<String> followingPubkeys = [];

  var isLoading = true.obs;

  late StreamSubscription userFeedSubscription;
  late StreamSubscription userFeedReplaySubscription;
  var isUserFeedSubscribed = false.obs;
  static String userFeedFreshId = "fresh";
  static String userFeedTimelineFetchId = "timeline";

  var feedShowType = 'G_HOT'.obs;
  var userFeedOriginalOnly = <Tweet>[].obs;
  var newUserFeedOriginalOnly = <Tweet>[].obs;
  var userFeedReplyOriginalOnly = <Tweet>[].obs;

  late final ScrollController scrollControllerUserFeedOriginal = ScrollController();
  late final ScrollController scrollControllerUserFeedReplyOriginal = ScrollController();
  late final ScrollController scrollControllerHotFeedReplyOriginal = ScrollController();

  var _isLoadingMore = false;

  @override
  void onInit() {
    super.onInit();
    controller = TabController(vsync: this, length: myTabs.length);
    userFeedSubscription = _nostrService.userFeedObj.userFeedStream.listen((event) {
          _onUserFeedReceived(event);
        });
    userFeedReplaySubscription = _nostrService.userFeedObj.userFeedStreamReplies.listen((event) {
      _onUserFeedReplyReceived(event);
    });
    initUserFeed();
    loadHotFeed();

    scrollControllerUserFeedOriginal.addListener(() {
      if (scrollControllerUserFeedOriginal.position.pixels >
          scrollControllerUserFeedOriginal.position.maxScrollExtent * 0.8) {
          if(!_isLoadingMore){
            _isLoadingMore = true;
            loadMore();
          }
      }
    });
  }

  @override
  void onClose() {
    controller.dispose();
    scrollControllerUserFeedOriginal.dispose();
    super.onClose();
  }

  void loadHotFeed() async {
    _nostrService.getHotTweets();
  }

  void loadMore() async{
    log("load more called");
    var following = await _nostrService.getUserContacts(_nostrService.myKeys.publicKey);
    // extract public keys
    followingPubkeys = [];
    for (var f in following) {
      followingPubkeys.add(f[1]);
    }
    // add own pubkey
    followingPubkeys.add(_nostrService.myKeys.publicKey);
    if (followingPubkeys.isEmpty) {
      log("!!! no following users found !!!");
      return;
    }
    _nostrService.requestUserFeed(
        users: followingPubkeys,
        // requestId: userFeedTimelineFetchId+generate64RandomHexChars(),
        requestId: userFeedTimelineFetchId + Helpers().getRandomString(6), // 上面方法应该 id 超长了
        limit: 100,
        until: userFeedOriginalOnly.last.tweetedAt,
        includeComments: false);
  }

  /// only for initial load
  void initUserFeed() async {
    print('initUserFeed');
    //wait for connection
    bool connection = await _nostrService.isNostrServiceConnected;
    if (!connection) {
      print("no connection to nostr service");
      return;
    }

    // check mounted
    if (this.isClosed) {
      print("not mounted");
      return;
    }

    //wait
    await Future.delayed(const Duration(seconds: 3));
    _subscribeToUserFeed();
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }

  Future<void> _subscribeToUserFeed() async {
    log("subscribed to user feed called");
    /// map with pubkey as identifier, second list [0] is p, [1] is pubkey, [2] is the relay url
    var following = await _nostrService.getUserContacts(_nostrService.myKeys.publicKey);
    _nostrService.searchFeedObj.requestUserBlackList(pubkey: _nostrService.myKeys.publicKey);
    _nostrService.userReplaysObj.getUserRelays(_nostrService.myKeys.publicKey);
    // extract public keys
    followingPubkeys = [];
    for (var f in following) {
      followingPubkeys.add(f[1]);
    }

    if (followingPubkeys.isEmpty) {
      log("!!! no following users found !!!");
    }

    // add own pubkey
    followingPubkeys.add(_nostrService.myKeys.publicKey);

    print(followingPubkeys);

    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    _nostrService.requestUserFeed(
        users: followingPubkeys,
        requestId: userFeedFreshId,
        limit: 150,
        //until: now,
        includeComments: false, initArticle: true);
  }


  void filterFeed(String type) async {
    feedShowType.value = type;
    _nostrService.getHotTweets();
  }

  _onUserFeedReceived(List<Tweet> tweets) {
    if (userFeedOriginalOnly.isEmpty) {
      userFeedOriginalOnly.assignAll(tweets);
      return;
    }
    userFeedOriginalOnly.assignAll(tweets);
    // sort by tweetedAt
    userFeedOriginalOnly.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
    _isLoadingMore = false;
  }

  _onUserFeedReplyReceived(List<Tweet> tweets) {
    if (userFeedReplyOriginalOnly.isEmpty) {
      userFeedReplyOriginalOnly.assignAll(tweets);
      return;
    }
    userFeedReplyOriginalOnly.assignAll(tweets);
    userFeedReplyOriginalOnly.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
  }
}
