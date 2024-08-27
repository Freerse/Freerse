import 'dart:async';
import 'dart:convert';


import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:freerse/services/SpUtils.dart';
import 'package:get/get.dart';
import 'package:json_cache/json_cache.dart';

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

class UserMetadata {
  RxMap<String, dynamic> usersMetadata = RxMap();

  late Map<String, SocketControl> _connectedRelaysRead = {};
  late Relays _relays;

  late JsonCache _jsonCache;

  List<String> _metadataWaitingPool = [];
  late Timer _metadataWaitingPoolTimer;
  var _metadataWaitingPoolTimerRunning = false;
  Map<String, Completer<Map>> _metadataFutureHolder = {};

  UserMetadata() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;
    _connectedRelaysRead = _relays.connectedRelaysRead;
    _init();
  }

  _init() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    _jsonCache = JsonCacheCrossLocalStorage(prefs);
    await getTopFend();
  }

  RxMap<String, dynamic> topFrends = RxMap();
  setTopFend(String pubkey, bool value){
    topFrends[pubkey] = value;
    _jsonCache.refresh('topFrends', topFrends);
  }

  bool isTopFrend(String key){
    var isTop = false;
    if(topFrends[key] != null){
      isTop = topFrends[key];
    }
    return isTop;
  }

  getTopFend() async{
    Map<String, dynamic>? topFrendsMap = await _jsonCache.value('topFrends');
    if (topFrendsMap != null) {
      topFrends.addAll(topFrendsMap);
    }
    return topFrends;
  }


  setUserInfo(String pubkey,dynamic content){
    usersMetadata[pubkey] = content;
    _jsonCache.refresh('usersMetadata', usersMetadata);
  }

  setUserRemark(String pubkey,String remark){
    usersMetadata[pubkey]['display_name'] = remark;
    _jsonCache.refresh('usersMetadata', usersMetadata);
  }

  getUserInfo(String pubkey){
    if(pubkey.isEmpty){
      return {};
    }

    if (usersMetadata.containsKey(pubkey)) {
      var mate =  usersMetadata[pubkey];
      return mate;
    }

    var requestId = "metadata-${Helpers().getRandomString(4)}";
    _getNetWork([pubkey], requestId);


    return {};
  }

  _getNetWork(List<String> users, requestId) async{
    var data = [
      "REQ",
      requestId,
      {
        "authors": users,
        "kinds": [0],
        "limit": users.length
      },
    ];

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[requestId] = true;
    };
  }

  receiveNostrEvent(event, SocketControl socketControl) {
    var eventMap = event[2];

    var pubkey = eventMap["pubkey"];

    //usersMetadata[pubkey] = jsonDecode(eventMap["content"]);
    if(!usersMetadata.containsKey(pubkey.toString())){
      // var userNickName = SpUtils.getString(pubkey, "");
      var userInfo = jsonDecode(eventMap["content"]);
      // userInfo['display_name'] = userNickName;
      usersMetadata.addAll({pubkey.toString(): userInfo});
    }

    // add access time
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    //usersMetadata[pubkey]["accessTime"] = now;

    //update cache
    _jsonCache.refresh('usersMetadata', usersMetadata);
  }
}
