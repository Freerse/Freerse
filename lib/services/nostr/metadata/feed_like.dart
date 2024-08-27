import 'dart:async';
import 'dart:convert';
import 'dart:developer';


import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freerse/model/LinghtItem.dart';
import 'package:get/get.dart';
import 'package:json_cache/json_cache.dart';

import '../../../helpers/bip340.dart';
import '../../../helpers/helpers.dart';
import '../../../model/socket_control.dart';
import '../relays/relays.dart';
import '../relays/relays_injector.dart';
import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:decimal/decimal.dart';


///
/// how metadata request works
///
/// batches of pubkeys in metadata request
/// request pool
/// mark no metadata available in cache do prevent double requests
///

class FeedLikedata {
  RxMap<String, int> feedLikes = RxMap();
  RxMap<String, int> feedLikesMine = RxMap();
  RxMap<String, int> feedReports = RxMap();
  RxMap<String, int> feedReportsMine = RxMap();
  RxMap<String, int> feedLightCounts = RxMap();
  RxMap<String, Decimal> feedLightAmounts = RxMap();

  RxMap<String,List<String>> reportMap = RxMap();
  RxMap<String,List<String>> zanMap = RxMap();
  RxMap<String,List<LinghtItem>> linghtMap = RxMap();

  late Map<String, SocketControl> _connectedRelaysRead = {};
  late Relays _relays;

  late JsonCache _jsonCache;
  late KeyPair myKeys;


  var _events = <String, dynamic>{};


  FeedLikedata() {
    RelaysInjector injector = RelaysInjector();
    _relays = injector.relays;
    _connectedRelaysRead = _relays.connectedRelaysRead;
    _init();
  }

  List<String> getUserList(String eventId, int type){
    List<String>? result = type == 1 ? zanMap[eventId] : reportMap[eventId];
    if(result != null){
      return result;
    }else{
      return [];
    }
  }

