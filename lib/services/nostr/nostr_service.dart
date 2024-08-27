import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:freerse/services/nostr/feeds/events_notify.dart';
import 'package:freerse/services/nostr/feeds/events_querier.dart';
import 'package:freerse/services/nostr/feeds/search_feed.dart';
import 'package:freerse/services/nostr/metadata/feed_like.dart';
import 'package:http/http.dart' as http;

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/services/nostr/feeds/user_message.dart';
import 'package:freerse/services/nostr/relays/relay_tracker.dart';
import 'package:freerse/services/nostr/relays/relays.dart';
import 'package:freerse/services/nostr/relays/relays_injector.dart';
import 'package:freerse/services/nostr/relays/relays_ranking.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:json_cache/json_cache.dart';
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:mime/mime.dart';

import '../../helpers/bip340.dart';
import '../../model/Tweet.dart';
import '../../model/socket_control.dart';
import '../../page/feed/feed_controller.dart';
import '../../page/feed_detail/feed_detail_controller.dart';
import '../../page/feed_detail_reply/feed_detail_reply_controller.dart';
import 'feeds/authors_feed.dart';
import 'feeds/events_feed.dart';
import 'feeds/global_feed.dart';
import 'feeds/user_feed.dart';
import 'metadata/metadata_injector.dart';
import 'metadata/nip_05.dart';
import 'metadata/user_contacts.dart';
import 'metadata/user_follow.dart';
import 'metadata/user_metadata.dart';
import 'metadata/user_relays.dart';


class NostrService extends GetxService {
  late Future isNostrServiceConnected;

  static String ownPubkeySubscriptionId =
      "own-${Helpers().getRandomString(20)}";

  var counterOwnSubscriptionsHits = 0;

  // global feed
  var globalFeedObj = GlobalFeed();

  // user feed
  var userFeedObj = UserFeed();

  // authors feed
  var authorsFeedObj = AuthorsFeed();

  var eventsFeedObj = EventsFeed();

  var userMetadataObj = UserMetadata();

  var userContactsObj = UserContacts();

  var userMessageObj = UserMessage();

  var feedLikeObj = FeedLikedata();

  var eventsNotifyObj = EventNotify();

  var userFollowObj = UserFollow();

  var searchFeedObj = SearchFeed();

  var userReplaysObj = UserRelays();

  var eventsQuerier = EventsQuerier();

  int lastUnReadMessgeTime = 0;


  late JsonCache jsonCache;

  late Relays relays;
  late RelayTracker relayTracker;

  bool _initKeyed = false;
  late KeyPair myKeys;

  late Nip05 nip05service;

  late RelaysRanking relaysRanking;

  Map<String, dynamic> get usersMetadata => userMetadataObj.usersMetadata;
  Map<String, List<List<dynamic>>> get following => userContactsObj.following;

  List<String> feedDetailTag = [];
  List<String> feedDetailReplyTag = [];



  Future<NostrService> init() async {
    RelaysInjector relaysInjector = RelaysInjector();
    MetadataInjector metadataInjector = MetadataInjector();
    nip05service = metadataInjector.nip05;
    relays = relaysInjector.relays;
    relayTracker = relaysInjector.relayTracker;
    relaysRanking = relaysInjector.relaysRanking;
    isNostrServiceConnected = relays.isNostrServiceConnectedCompleter.future;
    relays.receiveEventStream.listen((e) {
      _receiveEvent(e["event"], e["socketControl"]);
    });
    await _init();
    return this;
  }

  initKeyPairs() async {
    await _loadKeyPair();
    // global feed
    globalFeedObj = GlobalFeed();
    // user feed
    userFeedObj = UserFeed();
    // authors feed
    authorsFeedObj = AuthorsFeed();
    eventsFeedObj = EventsFeed();

    userMetadataObj = UserMetadata();

    userContactsObj = UserContacts();

    userMessageObj = UserMessage();

    feedLikeObj = FeedLikedata();

    eventsNotifyObj = EventNotify();

    userFollowObj = UserFollow();

    searchFeedObj = SearchFeed();

    userReplaysObj = UserRelays();

    eventsQuerier = EventsQuerier();
  }

