import 'dart:async';
import 'dart:convert';


import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';
import 'package:json_cache/json_cache.dart';

import '../../../model/Tweet.dart';
import '../../../model/socket_control.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';

class UserFeed {
  var feed = <Tweet>[].obs;
  var feedReplay = <Tweet>[].obs;
  var feedRepost = <Tweet>[].obs;
  var articleList = <Tweet>[].obs;

  var feedCollect = <Tweet>[].obs;
  RxMap<String, Tweet> feedCollectIdSet = RxMap();

  late JsonCache _jsonCache;
  late Relays _relays;

  late Stream userFeedStream;
  final StreamController<List<Tweet>> _userFeedStreamController =
  StreamController<List<Tweet>>.broadcast();

  late Stream userFeedStreamReplies;
  final StreamController<List<Tweet>> _userFeedStreamControllerReplies =
  StreamController<List<Tweet>>.broadcast();

  late Map<String, SocketControl> _connectedRelaysRead;

  UserFeed() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;
    _connectedRelaysRead = _relays.connectedRelaysRead;

    userFeedStream = _userFeedStreamController.stream;
    userFeedStreamReplies = _userFeedStreamControllerReplies.stream;
    _init();
  }

  _init() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    _jsonCache = JsonCacheCrossLocalStorage(prefs);
    await getCollectFeed();
  }

  collectFeed(Tweet feed){
    if(feedCollectIdSet[feed.id] == null){
      feedCollect.insert(0, feed);
      feedCollectIdSet[feed.id] = feed;
    }else{
      feedCollect.remove(feed);
      feedCollectIdSet.remove(feed.id);
    }
    Map<String, dynamic> usersMetadata = RxMap();
    usersMetadata.putIfAbsent("tweets", feedCollect);
    _jsonCache.refresh('userFeedCollect', usersMetadata);
  }

  getCollectFeed() async{
    final Map<String, dynamic>? cachedUserCollectFeed = await _jsonCache.value('userFeedCollect');
    if (cachedUserCollectFeed != null) {
      print('cachedUserCollectFeed');
      print(cachedUserCollectFeed);
      feedCollect.value = cachedUserCollectFeed["tweets"]
          .map<Tweet>((tweet) => Tweet.fromJson(tweet))
          .toList();
      for (Tweet tweet in feedCollect.value) {
        print(tweet.isArticle);
        feedCollectIdSet[tweet.id] = tweet;
      }
    }
  }

  Future<void> restoreFromCache() async {
    // user feed
    final Map<String, dynamic>? cachedUserFeed =
    await _jsonCache.value('userFeed');
    if (cachedUserFeed != null) {
      feed = cachedUserFeed["tweets"]
          .map<Tweet>((tweet) => Tweet.fromJson(tweet))
          .toList();

      // user Collect feed
      final Map<String, dynamic>? cachedUserCollectFeed =
      await _jsonCache.value('userFeedCollect');
      if (cachedUserCollectFeed != null) {
        feedCollect = cachedUserCollectFeed["tweets"]
            .map<Tweet>((tweet) => Tweet.fromJson(tweet))
            .toList();
        for (Tweet tweet in feedCollect) {
          feedCollectIdSet[tweet.id] = tweet;
        }
      }
      // replies
      for (var tweet in feed) {
        tweet.replies =
            tweet.replies.map<Tweet>((reply) => Tweet.fromJson(reply)).toList();
      }
      feed.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));

      // send to stream /send to ui
      _userFeedStreamController.add(feed);
    }
  }

  bool _needClear = false;

  void markClearArticle() {
    // articleList.clear();
    _needClear = true;
  }

  receiveNostrEvent(event, SocketControl socketControl) {
    if (event[0] == "EOSE") {
      return;
    }

    if (event[0] == "EVENT") {
      var eventMap = event[2];
      // content
      if (eventMap["kind"] == 1) {
        var tweet = Tweet.fromNostrEvent(eventMap);
        if (tweet.isReply) {
          // find parent tweet in tags else return null
          if (feedReplay.any((element) => element.id == tweet.id)) {
            return;
          }
          feedReplay.add(tweet);
          _userFeedStreamControllerReplies.sink.add(feedReplay);
        }else{
          if (feed.any((element) => element.id == tweet.id)) {
            return;
          }
          feed.add(tweet);
          feedReplay.add(tweet);
          _userFeedStreamController.sink.add(feed);
          _userFeedStreamControllerReplies.sink.add(feedReplay);
        }
        _jsonCache.refresh('userFeed', {"tweets": feed});
        return;
      }else if(eventMap["kind"] == 6){
        var tweet = Tweet.genRepostTweet(eventMap);
        if (tweet == null) {
          return;
        }
        if (feedReplay.any((element) => element.id == tweet.id)) {
          return;
        }
        feed.add(tweet);
        feedReplay.add(tweet);
        _userFeedStreamController.sink.add(feed);
        _userFeedStreamControllerReplies.sink.add(feedReplay);
      }else if(eventMap["kind"] == 30023){
        if (_needClear) {
          articleList.clear();
          _needClear = false;
        }

        var tweet = Tweet.fromNostrEvent(eventMap);
        if (articleList.any((element) => element.id == tweet.id)) {
          return;
        }
        articleList.add(tweet);
        articleList.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
      }
    }
    return;
  }

  void requestUserFeed(
      {required List<String> users,
        required String requestId,
        int? since,
        int? until,
        int? limit,
        bool? includeComments, bool initArticle = false}) {
    var reqId = "ufeed-$requestId";
    const defaultLimit = 5;

    var body1 = {
      "authors": users,
      "kinds": [1, 6],
      "limit": limit ?? defaultLimit,
    };

    // var body1 = {
    //   "authors": users,
    //   "kinds": [1],
    //   "limit": limit ?? defaultLimit,
    // };

    // used to fetch comments on the posts
    // var body2 = {
    //   "authors": users,
    //   "kinds": [6],
    //   "limit": limit ?? defaultLimit,
    // };

    if (since != null) {
      body1["since"] = since;
      // body2["since"] = since;
    }
    if (until != null) {
      body1["until"] = until;
      // body2["until"] = until;
    }

    print("query reqId $reqId");

    var data = [
      "REQ",
      reqId,
      body1,
      // body2,
    ];

    if (initArticle) {
      var body3 = {
        "authors": users,
        "kinds": [30023],
        "limit": 10,
      };

      data.add(body3);
    }

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[reqId] = true;
    }
  }

  void requestUserArticle(
      {required List<String> users,
        required String requestId,
        int? since,
        int? until,
        int? limit,
        bool? includeComments}) {
    var reqId = "ufeed-$requestId";
    const defaultLimit = 5;

    Map<String, dynamic> body = {
      "authors": users,
      "kinds": [30023],
      "limit": limit ?? defaultLimit,
    };

    if (since != null) {
      body["since"] = since;
    }
    if (until != null) {
      body["until"] = until;
    }

    var data = [
      "REQ",
      reqId,
      body,
    ];

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[reqId] = true;
    }
  }
}
