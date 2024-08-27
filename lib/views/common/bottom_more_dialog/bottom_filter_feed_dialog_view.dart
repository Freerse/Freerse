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
import 'bottom_more_dialog_controller.dart';
class BottomFilterFeedDialogComponent extends StatelessWidget {
  final String type;
  final Function filters;
  final controller = Get.put(BottomMoreDialogController());
  BottomFilterFeedDialogComponent({super.key, required this.type, required this.filters}) {}

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
    // var isBlocked = controller.nostrService.searchFeedObj.blackUserIdList.contains(data.pubkey);
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        child: Container(
          color: Get.isDarkMode ? ColorConstants.dialogBg : Colors.white,
          height: ScreenUtil().setHeight(180),
          child: Column(
            children: [
              buildOneRow("全部热门".tr, "", ColorConstants.textRed, onClick: (){
                filters('G_HOT');
                Get.back();
              }),
              Divider(height: 1),
              buildOneRow((type == 'HOT' ? "热门".tr : "热门".tr), "", ColorConstants.textRed, onClick: (){
                filters('HOT');
                Get.back();
              }),
              Container(height: ScreenUtil().setHeight(7), color: Get.isDarkMode ? Colors.black : ColorConstants.hexToColor("#f7f7f7"),),
              buildOneRow("QU_XIAO".tr, "", Get.isDarkMode ? Colors.white : ColorConstants.textBlack, onClick: (){Get.back();}),
            ],
          ),
        )
    );
  }
}
