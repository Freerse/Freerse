import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';


import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:freerse/services/nostr/relays/relay_tracker.dart';
import 'package:freerse/services/nostr/relays/relays_injector.dart';
import 'package:get/get.dart';

import 'package:json_cache/json_cache.dart';

import '../../../helpers/helpers.dart';
import '../../../model/socket_control.dart';
import '../nostr_service.dart';

class Relays {
  final RxMap<String, dynamic> initRelays = RxMap.from({
    "wss://relay.damus.io": true,
    "wss://purplepag.es":true,
    "wss://relay.snort.social": true,
    "wss://nos.lol": true,
    "wss://relay.nostr.band": true,
    "wss://offchain.pub":true,
    "wss://eden.nostr.land":true,
    "wss://nostr.wine":true,
    "wss://nostr.oxtr.dev":true,
    "wss://relay.nostr.bg":true,
    "wss://relay.plebstr.com":true,
    "wss://nostr.bitcoiner.social":true,
    "wss://nostr.mom":true,
    "wss://relay.mostr.pub":true,
    "wss://relay.nostrplebs.com":true,
    "wss://nostr.orangepill.dev":true,
    "wss://puravida.nostr.land/":true,
    "wss://nostr.fmt.wiz.biz ":true,
    "wss://nostr-relay.nokotaro.com":true,
    "wss://relay.primal.net ":true,
    "wss://welcome.nostr.wine ":true
  });

  Relays() {
    RelaysInjector injector = RelaysInjector();
    relayTracker = injector.relayTracker;
    _initCache().then((value) => {_restoreFromCache()});
  }

  _initCache() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    _jsonCache = JsonCacheCrossLocalStorage(prefs);
    return Future(() => true);
  }

  _restoreFromCache() async {
    if (relays.isEmpty) {
      var relaysCache = await _jsonCache.value('relays');
      if (relaysCache != null) {
        // relays = relaysCache.cast<String, Map<String, dynamic>>();
        relays = RxMap<String, dynamic>.from(relaysCache);
      } else {
        // if everything fails, use default relays
        relays = initRelays;
      }
    }
    relayServiceRdy.complete();
  }

  late NostrService nostrService = Get.find();

  late JsonCache _jsonCache;

  late RelayTracker relayTracker;

  RxMap<String, dynamic> relays = RxMap();

  Map<String, SocketControl> connectedRelays = {};
  Map<String, SocketControl> get connectedRelaysRead {
    return connectedRelays;
  }
  Map<String, SocketControl> get connectedRelaysWrite {
    return connectedRelays;
  }

  final Completer isNostrServiceConnectedCompleter = Completer();

  Completer relayServiceRdy = Completer();

  // stream for receiving events from relays
  final StreamController<Map<String, dynamic>>
  _receiveEventStreamController =
  StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get receiveEventStream =>
      _receiveEventStreamController.stream;

  Future<void> connectToRelays({bool useDefault = false}) async {
    var usedRelays = useDefault ? initRelays : relays;

    for (var relay in usedRelays.entries) {
      if (relay.value) {
        _connectToRelay(relay.key);
      }
    }

    try {
      isNostrServiceConnectedCompleter.complete(true);
    } catch (e) {
      log("e");
    }
  }

  void _connectToRelay(String url) {
    var id = url;
    SocketControl socketControl = SocketControl.connect(id, url, _receiveEventStreamController, relayTracker);
    connectedRelays[id] = socketControl;
  }

  String getRelaySaveContent() {
    Map<String, Map<String, dynamic>> casted = relays
        .map((key, value) => MapEntry(key, {"write":true,"read":true}));
    return jsonEncode(casted);
  }

  void start() {
    // interval to check
    relayServiceRdy.future.then((value) => {
      connectToRelays(),
    });
  }

  checkRelaysForConnection() async {
    print('reconnect');
    connectToRelays();
  }

  Future<void> closeRelays() async {
    for (var entry in connectedRelays.entries) {
      var socketControl = entry.value;
      socketControl.close();
    }

    connectedRelays.clear();
  }

  refreshReplay(Map<String, dynamic> casted) {
    relays = RxMap<String, dynamic>.from(casted);
    _jsonCache.refresh('relays', relays);
    _completeConnectedRelays();
  }

  getRelayState(String relay) {
    var control = connectedRelays[relay];
    if (control != null && control.socketIsRdy) {
      return 1;
    }
    return 0;
  }

  addRelay(String relay){
    relays[relay] = true;
    saveRelay();
    _jsonCache.refresh('relays', relays);
    _completeConnectedRelays();
  }

  removeRelay(String relay){
    relays.remove(relay);
    saveRelay();
    _jsonCache.refresh('relays', relays);
    _completeConnectedRelays();
  }

  saveRelay(){
    Map<String, Map<String, dynamic>> casted = relays
        .map((key, value) => MapEntry(key, {"write":true,"read":true}));
    nostrService.refreshReply(jsonEncode(casted));
  }

  void _completeConnectedRelays() {
    connectedRelays.removeWhere((url, control) {
      if (relays[url] != true) {
        control.close();
        return true;
      }

      return false;
    });

    for (var entry in relays.entries) {
      var url = entry.key;
      var connectable = entry.value;

      if (connectable == true) {
        var control = connectedRelays[url];
        if (control == null) {
          _connectToRelay(url);
        }
      }
    }
  }

}
