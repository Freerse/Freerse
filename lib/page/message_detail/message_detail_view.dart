// ignore_for_file: sort_child_properties_last, prefer_const_constructors, avoid_unnecessary_containers, prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/utils.dart';
import 'package:freerse/page/message_detail/message_gif_view.dart';
import 'package:freerse/services/SpUtils.dart';
import 'package:freerse/services/nostr/metadata/user_msg.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/common/auto_hide_keyboard.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/common/gallery_page/gallery_page_view.dart';
import '../../views/feed/avatar_holder.dart';
import 'message_detail_controller.dart';

class MessageDetailPage extends StatelessWidget {
  final controller = Get.put(MessageDetailController());
  late final NostrService _nostrService = Get.find();

  final Set<String> _favorites = Set(); //

  Widget buildTimeLine(UserMsg data) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
      child: Center(
        child: Text(
          Utils.handlerMsgTime(data.create),
          style: TextStyle(
              color: Get.isDarkMode ? Color(0xFF595959) : Color(0xFFa4a4a4),
              fontSize: ScreenUtil().setSp(13.3)),
        ),
      ),
    );
  }

  Widget buildContent(UserMsg data) {
    if (data.isTimeLine) {
      return buildTimeLine(data);
    }
    var result = _nostrService.userMetadataObj.getUserInfo(controller.userId);
    var result2 = _nostrService.userMetadataObj
        .getUserInfo(_nostrService.userMessageObj.myKeys.publicKey);
    var pic = result['picture'] ?? '';
    var picMy = result2['picture'] ?? '';
    if (data.sender != _nostrService.userMessageObj.myKeys.publicKey) {
      return Container(
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(20),
            bottom: ScreenUtil().setHeight(20)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed("/user", arguments: controller.userId);
              },
              child: CachedNetworkImage(
                imageUrl: pic,
                placeholder: (context, url) => AvatarHolder(
                  width: 42,
                  height: 42,
                ),
                errorWidget: (context, url, error) => AvatarHolder(
                  width: 42,
                  height: 42,
                ),
                imageBuilder: (context, imageProvider) => Container(
                  width: ScreenUtil().setWidth(42),
                  height: ScreenUtil().setWidth(42),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
              behavior: HitTestBehavior.translucent,
            ),
            Padding(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: ScreenUtil().setWidth(260)),
                child: data.isPic
                    ? GestureDetector(
                        onTap: () {
                          Get.to(GalleryPhotoViewWrapper(
                              galleryItems: [data.content]));
                        },
                        behavior: HitTestBehavior.translucent,
                        child: CachedNetworkImage(
                          imageUrl: data.content,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color:
                              Get.isDarkMode ? Color(0xFF2c2c2c) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
                        child:
                            // SelectableText.rich(
                            //   TextSpan(text: data.content),
                            //   style: TextStyle(fontSize: ScreenUtil().setSp(16.3),color: ColorConstants.hexToColor('#121212')),
                            // )

                            ViewUtils.buildCopyView(
                          data.content,
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil().setWidth(2)),
                            child: RichText(
                              text: TextSpan(
                                children: parseContentWithTextSpans(
                                  data.content,
                                  TextStyle(
                                    fontSize: ScreenUtil().setSp(16.3),
                                    color: Get.isDarkMode
                                        ? Color(0xFFd1d1d1)
                                        : Color(0xFF181818),
                                  ),
                                ),
                              ),
                            ),
                            // Text(
                            //   data.content,
                            //   style: TextStyle(
                            //     fontSize: ScreenUtil().setSp(16.3),
                            //     color: Get.isDarkMode
                            //         ? Color(0xFFd1d1d1)
                            //         : Color(0xFF181818),
                            //   ),
                            // ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(
            right: ScreenUtil().setWidth(20),
            bottom: ScreenUtil().setHeight(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: ScreenUtil().setWidth(260)),
                child: data.isPic
                    ? GestureDetector(
                        onTap: () {
                          Get.to(GalleryPhotoViewWrapper(
                            galleryItems: [data.content],
                          ));
                        },
                        behavior: HitTestBehavior.translucent,
                        child: CachedNetworkImage(
                          imageUrl: data.content,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Color(0xFF27b561)
                              : Color(0xFFa8ea7c),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
                        child:

                            // SelectableText.rich(
                            //   TextSpan(text: data.content),
                            //   style: TextStyle(fontSize: ScreenUtil().setSp(16.3),color: ColorConstants.hexToColor('#121212')),
                            // )

                            ViewUtils.buildCopyView(
                          data.content,
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil().setWidth(2)),
                            child: RichText(
                              text: TextSpan(
                                children: parseContentWithTextSpans(
                                  data.content,
                                  TextStyle(
                                    color: ColorConstants.hexToColor('#121212'),
                                    fontSize: ScreenUtil().setSp(16.3),
                                  ),
                                ),
                              ),
                            ),

                            // Text(
                            //   data.content,
                            //   style: TextStyle(
                            //     fontSize: ScreenUtil().setSp(16.3),
                            //     color: ColorConstants.hexToColor('#121212'),
                            //   ),
                            // ),
                          ),
                        ),
                      ),
              ),
            ),
            CachedNetworkImage(
              imageUrl: picMy,
              placeholder: (context, url) => AvatarHolder(
                width: 42,
                height: 42,
              ),
              errorWidget: (context, url, error) => AvatarHolder(
                width: 42,
                height: 42,
              ),
              imageBuilder: (context, imageProvider) => Container(
                width: ScreenUtil().setWidth(42),
                height: ScreenUtil().setWidth(42),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  List<TextSpan> parseContentWithTextSpans(String text, textStyle) {
    final spans = <TextSpan>[];
    final linkRegExp = RegExp(r'(\s+)|(\bhttps?:\/\/[^\s]+)');
    text.splitMapJoin(
      linkRegExp,
      onMatch: (Match match) {
        final linkText = match.group(0);
        spans.add(TextSpan(
          text: linkText,
          style: TextStyle(
            color: Get.isDarkMode ? Color(0xFF375082) : Color(0xFF576b95),
            // decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              debugPrint('Link tapped: $linkText');
              launchUrl(Uri.parse('$linkText'));
            },
        ));
        return '';
      },
      onNonMatch: (String text) {
        spans.add(
          TextSpan(
            text: text,
            style: textStyle,
          ),
        );
        return '';
      },
    );
    return spans;
  }

  Widget buildBottomItem(String title, String imgSrc, int index) {
    return GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: ScreenUtil().setWidth(64),
              height: ScreenUtil().setWidth(64),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Color(0xFF202020) : Colors.white,
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Center(
                child: Image.asset(
                  imgSrc,
                  width: ScreenUtil().setWidth(30),
                ),
              )),
          Container(
            height: ScreenUtil().setHeight(10),
          ),
          Text(title,
              style: TextStyle(
                  color: Get.isDarkMode ? Colors.white : Color(0xFF6d6d6d),
                  fontSize: ScreenUtil().setSp(14)))
        ],
      ),
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (index == 2) {
          controller.sendImg();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Obx(
        () {
          var result =
              _nostrService.userMetadataObj.getUserInfo(controller.userId);
          var name = ViewUtils.userShowName(result, userId: controller.userId);
          List<UserMsg>? datas =
              _nostrService.userMessageObj.userMessages[controller.userId];
          datas ??= [];
          datas.sort((a, b) => b.create.compareTo(a.create));
          return Scaffold(
            appBar: AppBar(
                leading: IconButton(
                  iconSize: 30,
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    Get.back();
                  },
                ),
                title: Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.more_horiz,
                        size: 20,
                        color: Get.isDarkMode
                            ? Color(0xFFd1d1d1)
                            : Color(0xFF181818)),
                    onPressed: () {
                      Get.toNamed("/chatSetting", arguments: controller.userId);
                    },
                  ),
                ]),
            // backgroundColor: ColorConstants.statuabarColor,
            body: GestureDetector(
              onTap: () {
                controller.closeBootom();
              },
              behavior: HitTestBehavior.translucent,
              child: Column(
                children: [
                  Divider(
                    height: 1,
                  ),
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      controller: controller.scrollController,
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                      itemBuilder: (context, index) {
                        // if (index == resultsData.length - 1) {
                        //   controller.jumpToBottom();
                        // }
                        // return buildContent(resultsData[index]);

                        List<UserMsg> resultsData = [];
                        if (index >= datas!.length) {
                          return null;
                        }

                        var tempMsg = datas[index];
                        var content = tempMsg.content;

                        // if(index == 0){
                        //   UserMsg timeMsg = UserMsg(id: tempMsg.id, create: tempMsg.create-1, plainContent: tempMsg.content, sig: tempMsg.sig, sender: tempMsg.sender,
                        //       receiver: tempMsg.receiver, tags: tempMsg.tags,isTimeLine: true);
                        //   resultsData.add(timeMsg);
                        // }else if(index == datas.length-1){
                        //   UserMsg timeMsg = UserMsg(id: tempMsg.id, create: tempMsg.create-1, plainContent: tempMsg.content, sig: tempMsg.sig, sender: tempMsg.sender,
                        //       receiver: tempMsg.receiver, tags: tempMsg.tags,isTimeLine: true);
                        //   resultsData.add(timeMsg);
                        // }else{
                        //   var timediff = datas[index-1].create - datas[index].create;
                        //
                        //   if(timediff >= 300){
                        //     UserMsg timeMsg = UserMsg(id: tempMsg.id, create: tempMsg.create-1, plainContent: tempMsg.content, sig: tempMsg.sig, sender: tempMsg.sender,
                        //         receiver: tempMsg.receiver, tags: tempMsg.tags,isTimeLine: true);
                        //     resultsData.add(timeMsg);
                        //   }
                        // }

                        RegExp exp = RegExp(r"(https?:\/\/[^\s]+)");
                        Iterable<RegExpMatch> matches =
                            exp.allMatches(tempMsg.content);
                        for (var match in matches) {
                          var link = match.group(0);
                          if (link!.endsWith(".jpg") ||
                              link.endsWith(".jpeg") ||
                              link.endsWith(".png") ||
                              link.endsWith(".gif")) {
                            UserMsg imgMsg = UserMsg(
                                id: tempMsg.id,
                                create: tempMsg.create - 1,
                                plainContent: link,
                                sig: tempMsg.sig,
                                sender: tempMsg.sender,
                                receiver: tempMsg.receiver,
                                tags: tempMsg.tags,
                                isPic: true);
                            resultsData.add(imgMsg);
                            content = content.replaceAll(link, "");
                          }
                        }
                        if (!content.isEmpty) {
                          resultsData.add(tempMsg);
                        }

                        if (index == 0) {
                        } else if (index == datas.length - 1) {
                        } else {
                          var timediff =
                              datas[index - 1].create - datas[index].create;
                          if (timediff >= 300) {
                            UserMsg timeMsg = UserMsg(
                                id: tempMsg.id,
                                create: tempMsg.create - 1,
                                plainContent: tempMsg.content,
                                sig: tempMsg.sig,
                                sender: tempMsg.sender,
                                receiver: tempMsg.receiver,
                                tags: tempMsg.tags,
                                isTimeLine: true);
                            resultsData.add(timeMsg);
                          }
                        }

                        if (resultsData.length > 1) {
                          List<Widget> list = [];
                          for (var um in resultsData) {
                            list.add(buildContent(um));
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: list,
                          );
                        } else {
                          return buildContent(resultsData[0]);
                        }
                      },
                      // itemCount: resultsData!.length,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(15),
                        right: ScreenUtil().setWidth(10),
                        top: ScreenUtil().setWidth(10),
                        bottom: ScreenUtil().setWidth(10)),
                    // color: Colors.blue,
                    color: Get.isDarkMode
                        ? ColorConstants.bottomColorBlack
                        : ColorConstants.bottomColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          // alignment: Alignment.centerLeft,
                          constraints: BoxConstraints(maxHeight: 160),
                          // padding: const EdgeInsets.all(5),
                          width: controller.showSendBton.value
                              ? ScreenUtil().screenWidth -
                                  ScreenUtil().setWidth(112)
                              : ScreenUtil().screenWidth -
                                  ScreenUtil().setWidth(126),
                          // height: ScreenUtil().setHeight(50),
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? Color(0xFF2c2c2c)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: AutoHideKeyBoard(
                            child: Scrollbar(
                              controller: controller.textScrollController,
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 1,
                                controller: controller.textEditingController,
                                focusNode: controller.focusNode,
                                scrollController:
                                    controller.textScrollController,
                                cursorColor: Color(0xFF56cb3e),
                                decoration: InputDecoration(
                                  // border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 0, color: Colors.transparent)),
                                  disabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 0, color: Colors.transparent)),
                                  enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 0, color: Colors.transparent)),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 0, color: Colors.transparent)),
                                  // contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                        ),
                        controller.showSendBton.value
                            ? Container(
                                width: ScreenUtil().setWidth(62),
                                height: ScreenUtil().setHeight(40), //
                                decoration: BoxDecoration(
                                  color: ColorConstants.greenColor,
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                margin: EdgeInsets.only(right: 7, left: 10),
                                child: TextButton(
                                  onPressed: () {
                                    controller.sendMessage();
                                  },
                                  child: Text(
                                    "FA_SONG".tr,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(12),
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              )
                            : Container(
                                // color: Colors.amber,
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (controller.showGifDialog.value ==
                                            false) {
                                          controller.showGif();
                                        } else {
                                          controller.hideGif();
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Image.asset(
                                          "assets/images/icon_gif.png",
                                          color: Get.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          width: ScreenUtil().setWidth(36),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.showBottom();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          right: 2,
                                        ),
                                        child: Image.asset(
                                          "assets/images/icon_add.png",
                                          color: Get.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          width: ScreenUtil().setWidth(36),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                  controller.showBottomDialog.value
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // buildBottomItem("SHAN_D_F_PIAO".tr,'assets/images/chat_light.png',0),
                                  // buildBottomItem("ZHUAN_ZHANG".tr,'assets/images/chat_transfer.png',1),
                                  buildBottomItem("ZHAO_PIAN".tr,
                                      'assets/images/chat_photo.png', 2),
                                  // buildBottomItem("SHOU_CANG".tr,'assets/images/chat_collect.png',3),
                                ],
                              ),
                            )
                          ],
                        )
                      : Container()
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  loadGifWidget() {
    return MessageGifView(controller: controller);
  }

  Future<void> loadFavorites() async {
    final favorites = SpUtil.getStringList("favorites");
    if (favorites!.isNotEmpty) {
      _favorites.addAll(favorites);
    }
  }

  Future<void> saveFavorites() async {
    await SpUtil.putStringList('favorites', _favorites.toList());
  }

  bool _isFavorite(String gifUrl) {
    return _favorites.contains(gifUrl);
  }

  void _toggleFavorite(String gifUrl) {
    if (_favorites.contains(gifUrl)) {
      _favorites.remove(gifUrl);
    } else {
      _favorites.add(gifUrl);
    }
    saveFavorites();
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, size.height / 2)
      ..lineTo(0, 0)
      ..lineTo(0, size.height)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
