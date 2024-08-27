
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:freerse/views/common/content/content_component.dart';
import 'package:freerse/views/feed/article_view.dart';
import 'package:get/get.dart';

import '../../../config/utils.dart';
import '../../../helpers/helpers.dart';
import '../../../model/Tweet.dart';
import '../../../page/feed_detail/feed_detail_view.dart';
import '../../../page/feed_detail_reply/feed_detail_reply_view.dart';
import '../../../services/nostr/nostr_service.dart';
import '../../feed/feed_article_view.dart';
import '../../feed/tweetImage.dart';
import '../ViewUtils.dart';
import '../bottom_more_dialog/bottom_more_dialog_view.dart';

class MentionedEventView extends StatelessWidget {

  // static final double imageHeight = 50;

  late final NostrService _nostrService = Get.find();

  String eventId;

  MentionedEventView({required this.eventId});

  @override
  Widget build(BuildContext context) {
    double imageHeight = 26;

    return Obx(() {
      var tweet = _nostrService.eventsQuerier.getOrFind(eventId, _nostrService);
      Widget? main;

      if (tweet != null) {
        if (tweet.isArticle) {
          // return ArticleComponent(showComments: false, data: tweet,);
          return FeedArticleView(data: tweet,);
        }

        var pubkey = tweet.pubkey;
        var userInfo = _nostrService.userMetadataObj.getUserInfo(pubkey);
        var name = ViewUtils.userShowName(userInfo, userId: pubkey);
        var pic = userInfo['picture'] ?? "";

        var picWidget = Container(
          margin: EdgeInsets.only(right: 6),
          width: imageHeight,
          height: imageHeight,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(imageHeight / 2,)),
          child: CachedNetworkImage(
            placeholder: (context, url) =>
                Image.asset(
                  'assets/images/default_avatar.png',
                  fit: BoxFit.cover,
                  width: ScreenUtil().setWidth(imageHeight),
                  height: ScreenUtil().setHeight(imageHeight),
                ),
            errorWidget: (context, url, error) =>
                Image.asset(
                  'assets/images/default_avatar.png',
                  fit: BoxFit.cover,
                  width: ScreenUtil().setWidth(imageHeight),
                  height: ScreenUtil().setHeight(imageHeight),
                ),
            imageUrl: pic,
            imageBuilder: (context, imageProvider) =>
                Container(
                  width: ScreenUtil().setWidth(imageHeight),
                  height: ScreenUtil().setHeight(imageHeight),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
          ),
        );

        List<Widget> list = [
          Container(
            margin: EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Get.toNamed("/user", arguments: pubkey, preventDuplicates: false);
                  },
                  child: picWidget,
                ),
                Expanded(child: Row(
                  children: [
                    Flexible(child: Container(
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(5)),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Get.toNamed("/user", arguments: pubkey, preventDuplicates: false);
                        },
                        child: Text(
                          name,
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )),
                    Text(
                      Utils.getTimeDiffForString(tweet.tweetedAt),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                )),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Get.bottomSheet(
                        BottomMoreDialogComponent(data: tweet,));
                  },
                  child: Container(
                    child: Icon(Icons.more_horiz_rounded, size: 18, color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191),),
                    margin: EdgeInsets.only(left: 10),
                  ),
                ),
              ],
            ),
          ),
          ContentComponent(
            content: tweet.content,
            tags: tweet.tags,
            showInFeed: false,
            onTap: () {
              jumpToTweet(tweet);
            },
          ),
        ];

        if (tweet.imageLinks.isNotEmpty) {
          list.add(Container(
            height: ScreenUtil().setHeight(3),
          ));
          list.add(TweetImage(
            picList: tweet.imageLinks,
          ));
        }

        main = Column(
          mainAxisSize: MainAxisSize.min,
          children: list,
        );
      } else {
        main = Text("Loading");
      }

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (tweet != null) {
            jumpToTweet(tweet);
          }
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 6, bottom: 6),
          decoration: BoxDecoration(
              border: Border.all(color: Get.theme.dividerColor, width: 0.5),
              borderRadius: BorderRadius.circular(8)
          ),
          child: main,
        ),
      );
    });
  }

  void jumpToTweet(Tweet tweet) {
    if (tweet.isReply) {
      Get.to(()=>FeedDetailReplyPage(),
          arguments: {'id':tweet.id,'hasHeader':false,'data':tweet},
          preventDuplicates:false);
    } else {
      Get.to(()=>FeedDetailPage(),
          arguments: {"data":tweet},
          preventDuplicates:false);
    }
  }

}