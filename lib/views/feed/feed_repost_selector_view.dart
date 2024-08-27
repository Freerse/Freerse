
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';

class FeedRepostSelectorView extends StatelessWidget {

  Function onRepost;

  String eventId;

  FeedRepostSelectorView({
    required this.onRepost,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    
    list.add(buildBtn(Get.isDarkMode ? "assets/images/repost_dark.png" : "assets/images/repost.png", "ZHUAN_FA".tr, repost));
    list.add(buildBtn(Get.isDarkMode ? "assets/images/quote_dark.png" : "assets/images/quote.png", "QUOTE".tr, quote));

    list.add(GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Get.back();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 38.h),
        height: 50.h,
        width: double.maxFinite,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Get.isDarkMode ? Color(0xFF242424) : Get.theme.dividerColor),
          borderRadius: BorderRadius.circular(25.h)
        ),
        child: Text("QU_XIAO".tr),
      ),
    ));

    return Container(
      padding: EdgeInsets.only(
        top: 30.h,
        left: 38.67.h,
        right: 38.67.h,
      ),
      decoration: BoxDecoration(
          color: Get.isDarkMode ? ColorConstants.dialogBg : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(33.33),
            topRight: Radius.circular(33.33),
          )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );
  }

  Widget buildBtn(String imagePath, String name, Function onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 26.33.h),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: [
            Image.asset(imagePath, width: 38.h,),
            Container(
              margin: EdgeInsets.only(left: 15.h),
              child: Text(name),
            ),
          ],
        ),
        onTap: () {
          onTap();
        },
      ),
    );
  }

  void repost() {
    Get.back();
    this.onRepost();
  }

  Future<void> quote() async {
    Get.back();
    Get.toNamed("/write", arguments: {"isArticle":false, "eventId": this.eventId,});
  }
}