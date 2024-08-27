import 'dart:async';
import 'dart:convert';


import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:get/get.dart';
import 'package:json_cache/json_cache.dart';

import '../../../helpers/helpers.dart';
import '../../../model/Tweet.dart';
import '../../../model/socket_control.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';

class GlobalFeed {
  late JsonCache _jsonCache;

  late Relays _relays;

  var feed = <Tweet>[].obs;
  late Stream globalFeedStream;
  final StreamController<List<Tweet>> _globalFeedStreamController =
      StreamController<List<Tweet>>.broadcast();

  late Map<String, SocketControl> _connectedRelaysRead;

  GlobalFeed() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;

    _connectedRelaysRead = _relays.connectedRelaysRead;

    globalFeedStream = _globalFeedStreamController.stream;
    //_init();
  }

  bool _needClear = false;

  void markClear() {
    _needClear = true;
  }

  _init() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    _jsonCache = JsonCacheCrossLocalStorage(prefs);
  }

  void restoreFromCache() async {
    final Map<String, dynamic>? cachedGlobalFeed =
        await _jsonCache.value('globalFeed');

    if (cachedGlobalFeed?["tweets"] != null) {
      feed = cachedGlobalFeed!["tweets"]
          .map<Tweet>((tweet) => Tweet.fromJson(tweet))
          .toList();
    }
    // replies
    for (var tweet in feed) {
      tweet.replies =
          tweet.replies.map<Tweet>((reply) => Tweet.fromJson(reply)).toList();
    }
    feed.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
    _globalFeedStreamController.add(feed);
  }

  receiveNostrEvent(event, SocketControl socketControl) {
    if (event[0] == "EOSE") {
      return;
    }

    if (event[0] == "EVENT") {
      var eventMap = event[2];

      /// global content
      if (eventMap["kind"] == 1) {
        List<dynamic> tags = eventMap["tags"] ?? [];

        Tweet tweet = Tweet.fromNostrEvent(eventMap);
        if(tweet.pubkey =='8ed237334555289b3f412a88f391b1a33e90f01a335fc31c410b4a2bcaa04c30'){
          return;
        }

        if (_needClear) {
          // 需要 clear
          feed.clear();
          _needClear = false;
        }

        //check for duplicates
        if (feed.any((element) => element.id == tweet.id)) {
          return;
        }

        // add tweet to global feed on top
        feed.add(tweet);

        //sort global feed by time
        feed.sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));

        // trim feed to 200 tweets
        if (feed.length > 200) {
          feed.removeRange(200, feed.length);
        }

        // save to cache as json
       /* _jsonCache.refresh('globalFeed',
            {"tweets": feed.map((tweet) => tweet.toJson()).toList()});*/

        //log("nostr_service: new tweet added to global feed");
        _globalFeedStreamController.add(feed);
      }
    }
  }

  String requestId = Helpers().getRandomString(6);

  void markNewRequest() {
    requestId = Helpers().getRandomString(6);
  }

  void requestGlobalFeed({
    // required String requestId,
    int? since,
    int? until,
    int? limit,
  }) {
    // global feed ["REQ","globalFeed 0739",{"since":1672483074,"kinds":[1,2],"limit":5}]

    var reqId = "gfeed-$requestId";
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    var body = {
      "kinds": [1],
      "limit": limit ?? 25,
    };
    if (since != null) {
      body["since"] = since;
    }
    if (until != null) {
      body["until"] = until;
    }

    var data = ["REQ", reqId, body];

    var jsonString = json.encode(data);
    bool existSearchable = false;
    for (var relay in _connectedRelaysRead.entries) {
      if (searchableRelays.contains(relay.value.id) && relay.value.socketIsRdy) {
        existSearchable = true;
        break;
      }
    }
    // print("global search $existSearchable");

    if (!existSearchable) {
      for (var relay in _connectedRelaysRead.entries) {
        print(relay.value.id);
        print(jsonString);
        _doSendForOnRelay(relay.value, jsonString);
      }
    } else {
      for (var relay in _connectedRelaysRead.entries) {
        if (searchableRelays.contains(relay.value.id)) {
          print(relay.value.id);
          print(jsonString);
          _doSendForOnRelay(relay.value, jsonString);
        }
      }
    }

    // for (var relay in _connectedRelaysRead.entries) {
    //   if(relay.value.connectionUrl == 'wss://relay.nostr.band'){
    //     relay.value.send(jsonString);
    //   }
    //   if(relay.value.connectionUrl == 'wss://welcome.nostr.wine'){
    //     relay.value.send(jsonString);
    //   }
    // }
  }

  _doSendForOnRelay(SocketControl relay, String jsonString) {
    relay.send(jsonString);
  }

  var searchableRelays = ["wss://nostr.wine", "wss://relay.nostr.band", "wss://welcome.nostr.wine"];
}
