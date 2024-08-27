import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';

import '../../../config/ColorConstants.dart';
import '../../../config/utils.dart';
import '../../../services/nostr/nostr_service.dart';
import '../avatar_holder.dart';
import 'feed_like_controller.dart';

class FeedLikeComponent extends StatelessWidget {
  late final Map<String, dynamic> data;
  late final NostrService _nostrService = Get.find();
  FeedLikeComponent({required this.data});

  @override
  Widget build(BuildContext context) {
    String dataId = "";
    String userId = data['pubkey'];
    data['tags'].forEach((element) {
      if (element[0] == "e") {
        dataId = element[1];
        return;
      }
    });
    print('点赞详情==>');
    print(data);

    return Column(
      children: [
        Obx((){
          var result = _nostrService.userMetadataObj.getUserInfo(userId);
          var pic = result['picture']??'';
          var name = ViewUtils.userShowName(result, userId: userId);
          return Container(
            width: ScreenUtil().screenWidth,
            padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/images/feed_like_p.png",width: ScreenUtil().setWidth(28)),
                Container(width: ScreenUtil().setWidth(15),),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: pic,
                      placeholder: (context, url) => AvatarHolder(width: 28,height: 28,),
                      errorWidget: (context, url, error) =>  AvatarHolder(width: 28,height: 28,),
                      imageBuilder: (context, imageProvider) => Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      )
                    ),
                    Container(height: ScreenUtil().setHeight(5),),
                    Text(name+' reacted to your post'),
                    Container(height: ScreenUtil().setHeight(5),),
                    Text(
                        Utils.getTimeDiffForString(data['created_at']),
                        style: TextStyle(
                            color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191),
                            fontSize: ScreenUtil().setSp(13.3)
                        )
                    ),
                  ],
                )
              ],
            ),
          );
        }),
        Divider(height: 1,)
      ],
    );
  }
}
