// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/page/webview/webview_view.dart';
import 'package:freerse/page/zap/zap_number_setting_view.dart';
import 'package:freerse/page/zap/zap_setting_controller.dart';
import 'package:freerse/services/nostr/nips/zap_service.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import 'zap_connect_view.dart';

class ZapSettingView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ZapSettingView();
  }
}

class _ZapSettingView extends State<ZapSettingView> {
  ZapService zapService = Get.find();

  ZapSettingController controller = Get.put(ZapSettingController());

  double mainPadding = 8;

  double cardWidth = 10;
  double cardHeight = 10;

  @override
  Widget build(BuildContext context) {
    cardWidth = ScreenUtil().screenWidth - mainPadding * 2;
    cardHeight = 496 / 410 * cardWidth;

    var greyColor = ColorConstants.hexToColor("#808080");
    var blackColor = ColorConstants.color1a;
    var cardBottomTextStyle = TextStyle(
      fontSize: 15,
      color: greyColor,
    );
    var cardTopTextStyle = TextStyle(
      color: blackColor,
    );

    String imageDes = "BITCOIN_LIGHTNING_WALLET".tr;
    Widget imageWidget = Image.asset(
      "assets/images/zapsetting_btc.png",
      width: ScreenUtil().setWidth(46),
      height: ScreenUtil().setWidth(46),
    );
    Widget accountWidget = Container();
    Widget bottom1Widget = Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Text(
        "ZAP_RECEIVE_SEND_TIP".tr,
        style: cardBottomTextStyle,
        textAlign: TextAlign.center,
      ),
    );
    Widget bottom2Widget = Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Image.asset(
              "assets/images/zapsetting_zap.png",
              width: ScreenUtil().setWidth(9.6),
              height: ScreenUtil().setWidth(17),
            ),
            margin: EdgeInsets.only(right: 4),
          ),
          Text("ZAP_DES".tr, style: cardBottomTextStyle),
        ],
      ),
    );
    var zapConfig = zapService.zapConfig;
    bool connectSetting = false;
    if (StringUtils.isNotBlank(zapConfig!.wallConnectUrl)) {
      connectSetting = true;
      cardBottomTextStyle = TextStyle(
        fontSize: 15,
        color: blackColor,
      );
      cardTopTextStyle = TextStyle(
        color: greyColor,
      );

      if (zapConfig.wallConnectUrl!.contains("getalby.com")) {
        imageWidget = Image.asset(
          "assets/images/zapsetting_alby.png",
          width: ScreenUtil().setWidth(46),
          height: ScreenUtil().setWidth(46),
        );

        imageDes = "ALBY_BITCOIN_LIGHTNING_WALLET_IS_CONNECTED".tr;
      } else {
        imageDes = "BITCOIN_LIGHTNING_WALLET_IS_CONNECTED".tr;
      }

      bottom1Widget = Container();
      bottom2Widget = Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Text(
          "DISCONNECT_TIP".tr,
          style: cardBottomTextStyle,
          textAlign: TextAlign.center,
        ),
      );
    }
    if (zapService.walletConnectionInfo != null &&
        StringUtils.isNotBlank(zapService.walletConnectionInfo!.lud16)) {
      accountWidget = Container(
        margin: EdgeInsets.only(top: 10),
        child: Text(zapService.walletConnectionInfo!.lud16!,
            style: cardTopTextStyle),
      );
    }

    var cardWidget = Container(
      height: cardHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.33),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(52)),
            child: imageWidget,
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(10)),
            child: Text(imageDes, style: cardTopTextStyle),
          ),
          accountWidget,
          Expanded(child: Container()),
          bottom1Widget,
          bottom2Widget,
          connectSetting
              ? buildCloseConnectWidget()
              : buildConnectToAlbyWidget(),
        ],
      ),
    );

    return Container(
      color: ColorConstants.zapSettingViewBG,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              iconSize: 30,
              icon: Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await Get.to(() => ZapConnectView());
                  setState(() {});
                },
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.white,
                ),
              ),
            ],
            title: Text(
              "CONNECT_WALLET".tr,
              style: Get.theme.textTheme.titleLarge!.merge(TextStyle(
                color: Colors.white,
              )),
            ),
            centerTitle: true,
          ),
          body: Container(
            padding: EdgeInsets.only(left: mainPadding, right: mainPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  cardWidget,
                  Container(
                    child: GestureDetector(
                      onTap: () async {
                        await Get.to(() => ZapNumberSettingView());
                        setState(() {});
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: ScreenUtil().setWidth(10)),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        width: double.infinity,
                        height: ScreenUtil().setWidth(58),
                        decoration: BoxDecoration(
                          color: ColorConstants.hexToColor("#FED569"),
                          borderRadius: BorderRadius.circular(8.33),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  right: ScreenUtil().setWidth(13.67),
                                  left: ScreenUtil().setWidth(10)),
                              child: Image.asset(
                                "assets/images/zapsetting_zap_white.png",
                                width: ScreenUtil().setWidth(12.67),
                                height: ScreenUtil().setWidth(22.67),
                              ),
                            ),
                            Text(
                              "ZAP_AMOUNT_SETTINGS".tr,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Expanded(child: Container()),
                            Container(
                              child: Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCloseConnectWidget() {
    return GestureDetector(
      onTap: () async {
        var zapConfig = zapService.zapConfig;
        zapConfig!.wallConnectUrl = null;
        await zapService.updateSetting();
        zapService.reconect();
        setState(() {});
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(
            top: ScreenUtil().setWidth(24), bottom: ScreenUtil().setWidth(110)),
        width: cardWidth - ScreenUtil().setWidth(44),
        height: ScreenUtil().setWidth(52.33),
        decoration: BoxDecoration(
          border: Border.all(
              color: ColorConstants.hexToColor("#F6C646"), width: 1.67),
          borderRadius: BorderRadius.circular(8.33),
        ),
        child: Text(
          "DISCONNECT_WALLET".tr,
          style: TextStyle(color: Color(0xFF181818)),
        ),
      ),
    );
  }

  Widget buildConnectToAlbyWidget() {
    return GestureDetector(
      onTap: () async {
        var result = await Get.to(() => WebviewView(title: "Connect to Alby"),
            arguments: "https://nwc.getalby.com/apps/new?c=Freerse");
        if (result != null &&
            result is String &&
            result.indexOf("nostr+walletconnect://") == 0) {
          var zapConfig = zapService.zapConfig;
          zapConfig!.wallConnectUrl = result;
          await zapService.updateSetting();
          zapService.reconect();
          setState(() {});
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(
            top: ScreenUtil().setWidth(37), bottom: ScreenUtil().setWidth(110)),
        width: cardWidth - ScreenUtil().setWidth(44),
        height: ScreenUtil().setWidth(52.33),
        decoration: BoxDecoration(
          color: ColorConstants.hexToColor("#f6e081"),
          borderRadius: BorderRadius.circular(8.33),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(13.67)),
              child: Image.asset(
                "assets/images/zapsetting_alby_btn.png",
                width: ScreenUtil().setWidth(32.33),
                height: ScreenUtil().setWidth(26),
              ),
            ),
            Text("CONNECT_ALBY_WALLET".tr,
                style: TextStyle(color: Color(0xFF181818))),
          ],
        ),
      ),
    );
  }
}
