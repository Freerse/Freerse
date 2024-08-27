// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/page/login/LoginView/LoginView.dart';
import 'package:freerse/page/login/RegSaveKeyView/RegSaveKeyView.dart';
import 'package:freerse/page/login/SlicesView/SlicesView.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/feed/avatar_holder.dart';
import 'package:get/get.dart';

import 'RegViewController.dart';

class RegView extends StatelessWidget {
  final controller = Get.put(RegViewController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
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
            body: Obx(() => Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil().setHeight(75),
                          bottom: ScreenUtil().setHeight(22)),
                      child: Text(
                        "CHUANG_JNDZ_HU".tr,
                        style: TextStyle(
                            color: Get.isDarkMode
                                ? Color(0xFFd1d1d1)
                                : Color(0xFF181818),
                            fontSize: ScreenUtil().setSp(30)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.sendImg();
                      },
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        // textDirection: TextDirection.ltr,
                        // fit: StackFit.loose,
                        // overflow: Overflow.clip,
                        children: <Widget>[
                          CachedNetworkImage(
                            fadeInDuration: Duration(milliseconds: 0),
                            fadeInCurve: Curves.linear,
                            imageUrl: controller.picture.value,
                            placeholder: (context, url) => AvatarHolder(
                                width: Cons.REG_IMAGE_WH,
                                height: Cons.REG_IMAGE_WH,
                                defalt: 'assets/images/null_avater.png'),
                            errorWidget: (context, url, error) => AvatarHolder(
                                width: Cons.REG_IMAGE_WH,
                                height: Cons.REG_IMAGE_WH,
                                defalt: 'assets/images/null_avater.png'),
                            imageBuilder: (context, imageProvider) => Container(
                              width: ScreenUtil().setWidth(Cons.REG_IMAGE_WH),
                              height: ScreenUtil().setWidth(Cons.REG_IMAGE_WH),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Center(
                            child: Image.asset(
                              'assets/images/up_image.png',
                              width: ScreenUtil().setWidth(27),
                            ),
                          )
                        ],
                      ),
                      behavior: HitTestBehavior.translucent,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil().setHeight(30),
                          left: ScreenUtil().setWidth(13),
                          right: ScreenUtil().setWidth(13)),
                      child: Row(
                        children: [
                          Container(
                            height: ScreenUtil().setHeight(57),
                            alignment: Alignment.center,
                            child: Text(
                              "MING_ZI".tr,
                            ),
                          ),
                          Expanded(
                              child: TextField(
                            controller: controller.nameController,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal),
                            decoration: InputDecoration(
                              hintText: "TIAN_JNDM_ZI".tr,
                              hintStyle:
                                  TextStyle(color: ColorConstants.hintColor),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(40)),
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
                            Get.to(() => SlicesView(),
                                preventDuplicates: false);
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
                      padding:
                          EdgeInsets.only(top: ScreenUtil().setHeight(280)),
                      child: GestureDetector(
                        onTap: () {
                          var nickName = controller.nameController.text;
                          if (!controller.acceptSlices.value) {
                            ViewUtils.showToast(context, "QING_XTYX_YI".tr);
                            return;
                          }
                          if (nickName.isEmpty) {
                            ViewUtils.showToast(context, "MING_ZBNW_KONG".tr);
                            return;
                          }
                          // if(controller.picture.value.isEmpty){
                          //   ViewUtils.showToast(context, "请先上传头像");
                          //   return;
                          // }
                          Get.to(() => RegSaveKeyView(),
                              arguments: {
                                "nickName": nickName,
                                "picture": controller.picture.value
                              },
                              preventDuplicates: false);
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
                              "TONG_YBJ_XU".tr,
                              style: TextStyle(
                                  color: Colors.white, fontSize: Cons.tsBig),
                            ),
                          ),
                        ),
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),
                  ],
                ))));
  }
}
