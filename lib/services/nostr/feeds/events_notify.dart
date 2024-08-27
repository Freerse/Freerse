
import 'dart:async';
import 'dart:convert';

import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:json_cache/json_cache.dart';

import '../../../helpers/bip340.dart';
import '../../../model/LinghtItem.dart';
import '../../../model/Tweet.dart';
import '../../../model/socket_control.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';

class EventNotify{
  var feedReplay = <Tweet>[].obs;

  late JsonCache _jsonCache;
  late Relays _relays;

  late Map<String, SocketControl> _connectedRelaysRead;

  late Stream eventsNotifyStream;
  final StreamController<Map<String, dynamic>> _eventsNotifyStreamController =
  StreamController<Map<String, dynamic>>.broadcast();

  // late Stream userNotifyStream;
  // final StreamController<Tweet> _userNotifyStreamController =
  // StreamController<Tweet>.broadcast();
  //
  // late Stream userNotifyLikeStream;
  // final StreamController<Map<String, dynamic>> _userNotifyLikeStreamController =
  // StreamController<Map<String, dynamic>>.broadcast();
  //
  // late Stream useLightStream;
  // final StreamController<LinghtItem> _userLightStreamController =
  // StreamController<LinghtItem>.broadcast();

  var _events = <String, dynamic>{};
  late KeyPair myKeys;

  EventNotify() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;
    _connectedRelaysRead = _relays.connectedRelaysRead;
    eventsNotifyStream = _eventsNotifyStreamController.stream;
    // userNotifyStream = _userNotifyStreamController.stream;
    // userNotifyLikeStream = _userNotifyLikeStreamController.stream;
    // useLightStream = _userLightStreamController.stream;
    _init();
  }

  _init() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    _jsonCache = JsonCacheCrossLocalStorage(prefs);
    FlutterSecureStorage storage = const FlutterSecureStorage();
    storage.read(key: "nostrKeys").then((nostrKeysString) {
      if (nostrKeysString == null) {
        return;
      }

      // to obj
      myKeys = KeyPair.fromJson(json.decode(nostrKeysString));
    });
  }

  receiveNostrEvent(event, SocketControl socketControl) {
    if(event[0] == 'EVENT') {
      var eventMap = event[2];
      var id = eventMap['id'];
      if (_events.containsKey(id)){
        return;
      }
      _events[id] = event;
      _eventsNotifyStreamController.sink.add(eventMap);
      // if(eventMap['kind'] == 1) {
      //   var tweet = Tweet.fromNostrEvent(eventMap);
      //   if(tweet.pubkey != myKeys.publicKey){
      //     _userNotifyStreamController.sink.add(tweet);
      //   }
      // }else if(eventMap['kind'] == 6){
      //   // repost
      //   var tweet = Tweet.genRepostTweet(eventMap);
      //   if(tweet.pubkey != myKeys.publicKey){
      //     _userNotifyStreamController.sink.add(tweet);
      //   }
      // }else if(eventMap['kind'] == 7){
      //   _userNotifyLikeStreamController.sink.add(eventMap);
      // }else if(eventMap['kind'] == 9735){
      //   String bolt = "";
      //   String feedId = "";
      //   String userKey = "";
      //   int createTime = 0;
      //   for (var t in eventMap["tags"]) {
      //     if (t[0] == "bolt11") {
      //       bolt = t[1];
      //     }
      //     if(t[0] == "e"){
      //       feedId = t[1];
      //     }
      //     if(t[0] == "description"){
      //       // print('description=start');
      //       var dianJiObj = jsonDecode(t[1]);
      //       // print(dianJiObj);
      //       // print('description=end');
      //       userKey = dianJiObj['pubkey']??'';
      //       createTime = dianJiObj['created_at']?? 0;
      //     }
      //   }
      //   Bolt11PaymentRequest req = Bolt11PaymentRequest(bolt);
      //   var result = req.amount * Decimal.parse("100000000");
      //   _userLightStreamController.sink.add(LinghtItem(pubkey: userKey , amount: result, createTime: createTime));
      // }
    }
  }

  void requestUserNotify(
      {required List<String> users,
        required String requestId,
        int? since,
        int? until,
        int? limit,
        bool? includeComments}) {
    var reqId = "unotify-$requestId";
    const defaultLimit = 100;

    // used to fetch comments on the posts
    var body1 = {
      "#p": users,
      "kinds": [1],
    };

    var body2 ={
      "#p": users,
      "kinds": [6,7,9735],
    };


    var data = [
      "REQ",
      reqId,
      body1,
      body2
    ];

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[reqId] = true;
    }
  }

}