  List<LinghtItem> getLightUserList(String eventId){
    List<LinghtItem>? result =  linghtMap[eventId];
    // var amount = getFeedLightAmount(eventId);
    if(result != null){
      return result;
    }else{
      return [];
    }
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

  bool chekIsFeedLike(String eventId){
    int? count = feedLikesMine[eventId];
    if(count != null){
      return true;
    }else{
      return false;
    }
  }

  getFeedLikeCount(String eventId){
    int my_count = 0;
    int? count = feedLikesMine[eventId];
    if(count != null){
      my_count = 1;
    }

    if(eventId.isEmpty){
      return 0+my_count;
    }

    if (feedLikes.containsKey(eventId)) {
      return feedLikes[eventId]!+my_count;
    }

    var requestId = "like-${eventId.substring(0, 10)}";
    _getNetWork([eventId], requestId);

    return 0+my_count;
  }

  bool chekIsReport(String eventId){
    int? count = feedReportsMine[eventId];
    if(count != null){
      return true;
    }else{
      return false;
    }
  }

  getFeedReportCount(String eventId){
    int my_count = 0;
    int? count = feedReportsMine[eventId];
    if(count != null){
      my_count = 1;
    }

    if(eventId.isEmpty){
      return 0+my_count;
    }

    if (feedReports.containsKey(eventId)) {
      return feedReports[eventId]!+my_count;
    }
    return 0+my_count;
  }

  getFeedLightCount(String eventId){
    if(eventId.isEmpty){
      return 0;
    }

    if (feedLightCounts.containsKey(eventId)) {
      return feedLightCounts[eventId];
    }
    return 0;
  }

  getFeedLightAmount(String eventId){
    if(eventId.isEmpty){
      return '0';
    }
    if (feedLightAmounts.containsKey(eventId)) {
      return formatNumber(feedLightAmounts[eventId]!.toDouble());
    }
    return '0';
  }

  static String formatNumber(num number) {
    if (number.abs() >= 1000) {
      return (number / 1000).toStringAsFixed(1) + 'K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  _getNetWork(List<String> ids, requestId) async{
    Map body = {
      "#e": ids,
      "kinds": [6,7,9735],
    };

    var data = [
      "REQ",
      requestId,
      body
    ];

    var jsonString = json.encode(data);
    for (var relay in _connectedRelaysRead.entries) {
      relay.value.send(jsonString);
      relay.value.requestInFlight[requestId] = true;
    };
  }

  bool hasZaped(String zapFeedId, String pubkey) {
    var list = linghtMap[zapFeedId];
    if (list != null) {
      for (var item in list) {
        if (item.pubkey == pubkey) {
          return true;
        }
      }
    }
    return false;
  }

  void removeZapTempEvent(String feedId, String zapEventId) {
    var list = linghtMap[feedId];
    if (list != null) {
      list.removeWhere((element) {
        if (element.zapEventId == zapEventId) {
          var counts = feedLightCounts[feedId];
          if (counts != null) {
            feedLightCounts[feedId] = counts - 1;
          }

          var amount = feedLightAmounts[feedId];
          if (amount != null) {
            feedLightAmounts[feedId] = amount - element.amount!;
          }
          return true;
        }
        return false;
      });
    }
  }

  void addZap(String feedId, String pubkey, Decimal zapAmount, int createTime, {String? zapEventId}) {
    Decimal? amount = feedLightAmounts[feedId];
    if(amount != null){
      feedLightAmounts[feedId] = amount+zapAmount;
    }else{
      feedLightAmounts[feedId] = zapAmount;
    }

    int? count = feedLightCounts[feedId];
    if(count != null){
      feedLightCounts[feedId] = count+1;

      var list = linghtMap[feedId]!;
      list.add(LinghtItem(pubkey: pubkey , amount: zapAmount, createTime: createTime, zapEventId: zapEventId));
      linghtMap[feedId] = list;
    }else{
      feedLightCounts[feedId] = 1;
      linghtMap[feedId] = [LinghtItem(pubkey: pubkey, amount: zapAmount, createTime: createTime, zapEventId: zapEventId)];
    }
  }

  receiveNostrEvent(event, SocketControl socketControl) {
    if(event[0] == 'EVENT'){
      String eventId = event[1].toString().replaceAll("like-", "");
      var eventMap = event[2];
      var id = eventMap['id'];
      if (_events.containsKey(id)){
        return;
      }
      _events[id] = event;

      if(eventMap['kind'] == 6){
        String feedId = "";
        for (var t in eventMap["tags"]) {
          if (t[0] == "e") {
            feedId = t[1];
          }
        }
        if(eventMap['pubkey'] == myKeys.publicKey){
          feedReportsMine[feedId] = 1;
          reportMap[feedId] = [eventMap['pubkey']];
        }else{
          int? count = feedReports[feedId];
          if(count != null){
            feedReports[feedId] = count+1;
            var list = reportMap[feedId]!;
            list.add(eventMap['pubkey']);
            reportMap[feedId] = list;

          }else{
            feedReports[feedId] = 1;
            reportMap[feedId] = [eventMap['pubkey']];
          }
        }
      }else if(eventMap['kind'] == 9735){
        String bolt = "";
        String feedId = "";
        String userKey = "";
        int createTime = 0;
        for (var t in eventMap["tags"]) {
          if (t[0] == "bolt11") {
            bolt = t[1];
          }
          if(t[0] == "e"){
            feedId = t[1];
          }
          if(t[0] == "description"){
            // print('description=start');
            var dianJiObj = jsonDecode(t[1]);
            // print(dianJiObj);
            // print('description=end');
            userKey = dianJiObj['pubkey']??'';
            createTime = dianJiObj['created_at']?? 0;
          }
        }

        // log(jsonEncode(eventMap));

        Bolt11PaymentRequest req = Bolt11PaymentRequest(bolt);
        var result = req.amount * Decimal.parse("100000000");

        addZap(feedId, userKey, result, createTime);

      }else if(eventMap['kind'] == 7){
        String feedId = "";
        for (var t in eventMap["tags"]) {
          if (t[0] == "e") {
            feedId = t[1];
          }
        }
        if(eventMap['pubkey'] == myKeys.publicKey){
          feedLikesMine[feedId] = 1;
          zanMap[feedId] = [eventMap['pubkey']];
        }else{
          int? count = feedLikes[feedId];
          if(count != null){
            feedLikes[feedId] = count+1;
            var list = zanMap[feedId]!;
            list.add(eventMap['pubkey']);
            zanMap[feedId] = list;
          }else{
            feedLikes[feedId] = 1;
            zanMap[feedId] = [eventMap['pubkey']];
          }
        }
      }
  }
  }
}