  void refreshFeedReply(){
    for(int i=0;i< feedDetailTag.length;i++){
      FeedDetailController controller = Get.find(tag: feedDetailTag[i]);
      controller.requestEvents();
    }
  }

  void refreshFeedReplyReply(){
    for(int i=0;i< feedDetailReplyTag.length;i++){
      FeedDetailReplyController controller = Get.find(tag: feedDetailReplyTag[i]);
      controller.refreshData();
    }
  }

  void refreshHomeFeed(){
    FeedController feedController = Get.find();
    feedController.initUserFeed();
  }

  String getTag(){
    return (feedDetailTag.length-1).toString();
  }

  String setTag(){
    String tag = feedDetailTag.length.toString();
    feedDetailTag.add(tag);
    return tag;
  }

  void removeTag(){
    feedDetailTag.removeAt(feedDetailTag.length-1);
  }

  String getTagReply(){
    return (feedDetailReplyTag.length-1).toString();
  }

  String setTagReply(){
    String tag = feedDetailReplyTag.length.toString();
    feedDetailReplyTag.add(tag);
    return tag;
  }

  void removeTagReply(){
    feedDetailReplyTag.removeAt(feedDetailReplyTag.length-1);
  }

  void refreshReply(String contents){
    List<List> tags = [];
    if(userContactsObj.following[myKeys.publicKey] != null){
      tags = userContactsObj.following[myKeys.publicKey]!;
    }
    print('refreshReply');
    print(contents);
    writeEvent(contents, 3, tags);
  }

  Future<void> followUser(String pubkey) async {
    // print(myKeys.publicKey);
    // List<List> tags = [];
    // if(userContactsObj.following[myKeys.publicKey] != null){
    //   tags = userContactsObj.following[myKeys.publicKey]!;
    // }
    // tags.add(['p',pubkey]);
    // userContactsObj.following[myKeys.publicKey] = tags;
    // List<String> tagsString = [];
    // for (List t in tags) {
    //   tagsString.add(t[1].toString());
    // }
    // userContactsObj.followingFormat[myKeys.publicKey] = tagsString;

    List<String> tags = userContactsObj.meFollowUserIdList;
    List<List> tagsResult = [];
    tags.forEach((element) {
      tagsResult.add(['p',element]);
    });
    tagsResult.add(['p', pubkey]);
    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var writeResult = await writeEvent(relays.getRelaySaveContent(), 3, tagsResult, now: now);
    if (writeResult != null) {
      // 发送成功，更新本地数据
      var ownPubkey = myKeys.publicKey;
      userContactsObj.followUserTime.value = now;
      userContactsObj.meFollowUserIdList.add(pubkey);

      userContactsObj.followingLastMsgTime[ownPubkey] = now;

      userContactsObj.following[ownPubkey] = tagsResult;
      userContactsObj.followingFormat[ownPubkey] = userContactsObj.meFollowUserIdList.value;

      try {
        FeedController feedcontroller = Get.find();
        feedcontroller.initUserFeed();
      } catch(e) {
        print(e);
      }
    }
  }

  void unFollowUser(String pubkey){
    // print(pubkey);

    userContactsObj.meFollowUserIdList.remove(pubkey);
    List<String> tags = userContactsObj.meFollowUserIdList;
    // List<String> tagsStringNew = [];
    // for (String t in tags) {
    //   if(pubkey != t){
    //     tagsStringNew.add(t);
    //   }
    // }
    // userContactsObj.followingFormat[myKeys.publicKey] = tagsStringNew;
    List<List> tagsResult = [];
    tags.forEach((element) {
      tagsResult.add(['p',element]);
    });
    // userContactsObj.following[myKeys.publicKey] = tagsResult;
    // print(tagsStringNew);
    // print(tagsResult);
    writeEvent(relays.getRelaySaveContent(), 3, tagsResult);

    FeedController feedcontroller = Get.find();
    feedcontroller.initUserFeed();
  }


  @override
  Future<void> onReady() async {
    super.onReady();
  }


