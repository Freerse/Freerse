
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';

class ZapNumberShowComponent extends StatelessWidget {

  String? text;

  int? num;

  ZapNumberShowComponent({
    this.text,
    this.num,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null && num != null) {
      text = num.toString();
    } else if (text != null && num == null) {
      try {
        num = int.parse(text!);
      } catch (e) {}
    } else {
      return Container();
    }

    num ??= 0;
    if (num! >= 1000000) {
      text = (num!.toDouble() / 1000000).toStringAsFixed(2) + " M";
    } else if (num! >= 1000) {
      text = (num!.toDouble() / 1000).toStringAsFixed(2) + " K";
    }

    text = text!.replaceAll(".00", "");

    var zapWidget = Container(
      margin: EdgeInsets.only(left: 4, right: 4),
      child: Image.asset("assets/images/zapsetting_zap_orange.png",
        width: ScreenUtil().setWidth(11.67),
        height: ScreenUtil().setWidth(21),
      ),
    );

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF4c4444) : ColorConstants.hexToColor("#FDF5F0"),
        // color: ColorConstants.hexToColor("#FDF5F0"),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.33)),
      ),
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(29), bottom: ScreenUtil().setWidth(29)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          zapWidget,
          Text(text!, style: TextStyle(
            color: ColorConstants.hexToColor("#EF8E53"),
            fontSize: 23.33,
          ),),
        ],
      ),
    );
  }

}