import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/page/set_nick_name/set_nickname_view.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';
import 'chat_setting_controller.dart';

class ChatSettingPage extends StatelessWidget {
  final controller = Get.put(ChatSettingController());
  late final NostrService nostrService = Get.find();

  Widget _buildItem(title,text, copyFlag){
    return Container(
      height: ScreenUtil().setHeight(58),
      color: Get.isDarkMode ? Color(0xFF191919) : Colors.white,
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          copyFlag != null ?
          Row(
            children: [
              // Text(text),
              GestureDetector(
                onTap: (){
                  Get.snackbar(
                    "TI_SHI".tr,
                    "FU_Z_C_GONG".tr,
                    duration: Duration(seconds: 3),
                  );
                  Clipboard.setData(ClipboardData(text: text));
                  copyFlag.value = true;
                },
                child: Container(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(11),right: ScreenUtil().setWidth(20)),
                  child: Obx(() => Image.asset(copyFlag.value ? "assets/images/copy_succ.png" : "assets/images/copy_btn.png",width: ScreenUtil().setWidth(18), height: ScreenUtil().setWidth(18)),),
                ),
                behavior: HitTestBehavior.translucent,
              )
            ],
          ) :  Padding(padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)), child: Text(text),)
        ],
      ),
    );
  }
  
  String formatKey(String pubkey){
    var pubkeyHr = pubkey.substring(0,10)+"...."+pubkey.substring(pubkey.length-10,pubkey.length);
    return pubkeyHr;
  }

  Widget _buildSwitchItem(title, openFlag, type){
    return Container(
      height: ScreenUtil().setHeight(58),
      // color: Colors.white,
      color: Get.isDarkMode ? Color(0xFF191919) : Colors.white,
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          GestureDetector(
              child: Container(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(11),right: ScreenUtil().setWidth(20)),
                child: Obx(() => Switch.adaptive(value: openFlag.value, onChanged: (value){
                  // print(value);
                  openFlag.value = value;
                  if(type == 1){
                    controller.switchTop();
                  }
                  if(type == 2){
                    controller.switchBlack();
                  }
                  // openFlag.notifyListeners();
                }),
                ),
              )
          )
        ],
      ),
    );
  }


  Widget _buildTextItem(title, onClick){
    return Container(
      height: ScreenUtil().setHeight(58),
      color: Get.isDarkMode ? Color(0xFF191919) : Colors.white,
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20)),
      child: GestureDetector(
        onTap: onClick,
        child:
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
             [
                Text(title),
                Image.asset('assets/images/arrow_right.png',width: ScreenUtil().setWidth(23),),
              ],
          ),
        behavior: HitTestBehavior.translucent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false,child:
    Scaffold(
        // backgroundColor: ColorConstants.statuabarColor,
        backgroundColor: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
        appBar: AppBar(
          backgroundColor: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
            Get.back();
          },
          ),
          title: Text("ZI_L_S_ZHI".tr,style: Theme.of(context).textTheme.titleLarge,),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildTextItem("SHE_Z_B_ZHU".tr, (){  Get.to(()=>SetNickNamePage(),arguments: controller.userId, preventDuplicates:false); },),
            ViewUtils.oneLine(),
            _buildItem("FU_ZYHGY_NONE".tr, Helpers().encodeBech32(controller.userId, 'npub'), controller.copy1),
            Container(height: ScreenUtil().setHeight(5)),
            // _buildTextItem("BA_TTJGP_YOU".tr, (){  },),
            // Container(height: ScreenUtil().setHeight(10)),
            _buildSwitchItem("ZHI_D_L_TIAN".tr, controller.topChatFlag, 1),
            Container(height: ScreenUtil().setHeight(5)),
            _buildSwitchItem("JIA_RHM_DAN".tr, controller.blackChatFlag, 2),
            // ViewUtils.oneLine(),
            Container(height: ScreenUtil().setHeight(5)),


          ],
        )
    ));
  }
}
