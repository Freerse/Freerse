import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

import '../../../model/Tweet.dart';
import '../../../model/socket_control.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';



class SearchFeed {
  late Relays _relays;
  late Map<String, SocketControl> _connectedRelaysRead;
  late Stream<Tweet> headerStream;
  final StreamController<Tweet> headerStreamController =
  StreamController<Tweet>.broadcast();

  late Stream<Tweet> replyStream;
  final StreamController<Tweet> replyStreamController =
  StreamController<Tweet>.broadcast();
  late final NostrService nostrService = Get.find();

  SearchFeed() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;
    _connectedRelaysRead = _relays.connectedRelaysRead;
    headerStream = headerStreamController.stream;
    replyStream = replyStreamController.stream;
    
    initKeywordGroup();
  }

  receiveNostrEvent(event, SocketControl socketControl) {
    // simply add to pool
    if (event[0] == "EVENT") {
      // print(event);
      var eventMap = event[2];
      var tweet = Tweet.fromNostrEvent(eventMap);
      replyStreamController.sink.add(tweet);
      var controller = socketControl.streamControllers[event[1]];
      if(controller != null && !controller.isClosed){
        // socketControl.streamControllers[event[1]]?.add(tweet);
        controller.add(tweet);
      }
      return;
    }
  }

  receiveNostrFindUserEvent(event, SocketControl socketControl) {
    // simply add to pool
    if (event[0] == "EVENT") {
      // print(socketControl.id);
      // print(event);
      var eventMap = event[2];
      var userInfo = RxMap<String, dynamic>.from(eventMap);

      // var tweet = Tweet.fromNostrEvent(eventMap);
      // replyStreamController.sink.add(tweet);
      var controller = socketControl.streamControllers[event[1]];
      if(controller != null && !controller.isClosed){
        // socketControl.streamControllers[event[1]]?.add(userInfo);
        controller.add(userInfo);
      }
      return;
    }
  }

  stopSearch({required String requestId}){
    var reqId = "search-$requestId";
    var data = ["CLOSE", reqId];
    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[reqId] = true;
    }
  }

  List<List<String>> keywordGroups = [
    ["Foodstr", "food"],
    ["Coffeechain", "coffee"],
    ["Plebchain", "pleb"],
    ["Bitcoin", "BTC"]
  ];
  Map<String, List<String>> keywordGroupMap = {};

  void initKeywordGroup() {
    for (var list in keywordGroups) {
      for (var kw in list) {
        keywordGroupMap[kw] = list;
      }
    }
  }

  requestSeach(
      {required String requestId,
        required String keyword,
      int? since,
      int? until,
      int? limit,
      StreamController? streamController}) {
    var reqId = "search-$requestId";
    bool isTag = false;
    if (keyword.indexOf("#") == 0) {
      isTag = true;
    }

    Map body = {
      // "search": keyword,
      "kinds": [1],
      "limit":100
    };

    // handleSearchKeyword(body, keyword);
    if (isTag) {
      List<String> tags = [];
      var sourceKw = keyword.substring(1);
      tags.add(sourceKw);

      var keywordGroup = keywordGroupMap[sourceKw];
      if (keywordGroup != null) {
        for (var kw in keywordGroup) {
          if (!tags.contains(kw)) {
            tags.add(kw);
          }
        }
      }

      {
        var changedKW = keyword.toLowerCase();
        if (keyword != changedKW) {
          var kw = changedKW.substring(1);
          if (!tags.contains(kw)) {
            tags.add(kw);
          }
        }
      }

      {
        var changedKW = keyword.toUpperCase();
        if (keyword != changedKW) {
          var kw = changedKW.substring(1);
          if (!tags.contains(kw)) {
            tags.add(kw);
          }
        }
      }

      body["#t"] = tags;
    } else {
      body["search"] = keyword;
    }

    var data = [
      "REQ",
      reqId,
      body,
    ];

    var jsonString = json.encode(data);
    print("search feed call!");
    print(jsonString);

    if (isTag) {
      for (var relay in _connectedRelaysRead.entries) {
        _doSendForOnRelay(relay.value, jsonString, reqId, streamController);
      }
    } else {
      bool existSearchable = false;
      for (var relay in _connectedRelaysRead.entries) {
        if (relay.value.socketIsRdy && searchableRelays.contains(relay.value.id)) {
          existSearchable = true;
          break;
        }
      }

      if (!existSearchable) {
        for (var relay in _connectedRelaysRead.entries) {
          _doSendForOnRelay(relay.value, jsonString, reqId, streamController);
        }
      } else {
        for (var relay in _connectedRelaysRead.entries) {
          if (searchableRelays.contains(relay.value.id)) {
            _doSendForOnRelay(relay.value, jsonString, reqId, streamController);
          }
        }
      }
    }

    // for (var relay in _connectedRelaysRead.entries) {
    //   relay.value.send(jsonString);
    //   relay.value.requestInFlight[reqId] = true;
    //   if (streamController != null) {
    //     relay.value.streamControllers[reqId] = streamController;
    //   }
    // }
  }

  // void handleSearchKeyword(Map body, String keyword) {
  //   if (keyword.indexOf("#") == 0) {
  //     body["#t"] = [keyword.substring(1)];
  //     return;
  //   }
  //
  //   body["search"] = keyword;
  // }

  var searchableRelays = ["wss://nostr.wine","wss://relay.nostr.band"];

  requestUserSeach(
      {required String requestId,
        required String keyword,
        int? since,
        int? until,
        int? limit,
        StreamController? streamController}) {
    var reqId = "finduser-$requestId";

    Map body = {
      "search": keyword,
      "kinds": [0],
      "limit":100
    };

    var data = [
      "REQ",
      reqId,
      body,
    ];

    var jsonString = json.encode(data);
    print("search call!");
    print(jsonString);

    bool existSearchable = false;
    for (var relay in _connectedRelaysRead.entries) {
      if (relay.value.socketIsRdy && searchableRelays.contains(relay.value.id)) {
        existSearchable = true;
        break;
      }
    }
    // print("search user $existSearchable");

    if (!existSearchable) {
      for (var relay in _connectedRelaysRead.entries) {
        // relay.value.send(jsonString);
        // relay.value.requestInFlight[reqId] = true;
        // if (streamController != null) {
        //   relay.value.streamControllers[reqId] = streamController;
        // }
        _doSendForOnRelay(relay.value, jsonString, reqId, streamController);
      }
    } else {
      for (var relay in _connectedRelaysRead.entries) {
        if (searchableRelays.contains(relay.value.id)) {
          _doSendForOnRelay(relay.value, jsonString, reqId, streamController);
        }
      }
    }
  }

  void _doSendForOnRelay(SocketControl relay, String jsonString, String reqId, StreamController? streamController) {
    relay.send(jsonString);
    relay.requestInFlight[reqId] = true;
    if (streamController != null) {
      relay.streamControllers[reqId] = streamController;
    }
  }


  requestUserBlackList({required String pubkey, StreamController? streamController}) {
    String searchId = Helpers().getRandomString(4);
    var reqId = "getblacklist-"+ searchId;
    Map body = {
      "pubkey":pubkey,
      "kinds": [10002],
      "limit": 10000
    };

    var data = [
      "REQ",
      reqId,
      body,
    ];

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[reqId] = true;
      if (streamController != null) {
        relay.value.streamControllers[reqId] = streamController;
      }
    }
  }

  switchBlackUser({required String userId}) {
    var newIdList = [];
    if(blackUserIdList.contains(userId)){
      blackUserIdList.remove(userId);
    }else{
      blackUserIdList.add(userId);
    }
    for (var userId in blackUserIdList) {
      newIdList.add(["p",userId]);
    }
    nostrService.writeEvent('BLACK_USER_INFO', 10002,  newIdList);
  }

  var backUserTime = 0.obs;
  var blackUserIdList = <String>[].obs;
  receiveNostrBlackListEvent(event, SocketControl socketControl) {
    if (event[0] == "EVENT") {
      var eventMap = event[2];
      var createdAt = eventMap['created_at'];
      var tagList = eventMap['tags'];
      var content = eventMap['content'];
      // print(eventMap);

      if(createdAt > backUserTime.value && content == 'BLACK_USER_INFO'){
        print(eventMap);
        backUserTime.value = createdAt;
        blackUserIdList.clear();
        List<String> pubkey = [];
        tagList.forEach((element) {
          if(element[0] == 'p'){
            if(!blackUserIdList.contains(element[1])){
              blackUserIdList.add(element[1]);
            }
            pubkey.add(element[1]);
          }
        });
      }
      // StreamController controller = socketControl.streamControllers[event[1]]!;
      // if(!controller.isClosed){
      //   socketControl.streamControllers[event[1]]?.add(pubkey);
      // }
      return;
    }
  }

}
