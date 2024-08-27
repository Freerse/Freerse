import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/page/notify/notify_counter.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';

import '../../config/Cons.dart';
import '../../model/LinghtItem.dart';
import '../../model/Tweet.dart';
import '../../services/nostr/nostr_service.dart';

class NotifyController extends GetxController  with GetSingleTickerProviderStateMixin {
  // final List<Tab> myTabs = <Tab>[
  //   Tab(text: "TIE_ZI".tr, height: ScreenUtil().setHeight(40),),
  //   Tab(text: "DIAN_JI".tr, height: ScreenUtil().setHeight(40),),
  //   Tab(text: "DIAN_ZAN".tr, height: ScreenUtil().setHeight(40),),
  // ];
  final List<Tab> myTabs = <Tab>[
    Tab(child: Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(Cons.APPBAR_TAB_BOTTOM)),
      child: Text("Freerse"),
    ), height: ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT),),
    Tab(child: Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(Cons.APPBAR_TAB_BOTTOM)),
      child: Text("DIAN_JI".tr),
    ), height: ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT),),
    Tab(child: Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(Cons.APPBAR_TAB_BOTTOM)),
      child: Text("DIAN_ZAN".tr),
    ), height: ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT),),
  ];

  late TabController tabController;
  late final NostrService nostrService = Get.find();

  late StreamSubscription eventsSubscription;
  // late StreamSubscription feedSubscription;
  // late StreamSubscription lightSubscription;
  // late StreamSubscription feedLikeSubscription;

  var feedCounterMap = RxMap<String, NotifyCounter>();
  var likeCounterMap = RxMap<String, NotifyCounter>();
  var lightCounterMap = RxMap<String, NotifyCounter>();
  // var feedList = <Tweet>[].obs;
  // var likeList = <Map<String, dynamic>>[].obs;
  // var lightList = <LinghtItem>[].obs;

  late final ScrollController scrollController1 = ScrollController();
  late final ScrollController scrollController2 = ScrollController();
  late final ScrollController scrollController3 = ScrollController();

  @override
  void onInit() {
    tabController = TabController(vsync: this, length: myTabs.length);
    eventsSubscription = nostrService.eventsNotifyObj.eventsNotifyStream.listen((event) {
      onEventReceive(event);
    });
    // feedSubscription = nostrService.eventsNotifyObj.userNotifyStream.listen((event) {
    //   onFeedReceive(event);
    // });
    // feedLikeSubscription = nostrService.eventsNotifyObj.userNotifyLikeStream.listen((event) {
    //   onFeedLikeReceive(event);
    // });
    // lightSubscription = nostrService.eventsNotifyObj.useLightStream.listen((event) {
    //   onLightReceive(event);
    // });
    initData();
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    scrollController1.dispose();
    scrollController2.dispose();
    scrollController3.dispose();
    // feedSubscription.cancel();
    // feedLikeSubscription.cancel();
    super.onClose();
  }

  Future<void> initData() async {
    await Future.delayed(Duration(milliseconds: 3000));
    nostrService.eventsNotifyObj.requestUserNotify(users: [nostrService.myKeys.publicKey], requestId: Helpers().getRandomString(12));
  }

  void onEventReceive(Map<String, dynamic> eventMap) {
    var eventKind = eventMap['kind'];

    var blackUserIdList = nostrService.searchFeedObj.blackUserIdList;
    var pubkey = eventMap["pubkey"];
    if (blackUserIdList.contains(pubkey)) {
      return;
    }

    if (pubkey == nostrService.myKeys.publicKey && eventKind != 9735) {
      return;
    }

    var ncItem = NotifyCounterItem(id: eventMap['id'], pubkey: eventMap["pubkey"], createdAt: eventMap["created_at"], feedId: eventMap['id']);

    if (eventKind == 1) {
      var counter = getCounter(feedCounterMap, ncItem.feedId);

      var tweet = Tweet.fromNostrEvent(eventMap);
      counter.pushAndSort(ncItem);
      counter.tweet = tweet;
      counter.isEvent = true;
    } else if (eventKind == 6) {
      // repost
      var repostTweet = Tweet.genRepostTweet(eventMap);
      if (repostTweet == null) {
        return;
      }
      if (repostTweet.parentTweet != null && repostTweet.parentTweet!.id != null) {
        var tweetId = repostTweet.parentTweet!.id;
        var counter = getCounter(feedCounterMap, tweetId, key: "repost_$tweetId");
        counter.pushAndSort(ncItem);
        counter.tweet ??= repostTweet.parentTweet;
      }
    } else if (eventKind == 7) {
      // like
      var tags = eventMap["tags"];
      String? feedId;
      for (var tag in tags) {
        if (tag.length > 1) {
          var tagName = tag[0];
          var tagValue = tag[1];

          if (tagName == "e") {
            feedId = tagValue;
            // break;
          }
        }
      }
      if (StringUtils.isNotBlank(feedId)) {
        ncItem.feedId = feedId!;

        var counter = getCounter(likeCounterMap, feedId);
        counter.pushAndSort(ncItem);
      }
    } else if (eventKind == 9735) {
      // zap
      String bolt = "";
      String feedId = "";
      String userKey = "";
      for (var t in eventMap["tags"]) {
        if (t[0] == "bolt11") {
          bolt = t[1];
        }
        if (t[0] == "e") {
          feedId = t[1];
        }
        if (t[0] == "description") {
          // print('description=start');
          var dianJiObj = jsonDecode(t[1]);
          // print(dianJiObj);
          // print('description=end');
          userKey = dianJiObj['pubkey']??'';
        }
      }
      Bolt11PaymentRequest req = Bolt11PaymentRequest(bolt);
      var result = req.amount * Decimal.parse("100000000");

      ncItem.pubkey = userKey;
      ncItem.amount = result;
      ncItem.feedId = feedId;

      var counter = getCounter(lightCounterMap, ncItem.feedId);
      counter.pushAndSort(ncItem);
    }
  }

  NotifyCounter getCounter(RxMap<String, NotifyCounter> map, String feedId, {String? key}) {
    key ??= feedId;
    var counter = map[key];
    if (counter == null) {
      counter = NotifyCounter(feedId: feedId);
      map[key] = counter;
    }

    return counter;
  }

  // void onFeedReceive(Tweet item){
  //   feedList.add(item);
  //   feedList.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
  // }
  //
  // void onFeedLikeReceive(Map<String, dynamic> item){
  //   likeList.add(item);
  // }
  //
  // void onLightReceive(LinghtItem item){
  //   lightList.add(item);
  //   lightList.sort((a, b) => b.createTime.compareTo(a.createTime));
  // }

}
