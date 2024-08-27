import 'package:flutter/widgets.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:get/get.dart';

class RepeaterListController extends GetxController {
  TextEditingController nameController = TextEditingController();
  late final NostrService nostrService = Get.find();

  void addReater() {
    var url = nameController.text;
    print('Url==>' + url);
    nostrService.relays.addRelay(url);
    nameController.text = "";
    Get.snackbar("TI_SHI".tr, "TIAN_J_C_GONG".tr, duration: Duration(seconds: 3),);
  }
}
