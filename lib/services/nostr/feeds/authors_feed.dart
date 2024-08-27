import 'dart:async';
import 'dart:convert';

import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:json_cache/json_cache.dart';

import '../../../model/Tweet.dart';
import '../../../model/socket_control.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';

class AuthorsFeed {
  late JsonCache _jsonCache;
  late Relays _relays;

  var authors = <String, List<Tweet>>{};
  var authorsReply = <String, List<Tweet>>{};
  var authorsArticle = <String, List<Tweet>>{};

  late Stream<Map<String, List<Tweet>>> authorsStream;
  final StreamController<Map<String, List<Tweet>>> _authorsStreamController =
      StreamController<Map<String, List<Tweet>>>.broadcast();

  late Stream<Map<String, List<Tweet>>> authorsReplyStream;
  final StreamController<Map<String, List<Tweet>>>
      _authorsReplyStreamController =
      StreamController<Map<String, List<Tweet>>>.broadcast();

  late Stream<Map<String, List<Tweet>>> authorsArticleStream;
  final StreamController<Map<String, List<Tweet>>>
      _authorsArticleStreamController =
      StreamController<Map<String, List<Tweet>>>.broadcast();

  late Map<String, SocketControl> _connectedRelaysRead;

  AuthorsFeed() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;
    _connectedRelaysRead = _relays.connectedRelaysRead;

    authorsStream = _authorsStreamController.stream;
    authorsReplyStream = _authorsReplyStreamController.stream;
    authorsArticleStream = _authorsArticleStreamController.stream;
    _init();
  }

  _init() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    _jsonCache = JsonCacheCrossLocalStorage(prefs);
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
          if (!authorsReply.containsKey(eventMap["pubkey"])) {
            authorsReply[eventMap["pubkey"]] = [];
          }
          if (authorsReply[eventMap["pubkey"]]!
              .any((element) => element.id == tweet.id)) {
            return;
          }
          authorsReply[eventMap["pubkey"]]!.add(tweet);
          authorsReply[eventMap["pubkey"]]!
              .sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
          _authorsReplyStreamController.add(authorsReply);
        } else {
          if (!authors.containsKey(eventMap["pubkey"])) {
            authors[eventMap["pubkey"]] = [];
          }
          if (authors[eventMap["pubkey"]]!
              .any((element) => element.id == tweet.id)) {
            return;
          }
          authors[eventMap["pubkey"]]!.add(tweet);
          authors[eventMap["pubkey"]]!
              .sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
          _authorsStreamController.add(authors);

          authorsReply[eventMap["pubkey"]]!.add(tweet);
          authorsReply[eventMap["pubkey"]]!
              .sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
          _authorsReplyStreamController.add(authorsReply);
        }

        return;
      } else if (eventMap["kind"] == 6) {
        var tweet = Tweet.fromNostrEvent(eventMap);
        print(eventMap['content']);
        var tweetRepost = Tweet.fromNostrEvent(jsonDecode(eventMap['content']));

        if (authorsReply[eventMap["pubkey"]]!.length < 10) {
          tweet.setRepostTweet(tweetRepost);
          if (!authorsReply.containsKey(eventMap["pubkey"])) {
            authorsReply[eventMap["pubkey"]] = [];
          }
          if (authorsReply[eventMap["pubkey"]]!
              .any((element) => element.id == tweet.id)) {
            return;
          }
          authors[eventMap["pubkey"]]!.add(tweet);
          authors[eventMap["pubkey"]]!
              .sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
          _authorsStreamController.add(authors);

          authorsReply[eventMap["pubkey"]]!.add(tweet);
          authorsReply[eventMap["pubkey"]]!
              .sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
          _authorsReplyStreamController.add(authorsReply);
        }
      } else if (eventMap['kind'] == 30023) {
        var tweet = Tweet.fromNostrEvent(eventMap);
        if (!authorsArticle.containsKey(eventMap["pubkey"])) {
          authorsArticle[eventMap["pubkey"]] = [];
        }
        // check if tweet already exists
        if (authorsArticle[eventMap["pubkey"]]!
            .any((element) => element.id == tweet.id)) {
          return;
        }
        authorsArticle[eventMap["pubkey"]]!.add(tweet);
        // sort by timestamp
        authorsArticle[eventMap["pubkey"]]!
            .sort((a, b) => b.tweetedAt.compareTo(a.tweetedAt));
        _authorsArticleStreamController.add(authorsArticle);
      }
    }
  }

  void requestArticle(
      {required List<String> authors,
      required String requestId,
      int? since,
      int? until,
      int? limit}) {
    // reqId contains authors to later sort it out
    var reqId = "authorsArticle-$requestId";
    Map<String, dynamic> body = {
      "authors": authors,
      "kinds": [30023],
    };
    if (limit != null) {
      body["limit"] = limit;
    }
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
    }
  }

  void requestAuthors(
      {required List<String> authors,
      required String requestId,
      int? since,
      int? until,
      int? limit}) {
    // reqId contains authors to later sort it out
    var reqId = "authors-$requestId";

    Map<String, dynamic> body = {
      "authors": authors,
      "kinds": [1],
    };
    var body2 = {
      "authors": authors,
      "kinds": [6],
    };
    if (limit != null) {
      body["limit"] = limit;
    }
    if (since != null) {
      body["since"] = since;
    }
    if (until != null) {
      body["until"] = until;
    }
    var data = ["REQ", reqId, body, body2];

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
    }
  }
}
