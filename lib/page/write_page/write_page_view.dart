// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/model/UserItem.dart';
import 'package:freerse/page/at_user_list/at_user_list_view.dart';
import 'package:freerse/page/message_detail/message_gif_view.dart';
import 'package:freerse/page/write_page/write_image_gif_video_preview.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';

import '../../views/common/auto_hide_keyboard.dart';
import '../../views/common/markdown_text_input.dart';
import '../../views/feed/avatar_holder.dart';
import 'write_page_controller.dart';

class WritePagePage extends StatelessWidget {
  final controller = Get.put(WritePageController());
  ValueNotifier<String> imageUrl = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? Color(0xFF191919) : Colors.white,
      body: Obx(
        () => GestureDetector(
          onTap: () {
            controller.closeBootom();
          },
          behavior: HitTestBehavior.translucent,
          child: Container(
            // color: Colors.white,
            padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(20),
                        right: ScreenUtil().setWidth(20)),
                    // color: Colors.white,
                    height: ScreenUtil().setHeight(80),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Text(
                            "QU_XIAO".tr,
                            style: TextStyle(fontSize: ScreenUtil().setSp(18)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.sendMsg();
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            width: ScreenUtil().setWidth(60),
                            height: ScreenUtil().setHeight(33),
                            decoration: BoxDecoration(
                              color: ColorConstants.greenColor,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Text(
                                "FA_BU".tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(14),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(20),
                          right: ScreenUtil().setWidth(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          controller.isReply.value
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    Get.bottomSheet(BottomWriteDialog());
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Obx(() {
                                        var result = controller
                                            .nostrService.userMetadataObj
                                            .getUserInfo(controller
                                                .nostrService.myKeys.publicKey);
                                        var pic = result['picture'] ?? '';
                                        return CachedNetworkImage(
                                          imageUrl: pic,
                                          placeholder: (context, url) =>
                                              AvatarHolder(
                                            width: 37,
                                            height: 37,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              AvatarHolder(
                                            width: 37,
                                            height: 37,
                                          ),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            width: ScreenUtil().setWidth(37),
                                            height: ScreenUtil().setWidth(37),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        );
                                      }),
                                      Container(
                                          width: ScreenUtil().setWidth(120),
                                          height: ScreenUtil().setHeight(30),
                                          margin: EdgeInsets.only(
                                              left: ScreenUtil().setWidth(10)),
                                          decoration: BoxDecoration(
                                            // color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            border: Border.all(
                                              color: ColorConstants.greenColor,
                                              width: 1.0,
                                            ),
                                            shape: BoxShape.rectangle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              controller.isArticle.value
                                                  ? "BIAO_JWCWZ_NONE".tr
                                                  : "BIAO_JWTW_NONE".tr,
                                              style: TextStyle(
                                                color:
                                                    ColorConstants.greenColor,
                                                fontSize:
                                                    ScreenUtil().setSp(13),
                                              ),
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                          controller.isReply.value
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: ViewUtils.buildMarkView(
                                      context, controller.replyTweet!,
                                      type: 1)
                                  // Text(''+controller.replyTweet!.content,style: TextStyle(fontSize: ScreenUtil().setSp(13),color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191)),)
                                  ,
                                )
                              : Container(),
                          controller.isArticle.value
                              ? Column(
                                  children: [
                                    Container(
                                      height: 20,
                                    ),
                                    TextField(
                                      maxLines: 1,
                                      controller: controller.titleController,
                                      cursorColor: Color(0xFF56cb3e),
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 16),
                                        hintText: "QING_ZZLSRB_TI".tr,
                                        hintStyle: TextStyle(
                                            color: ColorConstants.hexToColor(
                                                '#a3a3a3'),
                                            fontSize: ScreenUtil().setSp(15)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Get.isDarkMode
                                                  ? ColorConstants
                                                      .dividerColorDark2
                                                  : ColorConstants
                                                      .dividerColor),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Get.isDarkMode
                                                  ? ColorConstants
                                                      .dividerColorDark2
                                                  : ColorConstants
                                                      .dividerColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Get.isDarkMode
                                                  ? ColorConstants
                                                      .dividerColorDark2
                                                  : ColorConstants
                                                      .dividerColor),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        controller.sendImgTitle();
                                      },
                                      behavior: HitTestBehavior.translucent,
                                      child: controller.images.value == ''
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(20)),
                                              height:
                                                  ScreenUtil().setHeight(180),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                border: Border.all(
                                                  color: Get.isDarkMode
                                                      ? ColorConstants
                                                          .dividerColorDark2
                                                      : ColorConstants
                                                          .dividerColor,
                                                  width: 1.0,
                                                ),
                                                shape: BoxShape.rectangle,
                                              ),
                                              child: Center(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    "assets/images/write_add.png",
                                                    width: ScreenUtil()
                                                        .setWidth(66),
                                                  ),
                                                  Container(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "TIAN_JFMTPCCW_NONE".tr,
                                                    style: TextStyle(
                                                        color: Get.isDarkMode
                                                            ? Color(0xFF5e5e5e)
                                                            : Color(0xFF919191),
                                                        fontSize: ScreenUtil()
                                                            .setSp(13)),
                                                  )
                                                ],
                                              )))
                                          : Container(
                                              margin: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(20)),
                                              height:
                                                  ScreenUtil().setHeight(180),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                border: Border.all(
                                                  color: ColorConstants
                                                      .inputLineColor,
                                                  width: 1.0,
                                                ),
                                                shape: BoxShape.rectangle,
                                              ),
                                              child: Center(
                                                child: CachedNetworkImage(
                                                  height: ScreenUtil()
                                                      .setHeight(180),
                                                  imageUrl:
                                                      controller.images.value,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                )
                              : Container(),
                          controller.isArticle.value
                              ? Container(
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(20)),
                                  child: MarkdownTextInput(
                                    (String value) => print(value),
                                    '',
                                    label: "CONG_ZLKSXZ_WEN".tr,
                                    maxLines: 10,
                                    actions: MarkdownType.values,
                                    controller:
                                        controller.textEditingController,
                                    textStyle: TextStyle(
                                        color: Get.isDarkMode
                                            ? Color(0xFFd1d1d1)
                                            : Color(0xFF181818)),
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(20)),
                                  child: AutoHideKeyBoard(
                                    child: TextField(
                                      autofocus: true,
                                      maxLines: null,
                                      controller:
                                          controller.textEditingController,
                                      focusNode: controller.focusNode,
                                      cursorColor: Color(0xFF56cb3e),
                                      decoration: InputDecoration(
                                        hintText: "SHUO_DSM_BA".tr,
                                        hintStyle: TextStyle(
                                            color: Get.isDarkMode
                                                ? Color(0xFF515151)
                                                : Color(0xFF919191)),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                      ),
                                      style: Get.theme.textTheme.bodyMedium,
                                      onChanged: (value) {
                                        print(value);
                                      },
                                    ),
                                  ),
                                ),
                          Container(
                            padding: EdgeInsets.only(
                              top: 20,
                            ),
                            child: ValueListenableBuilder(
                              valueListenable: imageUrl,
                              builder: (context, String value, child) {
                                return WriteImageGifVidioPreView(url: value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: Get.isDarkMode
                      ? ColorConstants.dividerColorDark2
                      : ColorConstants.dividerColor,
                ),
                Container(
                  // color: Colors.white,
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(20),
                      right: ScreenUtil().setWidth(20)),
                  height: ScreenUtil().setHeight(70),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                            width: ScreenUtil().setWidth(60),
                            height: ScreenUtil().setHeight(30),
                            decoration: BoxDecoration(
                              // color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: ColorConstants.greenColor,
                                width: 2.0,
                              ),
                              shape: BoxShape.rectangle,
                            ),
                            child: Center(
                              child: Text(
                                "YU_LAN".tr,
                                style: TextStyle(
                                  color: ColorConstants.greenColor,
                                  fontSize: ScreenUtil().setSp(13.3),
                                ),
                              ),
                            )),
                        onTap: () {
                          controller.goToShow();
                        },
                      ),
                      Row(
                        children: [
                          controller.isArticle.value
                              ? Container()
                              : GestureDetector(
                                  onTap: () async {
                                    var selectUser = await Get.to(
                                        () => AtUserListPage(
                                              title: "LIAN_X_REN".tr,
                                            ),
                                        arguments: {'type': 1},
                                        preventDuplicates: false);
                                    print('==');
                                    print(selectUser);
                                    if (selectUser != null) {
                                      var userItem = selectUser as UserItem;
                                      controller.addAtUser(userItem);
                                    }
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(25)),
                                    child: Image.asset(
                                      'assets/images/write_ateren.png',
                                      width: ScreenUtil().setWidth(25),
                                    ),
                                  ),
                                ),
                          controller.isArticle.value
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    print("");
                                    // controller.sendGifImg().then(
                                    //   (value) {
                                    //     if (value.isNotEmpty) {
                                    //       // imageUrl.value = value;
                                    //     }
                                    //   },
                                    // );
                                    if (controller.showGifDialog.value ==
                                        false) {
                                      controller.showGifDialog.value = true;
                                    } else {
                                      controller.showGifDialog.value = true;
                                      controller.showGifDialog.value = false;
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(25)),
                                    child: Image.asset(
                                      'assets/images/write_gif.png',
                                      width: ScreenUtil().setWidth(25),
                                    ),
                                  ),
                                ),
                          controller.isArticle.value
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    controller.sendImgVedio(true);
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(25)),
                                    child: Image.asset(
                                      'assets/images/write_vedio.png',
                                      width: ScreenUtil().setWidth(25),
                                    ),
                                  ),
                                ),
                          controller.isArticle.value
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    controller.sendImgVedio(false);
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(25)),
                                    child: Image.asset(
                                      'assets/images/write_photo.png',
                                      width: ScreenUtil().setWidth(25),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
                controller.showGifDialog.value
                    ? Column(
                        children: [
                          Divider(
                            height: 1,
                          ),
                          Container(
                            color: Get.isDarkMode
                                ? ColorConstants.bottomColorBlack
                                : ColorConstants.bottomColor,
                            height: ScreenUtil().setHeight(300),
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: loadGifWidget(),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  loadGifWidget() {
    return MessageGifView(
      controller: controller,
      onPressed: (url) {
        print("url --->$url");
      },
    );
  }
}

class BottomWriteDialog extends StatelessWidget {
  final WritePageController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        child: Container(
          color: Get.isDarkMode ? Color(0xFF191919) : Colors.white,
          height: ScreenUtil().setHeight(300),
          child: Column(
            children: [
              Container(
                height: ScreenUtil().setHeight(80),
                child: Center(
                  child: Text(
                    "XUAN_ZWZL_XING".tr,
                    style: TextStyle(fontSize: ScreenUtil().setSp(16.3)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                  _controller.isArticle.value = false;
                },
                behavior: HitTestBehavior.translucent,
                child: Row(
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(33),
                    ),
                    Image.asset(
                      'assets/images/write_normal.png',
                      width: ScreenUtil().setWidth(52),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(13)),
                      child: Text(
                        "ZHENG_C_F_BU".tr,
                        style: TextStyle(fontSize: ScreenUtil().setSp(17)),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: ScreenUtil().setHeight(20),
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                  _controller.isArticle.value = true;
                },
                behavior: HitTestBehavior.translucent,
                child: Row(
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(33),
                    ),
                    Image.asset(
                      'assets/images/write_article.png',
                      width: ScreenUtil().setWidth(52),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(13)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BIAO_ZWCW_ZHANG".tr,
                            style: TextStyle(fontSize: ScreenUtil().setSp(17)),
                          ),
                          Text(
                            "TIE_ZJTBDWZX_SHI".tr,
                            style: TextStyle(
                                color: ColorConstants.hexToColor("#AEADAD"),
                                fontSize: ScreenUtil().setSp(15)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
