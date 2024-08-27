import 'dart:async';

import 'package:get/get.dart';

import '../../helpers/helpers.dart';
import '../../model/Tweet.dart';
import '../../model/post_reply_event.dart';
import '../../services/nostr/nostr_service.dart';

class FeedDetailController extends GetxController {
  late final Tweet data;
  late final NostrService nostrService = Get.find();

  late StreamSubscription _streamreplaySubscription;
  String requestId = Helpers().getRandomString(12);
  final StreamController<Tweet> replyStreamController =
  StreamController<Tweet>.broadcast();

  var replays = <Tweet>[].obs;
  var events = <String, Tweet>{};


  @override
  void onInit() {
    final params = Get.arguments;
    data = params['data'];
    _streamreplaySubscription = replyStreamController.stream.listen((event) {
      onEventReply(event);
    });

    requestEvents();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }


  @override
  void onClose() {
    closeSubscription();
    replyStreamController.close();
    _streamreplaySubscription.cancel();
    nostrService.removeTag();
    super.onClose();
  }

  void closeSubscription() {
    nostrService.closeSubscription("event-$requestId");
  }


  void requestEvents() {
    nostrService.requestEvents(
        eventIds: [data.id],
        requestId: requestId,
        //limit: 30,
        streamController: replyStreamController);
  }


  void onEventReply(Tweet item){
    if(events.containsKey(item.id)){
      return;
    }
    // print("onEvent isSecond? ${item.isSecondReply} ${item.toJson()}");

    events[item.id] = item;

    makeReply();

    // if(!item.isSecondReply && item.id != data.id){
    //   List<Tweet> tempList = [];
    //   for (Tweet item2 in events.values) {
    //     tempList.add(item2);
    //   }
    //   List<Tweet> childs = findAllRelatedItems(item.id, tempList);
    //   item.commentsCount = childs.length;
    //   replays.add(item);
    //   replays.value.sort((a, b) => a.tweetedAt.compareTo(b.tweetedAt));
    // }else{
    //
    // }
  }

  void makeReply() {
    replays.clear();
    for (var item in events.values) {
      if ((!item.isSecondReply || item.getSecondId() == data.id) && item.id != data.id) {
        List<Tweet> childs = findAllRelatedItems(item.id, events.values);
        item.commentsCount = childs.length;
        replays.add(item);
        replays.value.sort((a, b) => a.tweetedAt.compareTo(b.tweetedAt));
      }
    }
  }


  List<Tweet> findAllRelatedItems(String id, Iterable<Tweet> list) {
    List<Tweet> result = [];

    void dfs(String currentId) {
      for (Tweet item in list) {
        if (item.getSecondId() == currentId) {
          result.add(item);
          dfs(item.id);
        }
      }
    }

    dfs(id);
    return result;
  }




}
