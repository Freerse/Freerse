// ignore_for_file: sort_child_properties_last, prefer_interpolation_to_compose_strings

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/page/collect/collect_view.dart';
import 'package:freerse/page/mine_setting/mine_setting_view.dart';
import 'package:freerse/page/user/user_view.dart';
import 'package:freerse/page/zap/zap_setting_view.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/feed/avatar_holder.dart';
import '../RepeaterList/RepeaterList.dart';
import '../donate/donate_view.dart';
import 'mine_controller.dart';

class MinePage extends StatelessWidget {
  final controller = Get.put(MineController());
  late final NostrService nostrService = Get.find();

  Widget _buildItem(icon, title) {
    return Container(
      height: ScreenUtil().setHeight(56),
      color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(20), right: ScreenUtil().setWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                icon,
                width: ScreenUtil().setWidth(24),
              ),
              Container(
                width: ScreenUtil().setWidth(14),
              ),
              ViewUtils.menuText(title),
            ],
          ),
          Image.asset(
            'assets/images/arrow_right.png',
            color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191),
            width: ScreenUtil().setWidth(23),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Get.isDarkMode
              ? ColorConstants.setPageBg
              : ColorConstants.statuabarColor,
          body: Column(
            children: [
              Container(
                  color: Get.isDarkMode
                      ? ColorConstants.bottomColorBlack
                      : Colors.white,
                  height: ScreenUtil().setHeight(200),
                  padding: EdgeInsets.only(
                      top: ScreenUtil().statusBarHeight,
                      left: ScreenUtil().setWidth(25),
                      right: ScreenUtil().setWidth(25)),
                  // color: Colors.white,
                  child: Obx(() {
                    var result = nostrService.userMetadataObj
                        .getUserInfo(nostrService.myKeys.publicKey);
                    var name = ViewUtils.userShowName(result,
                        userId: nostrService.myKeys.publicKey);
                    var pic = result['picture'] ?? '';
                    var pubkey = nostrService.myKeys.publicKeyHr;
                    var pubkeyHr = pubkey.substring(0, 10) +
                        "...." +
                        pubkey.substring(pubkey.length - 10, pubkey.length);
                    var mykey = nostrService.myKeys.publicKey;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Get.to(() => UserPage(),
                                  arguments: mykey, preventDuplicates: false);
                            },
                            child: CachedNetworkImage(
                              imageUrl: pic,
                              fadeInDuration: Duration(milliseconds: 0),
                              fadeInCurve: Curves.linear,
                              placeholder: (context, url) => AvatarHolder(
                                width: 70,
                                height: 70,
                              ),
                              errorWidget: (context, url, error) =>
                                  AvatarHolder(
                                width: 70,
                                height: 70,
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: ScreenUtil().setHeight(70),
                                height: ScreenUtil().setHeight(70),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                            )),
                        Container(
                          width: ScreenUtil().setWidth(15),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Color(0xFF1a1a1a),
                                  fontSize: ScreenUtil().setSp(23)),
                            ),
                            Container(
                              height: 4,
                            ),
                            Text("ZHANG_HAO".tr + pubkeyHr,
                                style: TextStyle(
                                    color: ColorConstants.hexToColor('#757575'),
                                    fontSize: ScreenUtil().setSp(16)))
                          ],
                        )
                      ],
                    );
                  })),
              Container(
                height: ScreenUtil().setHeight(8),
              ),
              GestureDetector(
                child:
                    _buildItem('assets/images/mine_user.png', "GE_R_Z_LIAO".tr),
                onTap: () {
                  Get.to(() => UserPage(),
                      arguments: nostrService.myKeys.publicKey,
                      preventDuplicates: false);
                },
                behavior: HitTestBehavior.translucent,
              ),
              Container(
                height: ScreenUtil().setHeight(8),
              ),
              GestureDetector(
                child:
                    _buildItem('assets/images/mine_zap.png', "ZAP_WALLET".tr),
                onTap: () {
                  Get.to(() => ZapSettingView());
                },
                behavior: HitTestBehavior.translucent,
              ),
              Container(
                height: ScreenUtil().setHeight(8),
              ),
              // _buildItem('assets/images/mine_wallet.png',"QIAN_BAO".tr),
              // Container(height: ScreenUtil().setHeight(8),),
              GestureDetector(
                child: _buildItem(
                    'assets/images/mine_collect.png', "SHOU_CANG".tr),
                onTap: () {
                  Get.to(() => CollectPage(),
                      arguments: nostrService.myKeys.publicKey,
                      preventDuplicates: false);
                },
                behavior: HitTestBehavior.translucent,
              ),
              Container(
                height: ScreenUtil().setHeight(1),
              ),

              // Container(
              //   margin: EdgeInsets.only(left: ScreenUtil().setWidth(90)),
              //   child: Divider(height: 1,color: Get.isDarkMode ? ColorConstants.dividerColorDark2 : ColorConstants.dividerColor,),
              // ),

              GestureDetector(
                child:
                    _buildItem('assets/images/mine_reply.png', "ZHONG_J_QI".tr),
                onTap: () {
                  Get.to(() => RepeaterList(), preventDuplicates: false);
                },
                behavior: HitTestBehavior.translucent,
              ),
              Container(
                height: ScreenUtil().setHeight(1),
              ),
              // Container(
              //   margin: EdgeInsets.only(left: ScreenUtil().setWidth(90)),
              //   child: Divider(height: 1,color: Get.isDarkMode ? ColorConstants.dividerColorDark2 : ColorConstants.dividerColor,),
              // ),

              Platform.isIOS
                  ? GestureDetector(
                      child: _buildItem(
                          'assets/images/mine_juanzeng.png', "DONATE".tr),
                      onTap: () {
                        Get.to(() => DonateView(), preventDuplicates: false);
                      },
                      behavior: HitTestBehavior.translucent,
                    )
                  : Container(),

              Platform.isIOS
                  ? Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setWidth(90)),
                      child: Divider(
                        height: 1,
                        color: Get.isDarkMode
                            ? ColorConstants.dividerColorDark2
                            : ColorConstants.dividerColor,
                      ),
                    )
                  : Container(),

              GestureDetector(
                child: _buildItem(
                    'assets/images/mine_help.png', "BANG_Z_Z_XIN".tr),
                onTap: () {
                  launchUrl(Uri.parse('https://freerse.com/help-center'));
                  // Get.to(()=>SplashView(),preventDuplicates:false);
                },
                behavior: HitTestBehavior.translucent,
              ),

              Container(
                height: ScreenUtil().setHeight(8),
              ),
              GestureDetector(
                child:
                    _buildItem('assets/images/mine_setting.png', "SHE_ZHI".tr),
                onTap: () {
                  Get.to(() => MineSettingPage());
                },
                behavior: HitTestBehavior.translucent,
              )
            ],
          ),
        ));
  }
}
