// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/page/light_user_list/light_user_list_view.dart';
import 'package:freerse/page/user_list/user_list_view.dart';
import 'package:freerse/page/zap/zap_custom_sender_view.dart';
import 'package:freerse/services/nostr/nips/zap_service.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/common/bottom_more_dialog/bottom_more_dialog_view.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/ColorConstants.dart';
import '../../../config/utils.dart';
import '../../../model/Tweet.dart';
import '../../../page/zap/zap_setting_view.dart';
import '../../../services/nostr/nostr_service.dart';
import '../../common/content/content_component.dart';
import '../avatar_holder.dart';
import '../feed_repost_selector_view.dart';
import '../tweetImage.dart';
import 'feed_header_controller.dart';

class FeedHeaderComponent extends StatelessWidget {
  final controller = Get.put(FeedHeaderController());
  late final NostrService nostrService = Get.find();

  ZapService zapService = Get.find();

  bool showDivder;

  late final Tweet data;
  late final int commentsCount;
  FeedHeaderComponent(
      {required this.data,
      this.showDivder = true,
      required this.commentsCount});

  final LinkifyOptions linkifyOptions = LinkifyOptions(humanize: false);

  void bottomActions(int type) {
    switch (type) {
      case 0:
        Get.toNamed("/write",
            arguments: {"isArticle": false, 'replyTweet': data});
        break;
      case 1:
        nostrService.repostEvent(data);
        nostrService.feedLikeObj.feedReportsMine[data.id] = 1;
        // Get.dialog(
        //   AlertDialog(
        //     title: Text('Repost'),
        //     content: Text('Are you sure you want to repost this?'),
        //     actions: [
        //       TextButton(
        //         onPressed: () {
        //           Get.back();
        //         },
        //         child: Text('Cancel'),
        //       ),
        //       TextButton(
        //         onPressed: () {
        //           Get.back();
        //           nostrService.repostEvent(data);
        //           nostrService.feedLikeObj.feedReportsMine[data.id] = 1;
        //         },
        //         child: Text('Yes'),
        //       ),
        //     ],
        //   ),
        // );
        break;
      case 2:
        nostrService.likeEvent(data);
        nostrService.feedLikeObj.feedLikesMine[data.id] = 1;
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('推文调试===>' + data.isArticle.toString());
    return Container(
      child: Obx(
        () {
          var result = nostrService.userMetadataObj.getUserInfo(data.pubkey);
          var pic = result['picture'] ?? '';
          var name = ViewUtils.userShowName(result, userId: data.pubkey);

          var hasZap = nostrService.feedLikeObj
              .hasZaped(data.id, nostrService.myKeys.publicKey);

          var like_count = nostrService.feedLikeObj.getFeedLikeCount(data.id);
          var report_count =
              nostrService.feedLikeObj.getFeedReportCount(data.id);
          var light_count = nostrService.feedLikeObj.getFeedLightCount(data.id);
          var light_amount =
              nostrService.feedLikeObj.getFeedLightAmount(data.id);
          var isReport = nostrService.feedLikeObj.chekIsReport(data.id);
          var isLike = nostrService.feedLikeObj.chekIsFeedLike(data.id);

          var zanUserList = nostrService.feedLikeObj.getUserList(data.id, 1);
          var reportUserList = nostrService.feedLikeObj.getUserList(data.id, 2);
          var linghtUserList =
              nostrService.feedLikeObj.getLightUserList(data.id);

          bool isFollow =
              nostrService.userContactsObj.isFollowByMe(data.pubkey);
          bool isMe = false;
          if (nostrService.myKeys.publicKey == data.pubkey.toString()) {
            isMe = true;
          }

          print("data.content ---> start");
          print(data.content);
          List contentList = data.content.split("\n");
          for (var element in contentList) {
            print(element);
          }
          print("data.content ---> end");
          return Column(
            children: [
              data.isArticle
                  ? Container(
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setHeight(20),
                          left: ScreenUtil().setWidth(15),
                          right: ScreenUtil().setWidth(15)),
                      child: Text(data.title,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(22),
                              fontWeight: FontWeight.bold)),
                    )
                  : Container(),
              Container(
                child: Container(
                    width: ScreenUtil().screenWidth,
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(15),
                        right: ScreenUtil().setWidth(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            showDivder
                                ? Container(height: ScreenUtil().setHeight(15))
                                : Container(
                                    width: 1,
                                    height: ScreenUtil().setHeight(15),
                                    color: Get.isDarkMode
                                        ? Color(0xFF242424)
                                        : ColorConstants.dividerColor,
                                  ),
                            GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Get.toNamed("/user", arguments: data.pubkey);
                                },
                                child: CachedNetworkImage(
                                  imageUrl: pic,
                                  placeholder: (context, url) => AvatarHolder(),
                                  errorWidget: (context, url, error) =>
                                      AvatarHolder(),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: ScreenUtil().setWidth(50),
                                    height: ScreenUtil().setWidth(50),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        Container(
                          width: 10,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: ScreenUtil().setHeight(15)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Container(
                                  child: Text(
                                    name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                                isFollow || isMe
                                    ? Container()
                                    : GestureDetector(
                                        onTap: () {
                                          nostrService.followUser(
                                              data.pubkey.toString());
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right: ScreenUtil().setWidth(20)),
                                          height: ScreenUtil().setWidth(26),
                                          width: ScreenUtil().setWidth(45),
                                          decoration: BoxDecoration(
                                            // color: Colors.white,
                                            border: Border.all(
                                              width: 1,
                                              color: Get.isDarkMode
                                                  ? Color(0xFF242424)
                                                  : Color(0xFFe5e5e5),
                                              // color: Colors.red,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "GUAN_ZHU".tr,
                                              style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(12),
                                                color: Get.isDarkMode
                                                    ? Color(0xFFd1d1d1)
                                                    : Color(0xFF181818),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Get.bottomSheet(BottomMoreDialogComponent(
                                      data: data,
                                    ));
                                  },
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    size: 18,
                                    color: Get.isDarkMode
                                        ? Color(0xFF5e5e5e)
                                        : Color(0xFF919191),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              height: ScreenUtil().setHeight(4),
                            ),
                          ],
                        ))
                      ],
                    )),
              ),
              data.isArticle && data.coverImage != ''
                  ? Container(
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setHeight(20),
                          left: ScreenUtil().setWidth(15),
                          right: ScreenUtil().setWidth(15)),
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Image.asset(
                          'assets/images/default_header.png',
                          fit: BoxFit.cover,
                          width: ScreenUtil().setWidth(400),
                          height: ScreenUtil().setHeight(200),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/default_header.png',
                          fit: BoxFit.cover,
                          width: ScreenUtil().setWidth(400),
                          height: ScreenUtil().setHeight(200),
                        ),
                        imageUrl: data.coverImage,
                        imageBuilder: (context, imageProvider) => Container(
                          width: ScreenUtil().setWidth(400),
                          height: ScreenUtil().setHeight(200),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              data.isArticle
                  ? Container(
                      margin: EdgeInsets.only(
                          left: ScreenUtil().setWidth(20),
                          right: ScreenUtil().setWidth(20),
                          top: ScreenUtil().setHeight(20),
                          bottom: ScreenUtil().setHeight(20)),
                      child: MarkdownBody(
                        data: data.content,
                        selectable: true,
                        shrinkWrap: true,
                        onTapLink: ((text, href, title) {
                          print(text + href! + title);

                          if (href.isNotEmpty) {
                            launchUrl(Uri.parse('$href'));
                          }
                        }),
                        onTapHttpLink: (href) {
                          print("text");
                          if (href!.isNotEmpty) {
                            launchUrl(Uri.parse('$href'));
                          }
                        },
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(
                          left: ScreenUtil().setWidth(20),
                          right: ScreenUtil().setWidth(20),
                          top: ScreenUtil().setHeight(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContentComponent(
                              content: data.content, tags: data.tags),
                          // Linkify(
                          //   options:linkifyOptions,
                          //   linkifiers: [UrlLinkifier(),TweetTagLinkifier(), AtUserLinkfier(tags: data.tags)],
                          //   onOpen: (link) async {
                          //     print(link);
                          //     if(link.url.toString().startsWith('@')){
                          //       var mykey = link.url.split("_")[1];
                          //       if(link.url.split("_")[0] == '@p'){
                          //         Get.to(()=>UserPage(),arguments: mykey);
                          //       }else{
                          //         // Get.to(()=>FeedDetailPage(),arguments: mykey);
                          //         Get.to(()=>SearchListPage(),arguments: {"keyword":mykey});
                          //       }
                          //       return;
                          //     }
                          //     if(link.url.toString().startsWith('#')){
                          //       Get.to(()=>SearchListPage(),arguments: {"keyword":link.url});
                          //       return;
                          //     }
                          //     launchUrl(Uri.parse(link.url));
                          //     return;
                          //     if (await canLaunchUrl(Uri.parse(link.url))) {
                          //       await launchUrl(Uri.parse(link.url));
                          //     } else {
                          //       throw 'Could not launch $link';
                          //     }
                          //   },
                          //   text: data.content,
                          //   style: TextStyle(
                          //       color: Colors.black,
                          //       fontSize: ScreenUtil().setSp(22)
                          //   ),
                          //   linkStyle: TextStyle(color: ColorConstants.greenColor,decoration: TextDecoration.none,),
                          // ),
                          Container(
                            height: ScreenUtil().setHeight(3),
                          ),
                          Container(
                            child: TweetImage(
                              picList: data.imageLinks,
                            ),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(15),
                          ),
                        ],
                      ),
                    ),
              Container(
                margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                child: Row(
                  children: [
                    Text(
                      Utils.formatTimestampYYYY(data.tweetedAt),
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? Color(0xFF5e5e5e)
                              : Color(0xFF919191),
                          fontSize: ScreenUtil().setSp(13.3)),
                    ),
                  ],
                ),
              ),
              Container(
                height: ScreenUtil().setHeight(15),
              ),
              Divider(
                  height: 1,
                  color: Get.isDarkMode
                      ? ColorConstants.dividerColorDark2
                      : ColorConstants.dividerColor),
              Container(
                height: ScreenUtil().setHeight(50),
                margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Get.to(
                            () => UserListPage(
                                  title: "ZHUAN_FA".tr,
                                ),
                            arguments: {'data': reportUserList},
                            preventDuplicates: false);
                      },
                      child: Row(
                        children: [
                          Text(
                            report_count.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(16.7)),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(3),
                          ),
                          Text(
                            "ZHUAN_FA".tr,
                            style: TextStyle(
                              color: Get.isDarkMode
                                  ? Color(0xFF5e5e5e)
                                  : Color(0xFF919191),
                              fontSize: ScreenUtil().setSp(16.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                            () => UserListPage(
                                  title: "DIAN_ZAN".tr,
                                ),
                            arguments: {'data': zanUserList},
                            preventDuplicates: false);
                      },
                      child: Row(children: [
                        Container(
                          width: ScreenUtil().setWidth(14),
                        ),
                        Text(
                          like_count.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(16.7)),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(3),
                        ),
                        Text(
                          "DIAN_ZAN".tr,
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Color(0xFF5e5e5e)
                                  : Color(0xFF919191),
                              fontSize: ScreenUtil().setSp(16.7)),
                        ),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                            () => LightUserListPage(
                                  title: "DIAN_JI".tr,
                                ),
                            arguments: {'data': linghtUserList},
                            preventDuplicates: false);
                      },
                      child: Row(children: [
                        Container(
                          width: ScreenUtil().setWidth(14),
                        ),
                        Text(
                          light_count.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(16.7)),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(3),
                        ),
                        Text(
                          "DIAN_JI".tr,
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Color(0xFF5e5e5e)
                                  : Color(0xFF919191),
                              fontSize: ScreenUtil().setSp(16.7)),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Divider(
                  height: 1,
                  color: Get.isDarkMode
                      ? ColorConstants.dividerColorDark2
                      : ColorConstants.dividerColor),
              Container(
                height: ScreenUtil().setHeight(50),
                margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(10),
                    right: ScreenUtil().setWidth(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Row(
                        children: [
                          Image.asset("assets/images/feed_comment.png",
                              color: Get.isDarkMode
                                  ? Color(0xFF5e5e5e)
                                  : Color(0xFF919191),
                              width: ScreenUtil().setWidth(18)),
                          commentsCount == 0
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(left: 3),
                                  child: Text(
                                    commentsCount.toString(),
                                    style: TextStyle(
                                      color: Get.isDarkMode
                                          ? Color(0xFF5e5e5e)
                                          : Color(0xFF919191),
                                      fontSize: ScreenUtil().setSp(15),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      onTap: () {
                        bottomActions(0);
                      },
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Row(
                        children: [
                          Image.asset(
                            isReport
                                ? "assets/images/feed_repost_p.png"
                                : "assets/images/feed_repost.png",
                            color: isReport
                                ? null
                                : Get.isDarkMode
                                    ? Color(0xFF5e5e5e)
                                    : Color(0xFF919191),
                            width: ScreenUtil().setWidth(18),
                          ),
                          report_count == 0
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(left: 3),
                                  child: Text(
                                    report_count.toString(),
                                    style: TextStyle(
                                        color: isReport
                                            ? ColorConstants.reportColor
                                            : (Get.isDarkMode
                                                ? Color(0xFF5e5e5e)
                                                : Color(0xFF919191)),
                                        fontSize: ScreenUtil().setSp(15)),
                                  ),
                                ),
                        ],
                      ),
                      onTap: () {
                        Get.bottomSheet(FeedRepostSelectorView(
                          onRepost: () {
                            bottomActions(1);
                          },
                          eventId: data.id,
                        ));
                        // if(!isReport){
                        //   bottomActions(1);
                        // }
                      },
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Row(
                        children: [
                          Image.asset(
                            isLike
                                ? "assets/images/feed_like_p.png"
                                : "assets/images/feed_like.png",
                            color: isLike
                                ? null
                                : Get.isDarkMode
                                    ? Color(0xFF5e5e5e)
                                    : Color(0xFF919191),
                            width: ScreenUtil().setWidth(18),
                          ),
                          like_count == 0
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(left: 3),
                                  child: Text(
                                    like_count.toString(),
                                    style: TextStyle(
                                        color: isLike
                                            ? ColorConstants.likeColor
                                            : (Get.isDarkMode
                                                ? Color(0xFF5e5e5e)
                                                : Color(0xFF919191)),
                                        fontSize: ScreenUtil().setSp(15)),
                                  ),
                                ),
                        ],
                      ),
                      onTap: () {
                        if (!isLike) {
                          bottomActions(2);
                        }
                      },
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Row(
                        children: [
                          Image.asset(
                            hasZap
                                ? "assets/images/feed_zap_p.png"
                                : "assets/images/feed_zap.png",
                            color: hasZap
                                ? null
                                : Get.isDarkMode
                                    ? Color(0xFF5e5e5e)
                                    : Color(0xFF919191),
                            width: ScreenUtil().setWidth(18),
                          ),
                          // light_amount == '0'?Container():Container(padding:EdgeInsets.only(left: 3),child: Text(light_amount.toString(),style: TextStyle(color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191),fontSize: ScreenUtil().setSp(15)),))
                          light_amount == '0'
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(left: 3),
                                  child: Text(
                                    light_amount,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: hasZap
                                          ? ColorConstants.zapedColor
                                          : (Get.isDarkMode
                                              ? Color(0xFF5e5e5e)
                                              : Color(0xFF919191)),
                                      fontSize: ScreenUtil().setSp(15),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      onLongPress: () {
                        ZapCustomSenderView.show(data.pubkey, eventId: data.id);
                      },
                      onTap: () {
                        if (Platform.isIOS) {
                          if (zapService.canZap()) {
                            ZapCustomSenderView.show(data.pubkey,
                                eventId: data.id);
                          } else {
                            Get.to(() => ZapSettingView());
                          }
                        } else {
                          zapService.sendZap(data.pubkey, eventId: data.id);
                        }
                      },
                    )
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: Get.isDarkMode
                    ? ColorConstants.dividerColorDark2
                    : ColorConstants.dividerColor,
              ),
            ],
          );
        },
      ),
    );
  }
}
