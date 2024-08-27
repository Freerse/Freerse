
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/config/utils.dart';
import 'package:freerse/model/EventModel.dart';
import 'package:freerse/nostr/event.dart';
import 'package:freerse/nostr/events/userevent.dart';
import 'package:freerse/nostr/nips/nip_019.dart';
import 'package:freerse/page/feed_detail/feed_detail_view.dart';
import 'package:freerse/page/feed_detail_reply/feed_detail_reply_controller.dart';
import 'package:freerse/page/feed_detail_reply/feed_detail_reply_view.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/feed/tweetImage.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linkify/linkify.dart';

import '../../helpers/TweetLinkifier.dart';
import '../../helpers/helpers.dart';
import '../../model/Tweet.dart';
import '../../model/post_reply_event.dart';
import '../../services/nostr/nostr_service.dart';
import 'avatar_holder.dart';
import 'feed_controller.dart';
import 'nine_grid_view.dart';

class ArticleComponent extends StatelessWidget {
  late final Tweet repostData;
  late final Tweet data;
  bool isRepost;
  bool showComments;
  bool showDivder;
  bool showDivderTop;

  Map<String,Tweet>? events;
  ArticleComponent({required this.showComments, this.showDivder = true, this.showDivderTop = true,this.isRepost = false, Tweet? data, this.events}) {
    if (data != null) {
      if(data.isRepost){
        this.isRepost = true;
        this.repostData = data;
        this.data = data.parentTweet!;
      }else{
        this.isRepost = false;
        this.data = data;
      }
    } else {
    }
  }

  final LinkifyOptions linkifyOptions = LinkifyOptions(humanize: false);
  late final NostrService _nostrService = Get.find();
  late final FeedDetailReplyController feedDetailReplyController = Get.find();

  void bottomActions(int type){
    switch(type){
      case 0:
        Get.toNamed("/write", arguments: {"isArticle":false,'replyTweet':data});
        break;
      case 1:
        Get.dialog(
          AlertDialog(
            title: Text('Repost'),
            content: Text('Are you sure you want to repost this?'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  _nostrService.repostEvent(data);
                  _nostrService.feedLikeObj.feedReportsMine[data.id] = 1;
                },
                child: Text('Yes'),
              ),
            ],
          ),
        );
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
      if(element[0] == 'p'){
        pubkey.add(element[1]);
      }
    });
    return
    Container(
      // color: Get.isDarkMode ? ColorConstants.dialogBg : Colors.white,
    child:
    Column(
      children: [
        InkWell(
          onTap: (){
            if(data.isReply){
              if(Get.currentRoute.contains("FeedDetailPage") || Get.currentRoute.contains("FeedDetailReplyPage")){
                if(events != null){
                  Get.to(()=>FeedDetailReplyPage(),arguments: {'id':data.id,'hasHeader':true,'data':data,'datas':events},preventDuplicates:false);
                }else{
                  Get.to(()=>FeedDetailReplyPage(),arguments: {'id':data.id,'hasHeader':true,'data':data},preventDuplicates:false);
                }
              }else{
                Get.to(()=>FeedDetailReplyPage(),arguments: {'id':data.id,'hasHeader':false,'data':data},preventDuplicates:false);
              }
            }else{
              Get.to(()=>FeedDetailPage(),arguments: {"data":data});
              //Get.toNamed("/feed", arguments: {"data":data});
            }
          },
          child: Container(
              // color: Get.isDarkMode ? ColorConstants.dialogBg : Colors.white,
              width: ScreenUtil().screenWidth,
              padding: EdgeInsets.only(left:ScreenUtil().setWidth(6),right: ScreenUtil().setWidth(6) ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: ScreenUtil().setHeight(15),),
                            Obx((){
                              var result = _nostrService.userMetadataObj.getUserInfo(data.pubkey);
                              var pic = result['picture']??'';
                              var name = ViewUtils.userShowName(result, userId: data.pubkey);
                              return Container(
                                height: ScreenUtil().setHeight(245),
                                decoration: BoxDecoration(
                                  color: Get.isDarkMode ? ColorConstants.dialogBg : Color(0xFFf7f7f7),
                                  // color: ColorConstants.hexToColor('#f7f7f7'),
                                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(15)),
                                  border: Border.all(
                                    color: Get.isDarkMode ? ColorConstants.dialogBg : ColorConstants.inputLineColor,
                                    width: 1.0,
                                  ),
                                  shape: BoxShape.rectangle,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height:ScreenUtil().setHeight(50),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(width: 10,),
                                              CachedNetworkImage(
                                                imageUrl: pic,
                                                placeholder: (context, url) => AvatarHolder( width: 27,
                                                  height: 27,),
                                                errorWidget: (context, url, error) => AvatarHolder( width: 27,
                                                  height: 27,),
                                                imageBuilder: (context, imageProvider) => Container(
                                                  width: ScreenUtil().setWidth(27),
                                                  height: ScreenUtil().setWidth(27),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: imageProvider, fit: BoxFit.cover),
                                                  ),
                                                ),
                                              ),
                                              Container(width: 10,),
                                              Text(
                                                name,
                                                style: TextStyle(
                                                    color: ColorConstants.hexToColor("#5B6A91"),
                                                    fontSize: ScreenUtil().setSp(15)
                                                ),
                                              ),
                                              Container(width: 10,),
                                              Text(
                                                Utils.getTimeDiffForString(data.tweetedAt),
                                                style: TextStyle(
                                                    color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFFb4b4b4),
                                                    fontSize: ScreenUtil().setSp(13.3)
                                                )
                                              ),
                                            ],
                                          ),
                                          Image.asset("assets/images/article_label.png", color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFFb4b4b4), width: ScreenUtil().setWidth(30)),
                                        ],
                                      ),
                                    ),
                                    data.coverImage == ''?Container(
                                      height: ScreenUtil().setHeight(175),
                                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(35)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(child: Text(
                                            data.title,
                                            style: TextStyle(
                                                // color: ColorConstants.hexToColor('#1a1a1a'),
                                                fontSize: ScreenUtil().setSp(16.3)
                                            )
                                          ))
                                        ],
                                      ),
                                    ):Column(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: data.coverImage,
                                          imageBuilder: (context, imageProvider) => Container(
                                            width: ScreenUtil().setWidth(400),
                                            height: ScreenUtil().setHeight(140),
                                            decoration: BoxDecoration(
                                              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: ScreenUtil().setHeight(50),
                                          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                                          child: Row(
                                            children: [
                                              Expanded(child: Text(
                                                data.title,
                                                style: TextStyle(
                                                    // color: ColorConstants.hexToColor('#1a1a1a'),
                                                    fontSize: ScreenUtil().setSp(16.3)
                                                ),overflow: TextOverflow.ellipsis,
                                              ))
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }),
                          ],
                        )
                    ),
                  ],
                ),
              )
          ),
        ),
      ],
    )
    );
  }
}


