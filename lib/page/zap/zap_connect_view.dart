
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../helpers/helpers.dart';
import 'zap_connect_controller.dart';
import 'zap_connect_scanner_view.dart';

class ZapConnectView extends StatelessWidget {

  double mainPadding = 24;

  ZapConnectController controller = Get.put(ZapConnectController(), tag: Helpers().getRandomString(12));

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(Container(
      margin: EdgeInsets.only(top: mainPadding / 2, bottom: 20),
      child: Text("ZAP_CONNECT_TIP".tr, style: TextStyle(color: Color(0xFF181818))),
    ));

    list.add(Container(
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ColorConstants.hexToColor("#F7F7F7"),
        borderRadius: BorderRadius.circular(8.33),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller.textEditingController,
            minLines: 10,
            maxLines: 10,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: "PASTE_OR_ENTER_HERE".tr,
                hintStyle: TextStyle(
                  fontSize: 13.33,
                  color: ColorConstants.hexToColor("#C0C0C0"),
                  fontWeight: FontWeight.normal,
                )
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(child: Container()),
                buildInputHelperBtn((){
                  controller.paste();
                }, "PASTE".tr),
                buildInputHelperBtn((){
                  controller.clear();
                }, "CLEAR".tr),
              ],
            ),
          ),
        ],
      ),
    ));

    list.add(Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              var result = await controller.connect();
              if (result) {
                if (Get.isSnackbarOpen) {
                  Get.back();
                }
                Get.back();
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(37)),
              width: ScreenUtil().screenWidth * 0.8,
              height: ScreenUtil().setWidth(52.33),
              decoration: BoxDecoration(
                color: ColorConstants.hexToColor("#79D750"),
                borderRadius: BorderRadius.circular(8.33),
              ),
              child: Text("CONNECT_WALLET".tr, style: TextStyle(
                color: Colors.white,
              ),),
            ),
          ),
          GestureDetector(
            onTap: openCameraScan,
            behavior: HitTestBehavior.translucent,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(16)),
              width: ScreenUtil().screenWidth * 0.8,
              height: ScreenUtil().setWidth(52.33),
              decoration: BoxDecoration(
                color: ColorConstants.hexToColor("#F2F2F2"),
                borderRadius: BorderRadius.circular(8.33),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 6),
                    child: Image.asset("assets/images/zapsetting_camera.png",
                      width: ScreenUtil().setWidth(30),
                      height: ScreenUtil().setWidth(30),
                    ),
                  ),
                  Text("SCAN_QR_CODE".tr, style: TextStyle(
                    color: ColorConstants.hexToColor("#79D750"),
                  ),),
                ],
              ),
            ),
          )
        ],
      ),
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          iconSize: 30,
          icon: Icon(Icons.chevron_left, color: Colors.black,),
        ),
        title: Text("CONNECT_OTHER_WALLETS".tr, style: TextStyle(color: Color(0xFF181818))),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: mainPadding, right: mainPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list,
          ),
        ),
      ),
    );
  }

  Widget buildInputHelperBtn(Function onTap, String text) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Text(text, style: TextStyle(
          fontSize: 13.33,
          color: ColorConstants.hexToColor("#5B6A91"),
        ),),
      ),
    );
  }


  Future<void> openCameraScan() async {
    var result = await Get.to(ZapConnectScannerView());
    if (result != null) {
      controller.textEditingController.text = result;
    }
  }
}