import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/page/login/SlicesView/SlicesView.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/feed/avatar_holder.dart';
import 'package:get/get.dart';

import 'RegSaveKeyViewController.dart';

class RegSaveKeyView extends StatelessWidget {
  final controller = Get.put(RegSaveKeyViewController());


  Widget _buildItem(name, item, desc, TextEditingController textEditingController, copyFlag){
    return Column(
      children: [

        Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(47), bottom: ScreenUtil().setHeight(2)),
          child: Text(name,style: TextStyle(color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(23)),),
        ),

        Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(0), left: ScreenUtil().setWidth(13), right: ScreenUtil().setWidth(13)),
          child: Row(
            children: [
              Container(
                height: ScreenUtil().setHeight(50),
                alignment: Alignment.center,
                child: Text(item,),
              ),
              Expanded( child: TextField(
                controller: textEditingController,
                style: const TextStyle(fontWeight: FontWeight.normal),
                decoration: InputDecoration(
                  hintText: "TIAN_S_RU".tr + item,
                  hintStyle: TextStyle(color: ColorConstants.hintColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
                ),
              )),

              GestureDetector(
                  onTap: (){
                    Get.snackbar(
                      "TI_SHI".tr,
                      "FU_Z_C_GONG".tr,
                      duration: Duration(seconds: 3),
                    );
                    Clipboard.setData(ClipboardData(text: textEditingController.text));
                    copyFlag.value = true;
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(11),right: ScreenUtil().setWidth(20)),
                    child: Obx(() => Image.asset(copyFlag.value ? "assets/images/copy_succ.png" : "assets/images/copy_btn.png",width: ScreenUtil().setWidth(18), height: ScreenUtil().setWidth(18)),),
                  ),
                behavior: HitTestBehavior.translucent,
              )
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(13), right: ScreenUtil().setWidth(13), bottom: ScreenUtil().setHeight(10)),
          child: Divider(height: 1),
        ),

        Padding(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(13), right: ScreenUtil().setWidth(13),),
          child: Text(desc,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: Cons.tsCenter),),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var main = Obx(() => Column(
      children: [

        Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
          child: Text("BAO_CNDS_YUE".tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(30)),),
        ),
        _buildItem("GONG_YUE".tr, "ZHANG_HG_YUE_1".tr, "GONG_YSNGZ_NI".tr, controller.pubKeyController, controller.copy1),
        Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),),
        _buildItem("SI_YUE".tr, "ZHANG_HMMS_YUE".tr, "PRI_DESC".tr, controller.priKeyController, controller.copy2),
        Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(100)),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                controller.acceptSlices.value = !controller.acceptSlices.value;
              },
              child: Row(
                children: [
                  Image.asset(controller.acceptSlices.value ? "assets/images/login_slices_yes.png" : "assets/images/login_slices_no.png",width: ScreenUtil().setWidth(21), height: ScreenUtil().setWidth(21)),
                  Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(3),),
                    child: Text("WO_YJBCLWDMMS_YUE".tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                  ),
                ],
              ),
              behavior: HitTestBehavior.translucent,
            ),
          ],),

        Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(31), bottom: ScreenUtil().setHeight(31 * 3)),
          child: GestureDetector(
            onTap: () {
              if(!controller.acceptSlices.value){
                ViewUtils.showToast(context, "QING_XQRYJBCMMS_YUE".tr);
                return;
              }
              controller.saveNewAccount();
            },
            child: Container(
              width: ScreenUtil().setWidth(197),
              height: ScreenUtil().setHeight(52),
              decoration: BoxDecoration(
                color: ColorConstants.greenColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  "KAI_SHI".tr,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Cons.tsBig
                  ),
                ),
              ),
            ),
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    ),
    );

    return SafeArea(top:false,bottom:false,
      child: Scaffold(
        // backgroundColor: Colors.red,
        backgroundColor: Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
        appBar: AppBar(
          backgroundColor: Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
          leading: IconButton(
            color: ColorConstants.greenColor,
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
            Get.back();
          },
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: main,
        ),
    ));
  }

}
