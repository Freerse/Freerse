import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/data/event_db.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/model/EventModel.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';
import 'package:json_cache/json_cache.dart';

import '../../../helpers/bip340.dart';
import '../../../model/socket_control.dart';
import '../../../nostr/utils.dart';
import '../metadata/user_msg.dart';
import '../nips/nip04.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';

class UserMessage{
  late JsonCache _jsonCache;
  late Relays _relays;

  late Map<String, SocketControl> _connectedRelaysRead;
  Nip04 _nip04 = Nip04();

  late String myPrivateKey;
  late KeyPair myKeys;

  var newFriend = <UserMsg>[].obs;
  RxMap<String, List<UserMsg>> userMessages = RxMap();

  UserMessage() {
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

      // to obj
      myKeys = KeyPair.fromJson(json.decode(nostrKeysString));
      //userContactsObj.ownPubkey = myKeys.publicKey;
    });
  }

  Future<void> saveReadLastMessage(String type) async {
    int time = (DateTime.now().millisecondsSinceEpoch.toDouble() / 1000).toInt();
    await _jsonCache.refresh("latestReadTimes", {type : time});
  }

  Future<int> getReadLastMessage(String type) async {
    Map<String, dynamic>? cachedNotifyState = await _jsonCache.value("latestReadTimes");
    int time = (DateTime.now().millisecondsSinceEpoch.toDouble() / 1000).toInt();
    if(cachedNotifyState != null && cachedNotifyState![type] != null){
      return int.parse(cachedNotifyState![type]!.toString());
    }
    return time;
  }

  String encodeContent(String userId,String content){
    var result = "";
    result = _nip04.encrypt(myKeys.privateKey, userId, content);
    return result;
  }

  receiveNostrEvent(event, SocketControl socketControl) {
    _doReceiveNostrEvent(event);
  }

  String decrypt(String pubkey, String content) {
    return _nip04.decrypt(myKeys.privateKey, pubkey, content);
  }

  void _doReceiveNostrEvent(event, {bool ignoreDB = false}) {
    if (event[0] == "EOSE") {
      return;
    }
    if (event[0] == "EVENT") {
      var eventMap = event[2];
      if (eventMap["kind"] == 4) {
        String userId;
        // String text;
        UserMsg msg;
        if(eventMap['pubkey'] != myKeys.publicKey){
          userId = eventMap['pubkey'];
          // text = _nip04.decrypt(myKeys.privateKey, eventMap['pubkey'], eventMap['content']);
          msg = UserMsg(id: eventMap['id'], create: eventMap['created_at'], decryptFunc: decrypt, decryptPubkey: eventMap['pubkey'], sourceContent: eventMap['content'], sig: eventMap['sig'], sender: eventMap['pubkey'],
              receiver: myKeys.publicKey,tags: eventMap['tags']);
        } else {
          userId = eventMap['tags'][0][1];
          // text = _nip04.decrypt(myKeys.privateKey, eventMap['tags'][0][1], eventMap['content']);
          msg = UserMsg(id: eventMap['id'], create: eventMap['created_at'], decryptFunc: decrypt, decryptPubkey: eventMap['tags'][0][1], sourceContent: eventMap['content'], sig: eventMap['sig'], sender: eventMap['pubkey'],
              receiver: myKeys.publicKey,tags: eventMap['tags']);
        }

        if(!userMessages.containsKey(userId)){
          userMessages[userId] = [msg];
          if (!ignoreDB) {
            _checkAndInsertToDB(eventMap);
          }
        }else{
          List<UserMsg> list = userMessages[userId]!;
          if (list.any((element) => element.id == msg.id)) {
            return;
          }
          list!.add(msg);
          userMessages[userId] = list;
          if (!ignoreDB) {
            _checkAndInsertToDB(eventMap);
          }
        }
      }
    }
    return;
  }
  
  Future<void> restoreFromDB() async {
    var list = await EventDB.list(Cons.DEFAULT_DB_KEY_INDEX, 4, 0, 1000000);
    for (var eventObj in list) {
      List eventDataList = ["EVENT", "thisisqueryid", eventObj.toJson(hasTags: true)];
      _doReceiveNostrEvent(eventDataList, ignoreDB: true);
    }
  }

  Future<void> _checkAndInsertToDB(Map<String, dynamic> eventMap) async {
    var event = EventModel.fromJson(eventMap);
    if (StringUtils.isNotBlank(event.id)) {
      var oldEvent = await EventDB.get(Cons.DEFAULT_DB_KEY_INDEX, event.id!);
      if (oldEvent == null) {
        await EventDB.insert(Cons.DEFAULT_DB_KEY_INDEX, event);
      }
    }
  }

  void requestUserFeed(
      {required List<String> users,
        int? since,
        int? until,
        bool? includeComments}) {
    log("requestUserFeed call!");
    // var requestId = generate64RandomHexChars();
    var requestId = Helpers().getRandomString(10);
    var reqId = "umessage-$requestId";
    Map<String, dynamic> body1 = {
      "kinds": [4],
      "#p":users,
    };

    Map<String, dynamic> body2 = {
      "kinds": [4],
      "authors":users
    };

    if (since != null) {
      body1["since"] = since;
      body2["since"] = since;
    }

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
