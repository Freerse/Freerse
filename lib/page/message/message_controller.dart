import 'package:get/get.dart';

import '../../services/nostr/nostr_service.dart';
import '../../views/common/bottom_write_dialog/bottom_write_dialog_view.dart';

class MessageController extends GetxController {
  late final NostrService nostrService = Get.find();

  @override
  void onInit() {
    initUserMsg(6000);
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> initUserMsg(int seconds) async {
    await Future.delayed(Duration(milliseconds: seconds));
    nostrService.userMessageObj.requestUserFeed(users: [nostrService.myKeys.publicKey]);
  }

}
