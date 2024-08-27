import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AvatarHolder extends StatelessWidget {
  num? width;
  num? height;
  String defalt;
  AvatarHolder({this.width=50,this.height=50, this.defalt = 'assets/images/default_avatar.png'});


  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(width!),
      height: ScreenUtil().setWidth(height!),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Get.isDarkMode ?  Color(0xFF202020) : Color(0xFFdddddd),
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.asset(
        defalt,
        fit: BoxFit.cover,
        width: ScreenUtil().setWidth(width!),
        height: ScreenUtil().setWidth(height!),
        // color: Get.isDarkMode ?  Color(0xFF202020) : Color(0xFFdddddd),
      ),
    );
  }

}