  _init() async {
    SystemChannels.lifecycle.setMessageHandler((msg) {
      log('SystemChannels> $msg');
      switch (msg) {
        case "AppLifecycleState.resumed":
          relays.checkRelaysForConnection();
          break;
        case "AppLifecycleState.inactive":
          break;
        case "AppLifecycleState.paused":
          break;
        case "AppLifecycleState.detached":
          relays.closeRelays();
          break;
      }
      // reconnect to relays
      return Future(() {
        return;
      });
    });

    await _loadKeyPair();

    // restore messsages
    // 这里让它异步跑也没什么太大问题
    userMessageObj.restoreFromDB();

    // init json cache
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    jsonCache = JsonCacheCrossLocalStorage(prefs);

    // restore following
    var followingCache = (await jsonCache.value('following'));
    if (followingCache != null) {
      // cast using for loop to avoid type error
      for (var key in followingCache.keys) {
        userContactsObj.following[key] = [];
        var value = followingCache[key];
        for (List parentList in value) {
          userContactsObj.following[key]!.add(parentList);
        }
      }
    }

    relays.start();

    //userFeedObj.restoreFromCache();
    //globalFeedObj.restoreFromCache();

    // load cached users metadata
    final Map<String, dynamic>? cachedUsersMetadata =
    await jsonCache.value('usersMetadata');
    if (cachedUsersMetadata != null) {
      userMetadataObj.usersMetadata = RxMap<String, dynamic>.from(cachedUsersMetadata);
    }
  }

  Future<void> _loadKeyPair() async {
    // load keypair from storage
    FlutterSecureStorage storage = const FlutterSecureStorage();
    // storage.read(key: "nostrKeys").then((nostrKeysString) {
    //   if (nostrKeysString == null) {
    //     return;
    //   }
    //
    //   // to obj
    //   myKeys = KeyPair.fromJson(json.decode(nostrKeysString));
    //   userContactsObj.ownPubkey = myKeys.publicKey;
    // });

    var nostrKeysString = await storage.read(key: "nostrKeys");
    if (nostrKeysString == null) {
      return;
    }
    myKeys = KeyPair.fromJson(json.decode(nostrKeysString));
    userContactsObj.ownPubkey = myKeys.publicKey;

    _initKeyed = true;
  }

  finishedOnboarding() async {
    await _loadKeyPair();

    await relays.connectToRelays(useDefault: true);

    // subscribe to own pubkey

    var data = [
      "REQ",
      ownPubkeySubscriptionId,
      {
        "authors": [myKeys.publicKey],
        "kinds": [0, 2, 3], // 0=> metadata, 2=> relays, 3=> contacts
      },
    ];

    var jsonString = json.encode(data);

    for (var relay in relays.connectedRelaysRead.entries) {
      relay.value.send(jsonString);
    }
  }

  /// used for debugging
  void clearCache() async {
    // clears everything including shared preferences! don't use this!
    //await jsonCache.clear();

    // clear only nostr related stuff
    await jsonCache.remove('globalFeed');
    await jsonCache.remove('userFeed');
    await jsonCache.remove('usersMetadata');
    await jsonCache.remove('following');

    // don't clear relays and blocked users
  }

  // clears everything, potentially dangerous
  void clearCacheReset() async {
    await jsonCache.clear();
  }

