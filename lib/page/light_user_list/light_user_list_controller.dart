import 'package:freerse/model/LinghtItem.dart';
import 'package:get/get.dart';

class LightUserListController extends GetxController {
  List<LinghtItem> lightList = [];

  @override
  void onInit() {
    lightList = Get.arguments['data'];
    lightList.sort(((a, b) => (b.amount?.toDouble() ?? 0).compareTo(a.amount?.toDouble() ?? 0)));
    super.onInit();
  }

}
