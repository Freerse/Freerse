import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/common/bottom_conform_dialog/bottom_conform_dialog_view.dart';
import 'package:freerse/views/common/delete_bottom_conform_dialog/delete_bottom_conform_dialog_view.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';
import 'mine_setting_controller.dart';
import 'set_locale/set_locale_view.dart';
import 'set_theme/set_theme_view.dart';

class MineSettingPage extends StatelessWidget {
  final controller = Get.put(MineSettingController());
  late final NostrService nostrService = Get.find();

  Widget _buildItem(title,text,textkey, copyFlag){
    return Container(
      height: ScreenUtil().setHeight(58),
      color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ViewUtils.menuText(title),
          copyFlag != null ?
          Row(
            children: [
              ViewUtils.menuText(text),
              GestureDetector(
                onTap: (){
                  Get.snackbar(
                    "TI_SHI".tr,
                    "FU_Z_C_GONG".tr,
                    duration: Duration(seconds: 3),
                  );
                  Clipboard.setData(ClipboardData(text: textkey));
                  copyFlag.value = true;
                },
                  behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(11),right: ScreenUtil().setWidth(20)),
                  child: Obx(() => Image.asset(copyFlag.value ? "assets/images/copy_succ.png" : "assets/images/copy_btn.png",width: ScreenUtil().setWidth(18), height: ScreenUtil().setWidth(18)),),
                )
              )
            ],
          ) :  Padding(padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)), child: Text(text),)
        ],
      ),
    );
  }

  Widget _buildSelectItem(title){
    return Container(
      height: ScreenUtil().setHeight(56),
      color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20), right: ScreenUtil().setWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ViewUtils.menuText(title),
            ],
          ),
          Image.asset('assets/images/arrow_right.png', color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191), width: ScreenUtil().setWidth(23),),
        ],
      ),
    );
  }

  Widget _buildDeleteItem(title,){
    return Container(
      height: ScreenUtil().setHeight(58),
      color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: (){
                Get.bottomSheet(DeleteBottomConformDialogComponent(title: 'DELETE_ACCOUNT_TIP'.tr, action: "C_DELETE".tr, event: (){
                  Get.back();
                  controller.delete();
                },));
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                child: ViewUtils.menuText(title),
              )
          )
        ],
      ),
    );
  }

  static String formatKey(String pubkey){
    var pubkeyHr = pubkey.substring(0,5)+"...."+pubkey.substring(pubkey.length-5,pubkey.length);
    return pubkeyHr;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false,child:
    Scaffold(
        backgroundColor:  Get.isDarkMode ? ColorConstants.setPageBg : ColorConstants.statuabarColor,
        appBar: AppBar(
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
            Get.back();
          },
          ),
          title: ViewUtils.titleText("SHE_ZHI".tr),
          centerTitle: true,
        ),
        body: Column(
          children: [
            GestureDetector(
              child: _buildSelectItem("MENU_THEME".tr),
              onTap: (){
                Get.to(()=>SetThemePage());
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),
            GestureDetector(
              child: _buildSelectItem("MENU_LOCAL".tr),
              onTap: (){
                Get.to(()=>SetLocalePage());
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),

            Container(
              height: 30,
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
              child: Row(
                children: [
                  Text("SET_ACCOUNT".tr,style: TextStyle( fontSize: 14.sp, color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191)),)
                ],
              )
            ),

            _buildItem("ZHANG_HG_YUE".tr, formatKey(nostrService.myKeys.publicKeyHr),nostrService.myKeys.publicKeyHr, controller.copy1),
            Divider(height: 1,),
            _buildItem("ZHANG_HMMS_YUE".tr, formatKey(nostrService.myKeys.privateKeyHr),nostrService.myKeys.privateKeyHr, controller.copy2),
            Container(height: 1),
            _buildItem("GUAN_Y_NONE".tr, "BAN_B_NONE".tr + '1.5.3', null,null),
            Divider(height: 1,),
            _buildDeleteItem("DELETE_ACCOUNT".tr),
            Divider(height: 1,),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){
                controller.logout(context);
              },
              child: Container(
                  height: ScreenUtil().setHeight(58),
                  color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20)),
                  child: Center(
                    child: Text("TUI_C_D_LU".tr,style: TextStyle(color: Colors.red),),
                  )
              ),
            )
          ],
        )
    ));
  }
}