  _receiveEvent(event, SocketControl socketControl) async {
    if (event[0] == "AUTH" && _initKeyed ) {
      var challenge = event[1] as String;
      var tags = [
        ["relay", socketControl.id],
        ["challenge", challenge]
      ];

      var autoEvent = genAndSignEvent("", 22242, tags);
      socketControl.send(autoEvent);
      return;
    }

    if (event[0] != "EVENT") {
      //log("not an event: $event");
    }

    if (event[0] == "NOTICE") {
      // print("${socketControl.id} NOTICE");
      // print(event);
      //log("notice: $event, socket: ${socketControl.connectionUrl}, url: ${socketControl.connectionUrl}");
      return;
    }

    if (event[0] == "OK") {
      //log("ok: $event");
      return;
    }



    // blocked users

    if (event.length >= 3) {
      if (event[2] != null) {
        var eventMap = event[2];
        if (searchFeedObj.blackUserIdList.contains(eventMap["pubkey"])) {
          return;
        }
      }
    }

    // filter by subscription id

    if (event[1] == ownPubkeySubscriptionId) {
      if (event[0] == "EOSE") {
        // check if this is for all relays
        counterOwnSubscriptionsHits++;

        if (counterOwnSubscriptionsHits == relays.connectedRelaysWrite.length) {
          //if (relayTracker.isEmpty) {
          //  //publish default relays

          //  log("using default relays: $defaultRelays and write this to relays");

          //  writeEvent(json.encode(defaultRelays), 2, []);
          //}

          return;
        }
        return;
      }

      Map eventMap = event[2];
      // metadata
      if (eventMap["kind"] == 0) {
        // goes through to normal metadata cache
      }
      // recommended relays
      if (eventMap["kind"] == 2) {
        // todo
      }
    }

    if(event[1].contains("actionFollow")){
      return;
    }

    if(event[1].contains("unotify")){
      eventsNotifyObj.receiveNostrEvent(event, socketControl);
    }

    if(event[1].contains("like")){
      feedLikeObj.receiveNostrEvent(event, socketControl);
    }

    if (event[1].contains("authors")) {
      authorsFeedObj.receiveNostrEvent(event, socketControl);
    }

    if (event[1].contains("event")) {
      eventsFeedObj.receiveNostrEvent(event, socketControl);
    }

    if(event[1].contains("header")){
      eventsFeedObj.receiveNostrEventHeader(event, socketControl);
    }

    /// user feed
    if (event[1].contains("ufeed")) {
      userFeedObj.receiveNostrEvent(event, socketControl);
    }

    /// global feed
    if (event[1].contains("gfeed")) {
      globalFeedObj.receiveNostrEvent(event, socketControl);
    }

    if(event[1].contains("umessage")){
      userMessageObj.receiveNostrEvent(event,socketControl);
    }

    if(event[1].contains("userfollow")){
      userFollowObj.receiveNostrEvent(event,socketControl);
    }

    if(event[1].contains("search")){
      searchFeedObj.receiveNostrEvent(event,socketControl);
    }

    if(event[1].contains("finduser")){
      searchFeedObj.receiveNostrFindUserEvent(event,socketControl);
    }
    if(event[1].contains("getblacklist")){
      searchFeedObj.receiveNostrBlackListEvent(event,socketControl);
    }

    if(event[1].contains("userrelays")){
      // print('userrelays');
      // print(event);
    }

    if(event[1].contains(EventsQuerier.QUERY_PRE)) {
      eventsQuerier.receiveEvent(event, socketControl);
    }

    var eventMap = {};
    try {
      eventMap = event[2]; //json.decode(event[2])
    } catch (e) {
    }


    /// global metadata
    if (eventMap["kind"] == 0) {
      userMetadataObj.receiveNostrEvent(event, socketControl);
    }

    /// global following / contacts
    if (eventMap["kind"] == 3) {
      userContactsObj.receiveNostrEvent(event, socketControl);
    }

    // global EOSE
    if (event[0] == "EOSE") {
      var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if(event[1].contains("umessage")){
        return;
      }

      if(event[1].contains("unotify")){
        return;
      }


      if (socketControl.requestInFlight[event[1]] != null) {
        var requestsLeft = _howManyRequestsLeft(
            event[1], socketControl, relays.connectedRelaysRead);
        if (requestsLeft < 2) {
          // callback
          if (socketControl.completers.containsKey(event[1])) {
            // wait 200ms for other events to arrive
            Future.delayed(const Duration(milliseconds: 200)).then((value) {
              if (!socketControl.completers[event[1]]!.isCompleted) {
                socketControl.completers[event[1]]!.complete();
              }
            });
          }
        }

        // send close request
        var req = ["CLOSE", event[1]];
        var reqJson = jsonEncode(req);

        // close the stream
        socketControl.send(reqJson);
        socketControl.requestInFlight.remove(event[1]);
        //log("CLOSE request sent to socket Metadata: ${socketControl.id}");
      }

      // contacts
      if (socketControl.requestInFlight[event[1]] != null) {
        // callback
        if (socketControl.completers.containsKey(event[1])) {
          if (!socketControl.completers[event[1]]!.isCompleted) {
            socketControl.completers[event[1]]!.complete();
          }
        }

        // send close request
        var req = ["CLOSE", event[1]];
        var reqJson = jsonEncode(req);
        socketControl.send(reqJson);
        socketControl.requestInFlight.remove(event[1]);
        //log("CLOSE request sent to socket Contacts: ${socketControl.id}");
      }

      return;
    }
  }

