
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/model/UserItem.dart';
import 'package:freerse/views/feed/avatar_holder.dart';
import 'package:get/get.dart';

import '../../services/nostr/nostr_service.dart';

class UserRealComponent extends StatelessWidget {
  UserItem userItem;

  UserRealComponent({ required this.userItem}) {
    this.userItem = userItem;
  }


  @override
  Widget build(BuildContext context){
      // var result = nostrService.userMetadataObj.getUserInfo(userId);
      var userId = userItem.userId??'';
      var pic = userItem.avater??'';
      var name =  userItem.name??'';
      var about = userItem.about??'';
      // bool isFollow = nostrService.userContactsObj.isFollowByMe(userId);
      return Container(
        padding: EdgeInsets.only(left: Cons.IMAGE_ML,right: ScreenUtil().setWidth(20),top: ScreenUtil().setHeight(10),bottom: ScreenUtil().setHeight(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child:
             Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    Get.toNamed("/user", arguments: userId);
                  },
                  child: CachedNetworkImage(
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
          ],
        ),
      );
  }


}


