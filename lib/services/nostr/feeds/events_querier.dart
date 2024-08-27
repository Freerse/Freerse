
import 'dart:convert';

import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/model/Tweet.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:get/get.dart';

import '../../../model/socket_control.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';

///

class EventsQuerier extends GetxService {

  static final String QUERY_PRE = "esquery";

  late Relays _relays;

  late Map<String, SocketControl> _connectedRelaysRead;

  RxMap<String, Tweet> tweets = RxMap();

  List<String> _pendingIds = [];
  // var _pendingIds = <String>[].obs;

  List<String> _queryingIds = [];

  EventsQuerier() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;
    _connectedRelaysRead = _relays.connectedRelaysRead;
  }

  void receiveEvent(event, SocketControl socketControl) {
    // print(event);
    if (event.length > 2) {
      var eventMap = event[2];
      var id = eventMap["id"];

      _queryingIds.remove(id);
    }

    if (event[0] == "EVENT") {
      var eventMap = event[2];
      var tweet = Tweet.fromNostrEvent(eventMap);
      tweets[tweet.id] = tweet;
      return;
    }
  }

  bool _delaying = false;

  Tweet? getOrFind(String id, NostrService nostrService) {
    var t = tweets[id];
    if (t != null) {
      return t;
    }

    if (_pendingIds.contains(id)) {
      return null;
    }

    t = nostrService.tryToFindTweet(id);
    if (t != null) {
      // tweets[id] = t;
      tweets.value[id] = t;
      return t;
    }

    _pendingIds.add(id);

    if (_delaying) {
      return null;
    }

    _delaying = true;
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      if (_pendingIds.isEmpty) {
        return;
      }

      _queryingIds.addAll(_pendingIds);
      _doQuery(_pendingIds);
      _pendingIds.clear();

      _delaying = false;
    });
    // debounce(_pendingIds, (ids) {
    //   if (ids.isEmpty) {
    //     return;
    //   }
    //   print("queryPenddings");
    //
    //   _queryingIds.addAll(ids);
    //   _doQuery(ids);
    //   _pendingIds.clear();
    // }, time: Duration(seconds: 1));
  }

  void _doQuery(List<String> ids) {
    var reqId = "${QUERY_PRE}-${Helpers().getRandomString(8)}";

    var newIds = []..addAll(ids);

    Map body = {
      "ids": newIds,
      // "kinds": [1],
    };

    var data = [
      "REQ",
      reqId,
      body,
    ];

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      // relay.value.requestInFlight[reqId] = true;
      // relay.value.additionalData[reqId] = {"eventIds": eventIds};
    }
  }

  void cancelQuery(String id) {
    if (_pendingIds.contains(id)) {
      _pendingIds.remove(id);
    }
  }

}