  repostEvent(Tweet tweet){
    print('转发===>');
    print(tweet);
    Map<String,dynamic> content = tweet.eventString;
    print(content);
    writeEvent(jsonEncode(content), 6, [['e',tweet.id],['p',tweet.pubkey]]);
  }

  likeEvent(Tweet tweet){
    // List tags = tweet.tags.where((tag) => tag.length >= 2 && (tag[0] == 'e' || tag[0] == 'p')).toList();
    List tags = [];
    tags.add(["e",tweet.id]);
    tags.add(["p",tweet.pubkey]);
    writeEvent("+", 7, tags);
  }

  writeEventForShow(String content, int kind, List tags) {
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    var calcId = [0, myKeys.publicKey, now, kind, tags, content];
    // serialize
    String calcIdJson = jsonEncode(calcId);

    // hash
    Digest id = sha256.convert(utf8.encode(calcIdJson));
    String idString = id.toString();

    // hex encode
    String idHex = HEX.encode(id.bytes);

    // sign
    String sig = Bip340().sign(idHex, myKeys.privateKey);

    var req = {
      "id": idString,
      "pubkey": myKeys.publicKey,
      "created_at": now,
      "kind": kind,
      "tags": tags,
      "content": content,
      "sig": sig
    };
    return req;
  }

  Map genAndSignEvent(String content, int kind, List tags, {int? now}) {
    // now ??= DateTime.now().millisecondsSinceEpoch ~/ 1000;
    //
    // var calcId = [0, myKeys.publicKey, now, kind, tags, content];
    // // serialize
    // String calcIdJson = jsonEncode(calcId);
    //
    // // hash
    // Digest id = sha256.convert(utf8.encode(calcIdJson));
    // String idString = id.toString();
    //
    // // hex encode
    // String idHex = HEX.encode(id.bytes);
    //
    // // sign
    // String sig = Bip340().sign(idHex, myKeys.privateKey);
    //
    // return {
    //   "id": idString,
    //   "pubkey": myKeys.publicKey,
    //   "created_at": now,
    //   "kind": kind,
    //   "tags": tags,
    //   "content": content,
    //   "sig": sig,
    // };

    return genAndSignEventWithKey(myKeys.publicKey, myKeys.privateKey, content, kind, tags, now: now);
  }

  Map genAndSignEventWithKey(String pubkey, String secretKey, String content, int kind, List tags, {int? now}) {
    now ??= DateTime.now().millisecondsSinceEpoch ~/ 1000;

    var calcId = [0, pubkey, now, kind, tags, content];
    // serialize
    String calcIdJson = jsonEncode(calcId);

    // hash
    Digest id = sha256.convert(utf8.encode(calcIdJson));
    String idString = id.toString();

    // hex encode
    String idHex = HEX.encode(id.bytes);

    // sign
    String sig = Bip340().sign(idHex, secretKey);

    return {
      "id": idString,
      "pubkey": pubkey,
      "created_at": now,
      "kind": kind,
      "tags": tags,
      "content": content,
      "sig": sig,
    };
  }

  writeEvent(String content, int kind, List tags, {int? now}) {
    now ??= DateTime.now().millisecondsSinceEpoch ~/ 1000;

    var calcId = [0, myKeys.publicKey, now, kind, tags, content];
    // serialize
    String calcIdJson = jsonEncode(calcId);

    // hash
    Digest id = sha256.convert(utf8.encode(calcIdJson));
    String idString = id.toString();

    // hex encode
    String idHex = HEX.encode(id.bytes);

    // sign
    String sig = Bip340().sign(idHex, myKeys.privateKey);

    if(kind == 3){
      idString = idString;
      // idString = "actionFollow"+idString;
    }

    var req = [
      "EVENT",
      {
        "id": idString,
        "pubkey": myKeys.publicKey,
        "created_at": now,
        "kind": kind,
        "tags": tags,
        "content": content,
        "sig": sig
      }
    ];

    var reqJson = jsonEncode(req);
    log("write event: $reqJson");

    bool sended = false;
    for (var relay in relays.connectedRelaysWrite.entries) {
      if (!(relay.value.socketIsRdy)) {
        log("socket not ready");
        continue;
      }
      sended = true;
      relay.value.send(reqJson);
    }

    if (sended) {
      return reqJson;
    }
  }

