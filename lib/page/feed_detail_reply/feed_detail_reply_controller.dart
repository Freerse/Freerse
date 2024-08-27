import 'dart:async';

import 'package:get/get.dart';

import '../../helpers/helpers.dart';
import '../../model/Tweet.dart';
import '../../services/nostr/nostr_service.dart';
import '../feed_detail/feed_detail_controller.dart';

class FeedDetailReplyController extends GetxController {
  String root_id = '';
  String event_id = '';
  late final NostrService nostrService = Get.find();
  late final FeedDetailController feedDetailController;

  late StreamSubscription _streamSubscription;
  late StreamSubscription _headerSubscription;

  final StreamController<Tweet> replyStreamController =
  StreamController<Tweet>.broadcast();

  String requestId = Helpers().getRandomString(12);
  var data = Tweet(id: 'id', pubkey: 'pubkey', userFirstName: 'userFirstName', userUserName: 'userUserName', userProfilePic: 'userProfilePic', content: 'content', imageLinks: [], tweetedAt: 0, tags: [], likesCount: 0, commentsCount: 0, retweetsCount: 0, replies: []).obs;
  var replays = <Tweet>[].obs;
  var header = <Tweet>[].obs;

  var events = <String, Tweet>{};


  late Tweet? rootTree;
  var datas = <String, Tweet>{};

  Timer? _timer;

  @override
  void onInit() {
    event_id = Get.arguments['id'];
    var hasHeader = Get.arguments['hasHeader'];
    Tweet eventData = Get.arguments['data'];
    if(hasHeader){
      Map<String, Tweet>? eventDatas = Get.arguments['datas'];
      if(eventDatas != null){
        root_id = eventData.getRootId();
        data.value = eventData;
        datas = eventDatas;
        makeData();
      }else{
        getDataFromLastDetail();
      }
    }else{
      root_id = eventData.getRootId();
      data.value = eventData;
      requestEvents(root_id);
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        makeData();
      });
    }
    _streamSubscription = replyStreamController.stream.listen((event) {
      onEvent(event);
    });
    _headerSubscription = nostrService.eventsFeedObj.headerStream.listen((event) {
      _onHeaderReceived(event);
    });
    super.onInit();
  }

  @override
  void onClose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    closeSubscription();
    replyStreamController.close();
    _streamSubscription.cancel();
    _headerSubscription.cancel();
    nostrService.removeTagReply();
    super.onClose();
  }

  void refreshData(){
    requestEvents(root_id);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      makeData();
    });
  }

  void closeSubscription() {
    nostrService.closeSubscription("event-$requestId");
  }

  void makeData(){
    // print('makeData');

    Tweet? root = datas[root_id];
    if(root != null){
      if(!data.value.getSecondId().isEmpty){
        addHeader(root_id, data.value.getSecondId());
      }
      rootTree = root;
      if(hasTweet(header.value, rootTree!)){
        header.add(rootTree!);
      }
    }

    List<Tweet> tempList = [];
    for (Tweet item in datas.values) {
      tempList.add(item);
    }

    List<Tweet> list = findAllRelatedItems(data.value.id, tempList);
    replays.value = list;

    header.value.sort((a, b) => a.tweetedAt.compareTo(b.tweetedAt));
    replays.value.sort((a, b) => a.tweetedAt.compareTo(b.tweetedAt));
  }

  bool hasTweet(List<Tweet> list,Tweet tweet){
    if(list.contains(tweet)){
      return false;
    }else{
      return true;
    }
  }

  void getDataFromLastDetail(){
    feedDetailController = Get.find(tag: nostrService.getTag());
    datas = feedDetailController.events;
    data.value = datas[event_id]!;
    root_id = data.value.getRootId();
    rootTree = datas[root_id];

    if(!data.value.getSecondId().isEmpty){
      addHeader(root_id, data.value.getSecondId());
    }

    if(rootTree != null){
      header.add(rootTree!);
    }

    List<Tweet> tempList = [];
    for (Tweet item in datas.values) {
      tempList.add(item);
    }

    List<Tweet> list = findAllRelatedItems(data.value.id, tempList);
    replays.addAll(list);

    header.value.sort((a, b) => a.tweetedAt.compareTo(b.tweetedAt));
    replays.value.sort((a, b) => a.tweetedAt.compareTo(b.tweetedAt));
  }

  void addHeader(String rootId,String lastId){
    Tweet? temp = datas[lastId];
    if(temp != null){
      if(hasTweet(header.value, temp)){
        header.add(temp);
      }
      if(temp.isSecondReply){
        addHeader(rootId, temp.getSecondId());
      }
    }
  }


  List<Tweet> findAllRelatedItems(String id, List<Tweet> list) {
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


  void requestEvents(String rootId) {
    nostrService.eventsFeedObj.requestEvents(
        eventIds: [rootId],
        requestId: requestId,
        streamController: replyStreamController
        );
  }

  void requestHeader(List<String> ids){
    nostrService.eventsFeedObj.requestEventsHeader(
        eventIds: ids,
        requestId: requestId,
        );
  }

  bool isLoadHeader = false;

  void _onHeaderReceived(Tweet tweet){
    /*if(events.containsKey(tweet.id)){
      return;
    }
    events[tweet.id] = tweet;
    if (header.any((element) => element.id == tweet.id)) {

    }else{
      header.add(tweet);
      header.value.sort((a, b) => a.tweetedAt.compareTo(b.tweetedAt));
    }*/
  }

  void onEvent(Tweet item){
    if(datas.containsKey(item.id)){
      return;
    }

    datas[item.id] = item;

    makeData();
    if (item.id == root_id) {
      if (item.isReply) {
        var new_root_id = item.getRootId();
        if (new_root_id != root_id) {
          root_id = new_root_id;
          requestId = Helpers().getRandomString(12);
          requestEvents(root_id);
          return;
        }
      }
    }

    /*if(_events.containsKey(item.id)){
      return;
    }
    _events[item.id] = item;

    if(item.id == event_id){
      data.value = item;
      List<String> ids = [];
      for (var tag in item.tags) {
        if(tag[0] == 'e'){
          ids.add(tag[1]);
        }
      }
      if(ids.length>0 && !isLoadHeader){
        requestHeader(ids);
      }
    }else{
      replays.add(item);
      //sum(replies);
      replays.value.sort((a, b) => a.tweetedAt.compareTo(b.tweetedAt));
    }*/
  }

  void sum(List<dynamic> list){
    if(list.length > 0){
      list.forEach((element) {
        Tweet obj = element;
        replays.value.add(obj);
        sum(obj.replies);
      });
    }else{
      return;
    }
  }


}
