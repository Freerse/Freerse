import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/config/Cons.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/common/bottom_conform_dialog/bottom_conform_dialog_view.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';
import 'RepeaterListController.dart';

class RepeaterList extends StatelessWidget {
  final controller = Get.put(RepeaterListController());
  late final NostrService nostrService = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false,
        child: Scaffold(
            backgroundColor: Get.isDarkMode ? Color(0xFF111111) : ColorConstants.statuabarColor,
            appBar: AppBar(
              leading: IconButton(
                iconSize: 30,
                icon: Icon(Icons.chevron_left), onPressed: () {
                Get.back();
              },
              ),
              title: Text("ZHONG_J_QI".tr,style: Theme.of(context).textTheme.titleLarge,),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Cons.MARGIN_XY),
                child:
                Column(
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: Cons.MARGIN_XY),
                        // height: ScreenUtil().setHeight(245),
                        decoration: BoxDecoration(
                            color: Get.isDarkMode ? Color(0xFF191919) : Colors.white,
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(15)),
                          // border: Border.all(
                          //   color: ColorConstants.inputLineColor,
                          //   width: 1.0,
                          // ),
                          shape: BoxShape.rectangle,
                        ),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                children: [
                                  Container(
                                    height: ScreenUtil().setHeight(61),
                                    alignment: Alignment.center,
                                    child: Text("TIAN_JXDZJ_QI".tr,),
                                  ),
                                ]),
                            Divider(height: 1),
                            Row(
                              children: [
                                Container(
                                  height: ScreenUtil().setHeight(61),
                                  alignment: Alignment.center,
                                  child: Text("DI_ZHI".tr,),
                                ),
                                Expanded(child: TextField(
                                  controller: controller.nameController,
                                  style: const TextStyle(fontWeight: FontWeight.normal),
                                  decoration: InputDecoration(
                                    hintText: "SHU_RZJQDD_ZHI".tr,
                                    hintStyle: TextStyle(color: ColorConstants.hintColor),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                                  ),
                                ))
                              ],),
                            Divider(height: 1),
                            Center(
                                child:
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(23)),
                                    child:
                                    GestureDetector(
                                      onTap: () {
                                        controller.addReater();
                                      },
                                      behavior: HitTestBehavior.translucent,
                                      child: Container(
                                        width: ScreenUtil().setWidth(103),
                                        height: ScreenUtil().setHeight(34),
                                        decoration: BoxDecoration(
                                          color: ColorConstants.greenColor,
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "TIAN_JIA".tr,
                                            style: TextStyle(
                                                // color: Colors.white,
                                                fontSize: Cons.tsSmall
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                )
                            )
                          ],
                        )
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(6), bottom: ScreenUtil().setHeight(46)),
                      child: Text("ZHONG_XU_QI_DESC".tr,style: TextStyle(color: ColorConstants.hintColor,fontSize: Cons.tsCenter),),
                    ),


                    Row(children: [
                      Padding(
                        padding: EdgeInsets.only(left: ScreenUtil().setWidth(18), bottom: ScreenUtil().setHeight(11)),
                        child: Text("YI_TJZJ_QI".tr,),
                      ),
                    ],),



                    Container(
                        padding: EdgeInsets.only(left: ScreenUtil().setWidth(23.3), right: ScreenUtil().setWidth(24.7)),
                        // height: ScreenUtil().setHeight(245),
                        decoration: BoxDecoration(
                          color: Get.isDarkMode ? Color(0xFF191919) : Colors.white,
                          // color: ColorConstants.hexToColor('#f7f7f7'),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(15)),
                          // border: Border.all(
                          //   color: ColorConstants.inputLineColor,
                          //   width: 1.0,
                          // ),
                          shape: BoxShape.rectangle,
                        ),
                        child:Obx((){

                          var contents = <Widget>[];
                          controller.nostrService.relays.relays.forEach((key, value) {
                            contents.add(_buildItem(key));
                            contents.add(ViewUtils.oneLine(marginLeft: 47));
                          });

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: contents,
                          );
                        })
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(6), bottom: ScreenUtil().setHeight(46)),
                      child: Text("ZXQ_DI_QI".tr,style: TextStyle(color: ColorConstants.hintColor,fontSize: Cons.tsCenter),),
                    ),

                  ],
                )
            )
        ));
  }


  Widget _buildItem(String url){
    return Container(
      height: ScreenUtil().setHeight(44),
      alignment: Alignment.center,
      child: Row(
        children: [
          Badge(
            smallSize: ScreenUtil().setWidth(9),
            backgroundColor: ColorConstants.hexToColor(controller.nostrService.relays.getRelayState(url) == 0 ? '#E6442C' : '#4ACF4D'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
            child: Image.asset("assets/images/repeater_normal.png",width: ScreenUtil().setWidth(18), height: ScreenUtil().setWidth(18)),
          ),
          Expanded(
            child: Text(url,style: TextStyle(fontSize: Cons.tsBig),),
          ),
          GestureDetector(
            onTap: (){
              Get.bottomSheet(BottomConformDialogComponent(title: 'NI_YSCZGZJQ_MA'.tr, action: "C_DELETE".tr, event: (){
                Get.back();
                controller.nostrService.relays.removeRelay(url);
              },));
            },
            behavior: HitTestBehavior.translucent,
            child: Image.asset("assets/images/repeater_delete.png",width: ScreenUtil().setWidth(19), height: ScreenUtil().setWidth(18)),
          )
        ],
      ),
    );
  }
}
