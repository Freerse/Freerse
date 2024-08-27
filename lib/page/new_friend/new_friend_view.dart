import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/metadata/user_msg.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/feed/avatar_holder.dart';
import 'new_friend_controller.dart';

class NewFriendPage extends StatelessWidget {
  final controller = Get.put(NewFriendController());
  late final NostrService nostrService = Get.find();

  Widget _buildListItem(BuildContext context,String userId,String content){
    var result = nostrService.userMetadataObj.getUserInfo(userId);
    var pic = result['picture']??'';
    var name =  ViewUtils.userShowName(result, userId: userId);

    var displayContent = content;
    if(content.length >= 20){
      displayContent = displayContent.substring(0,18)+'...';
    }

    return InkWell(
      onTap: (){
        Get.toNamed("/message", arguments: userId);
      },
      child: Container(
        padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20),top: ScreenUtil().setHeight(10),bottom: ScreenUtil().setHeight(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [

                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    Get.toNamed("/user", arguments: userId);
                  },
                  child:  CachedNetworkImage(
                    imageUrl: pic,
                    placeholder: (context, url) => AvatarHolder(),
                    errorWidget: (context, url, error) => AvatarHolder(),
                    imageBuilder: (context, imageProvider) => Container(
                      width: ScreenUtil().setWidth(50),
                      height: ScreenUtil().setWidth(50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),

                Container(width: ScreenUtil().setWidth(20),),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,style: TextStyle(
                        // color: ColorConstants.color1a,
                        fontSize: ScreenUtil().setSp(16)
                    )),
                    Text(displayContent,maxLines:1,overflow: TextOverflow.ellipsis,style: TextStyle(
                        color: ColorConstants.colorb3,
                        fontSize: ScreenUtil().setSp(13.3)
                    ),)
                  ],
                )
              ],
            ),
            GestureDetector(
              onTap: () {
                controller.acceptFriend(userId);
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                width: ScreenUtil().setWidth(60),
                height: ScreenUtil().setHeight(33),
                decoration: BoxDecoration(
                  color: ColorConstants.greenColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    "JIE_SHOU".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(13.3),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false,child:
    Scaffold(
        backgroundColor: Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
      appBar: AppBar(
        backgroundColor: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
            Get.back();
          },
          ),
          title: Text("XIN_D_P_YOU".tr,style: Theme.of(context).textTheme.titleLarge,),
          centerTitle: true,
      ),
      body: Obx((){
        var publicKey = nostrService.userMessageObj.myKeys.publicKey;
        List<dynamic> showLists = [];
        nostrService.userMessageObj.userMessages.forEach((key, value) {
          bool isShow = false;
          UserMsg? lastMsg;
          value.forEach((element) {
            if(element.sender == publicKey){
              isShow = true;
            }
            if(lastMsg == null){
              lastMsg = element;
            }else{
              var time = lastMsg?.create;
              if(element.create >= time!){
                lastMsg = element;
              }
            }
          });
          if(!isShow){
            showLists.add({
              "userId": key,
              "data": lastMsg?.content,
              "date": lastMsg?.create,
            });
          }
        });

        showLists.sort((msg1, msg2) {
          if (msg1 != null && msg1["date"] != null && msg2 != null && msg2["date"] != null) {
            return msg2["date"] - msg1["date"];
          }
          return 0;
        });

        return ListView.builder(
          itemCount: showLists.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                _buildListItem(context,showLists[index]['userId'], showLists[index]['data']),
                Container(
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(90)),
                  child: Divider(height: 1,color: Get.isDarkMode ? ColorConstants.dividerColorDark2 : ColorConstants.dividerColor,),
                ),
              ],
            );
          },
        );
      })
    ));
  }
}
