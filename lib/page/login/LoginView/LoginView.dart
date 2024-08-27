// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/page/login/SlicesView/SlicesView.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';

import 'LoginViewController.dart';

class LoginView extends StatelessWidget {
  final controller = Get.put(LoginViewController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor:
            Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
        appBar: AppBar(
          backgroundColor:
              Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
          leading: IconButton(
            color: ColorConstants.greenColor,
            iconSize: 30,
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Get.back();
            },
          ),
          centerTitle: true,
        ),
        body: Obx(
          () => Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: ScreenUtil().setHeight(75),
                    bottom: ScreenUtil().setHeight(92)),
                child: Text(
                  "DENG_LU".tr,
                  style: TextStyle(
                      color: Get.isDarkMode
                          ? Color(0xFFd1d1d1)
                          : Color(0xFF181818),
                      fontSize: ScreenUtil().setSp(30)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(13),
                    right: ScreenUtil().setWidth(13)),
                child: Row(
                  children: [
                    Container(
                      height: ScreenUtil().setHeight(57),
                      alignment: Alignment.center,
                      child: Text(
                        "SI_YUE".tr,
                      ),
                    ),
                    Expanded(
                        child: TextField(
                      controller: controller.nameController,
                      style: const TextStyle(fontWeight: FontWeight.normal),
                      decoration: InputDecoration(
                        hintText: "TIAN_XNDZHS_YUE".tr,
                        hintStyle: TextStyle(color: ColorConstants.hintColor),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.only(left: ScreenUtil().setWidth(40)),
                      ),
                    ))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(13),
                    right: ScreenUtil().setWidth(13),
                    bottom: ScreenUtil().setHeight(38)),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.acceptSlices.value =
                          !controller.acceptSlices.value;
                    },
                    child: Row(
                      children: [
                        Image.asset(
                            controller.acceptSlices.value
                                ? "assets/images/login_slices_yes.png"
                                : "assets/images/login_slices_no.png",
                            width: ScreenUtil().setWidth(21),
                            height: ScreenUtil().setWidth(21)),
                        Padding(
                          padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(3),
                          ),
                          child: Text(
                            "YI_YDBT_YI".tr,
                            style: TextStyle(
                                color: Get.isDarkMode
                                    ? Color(0xFF5e5e5e)
                                    : Color(0xFFb3b3b3),
                                fontSize: ScreenUtil().setSp(15)),
                          ),
                        ),
                      ],
                    ),
                    behavior: HitTestBehavior.translucent,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => SlicesView(), preventDuplicates: false);
                    },
                    child: Text(
                      "NONE_ZZYHXKXY_NONE".tr,
                      style: TextStyle(
                          color: ColorConstants.hexToColor('#7FB65B'),
                          fontSize: ScreenUtil().setSp(15)),
                    ),
                    behavior: HitTestBehavior.translucent,
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(310)),
                child: GestureDetector(
                  onTap: () {
                    if (!controller.acceptSlices.value) {
                      ViewUtils.showToast(context, "QING_XTYX_YI".tr);
                      return;
                    }
                    controller.importAccount();
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(197),
                    height: ScreenUtil().setHeight(52),
                    decoration: BoxDecoration(
                      color: ColorConstants.greenColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        "DENG_LU".tr,
                        style: TextStyle(
                            color: Colors.white, fontSize: Cons.tsBig),
                      ),
                    ),
                  ),
                  behavior: HitTestBehavior.translucent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
