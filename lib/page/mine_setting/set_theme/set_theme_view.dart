import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/home/home_controller.dart';
import 'package:freerse/page/mine_setting/set_theme/set_theme_controller.dart';
import 'package:freerse/services/SpUtils.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/common/delete_bottom_conform_dialog/delete_bottom_conform_dialog_view.dart';
import 'package:get/get.dart';

import '../../../config/ColorConstants.dart';
import '../../../services/nostr/nostr_service.dart';
import '../mine_setting_controller.dart';
import '../mine_setting_view.dart';

class SetThemePage extends StatelessWidget {
  final controller = Get.put(SetThemeController());
  late final NostrService nostrService = Get.find();

  Widget _buildSelectItem(title, isDarkMode){
    return Container(
      color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
      height: ScreenUtil().setHeight(56),
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20), right: ScreenUtil().setWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ViewUtils.menuText(title),
            ],
          ),
          isDarkMode ? Image.asset('assets/images/select_yes.png',width: ScreenUtil().setWidth(23),) : Container(),
        ],
      ),
    );
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
          title: Text("SET_THEME".tr,style: Theme.of(context).textTheme.titleMedium,),
          centerTitle: true,
        ),
        body: Column(
          children: [
            GestureDetector(
              child: _buildSelectItem("THEME_AUTO".tr, SpUtil.getInt("APP_THEME") == 0),
              onTap: (){
                controller.setTheme(0);
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),
            GestureDetector(
              child: _buildSelectItem("THEME_LIGHT".tr, SpUtil.getInt("APP_THEME") == 1),
              onTap: (){
                controller.setTheme(1);
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),
            GestureDetector(
              child: _buildSelectItem("THEME_DARK".tr, SpUtil.getInt("APP_THEME") == 2),
              onTap: (){
                controller.setTheme(2);
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),
          ],
        )
    ));
  }
}
