import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/common/bottom_conform_dialog/bottom_conform_dialog_view.dart';
import 'package:get/get.dart';

import '../../../config/ColorConstants.dart';
import '../../../model/Tweet.dart';
import '../../../page/set_nick_name/set_nickname_view.dart';
import 'bottom_more_dialog_controller.dart';

class BottomUserMoreDialogComponent extends StatelessWidget {
  final String pubkey;
  final controller = Get.put(BottomMoreDialogController());
  BottomUserMoreDialogComponent({super.key, required this.pubkey}) {}

  @override
  Widget buildOneRow(String title, String content, Color color, {onClick}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        if(onClick != null){
          onClick();
        }else{
          Get.back();
          Get.snackbar(
            "TI_SHI".tr,
            "FU_Z_C_GONG".tr,
            duration: Duration(seconds: 3),
          );
          Clipboard.setData(ClipboardData(text: content));
        }
      },
      child: Container(
        height: ScreenUtil().setHeight(54.3),
        alignment: Alignment.center,
        child: Text(title, style: TextStyle(color: color,fontSize: ScreenUtil().setSp(17)),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var isBlocked = controller.nostrService.searchFeedObj.blackUserIdList.contains(pubkey);
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        child: Container(
          color: Get.isDarkMode ? ColorConstants.dialogBg : Colors.white,
          height: ScreenUtil().setHeight(290),
          child: Column(
            children: [
              buildOneRow("FU_ZYHG_YUE".tr, Helpers().encodeBech32(pubkey, 'npub'),Get.isDarkMode ? Colors.white :  ColorConstants.textBlack),
              Divider(height: 1),
              buildOneRow("SHE_Z_B_ZHU".tr, '', Get.isDarkMode ? Colors.white : ColorConstants.textBlack, onClick: (){
                Get.back();
                Get.to(()=>SetNickNamePage(), arguments: pubkey, preventDuplicates:false);
              }),
              Divider(height: 1),
              buildOneRow("JUBAO".tr,
                  '', Get.isDarkMode ? Colors.white : ColorConstants.textBlack, onClick: (){
                    Get.back();
                    Future.delayed(const Duration(seconds: 1)).then((value) => {
                      Get.snackbar(
                      "TI_SHI".tr,
                      "JUBAO_OK".tr,
                      duration: Duration(seconds: 3),
                      )
                    });
                  }
              ),
              Divider(height: 1),
              buildOneRow((isBlocked ? "QU_X_L_HEI".tr : "LA_HCY_HU".tr), '', ColorConstants.textRed, onClick: (){
                controller.nostrService.searchFeedObj.switchBlackUser(userId: pubkey);
                Get.back();
              }),
              Container(height: ScreenUtil().setHeight(7), color: Get.isDarkMode ? Colors.black : ColorConstants.hexToColor("#f7f7f7"),),
              buildOneRow("QU_XIAO".tr, '', Get.isDarkMode ? Colors.white : ColorConstants.textBlack, onClick: (){Get.back();}),
            ],
          ),
        )
    );
  }
}
