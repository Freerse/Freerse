import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';
import 'set_nickname_controller.dart';

class SetNickNamePage extends StatelessWidget {
  final controller = Get.put(SetNickNameController());

  Widget _buildItem(hintTxt, TextEditingController textEditingController){
    return Container(
      height: ScreenUtil().setHeight(56),
      // color: Colors.white,
      color: Get.isDarkMode ? Color(0xFF191919) : Colors.white,
      child: Row(
        children: [
          Expanded(child: TextField(
            controller:textEditingController ,
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16,),
            decoration: InputDecoration(
              hintText: hintTxt,
              hintStyle: TextStyle(color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
            ),
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false,child:
    Scaffold(
        backgroundColor: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
        appBar: AppBar(
          backgroundColor: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
            Get.back();
          },
          ),
          title: Text("SHE_Z_B_ZHU".tr,style: Theme.of(context).textTheme.titleLarge,),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: (){
                controller.onSave();
                Get.back();
              },
              behavior: HitTestBehavior.translucent,
              child: Center(
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  child:Text("BAO_CUN".tr,style: TextStyle(color:  Get.isDarkMode ? Colors.white : Colors.black,),),
                )
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child:
            Column(
              children: [
                ViewUtils.oneLine(),
                _buildItem("QING_SRHYB_ZHU".tr,controller.nameController),
                ViewUtils.oneLine(),
              ],
            )
        )
    ));
  }
}
