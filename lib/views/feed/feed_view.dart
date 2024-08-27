// ignore_for_file: prefer_const_constructors, unused_local_variable, non_constant_identifier_names

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/config/utils.dart';
import 'package:freerse/page/feed_detail/feed_detail_view.dart';
import 'package:freerse/page/feed_detail_reply/feed_detail_reply_controller.dart';
import 'package:freerse/page/feed_detail_reply/feed_detail_reply_view.dart';
import 'package:freerse/page/zap/zap_custom_sender_view.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/feed/feed_article_view.dart';
import 'package:freerse/views/feed/feed_repost_selector_view.dart';
import 'package:freerse/views/feed/tweetImage.dart';
import 'package:get/get.dart';
import 'package:linkify/linkify.dart';

import '../../helpers/helpers.dart';
import '../../model/Tweet.dart';
import '../../page/zap/zap_setting_view.dart';
import '../../services/nostr/nips/zap_service.dart';
import '../../services/nostr/nostr_service.dart';
import '../common/bottom_more_dialog/bottom_more_dialog_view.dart';
import '../common/content/content_component.dart';
import 'avatar_holder.dart';

class FeedComponent extends StatelessWidget {
  NostrService nostrService = Get.find();

  ZapService zapService = Get.find();

  late final Tweet repostData;
  late final Tweet data;
  bool isRepost;
  bool showComments;
  bool showDivder;
  bool showDivderTop;

  Map<String, Tweet>? events;
  FeedComponent(
      {required this.showComments,
      this.showDivder = true,
      this.showDivderTop = true,
      this.isRepost = false,
      Tweet? data,
      this.events}) {
    if (data != null) {
      if (data.isRepost) {
        this.isRepost = true;
        this.repostData = data;
        this.data = data.parentTweet!;
      } else {
        this.isRepost = false;
        this.data = data;
      }
    } else {}
  }

  final LinkifyOptions linkifyOptions = LinkifyOptions(humanize: false);
  late final NostrService _nostrService = Get.find();
  late final FeedDetailReplyController feedDetailReplyController = Get.find();

