import 'package:get/get.dart';

class UserListController extends GetxController {
  List<String> userIds = [];

  @override
  void onInit() {
    var arguments = Get.arguments['data'];
    if (arguments != null) {
      userIds = arguments;
    }

    super.onInit();
  }

}
