import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:get/get.dart';

import 'bottom_write_dialog_controller.dart';

class BottomWriteDialogPage extends StatelessWidget {
  final controller = Get.put(BottomWriteDialogController());

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        child: Container(
            color: Colors.white,
            height: ScreenUtil().setHeight(300),
            child: Column(
              children: [
                Container(
                  height: ScreenUtil().setHeight(80),
                  child: Center(
                    child: Text("XUAN_ZWZL_XING".tr,style: TextStyle(color: ColorConstants.hexToColor("#000000"),fontSize: ScreenUtil().setSp(16.3)),),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    Get.back();
                    Get.toNamed("/write", arguments: {"isArticle":false});
                  },
                  child: Row(
                    children: [
                      Container(width: ScreenUtil().setWidth(33),),
                      Image.asset('assets/images/write_normal.png',width: ScreenUtil().setWidth(52),),
                      Container(
                        padding: EdgeInsets.only(left: ScreenUtil().setWidth(13)),
                        child: Text("ZHENG_C_F_BU".tr,style: TextStyle(color: ColorConstants.hexToColor("#111019"),fontSize: ScreenUtil().setSp(17)),),
                      )
                    ],
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(20),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    Get.back();
                    Get.toNamed("/write", arguments: {"isArticle":true});
                  },
                  child: Row(
                    children: [
                      Container(width: ScreenUtil().setWidth(33),),
                      Image.asset('assets/images/write_article.png',width: ScreenUtil().setWidth(52),),
                      Container(
                        padding: EdgeInsets.only(left: ScreenUtil().setWidth(13)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("BIAO_ZWCW_ZHANG".tr,style: TextStyle(color: ColorConstants.hexToColor("#111019"),fontSize: ScreenUtil().setSp(17)),),
                            Text("TIE_ZJTBDWZX_SHI".tr,style: TextStyle(color: ColorConstants.hexToColor("#AEADAD"),fontSize: ScreenUtil().setSp(15)),)
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
        )
    );
  }
}
