import 'dart:async';
import 'dart:convert';

import 'package:freerse/nostr/event.dart';
import 'package:freerse/nostr/events/userevent.dart';
import 'package:freerse/nostr/filter.dart';
import 'package:freerse/nostr/relay.dart';
import 'package:freerse/nostr/request.dart';
import 'package:freerse/nostr/utils.dart';
import 'package:get/get.dart';

class RelayPool{
  var relays = <Relay>[];
  var subIds = {};

  var eventDownloadCounter = 0;

  var cacheIds = <String>[];
  var unSubIds = <String>[];


  var tempEvent = <Event>[];
  var lastIndex = 0;
  var users = <UserEvent>[].obs;
  var feeds = <Event>[].obs;
  var userContacts = <Event>[].obs;


  void getMyInfo(){
    Request requestWithFilter3 = Request(generate64RandomHexChars(), [
      Filter(
        kinds: [0, 2, 3, 10000, 10001, 10002, 12165],
        authors:["b58941290c7872cd01bb25a41610a45886acaa08e6b56a7647dff614fc60ad24"],
      )
    ]);
    sends(requestWithFilter3);
  }

  void getFollowUserInfo(List<String> author){
    Request requestWithFilter = Request(generate64RandomHexChars(), [
      Filter(
        kinds: [0],
        authors:author,
      )
    ]);
    sends(requestWithFilter);
  }

  void getFeedsByPubKey(List<String> author){
    Request requestWithFilter = Request(generate64RandomHexChars(), [
      Filter(
        kinds: [1],
        authors:author,
        limit: 5
      )
    ]);
    sends(requestWithFilter);
  }

  void connect(List<String> url){
    for(var i=0;i<url.length;i++){
      Relay relay = new Relay(i, url[i]);
      relay.register((e) {
        receiveEvent(e,i);
      });
      relays.add(relay);
    }
  }

  late Timer timer;
  bool isRunning = false;

  void sends(Request data) {
    relays.forEach((relay) {
      relay.send(data);
    });
  }

  void disconnects(){
    relays.forEach((relay) {
      relay.close();
    });
  }

  void closeSubById(String id,int relayIndex){
   /* relays.forEach((relay) {
      relay.unsub(id);
    });*/
    relays[relayIndex].unsub(id);
  }

  void doneEvent(){
    isRunning = false;
  }

  Timer? _timer;

  // 重置计时器
  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 3), () {
      refreshData();
      print('refreshData');
    });
  }

  void refreshData(){
    if(tempEvent.length == 0){
      tempEvent.forEach((element) {
        switchKind(element);
      });
      lastIndex = tempEvent.length;
    }else{
      for(var i = lastIndex;i<tempEvent.length;i++){
        switchKind(tempEvent[i]);
      }
    }
  }

  void receiveEvent(String event,int relayIndex){
    print(event);
    var msg = jsonDecode(event);
    var type = msg[0].toString();
    var channel = msg[1].toString();
    switch(type){
      case 'EVENT':{
        //_resetTimer();
        eventDownloadCounter++;
        var content = msg[2];
        Event event = Event.fromJson(content);
        if(!cacheIds.contains(event.id)){
          cacheIds.add(event.id);
          //tempEvent.add(event);
          switchKind(event);
          //print(event.id+":"+event.pubkey+":"+event.createdAt.toString());
        }
      }
      break;
      case 'EOSE':{
        print("EOSE ${relayIndex} $channel");
        closeSubById(channel,relayIndex);
      }
      break;

      case 'NOTICE':{

      }
      break;

      case 'OK':{

      }
      break;

      default: {
        print("Unknown type $type on channel $channel. Msg was $msg");
      }
      break;
    }
  }


  void switchKind(Event event){
    switch(event.kind){
      case 0:
        //print(event.id+"-------------"+event.pubkey+"--------"+event.createdAt.toString());
        UserEvent user = UserEvent(event.id, event.pubkey, event.createdAt, event.kind, event.tags, event.content, event.sig);
        int index = users.indexWhere((o) => o.pubkey == user.pubkey);
        if(index >= 0){
         if(users[index].createdAt < user.createdAt){
            users[index] = user;
         }
        }else{
          users.add(user);
        }
        getFeedsByPubKey([user.pubkey]);
        break;
      case 1:
        feeds.add(event);
        feeds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        /*if(event.tags.length > 0){
          event.tags.forEach((element) {
            if(element[0] == 'p'){
              getFollowUserInfo([element[1]]);
            }
          });
        }*/
        break;
      case 3:
        userContacts.add(event);
        if(event.tags.length > 0){
          List<String> author = [];
          event.tags.forEach((element) {
            if(element[0] == 'p'){
              author.add(element[1]);
            }
          });
          getFollowUserInfo(author);
        }
        break;
    }
  }

}
