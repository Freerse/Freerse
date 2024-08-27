
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/services/nostr/nips/zap_service.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../views/common/ViewUtils.dart';
import '../../views/feed/avatar_holder.dart';
import 'zap_custom_sender_controller.dart';
import 'zap_number_selected_component.dart';
import 'zap_number_show_component.dart';

class ZapCustomSenderView extends StatelessWidget {

  static Future<void> show(String pubkey, {String? eventId, Function(int amount, {String? noteId, String? pubkey})? onCompleted}) async {
    if (Platform.isIOS && !Get.currentRoute.contains("UserPage")) {
      // current isn't user page
      Get.toNamed("/user", arguments: pubkey);
      await Future.delayed(Duration(milliseconds: 500));
    }
    Get.bottomSheet(ZapCustomSenderView(pubkey: pubkey, eventId: eventId, onCompleted: onCompleted),
        isScrollControlled: true,);
  }

  Function(int amount, {String? noteId, String? pubkey})? onCompleted;

  String? eventId;

  String pubkey;

  ZapCustomSenderView({
    this.eventId,
    required this.pubkey,
    this.onCompleted,
  });

  NostrService nostrService = Get.find();

  ZapService zapService = Get.find();

  ZapCustomSenderController controller = Get.put(ZapCustomSenderController(), tag: Helpers().getRandomString(12));

  @override
  Widget build(BuildContext context) {
    controller.eventId = eventId;
    controller.pubkey = pubkey;

    List<Widget> list = [];

    list.add(Obx(() {
      var result = nostrService.userMetadataObj.getUserInfo(pubkey);
      var pic = result['picture']??'';
      var name = ViewUtils.userShowName(result, userId: pubkey);

      double imageHeight = 50;

      var userImage = CachedNetworkImage(
        imageUrl: pic,
        placeholder: (context, url) => AvatarHolder( width: imageHeight,
          height: imageHeight,),
        errorWidget: (context, url, error) => AvatarHolder( width: imageHeight,
          height: imageHeight,),
        imageBuilder: (context, imageProvider) => Container(
          width: ScreenUtil().setWidth(imageHeight),
          height: ScreenUtil().setWidth(imageHeight),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: imageProvider, fit: BoxFit.cover),
          ),
        ),
      );

      var nameWidget = Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(6), bottom: ScreenUtil().setWidth(20)),
        child: Text(
          name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          userImage,
          nameWidget,
        ],
      );
    }));

    list.add(Obx(() {
      var zapConfig = zapService.zapConfig;
      
      return Row(
        children: [
          Expanded(child: buildNumWidget(zapConfig!.num1!)),
          Container(width: 10),
          Expanded(child: buildNumWidget(zapConfig.num2!)),
          Container(width: 10),
          Expanded(child: buildNumWidget(zapConfig.num3!)),
        ],
      );
    }));

    list.add(Container(height: 10,));

    list.add(Obx(() {
      var zapConfig = zapService.zapConfig;

      return Row(
        children: [
          Expanded(child: buildNumWidget(zapConfig!.num4!)),
          Container(width: 10),
          Expanded(child: buildNumWidget(zapConfig.num5!)),
          Container(width: 10),
          Expanded(child: buildNumWidget(zapConfig.num6!)),
        ],
      );
    }));

    list.add(Container(
      margin: EdgeInsets.only(top: 25, bottom: 4),
      alignment: Alignment.centerLeft,
      child: Text("OTHER_AMOUNT".tr, style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      )),
    ));

    list.add(Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 2),
            child: Text("sat", style: TextStyle(
              fontSize: 18.33,
              fontWeight: FontWeight.bold,
            ),),
          ),
          Expanded(child: Container(
            margin: EdgeInsets.only(left: 10),
            child: TextField(
              controller: controller.othersController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: "PLEASE_INPUT_AMOUNT".tr,
                hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: ColorConstants.hexToColor("#c0c0c0"),
                )
              ),
              style: TextStyle(
                fontSize: 33.33,
                color: ColorConstants.hexToColor("#EF8E53"),
              ),
            ),
          )),
        ],
      ),
    ));
    list.add(Divider());

    list.add(Container(
      margin: EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("MESSAGE".tr, style: TextStyle(
            fontSize: 15,
          ),),
          Expanded(child: TextField(
            controller: controller.commentController,
            // minLines: 1,
            // maxLines: 2,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
              isDense: true,
              hintText: "PLEASE_INPUT_MESSAGE".tr,
              hintStyle: TextStyle(
                color: ColorConstants.hexToColor("#c0c0c0"),
                fontWeight: FontWeight.normal,
              )
            ),
          )),
        ],
      ),
    ));
    
    list.add(Container(
      margin: EdgeInsets.only(top: 4),
      child: GestureDetector(
        onTap: () {
          controller.comfirm(onCompleted: onCompleted);
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          // color: Colors.green,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 6, bottom: 6),
          child: Text("CONFIRM".tr, style: TextStyle(
            color: ColorConstants.hexToColor("#EA6B4E"),
            fontSize: 16.67,
          ),),
        ),
      ),
    ));

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Get.isDarkMode ? ColorConstants.dialogBg : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(33.33),
          topRight: Radius.circular(33.33),
        )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );
  }

  Widget buildNumWidget(int n) {
    if (controller.num.value == n) {
      return ZapNumberSelectedComponent(num: n);
    } else {
      return GestureDetector(
        onTap: () {
          controller.onSelect(n);
        },
        behavior: HitTestBehavior.translucent,
        child: ZapNumberShowComponent(num: n,),
      );
    }
  }

}