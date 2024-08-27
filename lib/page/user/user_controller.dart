import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/helpers.dart';
import '../../model/Tweet.dart';
import '../../services/nostr/nips/zap_service.dart';
import '../../services/nostr/nostr_service.dart';

class UserController extends GetxController  with GetSingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(text: "Freerse"),
    Tab(text: "HUI_FU".tr),
    Tab(text: "WEN_ZHANG".tr),
  ];

  late TabController tabController;
  var tabIndex = 0.obs;


  late final NostrService nostrService = Get.find();

  late ScrollController scrollController;
  late var scrollOffset = 0.0.obs;
  bool loadTweetsLock = false;

  var lastFlowTime = 0.obs;

  var pubkey = "".obs;
  String nip05verified = "";
  String requestId = Helpers().getRandomString(14);

  var myTweets = <Tweet>[].obs;
  var myTweetsReply = <Tweet>[].obs;
  var myTweetsArticle = <Tweet>[].obs;

  late StreamSubscription _nostrStream;
  late StreamSubscription _nostrStreamReply;
  late StreamSubscription _nostrStreamArticle;


  // var followingPubkeys = <String>[].obs;
  var showFollowers = false.obs;


  var repliedToTmp = [];


  var _isLoadingMore = false;

  @override
  void onInit() {
    pubkey.value = Get.arguments.toString();
    tabController = TabController(vsync: this, length: myTabs.length);
    tabController.addListener(() {
      tabIndex.value = tabController.index;
    });
    scrollController = ScrollController();
    scrollController.addListener(() {
      scrollOffset.value = scrollController.offset;
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        if (loadTweetsLock) return;
        loadTweetsLock = true;
        // load more tweets
        log("load more tweets");
       /* widget._nostrService.requestAuthors(
            authors: [widget.pubkey],
            requestId: requestId,
            limit: 10,
            since: _myTweets.last.tweetedAt);*/
        loadMore();
      }
    });
    List<Tweet> data = nostrService.authorsFeedObj.authors[pubkey] ?? [];
    myTweets.assignAll(data);
    List<Tweet> data2 = nostrService.authorsFeedObj.authorsReply[pubkey] ?? [];
    myTweetsReply.assignAll(data2);

    _nostrStream = nostrService.authorsFeedObj.authorsStream.listen((event) {
          List<Tweet> data = event[pubkey] ?? [];
          myTweets.assignAll(data);
          // todo make this better
          Future.delayed(const Duration(seconds: 5), () {
            loadTweetsLock = false;
          });
        });

    _nostrStreamReply = nostrService.authorsFeedObj.authorsReplyStream.listen((event) {
      List<Tweet> data = event[pubkey] ?? [];
      myTweetsReply.assignAll(data);
      // todo make this better
      Future.delayed(const Duration(seconds: 5), () {
        loadTweetsLock = false;
      });
    });

    _nostrStreamArticle = nostrService.authorsFeedObj.authorsArticleStream.listen((event) {
      List<Tweet> data = event[pubkey] ?? [];
      myTweetsArticle.assignAll(data);
      // todo make this better
      Future.delayed(const Duration(seconds: 5), () {
        loadTweetsLock = false;
      });
    });

    initData();
    initFollow();
    super.onInit();
  }

  void initData(){
    var pk = pubkey.toString();
    var list = nostrService.authorsFeedObj.authors[pk];
    if (list != null) {
      myTweets.addAll(list);
    }
    var replyList = nostrService.authorsFeedObj.authorsReply[pk];
    if (replyList != null) {
      myTweetsReply.addAll(replyList);
    }
    var articleList = nostrService.authorsFeedObj.authorsArticle[pk];
    if (articleList != null) {
      myTweetsArticle.addAll(articleList);
    }

    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    nostrService.requestAuthors(authors: [pubkey.toString()], requestId: requestId, limit: 100, until: now);
    nostrService.requestAuthorsArticle(authors: [pubkey.toString()], requestId: requestId, limit: 50, until: now);
  }

  void loadMore(){
    print("loadMore!!!!!!!!");
    if(tabIndex == 0){
      nostrService.requestAuthors(authors: [pubkey.toString()], requestId: requestId+myTweets.last.tweetedAt.toString(), limit: 100, until: myTweets.last.tweetedAt);
    }else if(tabIndex == 1){
      nostrService.requestAuthors(authors: [pubkey.toString()], requestId: requestId+myTweetsReply.last.tweetedAt.toString(), limit: 100, until: myTweetsReply.last.tweetedAt);
    }else{
      nostrService.requestAuthorsArticle(authors: [pubkey.toString()], requestId: requestId+myTweetsArticle.last.tweetedAt.toString(), limit: 50, until: myTweetsArticle.last.tweetedAt);
    }
  }

  Future<void> initFollow() async {
    await nostrService.getUserContacts(pubkey.toString());
    // List<String> temp = [];
    // var following = await nostrService.getUserContacts(pubkey.toString());
    // for (var f in following) {
    //   temp.add(f[1]);
    // }
    // followingPubkeys.value = temp;
  }


  @override
  void onClose() {
    _nostrStream.cancel();
    _nostrStreamArticle.cancel();
    _nostrStreamReply.cancel();
    super.onClose();
  }




}
