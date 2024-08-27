// ignore_for_file: sort_child_properties_last, dead_code, prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_is_empty

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/model/ChartItem.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/metadata/user_msg.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/feed/avatar_holder.dart';
import 'message_controller.dart';

class MessagePage extends StatelessWidget {
  final controller = Get.put(MessageController());
  late final NostrService _nostrService = Get.find();

  SelectView(IconData icon, String text, String id) {
    return PopupMenuItem<String>(
        value: id,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(width: ScreenUtil().setWidth(10)),
            Icon(icon, color: Colors.white),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ));
  }

  Widget _buildListItem(BuildContext context, String userId, String content) {
    var result = _nostrService.userMetadataObj.getUserInfo(userId);
    var pic = result['picture'] ?? '';
    var name = ViewUtils.userShowName(result, userId: userId);

    // if(name == ''){
    //   name = Helpers().encodeBech32(userId, 'npub').substring(0,10)+'...';
    // }
    var displayContent = content;
    if (content.length >= 20) {
      displayContent = '${displayContent.substring(0, 18)}...';
    }

    return InkWell(
      onTap: () {
        Get.toNamed("/message", arguments: userId);
      },
      child: Container(
        padding: EdgeInsets.only(
            left: Cons.IMAGE_ML,
            right: ScreenUtil().setWidth(20),
            top: ScreenUtil().setHeight(10),
            bottom: ScreenUtil().setHeight(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed("/user", arguments: userId);
                  },
                  child: CachedNetworkImage(
                    imageUrl: pic,
                    placeholder: (context, url) => AvatarHolder(
                      width: Cons.IMAGE_WH_SOURCE,
                      height: Cons.IMAGE_WH_SOURCE,
                    ),
                    errorWidget: (context, url, error) => AvatarHolder(
                      width: Cons.IMAGE_WH_SOURCE,
                      height: Cons.IMAGE_WH_SOURCE,
                    ),
                    imageBuilder: (context, imageProvider) => Container(
                      width: Cons.IMAGE_WH,
                      height: Cons.IMAGE_WH,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  behavior: HitTestBehavior.translucent,
                ),
                Container(
                  width: Cons.IMAGE_MR,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          // color: ColorConstants.color1a,
                          fontSize: ScreenUtil().setSp(16)),
                    ),
                    // Text(
                    //   displayContent,
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: TextStyle(
                    //       color: Color(0xFFb2b2b2),
                    //       fontSize: ScreenUtil().setSp(13.3)),
                    // )
                    RichText(
                      text: TextSpan(
                        children: parseContentWithTextSpans(
                          displayContent,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> parseContentWithTextSpans(String text) {
    final spans = <TextSpan>[];
    final linkRegExp = RegExp(r'(\s+)|(\bhttps?:\/\/[^\s]+)');
    text.splitMapJoin(
      linkRegExp,
      onMatch: (Match match) {
        final linkText = match.group(0);
        spans.add(TextSpan(
            text: linkText,
            style: TextStyle(
              // color: Get.isDarkMode ? Color(0xFF375082) : Color(0xFF576b95),
              color: Color(0xFFb2b2b2),

              fontSize: ScreenUtil().setSp(13.3),
            ),
            recognizer: TapGestureRecognizer()
            // ..onTap = () {
            //   debugPrint('Link tapped: $linkText');
            // },
            ));
        return '';
      },
      onNonMatch: (String text) {
        spans.add(TextSpan(
          text: text,
          style: TextStyle(
            color: Color(0xFFb2b2b2),
            fontSize: ScreenUtil().setSp(13.3),
          ),
        ));
        return '';
      },
    );
    return spans;
  }

  Widget _buildListHeader(BuildContext context, String icon, String title,
      String subtitle, int index, int total) {
    return InkWell(
      onTap: () {
        if (index == 0) {
          Get.toNamed("/articlelist");
        }
        if (index == 2) {
          Get.toNamed("/newfriend");
        }
      },
      child: Container(
        padding: EdgeInsets.only(
            left: Cons.IMAGE_ML,
            right: ScreenUtil().setWidth(20),
            top: ScreenUtil().setHeight(10),
            bottom: ScreenUtil().setHeight(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                (false)
                    ? Badge(
                        smallSize: ScreenUtil().setWidth(10),
                        backgroundColor: ColorConstants.badgeColor,
                        alignment: AlignmentDirectional.topEnd,
                        child: Image.asset(
                          icon,
                          width: Cons.IMAGE_WH,
                        ),
                      )
                    : Image.asset(
                        icon,
                        width: Cons.IMAGE_WH,
                      ),
                Container(
                  width: Cons.IMAGE_MR,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConstants.hexToColor("#b2b2b2"),
                          fontSize: ScreenUtil().setSp(13.3)),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor:
            Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
        // appBar: FreeAppBar(
        //   title: Text('Freerse', style: Theme.of(context).textTheme.titleLarge!.merge(TextStyle(fontSize: 20.sp,)),),
        // ),
        appBar: AppBar(
          title: Text(
            'Freerse',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          leading: Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(4),
                  top: ScreenUtil().setHeight(3)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /* Obx(() => Text(_nostrService.relays.connectedCount.string,style: Theme.of(context).textTheme.bodyLarge)),
                      Text("/"+_nostrService.relays.relays.length.toString(),style: Theme.of(context).textTheme.labelLarge),*/
                ],
              )),
          centerTitle: true,
        ),
        // backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          elevation: 3,
          onPressed: () {
            Get.toNamed("/write", arguments: {"isArticle": false});
          },
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.add),
        ),
        body: Obx(
          () {
            int latestMessageTime = 0;
            List<ChartItem> chartItemList = [];

            String articleContent = '';
            int messageNum = _nostrService.userFeedObj.articleList.length;
            // articleContent = '['+messageNum.toString()+"TIAO".tr;
            if (_nostrService.userFeedObj.articleList.length != 0) {
              articleContent = articleContent +
                  _nostrService.userFeedObj.articleList[0].title;
              latestMessageTime =
                  _nostrService.userFeedObj.articleList[0].tweetedAt;
            }
            var publicKey = _nostrService.userMessageObj.myKeys.publicKey;
            // List<dynamic> showLists = [];

            String lastContentFriend = "H_Y_S_Q_X_X".tr;
            // int lastContentCreate = 0;
            _nostrService.userMessageObj.userMessages.forEach((key, value) {
              bool isShow = false;
              UserMsg? lastMsg;
              value.forEach((element) {
                if (element.sender == publicKey) {
                  isShow = true;
                }
                if (lastMsg == null) {
                  lastMsg = element;
                } else {
                  var time = lastMsg?.create;
                  if (element.create >= time!) {
                    lastMsg = element;
                  }
                }
              });

              if (isShow) {
                chartItemList.add(
                  ChartItem(
                    userId: key,
                    message: lastMsg?.content,
                    latestTime: lastMsg?.create,
                    topFrend: _nostrService.userMetadataObj.isTopFrend(key),
                  ),
                );
                // showLists.add({
                //   "userId":key,
                //   "data":lastMsg?.content
                // });
              } else {
                // if(value[0].create > lastContentCreate){
                //   lastContentFriend = value[0].content;
                // }
                if (value[0].create > latestMessageTime) {
                  latestMessageTime = value[0].create;
                }
              }
            });
            chartItemList.sort();

            if (chartItemList.isNotEmpty) {
              if (chartItemList[0].latestTime! > latestMessageTime) {
                latestMessageTime = chartItemList[0].latestTime!;
              }
            }
            _nostrService.lastUnReadMessgeTime = latestMessageTime;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildListHeader(
                          context,
                          "assets/images/message_article.png",
                          "WEN_ZDYX_XI".tr,
                          articleContent,
                          0,
                          messageNum),
                      ViewUtils.oneLine(marginLeft: Cons.IMAGE_LINE_ML),
                      // _buildListHeader(context, "assets/images/message_light.png", 'Freese支付', "SHOU_D_NONE".tr,1, messageNum),
                      // ViewUtils.oneLine(marginLeft: Cons.IMAGE_LINE_ML),
                      _buildListHeader(
                          context,
                          "assets/images/message_friend.png",
                          "XIN_D_P_YOU".tr,
                          lastContentFriend,
                          2,
                          messageNum),
                      ViewUtils.oneLine(marginLeft: Cons.IMAGE_LINE_ML)
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Column(
                        children: [
                          _buildListItem(context, chartItemList[index].userId,
                              chartItemList[index].message!),
                          ViewUtils.oneLine(marginLeft: Cons.IMAGE_LINE_ML)
                        ],
                      );
                    },
                    childCount: chartItemList.length,
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
