import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';


import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:json_cache/json_cache.dart';

import '../../../helpers/bip340.dart';
import '../../../helpers/helpers.dart';
import '../../../model/socket_control.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';

class UserContacts {
  late Map<String, SocketControl> _connectedRelaysRead = {};
  late Relays _relays;
  late String ownPubkey;

  /// map with pubkey as identifier, second list [0] is p, [1] is pubkey, [2] is the relay url
  RxMap<String, List<List>> following = RxMap();
  RxMap<String, List<String>> followingFormat = RxMap();
  RxMap<String, int> followingLastMsgTime = RxMap();


  RxMap<String,List<String>> userRelays = RxMap();
  late JsonCache _jsonCache;

  List<String> _contactsWaitingPool = [];
  late Timer _contactsWaitingPoolTimer;
  var _contactsWaitingPoolTimerRunning = false;
  Map<String, Completer<List<List>>> _contactsFutureHolder = {};

  late KeyPair myKeys;


  UserContacts() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;
    _connectedRelaysRead = _relays.connectedRelaysRead;
    _init();
  }

  _init() async {
    //LocalStorageInterface prefs = await LocalStorage.getInstance();
    //_jsonCache = JsonCacheCrossLocalStorage(prefs);
    FlutterSecureStorage storage = const FlutterSecureStorage();
    storage.read(key: "nostrKeys").then((nostrKeysString) {
      if (nostrKeysString == null) {
        return;
      }

      // to obj
      myKeys = KeyPair.fromJson(json.decode(nostrKeysString));
    });
  }

  bool isFollowByMe(String pubkey){
    List<String>? result = meFollowUserIdList;
    if(result != null){
      if(result.contains(pubkey)){
        return true;
      }
    }
    return false;
  }



  List<String> getUserRelys(String pubkey){
    List<String>? result = userRelays[pubkey];
    if(result != null){
      return result;
    }else{
      return [];
    }
  }

  getContactsByPubkey(String pubkey, {bool force = false}) {
    // return from cache
   /* if (following.containsKey(pubkey) && !force) {
      return Future(() => following[pubkey]!);
    }*/

    Completer<Map> result = Completer();

    // check if pubkey is already in waiting pool
    if (!_contactsWaitingPool.contains(pubkey)) {
      _contactsWaitingPool.add(pubkey);
    }

    // if pool is full submit request
    if (_contactsWaitingPool.length >= 10) {
      _contactsWaitingPoolTimer.cancel();
      _contactsWaitingPoolTimerRunning = false;

      // submit request
      result.complete(_prepareContactsRequest(pubkey));
    } else if (!_contactsWaitingPoolTimerRunning) {
      _contactsWaitingPoolTimerRunning = true;
      _contactsWaitingPoolTimer = Timer(const Duration(milliseconds: 500), () {
        _contactsWaitingPoolTimerRunning = false;
        // submit request
        result.complete(_prepareContactsRequest(pubkey));
      });
    } else {
      // cancel previous timer
      _contactsWaitingPoolTimer.cancel();
      // start timer again
      _contactsWaitingPoolTimerRunning = true;
      _contactsWaitingPoolTimer = Timer(const Duration(milliseconds: 500), () {
        _contactsWaitingPoolTimerRunning = false;

        // submit request
        result.complete(_prepareContactsRequest(pubkey));
      });
    }
    if (_contactsFutureHolder[pubkey] == null) {
      _contactsFutureHolder[pubkey] = Completer<List<List>>();
    }
    result.future.then((value) => {
          for (var key in _contactsFutureHolder.keys)
            {
              if (!_contactsFutureHolder[key]!.isCompleted)
                {
                  _contactsFutureHolder[key]!.complete(value[key] ?? []),
                }
            },
          _contactsFutureHolder = {}
        });
    return _contactsFutureHolder[pubkey]!.future;
  }

  Future<Map<String, List>> _prepareContactsRequest(String pubkey) {
    // gets notified when first or last (on no data) request is received
    Completer completer = Completer();

    var requestId = "contacts-${Helpers().getRandomString(4)}";

    List<String> poolCopy = [..._contactsWaitingPool];

    _requestContacts(poolCopy, requestId, completer);

    // free pool
    _contactsWaitingPool = [];

    return completer.future.then((value) {
      if (following.containsKey(pubkey)) {
        // wait 300ms for the contacts to be received
        return Future.delayed(const Duration(milliseconds: 300), () {
          return Future(() => following);
        });
      }
      return Future(() => {});
    });
  }

  void _requestContacts(
      List<String> users, requestId, Completer? completer) async {
    var data = [
      "REQ",
      requestId,
      {
        "authors": users,
        "kinds": [3],
        "limit": users.length
      },
    ];
    var jsonString = json.encode(data);

    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[requestId] = true;
      if (completer != null) {
        relay.value.completers[requestId] = completer;
      }
    }
  }

  void requestContacts(
      List<String> users, requestId) async {
    var data = [
      "REQ",
      requestId,
      {
        "authors": users,
        "kinds": [3],
        "limit": users.length
      },
    ];
    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[requestId] = true;
    }
  }

  var followUserTime = 0.obs;
  var meFollowUserIdList = <String>[].obs;
  var followNow = DateTime.now().millisecondsSinceEpoch + 10000;
  receiveNostrEvent(event, SocketControl socketControl) {
    var eventMap = event[2];
    var pubkey = eventMap["pubkey"];
    // cast with for loop
    List<List<dynamic>> tags = [];
    List<String> tagsString = [];
    var isMe = myKeys.publicKey == pubkey;
    var createdAt = eventMap['created_at'];
    var lastFollowMsgTime = followingLastMsgTime[pubkey];


    if(lastFollowMsgTime != null && createdAt < lastFollowMsgTime){
      return;
    }
    followingLastMsgTime[pubkey] = createdAt;

    var meNewFollowFresh = false;
    var isMeFollowTimeNoOut = false;
    if(isMe && createdAt > followUserTime.value){
      meNewFollowFresh = true;
      isMeFollowTimeNoOut = DateTime.now().millisecondsSinceEpoch  <= followNow;
    }
    for (List t in eventMap["tags"]) {
      tags.add(t as List<dynamic>);
      tagsString.add(t[1].toString());
    }
    //isMeFollowTimeNoOut
    if(meNewFollowFresh){
      meFollowUserIdList.clear();
      meFollowUserIdList.addAll(tagsString);
      followUserTime.value = createdAt;
    }



    if(!userRelays.keys.contains(pubkey)){
      //var ssss  = json.decode(eventMap["content"]);
      //userRelays[pubkey] = ssss.keys.toList();
    }
    // var createdAt = eventMap['created_at'];

    if(isMe){
    //   if(createdAt > meLastFlowTime.value){
    //     meLastFlowTime.value = createdAt;
    //   }else{
    //     // return;
    //   }
    //   if(following[pubkey]!.isNotEmpty){
    //     return;
    //   }
    }

    // cast to list of lists
    following[pubkey] = tags;
    followingFormat[pubkey] = tagsString;
    //following[pubkey] = tags as List<List>;

    //update cache
    //_jsonCache.refresh('following', following);

    // callback
    if (socketControl.completers.containsKey(event[1])) {
      if (!socketControl.completers[event[1]]!.isCompleted) {
        socketControl.completers[event[1]]!.complete();
      }
    }

    if (pubkey == ownPubkey) {
      // update my following
      following[pubkey] = tags;

      try {
        Map cast = json.decode(eventMap["content"]);
        // cast every entry to Map<String, dynamic>>
        Map<String, dynamic> casted = cast
            .map((key, value) => MapEntry(key, true));


        _relays.refreshReplay(casted);
        // todo: update relays
        // update relays
        //relays = casted;
        //update cache
        //_jsonCache.refresh('relays', casted);
      } catch (e) {
        log("error: $e");
      }
    }
    //update cache
    //_jsonCache.refresh('following', following);
  }
}
