import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../config/Cons.dart';
import '../../services/nostr/nostr_service.dart';

class SearchController extends GetxController  with GetSingleTickerProviderStateMixin  {
  TextEditingController searchController = TextEditingController();


  List<String> userIds = ['769f03d2e964058793489c706951ad10a897680217b9a0cc9dce146c2b3684f3','e034d654802d7cfaa2d41a952801054114e09ad6a352b28288e23075ca919814'];


  // final List<Tab> myTabs = <Tab>[
  //   Tab(text: "BIAO_QIAN".tr, height: ScreenUtil().setHeight(40),),
  //   // Tab(text: "REN_MEN".tr),
  //   Tab(text: "QUAN_Q_T_WEN".tr, height: ScreenUtil().setHeight(40),),
  // ];
  final List<Tab> myTabs = <Tab>[
    Tab(child: Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(Cons.APPBAR_TAB_BOTTOM)),
      child: Text("BIAO_QIAN".tr),
    ), height: ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT),),
    Tab(child: Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(Cons.APPBAR_TAB_BOTTOM)),
      child: Text("QUAN_Q_T_WEN".tr),
    ), height: ScreenUtil().setHeight(Cons.APPBAR_TAB_HEIGHT),),
  ];

  late TabController controller;
  late final NostrService _nostrService = Get.find();


  @override
  void onInit() {
    controller = TabController(vsync: this, length: myTabs.length);
    controller.addListener(() {
      var preIndex = controller.previousIndex;
      var index = controller.index;
      if (preIndex == 1 && index == 0) {
        _nostrService.closeSubscription("gfeed-${_nostrService.globalFeedObj.requestId}");
      }
    });
    super.onInit();
  }
}
