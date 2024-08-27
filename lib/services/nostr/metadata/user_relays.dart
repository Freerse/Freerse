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

class UserRelays {
  RxMap<String, List<String>> usersFollowData = RxMap();

  late Map<String, SocketControl> _connectedRelaysRead = {};
  late Relays _relays;

  late JsonCache _jsonCache;
  late KeyPair myKeys;

  UserRelays() {
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


  getUserRelays(String publicKey) async{
    var requestId = "userrelays-${publicKey}";
    var data = [
      "REQ",
      requestId,
      {
        "authors": [publicKey],
        "kinds": [10002],
        "limit": 1
      },
    ];

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[requestId] = true;
    }
  }

}
