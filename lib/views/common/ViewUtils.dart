// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/model/Tweet.dart';
import 'package:freerse/views/common/content/content_component.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:w_popup_menu/w_popup_menu.dart';

class ViewUtils {
  static Text titleText(String title) {
    return Text(
      title,
      style: Theme.of(Get.context!).textTheme.titleLarge,
    );
  }

  static Text menuText(String title) {
    return Text(
      title,
      style: Theme.of(Get.context!).textTheme.bodyMedium,
    );
  }

  static userShowName(userInfo, {userId}) {
    var name = userInfo['display_name'];
    if (!isNotEmpty(name)) name = userInfo['name'];
    if (!isNotEmpty(name))
      name = formatLongText(Helpers().encodeBech32(userId, 'npub'));
    return name;
  }

  static bool isNotEmpty(String? inputText) {
    var emp = inputText?.isNotEmpty ?? false;
    return emp;
  }

  static Widget buildCopyView(String content, Widget childView) {
    return WPopupMenu(
      menuWidth: 60,
      onValueChanged: (int value) {
        Get.snackbar(
          "TI_SHI".tr,
          "FU_Z_C_GONG".tr,
          duration: Duration(seconds: 3),
        );
        Clipboard.setData(ClipboardData(text: content));
      },
      actions: ['COPY'.tr],
      child: childView,
    );
  }

  static Widget buildMarkView(BuildContext context, Tweet data, {type = 0}) {
    var content = (type == 1 ? "HUI_FU_2".tr : '') + " " + data.content;
    return ContentComponent(content: content, tags: data.tags);
    //  final LinkifyOptions linkifyOptions = LinkifyOptions(humanize: false);
    // return Linkify(
    //    options:linkifyOptions,
    //    linkifiers: [UrlLinkifier(),TweetTagLinkifier(), AtUserLinkfier(tags: data.tags)],
    //    onOpen: (link) async {
    //      print(link);
    //      if(link.url.toString().startsWith('@')){
    //        var mykey = link.url.split("_")[1];
    //        if(link.url.split("_")[0] == '@p'){
    //          Get.to(()=>UserPage(),arguments: mykey);
    //        }else{
    //          // Get.to(()=>FeedDetailPage(),arguments: mykey);
    //          Get.to(()=>SearchListPage(),arguments: {"keyword":mykey});
    //        }
    //        return;
    //      }
    //      if(link.url.toString().startsWith('#')){
    //        Get.to(()=>SearchListPage(),arguments: {"keyword":link.url});
    //        return;
    //      }
    //      launchUrl(Uri.parse(link.url));
    //      return;
    //      if (await canLaunchUrl(Uri.parse(link.url))) {
    //        await launchUrl(Uri.parse(link.url));
    //      } else {
    //        throw 'Could not launch $link';
    //      }
    //    },
    //    text: (type == 1 ? "HUI_FU_2".tr : '') + data.content,
    //    style: Theme.of(context).textTheme.bodyMedium,
    //    linkStyle: TextStyle(color: ColorConstants.greenColor,decoration: TextDecoration.none,),
    //  );
  }

  static Widget vedioPlayer(
      VideoPlayerController _videoPlayerController, Function onClick) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Hero(
        tag: 'video_page_player',
        child: Stack(
          children: [
            SizedBox(
              width: 200,
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(
                  _videoPlayerController,
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  onClick();
                },
                child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget oneLine({marginLeft = 20, isWthite = false}) {
    return Container(
      height: ScreenUtil().setHeight(1),
      color: isWthite
          ? (Get.isDarkMode
              ? ColorConstants.dividerColorDark2
              : ColorConstants.dividerColor)
          : null,
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(marginLeft),
      ),
      child: Divider(height: 1),
    );
  }

  static Future<void> showToast(BuildContext context, String message) async {
    Get.snackbar(
      "TI_SHI".tr,
      message,
      duration: Duration(seconds: 3),
    );
  }

  static Future<void> changeStateColor() async {
    // await StatusBarControl.setColor(ColorConstants.statuabarColor, animated:false);
    // await StatusBarControl.setStyle(StatusBarStyle.DARK_CONTENT);
  }

  static formatLongText(String text) {
    if (text.length >= 10) {
      text = text.substring(0, 8) + '...';
    }
    return text;
  }
}