  _howManyRequestsLeft(String requestId, SocketControl currentSocket,
      Map<String, SocketControl> pool) {
    int count = 0;
    for (var socket in pool.entries) {
      if (socket.value.requestInFlight.containsKey(requestId)) {
        if (socket.value.id == currentSocket.id) {
          continue;
        }
        count++;
      }
    }
    return count;
  }

  void requestGlobalFeed({
    // required String requestId,
    int? since,
    int? until,
    int? limit,
  }) {
    globalFeedObj.requestGlobalFeed(
        // requestId: requestId,
        since: since, until: until, limit: limit);
  }

  void requestUserArticle(
      {required List<String> users,
        required String requestId,
        int? since,
        int? until,
        int? limit,
        bool? includeComments}) {
    userFeedObj.requestUserArticle(
        users: users,
        requestId: requestId,
        since: since,
        until: until,
        limit: limit,
        includeComments: includeComments);
  }

  void requestUserFeed(
      {required List<String> users,
        required String requestId,
        int? since,
        int? until,
        int? limit,
        bool? includeComments, bool initArticle = false}) {
    userFeedObj.requestUserFeed(
        users: users,
        requestId: requestId,
        since: since,
        until: until,
        limit: limit,
        includeComments: includeComments, initArticle: initArticle);
  }

  void requestAuthorsArticle(
      {required List<String> authors,
        required String requestId,
        int? since,
        int? until,
        int? limit}) {
    authorsFeedObj.requestArticle(
        authors: authors,
        requestId: requestId,
        since: since,
        until: until,
        limit: limit);
  }

  void requestAuthors(
      {required List<String> authors,
        required String requestId,
        int? since,
        int? until,
        int? limit}) {
    authorsFeedObj.requestAuthors(
        authors: authors,
        requestId: requestId,
        since: since,
        until: until,
        limit: limit);
  }

  // eventId for the nostr event, requestId to track the request
  void requestEvents(
      {required List<String> eventIds,
        required String requestId,
        int? since,
        int? until,
        int? limit,
        StreamController? streamController}) {
    eventsFeedObj.requestEvents(
      eventIds: eventIds,
      requestId: requestId,
      since: since,
      until: until,
      limit: limit,
      streamController: streamController,
    );
  }

  void requestEventsHeader(
      {required List<String> eventIds,
        required String requestId,
        int? since,
        int? until,
        int? limit,
        StreamController? streamController}) {
    eventsFeedObj.requestEvents(
      eventIds: eventIds,
      requestId: requestId,
      since: since,
      until: until,
      limit: limit,
      streamController: streamController,
    );
  }

  void closeSubscription(String subId) {
    var data = [
      "CLOSE",
      subId,
    ];

    var jsonString = json.encode(data);
    for (var relay in relays.connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[subId] = true;
      //todo add stream
    }
  }

  /// get user metadata from cache and if not available request it from network
/*  Future<Map> getUserMetadata(String pubkey) async {
    return userMetadataObj.getMetadataByPubkey(pubkey);
  }*/

  /// get user metadata from cache and if not available request it from network
  Future<List<List<dynamic>>> getUserContacts(String pubkey,
      {bool force = false}) async {
    return userContactsObj.getContactsByPubkey(pubkey, force: force);
  }

  /// returns [nip5 identifier, true, ] if valid or [null, null] if not found
  Future<Map> checkNip05(String nip05, String pubkey) async {
    return await nip05service.checkNip05(nip05, pubkey);
  }

  var hotGlobalFeed = <Tweet>[].obs;
  Future<List<Tweet>> getHotTweets() async {
    print('开始读取热门推文');
    var notesList = await getHot("notes", "https://api.nostr.band/v0/trending/notes");
    var videosList = await getHot("videos","https://api.nostr.band/v0/trending/videos");
    var imagesList = await getHot("images","https://api.nostr.band/v0/trending/images");
    var tempTweetList = [];
    tempTweetList.addAll(notesList);
    tempTweetList.addAll(videosList);
    tempTweetList.addAll(imagesList);
    hotGlobalFeed.clear();
    Set<String> tweetIdSet = {};
    for (var tweet in tempTweetList) {
      if(!tweetIdSet.contains(tweet.id)){
        hotGlobalFeed.add(tweet);
        tweetIdSet.add(tweet.id);
      }
    }

    // var audiosList = await getHot("audios", "https://api.nostr.band/v0/trending/audios");
    // hotGlobalFeed.addAll(audiosList);
    // hotGlobalFeed.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
    return hotGlobalFeed;
  }


