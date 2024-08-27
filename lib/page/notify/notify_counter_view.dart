
import 'package:cached_network_image/cached_network_image.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/page/feed_detail/feed_detail_view.dart';
import 'package:freerse/page/notify/notify_counter.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/common/content/content_component.dart';
import 'package:get/get.dart';

import '../../model/Tweet.dart';
import '../../views/feed/avatar_holder.dart';
import '../../views/feed/tweetImage.dart';
import '../feed_detail_reply/feed_detail_reply_view.dart';

class NotifyCounterView extends StatelessWidget {

  static double LEFT_WIDTH = 65.w;

  NotifyCounter notifyCounter;

  NostrService nostrService = Get.find();

  String iconImage;

  String action;

  Tweet? tweet;

  NotifyCounterView({
    required this.notifyCounter,
    required this.action,
    required this.iconImage,
  });

  @override
  Widget build(BuildContext context) {
    var fontColor =  Get.isDarkMode ? Colors.white : ColorConstants.hexToColor("#5F6266");
    var fontSize = 15.sp;

    return Obx(() {
      var leftText = "";
      if (notifyCounter.amount.toDouble() > 1000000) {
        leftText = (notifyCounter.amount.toDouble() / 1000000).toStringAsFixed(1) + "m";
      } else if (notifyCounter.amount.toDouble() > 1000) {
        leftText = (notifyCounter.amount.toDouble() / 1000).toStringAsFixed(1) + "k";
      } else if (notifyCounter.amount.toDouble() > 0) {
        leftText = notifyCounter.amount.toString();
      }

      var items = notifyCounter.items;
      var itemWidth = 36.67.w;
      List<Widget> userList = [];
      var firstName = "Mario";
      for (var i = 0; i < items.length; i++) {
        if (i > 6) {
          break;
        }

        var item = items[i];
        Widget? userWidget;
        var userInfo = nostrService.userMetadataObj.getUserInfo(item.pubkey);
        if (userInfo != null) {
          if (i == 0) {
            firstName = ViewUtils.userShowName(userInfo, userId: item.pubkey);
          }

          if (userInfo["picture"] != null) {
            userWidget = CachedNetworkImage(
              imageUrl: userInfo["picture"],
              errorWidget: (context, url, error) => AvatarHolder( width: 36.67,
                height: 36.67,),
              imageBuilder: (context, imageProvider) => Container(
                width: itemWidth / 2,
                height: itemWidth / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            );
          }
        }

        userList.add(GestureDetector(
          onTap: () {
            Get.toNamed("/user", arguments: item.pubkey);
          },
          behavior: HitTestBehavior.translucent,
          child: Container(
            width: itemWidth,
            height: itemWidth,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(itemWidth / 2),
              color: ColorConstants.hexToColor("#7C8F9E"),
            ),
            margin: EdgeInsets.only(
              right: 4.w,
            ),
            child: userWidget,
          ),
        ));
      }

      var textList = [TextSpan(
        text: firstName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Get.isDarkMode ? Colors.white : ColorConstants.hexToColor("#0E1014"),
        ),
      )];
      if (items.length > 1) {
        textList.add(TextSpan(
            text: " ${"AND".tr} ${items.length - 1} ${"OTHERS".tr}",
          style: TextStyle(color: Get.isDarkMode ? Color(0xFFd1d1d1) : Color(0xFF181818),),
        ));
      }
      var actionText = " $action ${"YOUR_FREERSE".tr}";
      if (StringUtils.isBlank(notifyCounter.feedId)) {
        actionText = " $action ${"YOU".tr}";
      }
      textList.add(TextSpan(
          text: actionText,
        style: TextStyle(color: Get.isDarkMode ? Color(0xFFd1d1d1) : Color(0xFF181818),),
      ));
      var text = Text.rich(TextSpan(
          children: textList
      ), style: TextStyle(
        fontSize: fontSize,
        color: fontColor,
      ),);

      List<Widget> rightList = [
        Row(
          children: userList,
        ),
        Container(
          margin: EdgeInsets.only(
            top: 4.w,
            bottom: 4.w,
          ),
          alignment: Alignment.centerLeft,
          child: text,
        ),
      ];

      tweet = notifyCounter.tweet;
      if (tweet == null) {
        tweet = nostrService.eventsQuerier.tweets[notifyCounter.feedId];
        // tweet = nostrService.eventsQuerier.getOrFind(notifyCounter.feedId);
        if (tweet == null) {
          tweet = nostrService.eventsQuerier.getOrFind(notifyCounter.feedId, nostrService);
        }
      }

      if (tweet != null) {
        rightList.add(ContentComponent(
          content: tweet!.content,
          tags: tweet!.tags,
          fontColor: fontColor,
          fontSize: fontSize,
          showInFeed: false,
          limitMaxLines: 3,
          // showShowmore: false,
          onTap: () {
            jump(tweet);
          },
        ));
        if (tweet!.imageLinks.isNotEmpty) {
          rightList.add(Container(
            height: ScreenUtil().setHeight(3),
          ));
          rightList.add(TweetImage(
            picList: tweet!.imageLinks,
          ));
        }
      }

      var main = Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 10.w,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // color: Colors.red,
                  width: LEFT_WIDTH,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Image.asset(iconImage,
                          height: 23.w,
                        ),
                        margin: EdgeInsets.only(
                          bottom: 8.w,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          right: 4.w,
                        ),
                        child: Text(leftText, style: TextStyle(
                          fontSize: Get.theme.textTheme.bodyMedium!.fontSize,
                          color: ColorConstants.hexToColor("#FF8843"),
                        ),),
                      )
                    ],
                  ),
                ),
                Expanded(child: Container(
                  // color: Colors.blue,
                  margin: EdgeInsets.only(
                    left: 10.w,
                    right: 8.w,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: rightList,
                  ),
                ),),
              ],
            ),
          ),
          Container(height: 14.67.h,),
          Divider(height: 1,),
        ],
      );

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          jump(tweet);
        },
        child: main,
      );
    });
  }

  void jump(Tweet? tweet) {
    if (tweet != null) {
      print("tweet.isReply ${tweet.isReply}");
      if (tweet.isReply) {
        Get.to(()=>FeedDetailReplyPage(),arguments: {'id': notifyCounter.feedId,'hasHeader':false, 'data': tweet}, preventDuplicates:false);
      } else {
        Get.to(()=>FeedDetailPage(),arguments: {'hasHeader':false, 'data': tweet}, preventDuplicates:false);
      }
    }
  }

}