import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:status_bar_control/status_bar_control.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import 'home_controller.dart';

class HomePage extends StatelessWidget {
  final _homeController = Get.put(HomeController());
  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Get.snackbar("TI_SHI".tr, "OUT_APP_TIP".tr);
      // ScaffoldMessenger.of(Get.context!!).showSnackBar(SnackBar(content: Text("OUT_APP_TIP".tr),),);
      return false;
    }
    SystemNavigator.pop(); //
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          // color: Colors.red,
          color: Get.isDarkMode ? ColorConstants.bottomColorBlack : ColorConstants.bottomColor,
          elevation: 0,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _bottomAppBarItem(icon: "assets/images/tab_message.png",iconP: "assets/images/tab_message_p.png", page: 0,title: "XIAO_XI".tr,context: context, totalMsg: _homeController.unreadMsgTotal),flex: 1,),
                  Expanded(child: _bottomAppBarItem(icon: "assets/images/tab_search.png",iconP: "assets/images/tab_search_p.png", page: 1,title: "FA_XIAN".tr,context: context),flex: 1,),
                  Expanded(child: _bottomAppBarItem(icon: "assets/images/tab_feed.png",iconP: "assets/images/tab_feed_p.png", page: 2,title: "Freerse",context: context),flex: 1,),
                  Expanded(child: _bottomAppBarItem(icon: "assets/images/tab_notify.png",iconP: "assets/images/tab_notify_p.png", page: 3,title: "TONG_ZHI".tr,context: context),flex: 1,),
                  Expanded(child:  _bottomAppBarItem(icon: "assets/images/tab_mine.png",iconP: "assets/images/tab_mine_p.png", page: 4,title: "WO".tr,context: context),flex: 1,),
                ],
              ),
              )),
        ),
        body: PageView(
          controller: _homeController.pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ..._homeController.pages
          ],
        )
        )
    );
  }

  Widget _bottomAppBarItem({icon,iconP, page,title,context, totalMsg}) {
    return ZoomTapAnimation(
      onTap: () => _homeController.goToTab(page),
      child:
        Container(
          height: ScreenUtil().setHeight(50.2),
          child: Column(
            children: [
              (totalMsg != null && totalMsg.value)?
              Badge(
                smallSize: ScreenUtil().setWidth(7),
                backgroundColor: ColorConstants.badgeColor,
                alignment: AlignmentDirectional.topEnd,
                child: Image.asset(
                  _homeController.currentPage == page?iconP:icon,
                  color: _homeController.currentPage == page ? null : (Get.isDarkMode ? ColorConstants.bottomTextColorBlack : null),
                  width: ScreenUtil().setWidth(28),),
              ) : Image.asset(
                _homeController.currentPage == page?iconP:icon,
                color: _homeController.currentPage == page ? null : (Get.isDarkMode ? ColorConstants.bottomTextColorBlack : null),
                width: ScreenUtil().setWidth(28),
              ),
              Text(title,
                style: TextStyle(color:_homeController.currentPage == page?Theme.of(context).colorScheme.secondary:Get.isDarkMode ? ColorConstants.bottomTextColorBlack : Colors.black,fontSize: ScreenUtil().setSp(10)),)
            ],
          ),
        )
    );
  }

}
