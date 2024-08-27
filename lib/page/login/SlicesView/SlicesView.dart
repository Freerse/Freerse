import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:get/get.dart';

import 'SlicesViewController.dart';

class SlicesView extends StatelessWidget {
  final controller = Get.put(SlicesViewController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false,
      child: Scaffold(
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
            child: Container(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(26), right: ScreenUtil().setWidth(17), bottom: ScreenUtil().setHeight(60)),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(20), bottom: ScreenUtil().setHeight(43)),
                  child: Text("ZUI_ZYHXKX_YI".tr,style: TextStyle(fontWeight:FontWeight.bold, color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(30)),),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ZUI_ZYHXKX_YI".tr,style: TextStyle(fontWeight:FontWeight.bold, color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(17)),),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(21),bottom: ScreenUtil().setHeight(24),),
                      child: Text("COPY_DESC_12".tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    ),
                    Text("JIN_ZNRHX_WEI".tr,style: TextStyle(fontWeight:FontWeight.bold, color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(17)),),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(21),),
                      child: Text('NIN_TYBJYYJZDNRHXWBKDBX_YU'.tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10),),
                      child: Text('KONG_HWXMCSRHQLTRSHWCN_REN'.tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10),),
                      child: Text('COPY_DESC_10'.tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10),),
                      child: Text('DAI_YQSXSDBLXYCHY_LUN'.tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10),),
                      child: Text('YIN_HSQMFFBZSBLHHFFNRHX_DU'.tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10),),
                      child: Text('CU_ZDN_RONG'.tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10),),
                      child: Text('YU_DBYGDFFN_RONG'.tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(23),bottom: ScreenUtil().setHeight(24),),
                      child: Text("WEI_G_H_GUO".tr,style: TextStyle(fontWeight:FontWeight.bold, color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(17)),),
                    ),
                    Text("COPY_DESC".tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(23),bottom: ScreenUtil().setHeight(24),),
                      child: Text("ZE_REN".tr,style: TextStyle(fontWeight:FontWeight.bold, color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(17)),),
                    ),
                    Text("COPY_DESC_11".tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),

                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(23),bottom: ScreenUtil().setHeight(24),),
                      child: Text("BIAN_G_NONE".tr,style: TextStyle(fontWeight:FontWeight.bold, color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(17)),),
                    ),
                    Text("BAO_LIU_QUANLI".tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(23),bottom: ScreenUtil().setHeight(24),),
                      child: Text("LIAN_X_F_SHI".tr,style: TextStyle(fontWeight:FontWeight.bold, color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(17)),),
                    ),
                    Text("RU_GNDCYRHYWQTGYWML_XI".tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(23),bottom: ScreenUtil().setHeight(24),),
                      child: Text("JIE_S_T_KUAN".tr,style: TextStyle(fontWeight:FontWeight.bold, color: Get.isDarkMode ?  Color(0xFFd1d1d1) : Color(0xFF181818),fontSize: ScreenUtil().setSp(17)),),
                    ),
                    Text("LISENCE_ACCEPT_DESC1".tr,style: TextStyle(color: Get.isDarkMode ?  Color(0xFF5e5e5e) : Color(0xFFb3b3b3),fontSize: ScreenUtil().setSp(15)),),
                  ],
                ),
              ],
            )
          )
        )
    ));
  }

}
