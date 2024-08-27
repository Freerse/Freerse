import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../config/ColorConstants.dart';
import 'bottom_conform_dialog_controller.dart';

class BottomConformDialogComponent extends StatelessWidget {
  final String title;
  final String action;
  final dynamic event;
  final controller = Get.put(BottomConformDialogController());
  BottomConformDialogComponent({super.key, required this.title, required this.action, required this.event}) {}

  @override
  Widget buildOneRow(String title, Color color, {onClick, fontSize, height}) {
    return GestureDetector(
      onTap: (){
        if(onClick != null){
          onClick();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: height,
        alignment: Alignment.center,
        child: Text(title, style: TextStyle(color: color,fontSize: fontSize),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        child: Container(
          color: Colors.white,
          height: ScreenUtil().setHeight(188),
          child: Column(
            children: [
              buildOneRow(title, ColorConstants.textBlack, height: ScreenUtil().setHeight(54.5), fontSize: ScreenUtil().setSp(13.3)),
              Divider(height: 1),
              buildOneRow(action, ColorConstants.textRed, height: ScreenUtil().setHeight(54.5), fontSize: ScreenUtil().setSp(17),onClick: event),

              Container(height: ScreenUtil().setHeight(7), color: ColorConstants.hexToColor("#f7f7f7"),),
              buildOneRow("QU_XIAO".tr, ColorConstants.textBlack, onClick: (){Get.back();}, height: ScreenUtil().setHeight(54.5), fontSize: ScreenUtil().setSp(17)),
            ],
          ),
        )
    );
  }
}
