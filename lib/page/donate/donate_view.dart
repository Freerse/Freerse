
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/page/donate/donate_controller.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';

class DonateView extends StatelessWidget {

  DonateController controller = Get.put(DonateController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            iconSize: 30,
            icon: Icon(Icons.chevron_left, color: Colors.white,),
          ),
          title: Text('DONATE'.tr, style: Get.theme.textTheme.titleLarge!.merge(TextStyle(
            color: Colors.white,
          )),),
        ),
        backgroundColor: ColorConstants.donateViewBG,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 520.h,
                margin: EdgeInsets.only(
                  left: 10.w,
                  right: 10.w,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.33.w),
                ),
                child: buildTopWidget(),
              ),
              Container(
                margin: EdgeInsets.all(10.w),
                padding: EdgeInsets.only(
                  top: 16.67.w,
                  bottom: 16.67.w,
                  left: 20.w,
                  right: 20.w,
                ),
                decoration: BoxDecoration(
                  color: ColorConstants.hexToColor("#CA7ADD"),
                  borderRadius: BorderRadius.circular(8.33.w),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildBtn(controller.donateId1.value, controller.price1.value, "DONATE1_NAME".tr),
                    buildBtn(controller.donateId2.value, controller.price2.value, "DONATE2_NAME".tr),
                    buildBtn(controller.donateId3.value, controller.price3.value, "DONATE3_NAME".tr),
                    buildBtn(controller.donateId4.value, controller.price4.value, "DONATE4_NAME".tr, hasBottom: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget buildTopWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 63.33.h,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/log_freerse.png", width: 80.h, height: 80.h,),
                Container(
                  margin: EdgeInsets.only(top: 13.67.h),
                  child: Text("Freerse", style: TextStyle(
                    color: ColorConstants.hexToColor("#79D750"),
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 120.h,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("DONATE_DES1".tr, style: TextStyle(color: Color(0xFF181818))),
                Container(
                  margin: EdgeInsets.only(
                    top: 10.h,
                  ),
                  child: Text("DONATE_DES2".tr, style: TextStyle(color: Color(0xFF181818))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBtn(String id, String price, String name, {bool hasBottom = true}) {
    if (StringUtils.isBlank(price)) {
      return Container();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        controller.buy(id);
      },
      child: Container(
        height: 60.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorConstants.hexToColor("#ECC2FB"),
            width: 1.33.w,
          ),
          borderRadius: BorderRadius.circular(8.33.w),
        ),
        margin: hasBottom ? EdgeInsets.only(bottom: 12.33.w) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(right: 30.w),
              child: Text(name, style: TextStyle(
                color: Colors.white,
                fontSize: Get.theme.textTheme.bodyMedium!.fontSize,
              ),),
            ),
            Text(price, style: TextStyle(
              color: ColorConstants.hexToColor("#F6E1FD"),
              fontSize: 13.33.sp,
            ),)
          ],
        ),
      ),
    );
  }

}