import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';

import '../../../config/ColorConstants.dart';
import '../../../services/SpUtils.dart';
import '../../../services/nostr/nostr_service.dart';
import 'set_locale_controller.dart';

class SetLocalePage extends StatelessWidget {
  final controller = Get.put(SetLocaleController());
  late final NostrService nostrService = Get.find();

  Widget _buildSelectItem(title, locale, lang){
    String? localSave = SpUtil.getString("APP_LOCALE", defValue: ui.window.locale.toString());
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
          localSave == locale + '_' + lang ? Image.asset('assets/images/select_yes.png',width: ScreenUtil().setWidth(23),) : Container(),
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
          title: Text("SET_LOCAL".tr,style: Theme.of(context).textTheme.titleMedium,),
          centerTitle: true,
        ),
        body: Column(
          children: [
            GestureDetector(
              child: _buildSelectItem("EN_US".tr, 'en', 'US'),
              onTap: (){
                controller.setLocale('en', 'US');
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),
            GestureDetector(
              child: _buildSelectItem("ZH_CN".tr, 'zh', 'CN'),
              onTap: (){
                controller.setLocale('zh', 'CN');
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),
            GestureDetector(
              child: _buildSelectItem("ZH_TW".tr, 'zh', 'TW'),
              onTap: (){
                controller.setLocale('zh', 'TW');
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),
            GestureDetector(
              child: _buildSelectItem("JA_JP".tr, 'ja', 'JP'),
              onTap: (){
                controller.setLocale('ja', 'JP');
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),
            GestureDetector(
              child: _buildSelectItem("TH_TH".tr, 'th', 'TH'),
              onTap: (){
                controller.setLocale('th', 'TH');
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),

            GestureDetector(
              child: _buildSelectItem("FR_CH".tr, 'fr', 'CH'),
              onTap: (){
                controller.setLocale('fr', 'CH');
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),

            GestureDetector(
              child: _buildSelectItem("PT_BR".tr, 'pt', 'BR'),
              onTap: (){
                controller.setLocale('pt', 'BR');
              },
              behavior: HitTestBehavior.translucent,
            ),
            Divider(height: 1,),
          ],
        )
    ));
  }
}