  Future<List<Tweet>> getHot(String type, String url) async {
    var request = http.MultipartRequest('GET', Uri.parse(url));
    final response = await request.send();
    var responseString = await response.stream.transform(utf8.decoder).join();
    var rsObj = const JsonCodec().decode(responseString);
    // print('tweetList==>');
    var tweetList = rsObj[type].map<Tweet>((tweet) => Tweet.fromHttpJson(tweet)).toList();
    return tweetList;
  }



  Future<String> uploadImage(File file) async {
    final uri = Uri.parse('https://nostr.build/api/v2/upload/files');
    var request = http.MultipartRequest('POST', uri);
    var bytes = await file.readAsBytes();
    var mimeType = lookupMimeType(file.path);
    var filename = file.path.split('/').last;

    final httpImage = http.MultipartFile.fromBytes("fileToUpload", bytes,
        contentType: MediaType.parse(mimeType!), filename: filename);
    request.files.add(httpImage);

    final response = await request.send();
    print(response.statusCode);

    if (response.statusCode != 200) {
      return "";
    }

    var responseString = await response.stream.transform(utf8.decoder).join();
    print(responseString);
    /// {"status":"success","message":"Files uploaded successfully","data":[{"input_name":"APIv2","name":"0eea976afb49365773d2ec035145e0f6e50a58b417b005ecc29f7f5ba3fd7173.jpg","sha256":"0eea976afb49365773d2ec035145e0f6e50a58b417b005ecc29f7f5ba3fd7173","type":"picture","mime":"image\/jpeg","size":110443,"blurhash":"LIH-=38{TL%M_N-oM{xZtR-;RiIU","dimensions":{"width":824,"height":1024},"url":"https:\/\/image.nostr.build\/0eea976afb49365773d2ec035145e0f6e50a58b417b005ecc29f7f5ba3fd7173.jpg","thumbnail":"https:\/\/image.nostr.build\/thumb\/0eea976afb49365773d2ec035145e0f6e50a58b417b005ecc29f7f5ba3fd7173.jpg","responsive":{"240p":"https:\/\/image.nostr
    int sepLength = 7;
    var index = responseString.indexOf("\"url\":\"");
    var index2 = responseString.indexOf("\"", index + sepLength);
    if (index > -1 && index2 > -1) {
      var text = responseString.substring(index + sepLength, index2);
      text = text.replaceAll("\\/", "/");
      return text;
    } else {
      return "";
    }
    // // extract url https://nostr.build/i/4697.png
    // final RegExp urlPattern =
    // RegExp(r'https:\/\/cdn\.nostr\.build\/i\/\S+\.(?:jpg|jpeg|png|gif)');
    // final Match? urlMatch = urlPattern.firstMatch(responseString);
    // if (urlMatch != null) {
    //   final String myUrl = urlMatch.group(0)!;
    //   print('myUrl'+myUrl);
    //   return myUrl;
    // } else {
    //   return "";
    // }
  }

  void debug() {
    log("debug");
    relaysRanking.getBestRelays(
        "cd25e76b6a171b9a01a166a37dae7d217e0ccd573fb53207ca6d4d082bddc605",
        Direction.read);
  }

  Tweet? tryToFindTweet(String id) {
    var lists = authorsFeedObj.authorsReply.values;
    for (var list in lists) {
      for (var tweet in list) {
        if (tweet.id == id) {
          return tweet;
        }
      }
    }

    lists = authorsFeedObj.authorsArticle.values;
    for (var list in lists) {
      for (var tweet in list) {
        if (tweet.id == id) {
          return tweet;
        }
      }
    }

    for (var tweet in userFeedObj.feedReplay) {
      if (tweet.id == id) {
        return tweet;
      }
    }

    for (var tweet in userFeedObj.articleList) {
      if (tweet.id == id) {
        return tweet;
      }
    }
  }

}
