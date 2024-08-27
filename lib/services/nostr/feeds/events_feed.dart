import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import '../../../model/Tweet.dart';
import '../../../model/socket_control.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';



class EventsFeed {
  late Relays _relays;
  late Map<String, SocketControl> _connectedRelaysRead;
  late Stream<Tweet> headerStream;
  final StreamController<Tweet> headerStreamController =
  StreamController<Tweet>.broadcast();

  late Stream<Tweet> replyStream;
  final StreamController<Tweet> replyStreamController =
  StreamController<Tweet>.broadcast();

  // events, replies
  var _events = <String, List<Tweet>>{};
  var _eventsHeader = <String, List<Tweet>>{};


  EventsFeed() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;
    _connectedRelaysRead = _relays.connectedRelaysRead;
    headerStream = headerStreamController.stream;
    replyStream = replyStreamController.stream;
  }

  receiveNostrEvent(event, SocketControl socketControl) {
    // simply add to pool
    if (event[0] == "EVENT") {
      var eventMap = event[2];

      var tweet = Tweet.fromNostrEvent(eventMap);
      replyStreamController.sink.add(tweet);
      StreamController controller = socketControl.streamControllers[event[1]]!;
      if(!controller.isClosed){
        socketControl.streamControllers[event[1]]?.add(tweet);
      }

      return;
    }

  }

  requestEvents(
      {required List<String> eventIds,
      required String requestId,
      int? since,
      int? until,
      int? limit,
      StreamController? streamController}) {
    var reqId = "event-$requestId";

    Map body = {
      "ids": eventIds,
      "kinds": [1],
    };

    Map body2 = {
      "#e": eventIds,
      "kinds": [1],
      //"limit": limit ?? 10,
    };
    if (since != null) {
      body["since"] = since;
      body2["since"] = since;
    }
    if (until != null) {
      body["until"] = until;
      body2["until"] = until;
    }

    var data = [
      "REQ",
      reqId,
      body,
      body2,
    ];

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[reqId] = true;
      relay.value.additionalData[reqId] = {"eventIds": eventIds};
      if (streamController != null) {
        relay.value.streamControllers[reqId] = streamController;
      }
    }
  }


  requestEventsHeader(
      {required List<String> eventIds,
        required String requestId,
        int? since,
        int? until,
        int? limit,
        StreamController? streamController}) {
    var reqId = "header-$requestId";

    Map body = {
      "ids": eventIds,
      "kinds": [1],
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
      relay.value.additionalData[reqId] = {"eventIds": eventIds};
      if (streamController != null) {
        relay.value.streamControllers[reqId] = streamController;
      }
    }
  }

  receiveNostrEventHeader(event, SocketControl socketControl) {
    if (event[0] == "EVENT") {
      var eventMap = event[2];
      if(eventMap["kind"] == 1){
        var tweet = Tweet.fromNostrEvent(eventMap);
        headerStreamController.sink.add(tweet);
      }
      return;
    }
    if (event[0] == "EOSE") {

      return;
    }
  }
}