  void bottomActions(int type) {
    switch (type) {
      case 0:
        Get.toNamed("/write",
            arguments: {"isArticle": false, 'replyTweet': data});
        break;
      case 1:
        _nostrService.repostEvent(data);
        _nostrService.feedLikeObj.feedReportsMine[data.id] = 1;
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
        //           _nostrService.repostEvent(data);
        //           _nostrService.feedLikeObj.feedReportsMine[data.id] = 1;
        //         },
        //         child: Text('Yes'),
        //       ),
        //     ],
        //   ),
        // );
        break;
      case 2:
        _nostrService.likeEvent(data);
        _nostrService.feedLikeObj.feedLikesMine[data.id] = 1;
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    /*  if(data.isRepost){
      repostData = data;
      data = data.parentTweet!;
    }*/
    List<String> pubkey = [];
    data.tags.forEach((element) {
      if (element[0] == 'p') {
        pubkey.add(element[1]);
      }
    });

    Widget mainWidget = Container(
      // color: Get.isDarkMode ? ColorConstants.setPageBg : Colors.white,
      // width: ScreenUtil().screenWidth,
      width: double.infinity,
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(15), right: ScreenUtil().setWidth(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: ScreenUtil().setHeight(15)),
              // showDivderTop?Container(height:ScreenUtil().setHeight(15)): Container(width: 1,height:ScreenUtil().setHeight(15),color: ColorConstants.dividerColor,),
              Obx(() {
                var result =
                    _nostrService.userMetadataObj.getUserInfo(data.pubkey);
                var pic = result['picture'] ?? '';
                return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Get.toNamed("/user",
                          arguments: data.pubkey, preventDuplicates: false);
                    },
                    child: CachedNetworkImage(
                      imageUrl: pic,
                      placeholder: (context, url) => AvatarHolder(
                        width: 50,
                        height: 50,
                      ),
                      errorWidget: (context, url, error) => AvatarHolder(
                        width: 50,
                        height: 50,
                      ),
                      imageBuilder: (context, imageProvider) => Container(
                        width: ScreenUtil().setWidth(50),
                        height: ScreenUtil().setWidth(50),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                    ));
              }),
              // showDivder?Container():Expanded(child: Container(width: 1,color: ColorConstants.dividerColor,))
              Container(),
            ],
          ),
          Container(
            width: 10,
          ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: ScreenUtil().setHeight(15),
              ),
              Obx(() {
                var result =
                    _nostrService.userMetadataObj.getUserInfo(data.pubkey);
                var name = ViewUtils.userShowName(result, userId: data.pubkey);
                bool isFollow =
                    nostrService.userContactsObj.isFollowByMe(data.pubkey);

                return Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                              child: Container(
                            margin: EdgeInsets.only(right: 5.w),
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          )),
                          Text(
                            Utils.getTimeDiffForString(data.tweetedAt),
                            style: TextStyle(
                              color: Get.isDarkMode
                                  ? Color(0xFF5e5e5e)
                                  : Color(0xFF919191),
                              fontSize: ScreenUtil().setSp(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Get.bottomSheet(BottomMoreDialogComponent(
                          data: data,
                        ));
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          size: 18,
                          color: Get.isDarkMode
                              ? Color(0xFF5e5e5e)
                              : Color(0xFF919191),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              Container(
                height: ScreenUtil().setHeight(4),
              ),
              data.isArticle
                  ? FeedArticleView(data: data)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        data.isReply && pubkey.length > 0
                            ? Padding(
                                padding: EdgeInsets.only(
                                    bottom: ScreenUtil().setHeight(2)),
                                child: Row(
                                  children: [
                                    Text("HUI_FU".tr,
                                        style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.fontSize,
                                          color: Get.isDarkMode
                                              ? Color(0xFF5e5e5e)
                                              : Color(0xFF919191),
                                        )),
                                    Obx(() {
                                      var result = _nostrService.userMetadataObj
                                          .getUserInfo(
                                              pubkey[pubkey.length - 1]);
                                      var name = ViewUtils.userShowName(result,
                                          userId: pubkey[pubkey.length - 1]);
                                      return Flexible(
                                        child: Text(" @" + name,
                                            style: TextStyle(
                                              color: ColorConstants.greenColor,
                                              fontSize: ScreenUtil().setSp(14),
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                      );
                                    })
                                  ],
                                ),
                              )
                            : Container(),
                        ContentComponent(
                          content: data.content,
                          tags: data.tags,
                          onTap: onFeedTap,
                        ),
                        // Container(
                        //   child: SelectableText(data.content),
                        // ),
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
                        //     if (await canLaunchUrl(Uri.parse(link.url.toString()))) {
                        //       await launchUrl(Uri.parse(link.url.toString()));
                        //     } else {
                        //       throw 'Could not launch $link';
                        //     }
                        //   },
                        //   text: data.content,
                        //   style: Theme.of(context).textTheme.bodyMedium,
                        //   linkStyle: TextStyle(color: ColorConstants.greenColor,decoration: TextDecoration.none,),
                        // ),
                        Container(
                          height: ScreenUtil().setHeight(3),
                        ),
                        TweetImage(
                          picList: data.imageLinks,
                        ),
                      ],
                    ),
              Container(
                height: ScreenUtil().setHeight(10),
              ),
              Obx(() {
                var hasZap = nostrService.feedLikeObj
                    .hasZaped(data.id, nostrService.myKeys.publicKey);
                var like_count =
                    _nostrService.feedLikeObj.getFeedLikeCount(data.id);
                var report_count =
                    _nostrService.feedLikeObj.getFeedReportCount(data.id);
                var light_amount =
                    _nostrService.feedLikeObj.getFeedLightAmount(data.id);
                var isReport = _nostrService.feedLikeObj.chekIsReport(data.id);
                var isLike = _nostrService.feedLikeObj.chekIsFeedLike(data.id);
                var linghtUserList =
                    _nostrService.feedLikeObj.getLightUserList(data.id);
                return Padding(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          // color: ColorConstants.testColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setHeight(20),
                              vertical: ScreenUtil().setWidth(20)),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/feed_comment.png",
                                width: ScreenUtil().setWidth(18),
                              ),
                              showComments
                                  ? data.commentsCount == 0
                                      ? Container()
                                      : Container(
                                          padding: EdgeInsets.only(left: 3),
                                          child: Text(
                                            data.commentsCount.toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Get.isDarkMode
                                                  ? Color(0xFF5e5e5e)
                                                  : Color(0xFF919191),
                                              fontSize: ScreenUtil().setSp(15),
                                            ),
                                          ),
                                        )
                                  : Container(),
                            ],
                          ),
                        ),
                        onTap: () {
                          bottomActions(0);
                        },
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setHeight(20),
                              vertical: ScreenUtil().setWidth(10)),
                          child: Row(
                            children: [
                              Image.asset(
                                isReport
                                    ? "assets/images/feed_repost_p.png"
                                    : "assets/images/feed_repost.png",
                                width: ScreenUtil().setWidth(18),
                              ),
                              report_count == 0
                                  ? Container()
                                  : Container(
                                      padding: EdgeInsets.only(left: 3),
                                      child: Text(
                                        report_count.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isReport
                                              ? ColorConstants.reportColor
                                              : Get.isDarkMode
                                                  ? Color(0xFF5e5e5e)
                                                  : Color(0xFF919191),
                                          fontSize: ScreenUtil().setSp(15),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                        onTap: () {
                          Get.bottomSheet(FeedRepostSelectorView(
                            onRepost: () {
                              print("bottomActions(1)");
                              bottomActions(1);
                            },
                            eventId: data.id,
                          ));
                        },
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setHeight(20),
                              vertical: ScreenUtil().setWidth(10)),
                          child: Row(children: [
                            Image.asset(
                              isLike
                                  ? "assets/images/feed_like_p.png"
                                  : "assets/images/feed_like.png",
                              width: ScreenUtil().setWidth(18),
                            ),
                            like_count == 0
                                ? Container()
                                : Container(
                                    padding: EdgeInsets.only(left: 3),
                                    child: Text(
                                      like_count.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: isLike
                                              ? ColorConstants.likeColor
                                              : Get.isDarkMode
                                                  ? Color(0xFF5e5e5e)
                                                  : Color(0xFF919191),
                                          fontSize: ScreenUtil().setSp(15)),
                                    ))
                          ]),
                        ),
                        onTap: () {
                          if (!isLike) {
                            bottomActions(2);
                          }
                        },
                      ),
                      GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setHeight(20),
                                vertical: ScreenUtil().setWidth(10)),
                            child: Row(
                              children: [
                                Image.asset(
                                  hasZap
                                      ? "assets/images/feed_zap_p.png"
                                      : "assets/images/feed_zap.png",
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
                                                  : Get.isDarkMode
                                                      ? Color(0xFF5e5e5e)
                                                      : Color(0xFF919191),
                                              fontSize: ScreenUtil().setSp(15)),
                                        ),
                                      )
                              ],
                            ),
                          ),
                          onLongPress: () {
                            ZapCustomSenderView.show(data.pubkey,
                                eventId: data.id);
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
                          }
                          // onTap: (){
                          //   // Get.to(() => WebviewView(title: "Connect to Alby",), arguments: "https://getalby.com/oauth?client_id=X4IZDc2Yt4&response_type=code&redirect_uri=https://nostrmo.com/thirdparty/getalby/callback&scope=balance:read%20payments:send");
                          //   // print(data.id);
                          //   // // bottomActions(3);
                          //   Get.to(()=>LightUserListPage(title: "DIAN_JI".tr,),arguments: {'data':linghtUserList},preventDuplicates:false);
                          // },
                          )
                    ],
                  ),
                );
              }),
              Container(
                height: ScreenUtil().setHeight(6),
              ),
            ],
          )),
        ],
      ),
    );

    if (showDivderTop || !showDivder) {
      // IntrinsicHeight 会导致 content 中的 WidgetSpan 报错，改成这种方式实现时间线
      mainWidget = Stack(children: [
        Positioned(
          child: showDivderTop
              ? Container()
              : Container(
                  width: 1,
                  color: Get.isDarkMode
                      ? Color(0xFF242424)
                      : ColorConstants.dividerColor,
                ),
          top: 0,
          bottom: ScreenUtil().setWidth(15),
          left: ScreenUtil().setWidth(39.5),
        ),
        Positioned(
          child: showDivder
              ? Container()
              : Container(
                  width: 1,
                  color: Get.isDarkMode
                      ? Color(0xFF242424)
                      : ColorConstants.dividerColor,
                ),
          top: ScreenUtil().setWidth(15),
          bottom: 0,
          left: ScreenUtil().setWidth(39.5),
        ),
        mainWidget,
      ]);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isRepost
            ? Container(
                padding: EdgeInsets.only(
                    top: ScreenUtil().setHeight(15),
                    left: ScreenUtil().setWidth(20)),
                child: Obx(() {
                  var result = _nostrService.userMetadataObj
                      .getUserInfo(repostData.pubkey);
                  var name =
                      ViewUtils.userShowName(result, userId: repostData.pubkey);
                  if (name == '') {
                    name = Helpers()
                            .encodeBech32(repostData.pubkey, 'npub')
                            .substring(0, 10) +
                        '...';
                  }
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed("/user",
                          arguments: repostData.pubkey,
                          preventDuplicates: false);
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Row(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(30),
                        ),
                        Image.asset(
                          "assets/images/feed_repost.png",
                          width: ScreenUtil().setWidth(18),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(10),
                        ),
                        Flexible(
                            child: Text(
                          name,
                          style: TextStyle(
                              color: ColorConstants.hexToColor('#6E6D6D'),
                              fontSize: ScreenUtil().setSp(16),
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        )),
                        Container(
                          width: ScreenUtil().setWidth(7),
                        ),
                        Text(
                          "YI_Z_FA".tr,
                          style: TextStyle(
                              color: ColorConstants.hexToColor('#6E6D6D'),
                              fontSize: ScreenUtil().setSp(14),
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(10),
                        ),
                      ],
                    ),
                  );
                }),
              )
            : Container(),
        InkWell(
          onTap: onFeedTap,
          child: mainWidget,
        ),
        showDivder
            ? Divider(
                height: 1,
              )
            : Container()
      ],
    );
  }

  void onFeedTap() {
    if (Get.currentRoute.contains("ArticleListPage")) {
      return;
    }

    if (data.isReply) {
      if (Get.currentRoute.contains("FeedDetailPage") ||
          Get.currentRoute.contains("FeedDetailReplyPage")) {
        if (events != null) {
          // Get.to(()=>FeedDetailReplyPage(),arguments: {'id':data.id,'hasHeader':true,'data':data,'datas':events},preventDuplicates:false);
          Get.to(() => FeedDetailReplyPage(),
              arguments: {
                'id': data.id,
                'hasHeader': false,
                'data': data,
                'datas': events
              },
              preventDuplicates: false);
        } else {
          // Get.to(()=>FeedDetailReplyPage(),arguments: {'id':data.id,'hasHeader':true,'data':data},preventDuplicates:false);
          Get.to(() => FeedDetailReplyPage(),
              arguments: {'id': data.id, 'hasHeader': false, 'data': data},
              preventDuplicates: false);
        }
      } else {
        Get.to(() => FeedDetailReplyPage(),
            arguments: {'id': data.id, 'hasHeader': false, 'data': data},
            preventDuplicates: false);
      }
    } else {
      Get.to(() => FeedDetailPage(), arguments: {"data": data});
      //Get.toNamed("/feed", arguments: {"data":data});
    }
  }
}
