import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/common/auto_hide_keyboard.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';
import '../../views/feed/avatar_holder.dart';
import 'mine_profile_controller.dart';

class MineProfilePage extends StatelessWidget {
  final controller = Get.put(MineProfileController());
  late final NostrService nostrService = Get.find();

  Widget _buildItem(title, hintTxt, TextEditingController textEditingController, FocusNode focusNode){
    return Container(
      color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
      height: ScreenUtil().setHeight(56),
      // color: Colors.white,
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20)),
      child: Row(
        children: [
          Container(
            // width: ScreenUtil().setWidth(110),
            child: Text(title),
          ),
          Expanded(child:

          AutoHideKeyBoard(
            child: TextField(
              minLines: 1,
              maxLines: null,
              controller:textEditingController,
              focusNode: focusNode,
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              decoration: InputDecoration(
                hintText: hintTxt,
                hintStyle: TextStyle(color: ColorConstants.hexToColor('#B3B3B3')),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
              ),
            ),
          ),

          // TextField(
          //   controller:textEditingController ,
          //   enableInteractiveSelection: false,
          //   // focusNode: controller.focusNode,
          //   style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
          //   decoration: InputDecoration(
          //     hintText: hintTxt,
          //     hintStyle: TextStyle(color: ColorConstants.hexToColor('#B3B3B3')),
          //     border: InputBorder.none,
          //     contentPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
          //   ),
          // )
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode ? ColorConstants.setPageBg : ColorConstants.statuabarColor ,
        appBar: AppBar(
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
            Get.back();
          },
          ),
          title: Text("GE_R_Z_LIAO".tr,style: Theme.of(context).textTheme.titleLarge,),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: (){
                controller.onSave();
                Get.back();
              },
              child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    child:Text("BAO_CUN".tr, style: TextStyle(
                        color: Get.isDarkMode ? Color(0xFFd1d1d1) : Color(0xFF181818),
                    ),),
                  )
              ),
              behavior: HitTestBehavior.translucent,
            )
          ],
        ),
        body:
        SingleChildScrollView(
            child:
            Column(
              children: [
                GestureDetector(
                  onTap: (){
                    controller.sendImg();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    height: ScreenUtil().setHeight(81),
                    color: Get.isDarkMode ? ColorConstants.dialogBg : Colors.white,
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("TOU_XIANG".tr),
                        Obx((){
                          return

                            Stack(
                              alignment: AlignmentDirectional.center,
                              // textDirection: TextDirection.ltr,
                              // fit: StackFit.loose,
                              // overflow: Overflow.clip,
                              children: <Widget>[
                                CachedNetworkImage(
                                  fadeInDuration: Duration(milliseconds: 0),
                                  fadeInCurve: Curves.linear,
                                  imageUrl: controller.picture.value,
                                  placeholder: (context, url) => AvatarHolder(width: 62,height: 62,),
                                  errorWidget: (context, url, error) => AvatarHolder(width: 62,height: 62,),
                                  imageBuilder: (context, imageProvider) => Container(
                                    width:  ScreenUtil().setWidth(62),
                                    height:  ScreenUtil().setWidth(62),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Image.asset('assets/images/up_image.png',width: ScreenUtil().setWidth(27),),
                                )
                              ],
                            );
                        })
                      ],
                    ),
                  ),
                ),
                ViewUtils.oneLine(isWthite: true),
                _buildItem("MING_ZI".tr, "TIAN_JNDM_ZI".tr, controller.nameController, controller.focusNode1),
                ViewUtils.oneLine(isWthite: true),
                _buildItem("YONG_H_MING".tr,"TIAN_JNDYH_MING".tr,controller. displayNameController, controller.focusNode2),
                ViewUtils.oneLine(isWthite: true),
                _buildItem("WANG_ZHAN".tr,"TIAN_JNDW_ZHAN".tr,controller.websiteController, controller.focusNode3),
                ViewUtils.oneLine(isWthite: true),
                _buildItem("SHAN_DQBD_ZHI".tr,"TIAN_JNDSDQBD_ZHI".tr,controller.lud16Controller, controller.focusNode4),
                ViewUtils.oneLine(isWthite: true),
                _buildItem('NIP_AUTH'.tr,"TIAN_JNDRZW_ZHI".tr,controller.nip05Controller, controller.focusNode5),

                Container(
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                    color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
                    child: Column(
                      children: [
                        Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(20), bottom: ScreenUtil().setHeight(10)),
                            child:  Row(children: [Padding(padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),), child:Text("GUAN_Y_WO".tr))],)
                        ),
                        AutoHideKeyBoard(
                          child: TextField(
                            minLines: 6,
                            maxLines: null,
                            controller: controller.aboutController,
                            focusNode: controller.focusNode,
                            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: "ZAI_NDGRZLZTJJ_JIE".tr,
                              hintStyle: TextStyle(color: ColorConstants.hexToColor('#B3B3B3')),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                            ),
                          ),
                        ),
                      ],
                    )
                ),

                Container(
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                    color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: ScreenUtil().setHeight(20), ),
                            child:  Row(children: [Padding(padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),), child:Text("ZHU_YBJ_TU".tr))],)
                        ),
                        Obx(()=>GestureDetector(
                            onTap: (){
                              controller.sendImgTitle();
                            },
                            behavior: HitTestBehavior.translucent,
                            child:
                            Padding(
                                padding: EdgeInsets.only(left: ScreenUtil().setWidth(20), right: ScreenUtil().setWidth(20), bottom: ScreenUtil().setHeight(30)),
                                child: controller.banner.value == ''?Container(
                                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                                    height: ScreenUtil().setHeight(180),
                                    decoration: BoxDecoration(
                                      color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
                                      // borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: Get.isDarkMode ? Color(0xFF242424) : Color(0xFFe5e5e5),
                                        width: 1.0,
                                      ),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Image.asset("assets/images/write_add.png",width: ScreenUtil().setWidth(66),),
                                            Container(height: 20,),
                                            Text("TIAN_JZYB_JING".tr,style: TextStyle(color:  Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191),fontSize: Cons.tsSmall),),
                                            Container(height: 4,),
                                            Text("CHI_C_NONE".tr,style: TextStyle(color:  Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191),fontSize: Cons.tsSmall),),
                                          ],
                                        )
                                    )
                                ):Container(
                                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                                    height: ScreenUtil().setHeight(180),
                                    decoration: BoxDecoration(
                                      color: Get.isDarkMode ? ColorConstants.bottomColorBlack : Colors.white,
                                      // borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: Get.isDarkMode ? Color(0xFF242424) : Color(0xFFe5e5e5),
                                        width: 1.0,
                                      ),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child:Center(
                                      child: CachedNetworkImage(
                                        height: ScreenUtil().setHeight(180),
                                        imageUrl: controller.banner.value,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                )
                            )
                        ),)
                      ],
                    )
                ),


              ],
            )
        )
    );
  }
}
