
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/page/feed/feed_controller.dart';
import 'package:freerse/views/feed/avatar_holder.dart';
import 'package:get/get.dart';

import '../../services/nostr/nostr_service.dart';
import '../helpers/helpers.dart';
import 'common/ViewUtils.dart';

class UserComponent extends StatelessWidget {
  String userId;

  UserComponent({ required this.userId}) {
    this.userId = userId;
  }

  late final NostrService nostrService = Get.find();

  @override
  Widget build(BuildContext context){
    try {
      Helpers().encodeBech32(userId, 'npub');
    } catch (e) {
      return Container();
    }

    return Obx((){
      var result = nostrService.userMetadataObj.getUserInfo(userId);
      var pic = result['picture']??'';
      // var name =  result['name']??result['display_name']??'';
      var name = ViewUtils.userShowName(result, userId: userId);
      var about = result['about']??'';
      bool isFollow = nostrService.userContactsObj.isFollowByMe(userId);
      return Container(
        padding: EdgeInsets.only(left: Cons.IMAGE_ML,right: ScreenUtil().setWidth(20),top: ScreenUtil().setHeight(10),bottom: ScreenUtil().setHeight(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           Expanded(child:
             GestureDetector(
               behavior: HitTestBehavior.translucent,
               onTap: (){
                 Get.toNamed("/user", arguments: userId);
               },
               child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: pic,
                      placeholder: (context, url) => AvatarHolder(width: Cons.IMAGE_WH_SOURCE,height: Cons.IMAGE_WH_SOURCE,),
                      errorWidget: (context, url, error) => AvatarHolder(width: Cons.IMAGE_WH_SOURCE,height: Cons.IMAGE_WH_SOURCE,),
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
                    Container(width: Cons.IMAGE_MR,),
                    Flexible(child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,style: TextStyle(
                            color: Get.isDarkMode ? Color(0xFFd1d1d1) : Color(0xFF181818),
                            fontSize: ScreenUtil().setSp(16)
                        ),),
                        Container(height: 3,),
                        Text(about,maxLines:3,overflow: TextOverflow.ellipsis,style: TextStyle(
                            color: Get.isDarkMode ? Color(0xFF5e5e5e) : ColorConstants.colorb3,
                            fontSize: ScreenUtil().setSp(13.3)
                        ),)
                      ],
                    ))
                  ],
                ),
              ),
            ),
            isFollow?GestureDetector(
              onTap: () {
                nostrService.unFollowUser(userId);
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                width: ScreenUtil().setWidth(90),
                height: ScreenUtil().setHeight(38),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    "QU_X_G_ZHU".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(15),
                    ),
                  ),
                ),
              ),
            ):
            GestureDetector(
              onTap: () {
                nostrService.followUser(userId);
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                width: ScreenUtil().setWidth(90),
                height: ScreenUtil().setHeight(38),
                decoration: BoxDecoration(
                  color: ColorConstants.greenColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    "GUAN_ZHU".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(15),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }


}


