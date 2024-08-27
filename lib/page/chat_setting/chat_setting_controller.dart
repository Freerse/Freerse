import 'dart:async';
import 'dart:convert';

import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:get/get.dart';

class ChatSettingController extends GetxController {
  var copy1 = false.obs;
  var copy2 = false.obs;
  var topChatFlag = false.obs;
  var blackChatFlag = false.obs;
  late String userId;
  late final NostrService nostrService = Get.find();
  final StreamController<dynamic> replyUserStreamController = StreamController<dynamic>.broadcast();
  late StreamSubscription _streamSubscription;
  var userIdList = <String>[].obs;

  @override
  void onInit() {
    userId = Get.arguments.toString();
    topChatFlag.value = nostrService.userMetadataObj.isTopFrend(userId);
    super.onInit();

    // _streamSubscription = replyUserStreamController.stream.listen((event) {
    //   onUserEvent(event);
    // });

    var index = 1;
    for (var userId in nostrService.searchFeedObj.blackUserIdList) {
      index ++;
    }

    blackChatFlag.value = nostrService.searchFeedObj.blackUserIdList.contains(userId);
    // nostrService.searchFeedObj.requestUserBlackList(pubkey: nostrService.myKeys.publicKey, streamController: replyUserStreamController);
  }



  void switchTop(){
    nostrService.userMetadataObj.setTopFend(userId, topChatFlag.value);
  }

  void switchBlack(){
    nostrService.searchFeedObj.switchBlackUser(userId: userId);
    // var newIdList = [];
    // if(nostrService.searchFeedObj.blackUserIdList.contains(userId)){
    //   nostrService.searchFeedObj.blackUserIdList.remove(userId);
    // }else{
    //   nostrService.searchFeedObj.blackUserIdList.add(userId);
    // }
    // for (var userId in nostrService.searchFeedObj.blackUserIdList) {
    //   newIdList.add(["p",userId]);
    // }
  }
}
