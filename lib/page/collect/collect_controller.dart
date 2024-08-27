import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';

class CollectController extends GetxController  with GetSingleTickerProviderStateMixin {

  @override
  void onInit() {
    ViewUtils.changeStateColor();
  }
}
