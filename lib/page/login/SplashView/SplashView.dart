import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/page/login/LoginView/LoginView.dart';
import 'package:freerse/page/login/RegView/RegView.dart';
import 'package:get/get.dart';

import 'SplashViewController.dart';

class SplashView extends StatelessWidget {
  final controller = Get.put(SplashViewController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false,
        child: Scaffold(
            backgroundColor: Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
            body:
            Column(
              children: [

                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(145), bottom: ScreenUtil().setHeight(13)),
                  child: Image.asset("assets/images/log_freerse.png",width: ScreenUtil().setWidth(80), height: ScreenUtil().setWidth(80)),
                ),

                Text('Freerse',style: TextStyle(color: ColorConstants.textGreen,fontSize: ScreenUtil().setSp(30)),),

                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(96), bottom: ScreenUtil().setHeight(40)),
                  child: Text("YI_QJRZYY_ZHOU".tr,style: TextStyle(fontWeight:FontWeight.w900,
                      color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),
                      fontSize: ScreenUtil().setSp(22)),),
                ),
                Text("SHU_YNZJDSJW_LUO".tr,style: TextStyle(fontWeight:FontWeight.w900, color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(26)),),

                Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setHeight(200), left: ScreenUtil().setWidth(34), right: ScreenUtil().setWidth(34)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(()=>LoginView(),preventDuplicates:false);
                          },
                          child: Container(
                            width: ScreenUtil().setWidth(136),
                            height: ScreenUtil().setHeight(52),
                            decoration: BoxDecoration(
                              color: ColorConstants.greenColor,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Text(
                                "DENG_LU".tr,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Cons.tsBig
                                ),
                              ),
                            ),
                          ),
                          behavior: HitTestBehavior.translucent,
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(()=>RegView(),preventDuplicates:false);
                          },
                          child: Container(
                            width: ScreenUtil().setWidth(136),
                            height: ScreenUtil().setHeight(52),
                            decoration: BoxDecoration(
                              // color: ColorConstants.greenColor,
                              borderRadius: BorderRadius.circular(10.0),
                              border: new Border.all(width: 1, color: ColorConstants.greenColor,),
                            ),
                            child: Center(
                              child: Text(
                                "CHUANG_J_Z_HU".tr,
                                style: TextStyle(
                                    color: ColorConstants.greenColor,
                                    fontSize: Cons.tsBig
                                ),
                              ),
                            ),
                          ),
                          behavior: HitTestBehavior.translucent,
                        )
                      ],
                    )
                ),
              ],
            )
        ));
  }

}
