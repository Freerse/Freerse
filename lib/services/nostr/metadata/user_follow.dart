import 'dart:async';
import 'dart:convert';


import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:json_cache/json_cache.dart';

import '../../../helpers/bip340.dart';
import '../../../helpers/helpers.dart';
import '../../../model/socket_control.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';

///
/// how metadata request works
///
/// batches of pubkeys in metadata request
/// request pool
/// mark no metadata available in cache do prevent double requests
///

class UserFollow {
  RxMap<String, List<String>> usersFollowData = RxMap();

  late Map<String, SocketControl> _connectedRelaysRead = {};
  late Relays _relays;

  late JsonCache _jsonCache;
  late KeyPair myKeys;

  UserFollow() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;
    _connectedRelaysRead = _relays.connectedRelaysRead;
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

      myKeys = KeyPair.fromJson(json.decode(nostrKeysString));
    });
  }



  getUserFollows(String pubkey){
    if(pubkey.isEmpty){
      return [];
    }

    if (usersFollowData.containsKey(pubkey)) {
      return usersFollowData[pubkey];
    }

    var requestId = "userfollow-${pubkey}";
    _getNetWork([pubkey], requestId);

    return [];
  }

  _getNetWork(List<String> users, requestId) async{
    var data = [
      "REQ",
      requestId,
      {
        "#p": users,
        "kinds": [3],
      },
    ];

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[requestId] = true;
    }
  }

  receiveNostrEvent(event, SocketControl socketControl) {
    if(event[0] == 'EVENT'){
      var eventMap = event[2];
      var pubkey = eventMap["pubkey"];
      String userId = event[1].toString().replaceAll("userfollow-", "");
      if(!usersFollowData.containsKey(userId.toString())){
        List<String> result = [pubkey];
        usersFollowData[userId.toString()] = result;
      }else{
        List<String> result = usersFollowData[userId.toString()]!;
        if(!result.contains(pubkey)){
          result.add(pubkey);
          usersFollowData[userId.toString()] = result;
        }
      }
    }

   /* var eventMap = event[2];
    var pubkey = eventMap["pubkey"];
    if(!usersFollowData.containsKey(pubkey.toString())){

    }
    _jsonCache.refresh('usersMetadata', usersFollowData);*/
  }
}
