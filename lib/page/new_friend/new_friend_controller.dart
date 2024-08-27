import 'package:get/get.dart';

import '../../services/nostr/nostr_service.dart';

class NewFriendController extends GetxController {
  late final NostrService nostrService = Get.find();


  void acceptFriend(String userId){
    var content = nostrService.userMessageObj.encodeContent(userId, 'Hi');
    nostrService.writeEvent(content, 4, [["p",userId]]);
  }
}
