
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/config/utils.dart';
import 'package:freerse/model/LinghtItem.dart';
import 'package:freerse/views/feed/avatar_holder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../services/nostr/nostr_service.dart';

class LightComponent extends StatelessWidget {
  LinghtItem lightItem;

  LightComponent({ required this.lightItem}) {
    this.lightItem = lightItem;
  }

  late final NostrService nostrService = Get.find();
  final format = NumberFormat("#,##0", "en_US");

  @override
  Widget build(BuildContext context){
    return Obx((){
      var result = nostrService.userMetadataObj.getUserInfo(lightItem.pubkey);
      var pic = result['picture']??'';
      var name =  result['name']??result['display_name']??'';
      var amount = lightItem.amount?.toDouble()??0;
      var time = lightItem.createTime;
      return Container(
        padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20),top: ScreenUtil().setHeight(10),bottom: ScreenUtil().setHeight(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Row(
              children: [
                GestureDetector(
                  child: CachedNetworkImage(
                    imageUrl: pic,
                    placeholder: (context, url) => AvatarHolder(),
                    errorWidget: (context, url, error) => AvatarHolder(),
                    imageBuilder: (context, imageProvider) => Container(
                      width: ScreenUtil().setWidth(50),
                      height: ScreenUtil().setWidth(50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    Get.toNamed("/user", arguments: lightItem.pubkey);
                  },
                ),
                Container(width: ScreenUtil().setWidth(12),),

                Text(name,style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Get.isDarkMode ? Color(0xFFd1d1d1) : Color(0xFF181818),
                    fontSize: ScreenUtil().setSp(16)
                ),),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(5)),
                  child: Text(
                      "·",
                      style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191),
                          fontSize: ScreenUtil().setSp(22)
                      )
                  ),
                ),
                Text(
                    Utils.getTimeDiffForString(time),
                    style: TextStyle(
                        color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191),
                        fontSize: ScreenUtil().setSp(13.3)
                    )
                ),
              ],
            ),),
            Row(children: [
              Padding(padding:  EdgeInsets.only(right: ScreenUtil().setWidth(8)), child: Image.asset("assets/images/light_icon.png",width: ScreenUtil().setWidth(13)),),
              Text(
                '${format.format(amount)} 聪',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode ? Color(0xFFd1d1d1) : Color(0xFF181818),
                  fontSize: ScreenUtil().setSp(16),
                ),
              ),
            ],)
          ],
        ),
      );
    });
  }


}


