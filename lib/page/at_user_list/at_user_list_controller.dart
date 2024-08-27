import 'package:flutter/widgets.dart';
import 'package:freerse/model/UserItem.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';

class AtUserListController extends GetxController {
  List<UserItem> userList = [];
  var showUserList = <UserItem>[].obs;
  late final NostrService _nostrService = Get.find();
  var isMyFollowUser = false.obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    var type = Get.arguments['type'];
    if(type == 1){
      loadMyFollow();
    }
    super.onInit();
  }

  void filterUsers() async{
    showUserList.clear();
    for (var f in userList) {
      var searchText = searchController.text;
      if(searchText.isNotEmpty){
        if(f.name.contains(searchText) || f.name.toLowerCase().contains(searchText.toLowerCase())){
          showUserList.add(f);
        }
      }else{
        showUserList.add(f);
      }
    }
  }

  void loadMyFollow() async{
    var following = await _nostrService.getUserContacts(_nostrService.myKeys.publicKey);
    // extract public keys
    for (var f in following) {
      // userIds.add(f[1]);
      var userId = f[1];
      var result = _nostrService.userMetadataObj.getUserInfo(userId);
      var pic = result['picture']??'';
      var name = ViewUtils.userShowName(result, userId: userId);
      var about = result['about']??'';
      userList.add(UserItem(userId: userId, avater: pic, name: name, about: about));
    }
    filterUsers();
  }

}
